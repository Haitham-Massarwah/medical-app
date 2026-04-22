import db from '../config/database';
import { logger } from '../config/logger';
import { NoShowMetricsService } from './noShowMetrics.service';
import { NOSHOW_FEATURE_KEYS, NOSHOW_MODEL_KEY } from './noShowFeatureConfig';

type FeatureRow = {
  appointment_id: string;
  tenant_id: string;
  patient_id: string;
  doctor_id: string;
  appointment_date: Date;
  created_at: Date;
  duration_minutes: number;
  label: 0 | 1;
  features: number[];
};

type TrainedModel = {
  weights: number[];
  bias: number;
  metrics: any;
  feature_schema_version: string;
  threshold_medium: number;
  threshold_high: number;
  validation_rows_count: number;
  training_rows_count: number;
  training_positive_count: number;
  training_negative_count: number;
  data_range_from: Date | null;
  data_range_to: Date | null;
};

const MODEL_TYPE = 'no_show_prediction';
const FEATURE_SCHEMA_VERSION = 'v1';

export class NoShowTrainingService {
  private metrics = new NoShowMetricsService();

  private cfg = {
    minRows: Number(process.env.NOSHOW_MIN_TRAINING_ROWS || 100),
    minPositives: Number(process.env.NOSHOW_MIN_POSITIVE_LABELS || 10),
    minAucForPromotion: Number(process.env.NOSHOW_MIN_AUC_FOR_PROMOTION || 0.65),
    minPrecisionForPromotion: Number(process.env.NOSHOW_MIN_PRECISION_FOR_PROMOTION || 0.55),
    minRecallForPromotion: Number(process.env.NOSHOW_MIN_RECALL_FOR_PROMOTION || 0.45),
    learningRate: Number(process.env.NOSHOW_LR || 0.2),
    epochs: Number(process.env.NOSHOW_EPOCHS || 240),
    l2: Number(process.env.NOSHOW_L2 || 0.001),
    thresholdMedium: Number(process.env.NOSHOW_DEFAULT_THRESHOLD_MEDIUM || 0.4),
    thresholdHigh: Number(process.env.NOSHOW_DEFAULT_THRESHOLD_HIGH || 0.7),
  };

  private sigmoid(z: number): number {
    const clamped = Math.max(-25, Math.min(25, z));
    return 1 / (1 + Math.exp(-clamped));
  }

  async buildTrainingDataset(tenantId: string): Promise<FeatureRow[]> {
    const raw = await db('appointments')
      .where({ tenant_id: tenantId })
      .whereIn('status', ['completed', 'no_show'])
      .whereNotNull('patient_id')
      .whereNotNull('doctor_id')
      .whereNotNull('appointment_date')
      .orderBy('appointment_date', 'asc')
      .select(
        'id',
        'tenant_id',
        'patient_id',
        'doctor_id',
        'appointment_date',
        'created_at',
        'duration_minutes',
        'status',
      );

    const history = new Map<string, { total: number; noShows: number; completed: number; lastDate: Date | null }>();
    const out: FeatureRow[] = [];
    for (const r of raw as any[]) {
      const pid = String(r.patient_id);
      const apptDate = new Date(r.appointment_date);
      const createdAt = r.created_at ? new Date(r.created_at) : apptDate;
      const h = history.get(pid) || { total: 0, noShows: 0, completed: 0, lastDate: null };
      const leadHours = Math.max(0, (apptDate.getTime() - createdAt.getTime()) / 3600000);
      const patientNoShowRate = h.total > 0 ? h.noShows / h.total : 0;
      const patientRecentNoShowRate = patientNoShowRate;
      const daysSinceLast = h.lastDate
        ? Math.max(0, (apptDate.getTime() - h.lastDate.getTime()) / (24 * 3600000))
        : -1;
      const features = [
        Math.min(leadHours, 24 * 30) / (24 * 30),
        apptDate.getHours() / 23,
        apptDate.getDay() / 6,
        (apptDate.getMonth() + 1) / 12,
        Math.min(Number(r.duration_minutes || 30), 240) / 240,
        Math.min(h.total, 100) / 100,
        Math.min(h.completed, 100) / 100,
        Math.min(h.noShows, 100) / 100,
        patientNoShowRate,
        patientRecentNoShowRate,
        daysSinceLast < 0 ? 0 : Math.min(daysSinceLast, 365) / 365,
      ];

      const label: 0 | 1 = r.status === 'no_show' ? 1 : 0;
      out.push({
        appointment_id: String(r.id),
        tenant_id: String(r.tenant_id),
        patient_id: pid,
        doctor_id: String(r.doctor_id),
        appointment_date: apptDate,
        created_at: createdAt,
        duration_minutes: Number(r.duration_minutes || 30),
        label,
        features,
      });

      h.total += 1;
      if (label === 1) h.noShows += 1;
      else h.completed += 1;
      h.lastDate = apptDate;
      history.set(pid, h);
    }
    return out;
  }

  trainModel(dataset: FeatureRow[]): TrainedModel {
    const rows = [...dataset];
    const training_rows_count = rows.length;
    const positiveCount = rows.filter((r) => r.label === 1).length;
    const negativeCount = rows.length - positiveCount;
    if (
      training_rows_count < this.cfg.minRows ||
      positiveCount < this.cfg.minPositives ||
      negativeCount < this.cfg.minPositives
    ) {
      throw new Error(
        `Insufficient data rows=${training_rows_count} positives=${positiveCount} negatives=${negativeCount}`,
      );
    }

    const split = Math.max(1, Math.floor(rows.length * 0.8));
    const trainRows = rows.slice(0, split);
    const valRows = rows.slice(split);
    const dim = trainRows[0].features.length;
    const w = new Array<number>(dim).fill(0);
    let b = 0;

    for (let epoch = 0; epoch < this.cfg.epochs; epoch += 1) {
      const gradW = new Array<number>(dim).fill(0);
      let gradB = 0;
      for (const row of trainRows) {
        let z = b;
        for (let j = 0; j < dim; j += 1) z += w[j] * row.features[j];
        const p = this.sigmoid(z);
        const err = p - row.label;
        for (let j = 0; j < dim; j += 1) gradW[j] += err * row.features[j];
        gradB += err;
      }
      for (let j = 0; j < dim; j += 1) {
        const reg = this.cfg.l2 * w[j];
        w[j] -= (this.cfg.learningRate / trainRows.length) * (gradW[j] + reg);
      }
      b -= (this.cfg.learningRate / trainRows.length) * gradB;
    }

    const valLabels = valRows.map((r) => r.label);
    const valProb = valRows.map((r) => {
      let z = b;
      for (let j = 0; j < w.length; j += 1) z += w[j] * r.features[j];
      return this.sigmoid(z);
    });
    const metrics = this.metrics.evaluate(valLabels, valProb, this.cfg.thresholdMedium);

    return {
      weights: w,
      bias: b,
      metrics,
      feature_schema_version: FEATURE_SCHEMA_VERSION,
      threshold_medium: this.cfg.thresholdMedium,
      threshold_high: this.cfg.thresholdHigh,
      validation_rows_count: valRows.length,
      training_rows_count,
      training_positive_count: positiveCount,
      training_negative_count: negativeCount,
      data_range_from: rows.length > 0 ? rows[0].appointment_date : null,
      data_range_to: rows.length > 0 ? rows[rows.length - 1].appointment_date : null,
    };
  }

  async saveModelVersion(
    tenantId: string,
    model: TrainedModel,
    source: 'cron' | 'manual' | 'runtime_fallback',
    notes?: string,
  ): Promise<string> {
    const versionCode = `${MODEL_TYPE}_${new Date().toISOString().replace(/[-:.TZ]/g, '').slice(0, 14)}`;
    const [row] = await db('ml_model_versions')
      .insert({
        tenant_id: tenantId,
        model_type: MODEL_TYPE,
        version_code: versionCode,
        status: 'draft',
        trained_at: new Date(),
        training_started_at: new Date(),
        training_finished_at: new Date(),
        training_rows_count: model.training_rows_count,
        training_positive_count: model.training_positive_count,
        training_negative_count: model.training_negative_count,
        validation_rows_count: model.validation_rows_count,
        feature_schema_version: model.feature_schema_version,
        hyperparameters_json: {
          learning_rate: this.cfg.learningRate,
          epochs: this.cfg.epochs,
          l2: this.cfg.l2,
          threshold_medium: model.threshold_medium,
          threshold_high: model.threshold_high,
        },
        weights_json: { weights: model.weights },
        bias_value: model.bias,
        metrics_json: model.metrics,
        data_range_from: model.data_range_from,
        data_range_to: model.data_range_to,
        created_by_source: source,
        is_active: false,
        notes: notes || null,
      })
      .returning('id');
    return row.id as string;
  }

  private async saveFeatureDistributionBaselines(
    tenantId: string,
    modelVersionId: string,
    dataset: FeatureRow[],
  ): Promise<void> {
    if (dataset.length === 0) return;
    const dim = dataset[0].features.length;
    const rows: Record<string, unknown>[] = [];
    for (let i = 0; i < dim; i += 1) {
      const vals = dataset.map((d) => d.features[i]);
      const n = vals.length;
      const mean = vals.reduce((a, b) => a + b, 0) / n;
      const variance = vals.reduce((a, v) => a + (v - mean) ** 2, 0) / n;
      const std = Math.sqrt(variance);
      const sorted = [...vals].sort((a, b) => a - b);
      const p10 = sorted[Math.min(sorted.length - 1, Math.floor((sorted.length - 1) * 0.1))];
      const p90 = sorted[Math.min(sorted.length - 1, Math.floor((sorted.length - 1) * 0.9))];
      const key = (NOSHOW_FEATURE_KEYS as readonly string[])[i] || `feature_${i}`;
      rows.push({
        tenant_id: tenantId,
        model_key: NOSHOW_MODEL_KEY,
        model_version_id: modelVersionId,
        feature_name: key,
        feature_type: 'numeric',
        baseline_json: { mean, std, p10, p90 },
        sample_size: n,
        created_at: new Date(),
      });
    }
    if (rows.length) await db('ml_feature_distribution_baselines').insert(rows);
  }

  async activateModelVersion(modelVersionId: string): Promise<void> {
    const target = await db('ml_model_versions').where({ id: modelVersionId }).first();
    if (!target) throw new Error('Model version not found');
    await db.transaction(async (trx) => {
      await trx('ml_model_versions')
        .where({ tenant_id: target.tenant_id, model_type: target.model_type, is_active: true })
        .update({ is_active: false, status: 'archived', updated_at: new Date() });
      await trx('ml_model_versions')
        .where({ id: modelVersionId })
        .update({ is_active: true, status: 'active', updated_at: new Date() });
    });
  }

  async archiveModelVersion(modelVersionId: string): Promise<void> {
    await db('ml_model_versions')
      .where({ id: modelVersionId })
      .update({ is_active: false, status: 'archived', updated_at: new Date() });
  }

  async shouldPromoteModel(
    candidateModelVersionId: string,
    tenantId: string,
    activateIfBetter: boolean,
  ): Promise<boolean> {
    const candidate = await db('ml_model_versions').where({ id: candidateModelVersionId }).first();
    if (!candidate) return false;
    const cand = candidate.metrics_json || {};
    const auc = Number(cand.auc || 0);
    const precision = Number(cand.precision || 0);
    const recall = Number(cand.recall || 0);
    if (
      auc < this.cfg.minAucForPromotion ||
      precision < this.cfg.minPrecisionForPromotion ||
      recall < this.cfg.minRecallForPromotion
    ) {
      return false;
    }
    if (!activateIfBetter) return true;

    const current = await db('ml_model_versions')
      .where({ tenant_id: tenantId, model_type: MODEL_TYPE, is_active: true })
      .first();
    if (!current) return true;
    const cur = current.metrics_json || {};
    const currentAuc = Number(cur.auc || 0);
    return auc >= currentAuc;
  }

  async trainTenantModel(
    tenantId: string,
    triggerType: 'cron' | 'manual' | 'runtime_fallback',
    options: { activateIfBetter?: boolean; force?: boolean } = {},
  ): Promise<Record<string, unknown>> {
    const activateIfBetter = options.activateIfBetter !== false;
    const [job] = await db('ml_training_jobs')
      .insert({
        tenant_id: tenantId,
        model_type: MODEL_TYPE,
        trigger_type: triggerType,
        status: 'running',
        started_at: new Date(),
      })
      .returning('*');

    try {
      const dataset = await this.buildTrainingDataset(tenantId);
      if (!options.force && dataset.length < this.cfg.minRows) {
        await db('ml_training_jobs')
          .where({ id: job.id })
          .update({
            status: 'skipped',
            reason: `Insufficient rows ${dataset.length}`,
            input_rows_count: dataset.length,
            finished_at: new Date(),
            updated_at: new Date(),
          });
        return { status: 'skipped', reason: 'Insufficient data', rows: dataset.length };
      }

      const model = this.trainModel(dataset);
      const versionId = await this.saveModelVersion(tenantId, model, triggerType);
      try {
        await this.saveFeatureDistributionBaselines(tenantId, versionId, dataset);
      } catch (e: any) {
        logger.warn('Feature baselines insert skipped or failed', {
          tenantId,
          versionId,
          error: e?.message || String(e),
        });
      }
      const promote = await this.shouldPromoteModel(versionId, tenantId, activateIfBetter);
      if (promote) {
        await this.activateModelVersion(versionId);
      }

      await db('ml_training_jobs')
        .where({ id: job.id })
        .update({
          status: 'success',
          reason: promote ? 'Activated' : 'Saved as draft',
          input_rows_count: dataset.length,
          output_model_version_id: versionId,
          metrics_json: model.metrics,
          finished_at: new Date(),
          updated_at: new Date(),
        });

      return {
        status: 'success',
        model_version_id: versionId,
        activated: promote,
        metrics: model.metrics,
      };
    } catch (e: any) {
      logger.error('No-show training failed', { tenantId, error: e?.message || String(e) });
      await db('ml_training_jobs')
        .where({ id: job.id })
        .update({
          status: 'failed',
          error_message: e?.message || String(e),
          finished_at: new Date(),
          updated_at: new Date(),
        });
      throw e;
    }
  }
}

export const noShowTrainingService = new NoShowTrainingService();

