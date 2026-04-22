import { Request, Response, NextFunction } from 'express';
import db from '../config/database';
import { asyncHandler, AuthorizationError, ValidationError, NotFoundError } from '../middleware/errorHandler';
import { noShowPredictionService } from '../services/noShowPrediction.service';
import { noShowTrainingService } from '../services/noShowTraining.service';
import { noShowThresholdService } from '../services/noShowThreshold.service';
import { noShowDriftService } from '../services/noShowDrift.service';
import { noShowMonitoringService } from '../services/noShowMonitoring.service';
import { buildNoShowSmsBody, isTwilioSmsConfigured, sendSMS } from '../services/sms.service';
import { noShowOverbookingService } from '../services/noShowOverbooking.service';

const MODEL_TYPE = 'no_show_prediction';

export class NoShowAiController {
  private async resolveScope(req: Request): Promise<{
    tenantId: string;
    role: string;
    scopedDoctorId: string | null;
    actorUserId: string | null;
  }> {
    const tenantId = req.tenantId!;
    const role = req.user?.role || '';
    const userId = req.user?.userId || req.user?.id;
    let scopedDoctorId: string | null = null;
    if (role === 'doctor' || role === 'paramedical') {
      const doc = await db('doctors')
        .where({ tenant_id: tenantId, user_id: userId, is_active: true })
        .first('id');
      scopedDoctorId = doc?.id || null;
    }
    return {
      tenantId,
      role,
      scopedDoctorId,
      actorUserId: userId != null ? String(userId) : null,
    };
  }

  getUpcoming = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const scope = await this.resolveScope(req);
    if (!['developer', 'admin', 'doctor', 'paramedical'].includes(scope.role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    const data = await noShowPredictionService.predictBatchUpcomingAppointments(scope, {
      dateFrom: req.query.date_from as string | undefined,
      dateTo: req.query.date_to as string | undefined,
      doctorId: req.query.doctor_id as string | undefined,
      riskLevel: req.query.risk_level as string | undefined,
      page: Number(req.query.page || 1),
      limit: Number(req.query.limit || 25),
    });
    res.status(200).json({ status: 'success', data });
  });

  getAppointmentPrediction = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const scope = await this.resolveScope(req);
    if (!['developer', 'admin', 'doctor', 'paramedical'].includes(scope.role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    const data = await noShowPredictionService.predictAppointmentNoShow(scope, req.params.id);
    res.status(200).json({ status: 'success', data });
  });

  listModelVersions = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can view model versions');
    }
    const rows = await db('ml_model_versions')
      .where({ tenant_id: req.tenantId!, model_type: MODEL_TYPE })
      .orderBy('trained_at', 'desc');
    res.status(200).json({ status: 'success', data: rows });
  });

  getModelMetrics = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can view model metrics');
    }
    const active = await db('ml_model_versions')
      .where({ tenant_id: req.tenantId!, model_type: MODEL_TYPE, is_active: true })
      .first();
    res.status(200).json({
      status: 'success',
      data: active
        ? {
            model_version_id: active.id,
            trained_at: active.trained_at,
            metrics: active.metrics_json || {},
            feature_schema_version: active.feature_schema_version,
          }
        : null,
    });
  });

  trainModel = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can trigger training');
    }
    const tenantId = req.tenantId!;
    const result = await noShowTrainingService.trainTenantModel(tenantId, 'manual', {
      force: req.body?.force === true,
      activateIfBetter: req.body?.activate_if_better !== false,
    });
    res.status(200).json({ status: 'success', data: result });
  });

  activateModel = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can activate model version');
    }
    const versionId = req.body?.model_version_id as string;
    if (!versionId) throw new ValidationError('model_version_id is required');
    const row = await db('ml_model_versions')
      .where({ id: versionId, tenant_id: req.tenantId!, model_type: MODEL_TYPE })
      .first();
    if (!row) throw new ValidationError('Model version not found in tenant');
    await noShowTrainingService.activateModelVersion(versionId);
    res.status(200).json({ status: 'success', message: 'Model version activated' });
  });

  /** Alias: rollback = activate a previous version by id. */
  rollbackModel = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can rollback model version');
    }
    const versionId = req.body?.model_version_id as string;
    if (!versionId) throw new ValidationError('model_version_id is required');
    const row = await db('ml_model_versions')
      .where({ id: versionId, tenant_id: req.tenantId!, model_type: MODEL_TYPE })
      .first();
    if (!row) throw new ValidationError('Model version not found in tenant');
    await noShowTrainingService.activateModelVersion(versionId);
    res.status(200).json({ status: 'success', message: 'Rolled back to model version', data: { model_version_id: versionId } });
  });

  getThresholds = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can view thresholds');
    }
    const tenantId = req.tenantId!;
    const doctorUserId = (req.query.doctor_user_id as string) || null;
    const active = await db('ml_model_versions')
      .where({ tenant_id: tenantId, model_type: MODEL_TYPE, is_active: true })
      .first();
    const resolved = await noShowThresholdService.resolveForPrediction(
      tenantId,
      doctorUserId,
      active?.hyperparameters_json || null,
    );
    const storedRow = await noShowThresholdService.getTenantConfig(tenantId, doctorUserId || undefined);
    res.status(200).json({
      status: 'success',
      data: {
        resolved,
        stored_row: storedRow || null,
        env_defaults: {
          medium: Number(process.env.NOSHOW_DEFAULT_THRESHOLD_MEDIUM || 0.4),
          high: Number(process.env.NOSHOW_DEFAULT_THRESHOLD_HIGH || 0.7),
        },
      },
    });
  });

  putThresholds = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can update thresholds');
    }
    const tenantId = req.tenantId!;
    const userId = (req.user?.userId || req.user?.id) as string | undefined;
    const body = req.body || {};
    const doctorUserId = body.doctor_user_id as string | undefined;
    if (doctorUserId) {
      await noShowThresholdService.upsertDoctorOverride(tenantId, doctorUserId, body, userId);
    } else {
      await noShowThresholdService.upsertTenantDefault(tenantId, body, userId);
    }
    res.status(200).json({ status: 'success', message: 'Thresholds saved' });
  });

  listDrift = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can view drift');
    }
    const limit = Number(req.query.limit || 50);
    const rows = await noShowDriftService.listSnapshots(req.tenantId!, limit);
    res.status(200).json({ status: 'success', data: rows });
  });

  runDriftCheck = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can run drift checks');
    }
    const result = await noShowDriftService.runFeatureDriftCheck(req.tenantId!);
    res.status(200).json({ status: 'success', data: result });
  });

  listAlerts = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can view alerts');
    }
    const onlyUnacked = String(req.query.unacked || '') === '1' || String(req.query.unacked || '') === 'true';
    const limit = Number(req.query.limit || 100);
    const rows = await noShowDriftService.listAlerts(req.tenantId!, onlyUnacked, limit);
    res.status(200).json({ status: 'success', data: rows });
  });

  acknowledgeAlert = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can acknowledge alerts');
    }
    const alertId = req.params.id;
    if (!alertId) throw new ValidationError('Alert id is required');
    const userId = (req.user?.userId || req.user?.id) as string | undefined;
    await noShowDriftService.acknowledgeAlert(req.tenantId!, alertId, userId);
    res.status(200).json({ status: 'success', message: 'Alert acknowledged' });
  });

  listTrainingJobs = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can view training jobs');
    }
    const rows = await db('ml_training_jobs')
      .where({ tenant_id: req.tenantId!, model_type: MODEL_TYPE })
      .orderBy('started_at', 'desc')
      .limit(200);
    res.status(200).json({ status: 'success', data: rows });
  });

  getMonitoringDaily = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can view monitoring');
    }
    const days = Number(req.query.days || 90);
    const rows = await noShowMonitoringService.listDaily(req.tenantId!, days);
    res.status(200).json({ status: 'success', data: rows });
  });

  rollupMonitoring = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can run monitoring rollup');
    }
    const statDate =
      (req.body?.stat_date as string) ||
      new Date(Date.now() - 86400000).toISOString().slice(0, 10);
    const result = await noShowMonitoringService.rollupForStatDate(req.tenantId!, statDate);
    res.status(200).json({ status: 'success', data: result });
  });

  sendNoShowSms = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const scope = await this.resolveScope(req);
    if (!['developer', 'admin', 'doctor', 'paramedical'].includes(scope.role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    if (!isTwilioSmsConfigured()) {
      throw new ValidationError('Twilio SMS is not configured on the server');
    }
    const appointmentId = req.body?.appointment_id as string;
    const kind = req.body?.kind as string;
    if (!appointmentId) throw new ValidationError('appointment_id is required');
    if (kind !== 'reminder' && kind !== 'confirm') {
      throw new ValidationError('kind must be reminder or confirm');
    }

    let q = db('appointments as a')
      .join('patients as p', 'a.patient_id', 'p.id')
      .join('users as u', 'p.user_id', 'u.id')
      .where({ 'a.tenant_id': scope.tenantId, 'a.id': appointmentId })
      .select('a.id', 'a.doctor_id', 'u.phone', 'u.first_name', 'a.appointment_date');
    if (scope.scopedDoctorId) {
      q = q.andWhere('a.doctor_id', scope.scopedDoctorId);
    }
    const row = await q.first();
    if (!row) throw new NotFoundError('Appointment');

    const rawPhone = String((row as { phone?: string }).phone || '').trim();
    if (!rawPhone) throw new ValidationError('Patient has no phone number on file');
    const text = buildNoShowSmsBody(
      kind as 'reminder' | 'confirm',
      String((row as { first_name?: string }).first_name || ''),
      String((row as { appointment_date?: string }).appointment_date || ''),
    );
    const doctorId = (row as { doctor_id?: string }).doctor_id || undefined;
    const ok = await sendSMS({
      to: rawPhone,
      message: text,
      doctorId,
      appointmentId,
      smsType: kind === 'confirm' ? 'confirmation' : 'reminder',
    });
    if (!ok) {
      throw new ValidationError(
        'SMS could not be sent (Twilio off, doctor SMS disabled, or insufficient balance)',
      );
    }
    const usage = await db('doctor_sms_usage')
      .where({ appointment_id: appointmentId, sent_successfully: true })
      .orderBy('created_at', 'desc')
      .first();
    const sid = (usage as { twilio_message_sid?: string } | undefined)?.twilio_message_sid || '';

    const pred = await db('appointment_no_show_predictions')
      .where({ tenant_id: scope.tenantId, appointment_id: appointmentId, is_current: true })
      .first();

    await db('ml_action_outcomes').insert({
      tenant_id: scope.tenantId,
      appointment_id: appointmentId,
      prediction_id: pred?.id || null,
      action_type: 'sms',
      message_kind: kind,
      twilio_sid: sid || null,
      to_phone_tail: rawPhone.replace(/\D/g, '').slice(-8) || null,
      details_json: { preview: text.slice(0, 120) },
    });

    res.status(200).json({ status: 'success', data: { twilio_sid: sid } });
  });

  getOverbookingRule = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can view overbooking rules');
    }
    const doctorId = (req.query.doctor_id as string) || null;
    const row = await noShowOverbookingService.getRule(req.tenantId!, doctorId);
    res.status(200).json({ status: 'success', data: row || null });
  });

  putOverbookingRule = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can update overbooking rules');
    }
    await noShowOverbookingService.upsertRule(req.tenantId!, {
      doctor_id: (req.body?.doctor_id as string) || null,
      risk_threshold: Number(req.body?.risk_threshold ?? 0.7),
      max_extra_slots: Number(req.body?.max_extra_slots ?? 1),
      is_enabled: req.body?.is_enabled === true,
    });
    res.status(200).json({ status: 'success', message: 'Overbooking rule saved' });
  });
}

export const noShowAiController = new NoShowAiController();

