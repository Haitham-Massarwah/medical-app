import db from '../config/database';
import { NotFoundError } from '../middleware/errorHandler';
import { logger } from '../config/logger';
import { NOSHOW_FEATURE_KEYS, NOSHOW_FEATURE_LABELS } from './noShowFeatureConfig';
import { noShowThresholdService } from './noShowThreshold.service';
import { predictNoShowViaAiService } from './noShowAiGateway.service';

export type NoShowPredictionScope = {
  role: string;
  tenantId: string;
  scopedDoctorId: string | null;
  /** Required for optional Python service auth context */
  actorUserId?: string | null;
};

const MODEL_TYPE = 'no_show_prediction';

export class NoShowPredictionService {
  private sigmoid(z: number): number {
    const clamped = Math.max(-25, Math.min(25, z));
    return 1 / (1 + Math.exp(-clamped));
  }

  private async getActiveModel(tenantId: string): Promise<any | null> {
    return db('ml_model_versions')
      .where({ tenant_id: tenantId, model_type: MODEL_TYPE, is_active: true })
      .first();
  }

  private async featureVectorForAppointment(tenantId: string, appointment: any): Promise<number[]> {
    const patientId = String(appointment.patient_id || '');
    const apptDate = new Date(appointment.appointment_date);
    const createdAt = appointment.created_at ? new Date(appointment.created_at) : apptDate;
    const histRows = await db('appointments')
      .where({ tenant_id: tenantId, patient_id: patientId })
      .whereIn('status', ['completed', 'no_show'])
      .andWhere('appointment_date', '<', appointment.appointment_date)
      .select('status', 'appointment_date');
    const total = histRows.length;
    const noShows = histRows.filter((r: any) => r.status === 'no_show').length;
    const completed = histRows.filter((r: any) => r.status === 'completed').length;
    const last = histRows.length > 0 ? new Date(histRows[histRows.length - 1].appointment_date) : null;
    const leadHours = Math.max(0, (apptDate.getTime() - createdAt.getTime()) / 3600000);
    const noShowRate = total > 0 ? noShows / total : 0;
    const daysSinceLast = last ? Math.max(0, (apptDate.getTime() - last.getTime()) / (24 * 3600000)) : -1;
    return [
      Math.min(leadHours, 24 * 30) / (24 * 30),
      apptDate.getHours() / 23,
      apptDate.getDay() / 6,
      (apptDate.getMonth() + 1) / 12,
      Math.min(Number(appointment.duration_minutes || 30), 240) / 240,
      Math.min(total, 100) / 100,
      Math.min(completed, 100) / 100,
      Math.min(noShows, 100) / 100,
      noShowRate,
      noShowRate,
      daysSinceLast < 0 ? 0 : Math.min(daysSinceLast, 365) / 365,
    ];
  }

  private mapRiskLevel(score: number, thresholdMedium: number, thresholdHigh: number): 'low' | 'medium' | 'high' {
    if (score >= thresholdHigh) return 'high';
    if (score >= thresholdMedium) return 'medium';
    return 'low';
  }

  /** Signed contribution to logit: w_i * x_i (linear part of logistic model). */
  private explainSignedContributions(
    features: number[],
    weights: number[],
    topN = 5,
  ): Array<Record<string, unknown>> {
    const keys = NOSHOW_FEATURE_KEYS as readonly string[];
    const items = features.map((value, i) => {
      const w = Number(weights[i] || 0);
      const featureKey = keys[i] || `feature_${i}`;
      const label =
        (NOSHOW_FEATURE_LABELS as Record<string, string>)[featureKey] ?? featureKey;
      const scoreContribution = w * value;
      return {
        feature_key: featureKey,
        label,
        value: Number(Number(value).toFixed(6)),
        weight: Number(w.toFixed(8)),
        score_contribution: Number(scoreContribution.toFixed(6)),
      };
    });
    items.sort((a, b) => Math.abs(Number(b.score_contribution)) - Math.abs(Number(a.score_contribution)));
    return items.slice(0, topN);
  }

  private async doctorUserIdForAppointmentDoctor(doctorId: string | null): Promise<string | null> {
    if (!doctorId) return null;
    const d = await db('doctors').where({ id: doctorId }).first('user_id');
    return d?.user_id != null ? String(d.user_id) : null;
  }

  private normalizeExternalPrediction(raw: Record<string, unknown>): {
    score: number;
    factors: unknown;
    modelVersionId: string;
  } {
    const score = Number(raw.score ?? raw.risk_score ?? 0);
    const modelVersionId = String(raw.model_version_id || '').trim();
    let factors: unknown = raw.top_factors;
    if (!Array.isArray(factors)) factors = [];
    return { score, factors, modelVersionId };
  }

  private async persistPredictionRow(
    scope: NoShowPredictionScope,
    appointment: Record<string, unknown>,
    modelVersionId: string,
    riskScore: number,
    riskLevel: string,
    factors: unknown,
  ): Promise<void> {
    await db.transaction(async (trx) => {
      await trx('appointment_no_show_predictions')
        .where({ tenant_id: scope.tenantId, appointment_id: appointment.id, is_current: true })
        .update({ is_current: false });
      await trx('appointment_no_show_predictions').insert({
        tenant_id: scope.tenantId,
        appointment_id: appointment.id,
        patient_id: appointment.patient_id,
        doctor_id: appointment.doctor_id,
        model_version_id: modelVersionId,
        risk_score: riskScore,
        risk_level: riskLevel,
        factors_json: factors,
        predicted_at: new Date(),
        is_current: true,
      });
    });
  }

  async predictAppointmentNoShow(
    scope: NoShowPredictionScope,
    appointmentId: string,
  ): Promise<Record<string, unknown>> {
    let q = db('appointments as a')
      .join('patients as p', 'a.patient_id', 'p.id')
      .join('users as u', 'p.user_id', 'u.id')
      .where({ 'a.tenant_id': scope.tenantId, 'a.id': appointmentId })
      .select('a.*', 'u.first_name', 'u.last_name');
    if (scope.scopedDoctorId) {
      q = q.andWhere('a.doctor_id', scope.scopedDoctorId);
    }
    const appointment = await q.first();
    if (!appointment) throw new NotFoundError('Appointment');

    const model = await this.getActiveModel(scope.tenantId);
    if (!model) {
      return {
        model_available: false,
        message: 'No active no-show model for tenant',
      };
    }

    const weights = Array.isArray(model.weights_json?.weights) ? model.weights_json.weights : [];
    const bias = Number(model.bias_value || 0);
    const doctorUserId = await this.doctorUserIdForAppointmentDoctor(
      appointment.doctor_id != null ? String(appointment.doctor_id) : null,
    );
    const thrCtx = await noShowThresholdService.buildResolutionContext(scope.tenantId, [doctorUserId]);
    const thr = noShowThresholdService.resolveOne(doctorUserId, thrCtx, model.hyperparameters_json);
    const thresholdMedium = thr.medium_threshold;
    const thresholdHigh = thr.high_threshold;

    const features = await this.featureVectorForAppointment(scope.tenantId, appointment);
    const featureKeys = NOSHOW_FEATURE_KEYS as readonly string[];
    const featuresMap: Record<string, number> = {};
    for (let i = 0; i < Math.min(featureKeys.length, features.length); i += 1) {
      featuresMap[String(featureKeys[i])] = Number(features[i] || 0);
    }

    const aiBase = (process.env.AI_SERVICE_BASE_URL || '').trim();
    const usePython = aiBase.length > 0 && !!scope.actorUserId;
    if (usePython) {
      try {
        const remote = await predictNoShowViaAiService({
          tenantId: scope.tenantId,
          appointmentId: String(appointment.id),
          actorRole: scope.role,
          actorUserId: String(scope.actorUserId),
          doctorUserId,
          features,
          featuresMap,
        });
        if (remote && typeof remote === 'object') {
          const norm = this.normalizeExternalPrediction(remote as Record<string, unknown>);
          let mvId = norm.modelVersionId;
          const mvRow = await db('ml_model_versions')
            .where({ id: mvId, tenant_id: scope.tenantId, model_type: MODEL_TYPE })
            .first();
          if (!mvRow) mvId = String(model.id);
          const pyScore = Math.max(0, Math.min(1, norm.score));
          const pyRisk = this.mapRiskLevel(pyScore, thresholdMedium, thresholdHigh);
          await this.persistPredictionRow(scope, appointment, mvId, pyScore, pyRisk, norm.factors);
          return {
            appointment_id: appointment.id,
            appointment_date: appointment.appointment_date,
            patient_name: `${appointment.first_name || ''} ${appointment.last_name || ''}`.trim(),
            doctor_id: appointment.doctor_id,
            risk_score: Number(pyScore.toFixed(6)),
            risk_level: pyRisk,
            top_factors: norm.factors,
            threshold_source: thr.source,
            model_version_id: mvId,
            prediction_engine: 'python_service',
            predicted_at: new Date().toISOString(),
          };
        }
      } catch (e: unknown) {
        const msg = e instanceof Error ? e.message : String(e);
        logger.warn('Python AI service unavailable or failed; using Node model', {
          tenantId: scope.tenantId,
          appointmentId: appointment.id,
          error: msg,
        });
      }
    }

    let z = bias;
    for (let i = 0; i < Math.min(weights.length, features.length); i += 1) z += Number(weights[i] || 0) * features[i];
    const riskScore = this.sigmoid(z);
    const riskLevel = this.mapRiskLevel(riskScore, thresholdMedium, thresholdHigh);
    const factors = this.explainSignedContributions(features, weights);
    await this.persistPredictionRow(scope, appointment, String(model.id), riskScore, riskLevel, factors);

    return {
      appointment_id: appointment.id,
      appointment_date: appointment.appointment_date,
      patient_name: `${appointment.first_name || ''} ${appointment.last_name || ''}`.trim(),
      doctor_id: appointment.doctor_id,
      risk_score: Number(riskScore.toFixed(6)),
      risk_level: riskLevel,
      top_factors: factors,
      threshold_source: thr.source,
      model_version_id: model.id,
      prediction_engine: 'node_logistic',
      predicted_at: new Date().toISOString(),
    };
  }

  async predictBatchUpcomingAppointments(
    scope: NoShowPredictionScope,
    filters: {
      dateFrom?: string;
      dateTo?: string;
      doctorId?: string;
      riskLevel?: string;
      page?: number;
      limit?: number;
    },
  ): Promise<Record<string, unknown>> {
    const page = Math.max(1, Number(filters.page || 1));
    const limit = Math.min(200, Math.max(1, Number(filters.limit || 25)));
    const offset = (page - 1) * limit;

    let q = db('appointments as a')
      .join('patients as p', 'a.patient_id', 'p.id')
      .join('users as u', 'p.user_id', 'u.id')
      .where('a.tenant_id', scope.tenantId)
      .whereIn('a.status', ['scheduled', 'confirmed'])
      .andWhere('a.appointment_date', '>=', new Date().toISOString())
      .select('a.*', 'u.first_name', 'u.last_name')
      .orderBy('a.appointment_date', 'asc');

    if (filters.dateFrom) q = q.andWhere('a.appointment_date', '>=', filters.dateFrom);
    if (filters.dateTo) q = q.andWhere('a.appointment_date', '<=', filters.dateTo);

    const effectiveDoctorId =
      scope.scopedDoctorId || (scope.role === 'admin' || scope.role === 'developer' ? filters.doctorId || null : null);
    if (effectiveDoctorId) q = q.andWhere('a.doctor_id', effectiveDoctorId);

    const itemsRaw = await q.clone().limit(limit).offset(offset);
    const totalRow = await q.clone().clearSelect().count('* as c').first();
    const total = Number((totalRow as any)?.c || 0);

    const model = await this.getActiveModel(scope.tenantId);
    if (!model) {
      return {
        scope: {
          tenant_id: scope.tenantId,
          role: scope.role,
          scoped_doctor_id: scope.scopedDoctorId,
        },
        model: null,
        summary: { total_upcoming: total, high_risk: 0, medium_risk: 0, low_risk: 0 },
        items: [],
        pagination: { page, limit, total, totalPages: Math.max(1, Math.ceil(total / limit)) },
        message: 'No active model',
      };
    }

    const weights = Array.isArray(model.weights_json?.weights) ? model.weights_json.weights : [];
    const bias = Number(model.bias_value || 0);
    const rawItems = itemsRaw as any[];
    const doctorIds = [...new Set(rawItems.map((a) => a.doctor_id).filter(Boolean).map(String))];
    const docRows =
      doctorIds.length > 0
        ? await db('doctors').whereIn('id', doctorIds).select('id', 'user_id')
        : [];
    const doctorIdToUserId = new Map<string, string | null>(
      docRows.map((d: any) => [String(d.id), d.user_id != null ? String(d.user_id) : null]),
    );
    const doctorUserIds = [...new Set([...doctorIdToUserId.values()].filter((x): x is string => !!x))];
    const thrCtx = await noShowThresholdService.buildResolutionContext(scope.tenantId, doctorUserIds);
    const out: any[] = [];
    for (const a of rawItems) {
      const du =
        a.doctor_id != null ? doctorIdToUserId.get(String(a.doctor_id)) ?? null : null;
      const thr = noShowThresholdService.resolveOne(du, thrCtx, model.hyperparameters_json);
      const fv = await this.featureVectorForAppointment(scope.tenantId, a);
      let z = bias;
      for (let i = 0; i < Math.min(weights.length, fv.length); i += 1) z += Number(weights[i] || 0) * fv[i];
      const score = this.sigmoid(z);
      const level = this.mapRiskLevel(score, thr.medium_threshold, thr.high_threshold);
      const factors = this.explainSignedContributions(fv, weights, 3);
      out.push({
        appointment_id: a.id,
        appointment_date: a.appointment_date,
        patient_name: `${a.first_name || ''} ${a.last_name || ''}`.trim(),
        doctor_id: a.doctor_id,
        risk_score: Number(score.toFixed(6)),
        risk_level: level,
        top_factors: factors,
      });
    }

    const filtered = filters.riskLevel ? out.filter((i) => i.risk_level === filters.riskLevel) : out;
    const summary = {
      total_upcoming: total,
      high_risk: out.filter((i) => i.risk_level === 'high').length,
      medium_risk: out.filter((i) => i.risk_level === 'medium').length,
      low_risk: out.filter((i) => i.risk_level === 'low').length,
    };
    return {
      scope: {
        tenant_id: scope.tenantId,
        role: scope.role,
        scoped_doctor_id: scope.scopedDoctorId,
      },
      model: {
        model_version_id: model.id,
        trained_at: model.trained_at,
        ...(model.metrics_json || {}),
      },
      summary,
      items: filtered,
      pagination: { page, limit, total, totalPages: Math.max(1, Math.ceil(total / limit)) },
    };
  }
}

export const noShowPredictionService = new NoShowPredictionService();

