import db from '../config/database';
import { NOSHOW_MODEL_KEY } from './noShowFeatureConfig';

const envMedium = () => Number(process.env.NOSHOW_DEFAULT_THRESHOLD_MEDIUM || 0.4);
const envHigh = () => Number(process.env.NOSHOW_DEFAULT_THRESHOLD_HIGH || 0.7);

export type ResolvedThresholds = {
  medium_threshold: number;
  high_threshold: number;
  source: 'doctor_override' | 'tenant_default' | 'env' | 'model_hyperparams';
};

export class NoShowThresholdService {
  async buildResolutionContext(
    tenantId: string,
    doctorUserIds: (string | null | undefined)[],
  ): Promise<{
    tenantRow: Record<string, unknown> | undefined;
    byDoctorUserId: Map<string, Record<string, unknown>>;
  }> {
    const ids = [...new Set(doctorUserIds.filter((x): x is string => !!x))];
    const tenantRow = await db('ml_model_threshold_configs')
      .where({ tenant_id: tenantId, model_key: NOSHOW_MODEL_KEY })
      .whereNull('doctor_user_id')
      .first();
    const byDoctorUserId = new Map<string, Record<string, unknown>>();
    if (ids.length > 0) {
      const rows = await db('ml_model_threshold_configs')
        .where({ tenant_id: tenantId, model_key: NOSHOW_MODEL_KEY })
        .whereIn('doctor_user_id', ids);
      for (const r of rows as Record<string, unknown>[]) {
        const uid = r.doctor_user_id != null ? String(r.doctor_user_id) : '';
        if (uid) byDoctorUserId.set(uid, r);
      }
    }
    return { tenantRow, byDoctorUserId };
  }

  resolveOne(
    doctorUserId: string | null,
    ctx: {
      tenantRow?: Record<string, unknown> | null;
      byDoctorUserId: Map<string, Record<string, unknown>>;
    },
    modelHyperparams?: { threshold_medium?: number; threshold_high?: number } | null,
  ): ResolvedThresholds {
    if (doctorUserId && ctx.byDoctorUserId.has(doctorUserId)) {
      const row = ctx.byDoctorUserId.get(doctorUserId)!;
      return {
        medium_threshold: Number(row.medium_threshold),
        high_threshold: Number(row.high_threshold),
        source: 'doctor_override',
      };
    }
    if (ctx.tenantRow) {
      return {
        medium_threshold: Number(ctx.tenantRow.medium_threshold),
        high_threshold: Number(ctx.tenantRow.high_threshold),
        source: 'tenant_default',
      };
    }
    if (modelHyperparams?.threshold_medium != null && modelHyperparams?.threshold_high != null) {
      return {
        medium_threshold: Number(modelHyperparams.threshold_medium),
        high_threshold: Number(modelHyperparams.threshold_high),
        source: 'model_hyperparams',
      };
    }
    return {
      medium_threshold: envMedium(),
      high_threshold: envHigh(),
      source: 'env',
    };
  }

  async resolveForPrediction(
    tenantId: string,
    doctorUserId: string | null,
    modelHyperparams?: { threshold_medium?: number; threshold_high?: number } | null,
  ): Promise<ResolvedThresholds> {
    const ctx = await this.buildResolutionContext(tenantId, [doctorUserId]);
    return this.resolveOne(doctorUserId, ctx, modelHyperparams);
  }

  async getTenantConfig(tenantId: string, doctorUserId?: string | null) {
    if (doctorUserId) {
      const doc = await db('ml_model_threshold_configs')
        .where({
          tenant_id: tenantId,
          model_key: NOSHOW_MODEL_KEY,
          doctor_user_id: doctorUserId,
        })
        .first();
      if (doc) return doc;
    }
    return db('ml_model_threshold_configs')
      .where({ tenant_id: tenantId, model_key: NOSHOW_MODEL_KEY })
      .whereNull('doctor_user_id')
      .first();
  }

  async upsertTenantDefault(
    tenantId: string,
    body: {
      medium_threshold: number;
      high_threshold: number;
      auto_sms_medium_enabled?: boolean;
      auto_sms_high_enabled?: boolean;
      smart_overbooking_enabled?: boolean;
      model_version_id?: string | null;
    },
    userId: string | undefined,
  ): Promise<void> {
    const medium = Number(body.medium_threshold);
    const high = Number(body.high_threshold);
    if (medium < 0 || medium > 1 || high < 0 || high > 1 || medium >= high) {
      throw new Error('Invalid thresholds: require 0 <= medium < high <= 1');
    }
    const existing = await db('ml_model_threshold_configs')
      .where({ tenant_id: tenantId, model_key: NOSHOW_MODEL_KEY })
      .whereNull('doctor_user_id')
      .first();

    const payload = {
      medium_threshold: medium,
      high_threshold: high,
      auto_sms_medium_enabled: body.auto_sms_medium_enabled === true,
      auto_sms_high_enabled: body.auto_sms_high_enabled !== false,
      smart_overbooking_enabled: body.smart_overbooking_enabled === true,
      model_version_id: body.model_version_id || null,
      updated_by: userId || null,
      updated_at: new Date(),
    };

    if (existing) {
      await db('ml_model_threshold_configs').where({ id: existing.id }).update(payload);
    } else {
      await db('ml_model_threshold_configs').insert({
        tenant_id: tenantId,
        doctor_user_id: null,
        model_key: NOSHOW_MODEL_KEY,
        ...payload,
        created_by: userId || null,
        created_at: new Date(),
      });
    }
  }

  async upsertDoctorOverride(
    tenantId: string,
    doctorUserId: string,
    body: {
      medium_threshold: number;
      high_threshold: number;
      auto_sms_medium_enabled?: boolean;
      auto_sms_high_enabled?: boolean;
      smart_overbooking_enabled?: boolean;
      model_version_id?: string | null;
    },
    userId: string | undefined,
  ): Promise<void> {
    const medium = Number(body.medium_threshold);
    const high = Number(body.high_threshold);
    if (medium < 0 || medium > 1 || high < 0 || high > 1 || medium >= high) {
      throw new Error('Invalid thresholds: require 0 <= medium < high <= 1');
    }
    const existing = await db('ml_model_threshold_configs')
      .where({
        tenant_id: tenantId,
        model_key: NOSHOW_MODEL_KEY,
        doctor_user_id: doctorUserId,
      })
      .first();
    const payload = {
      medium_threshold: medium,
      high_threshold: high,
      auto_sms_medium_enabled: body.auto_sms_medium_enabled === true,
      auto_sms_high_enabled: body.auto_sms_high_enabled !== false,
      smart_overbooking_enabled: body.smart_overbooking_enabled === true,
      model_version_id: body.model_version_id || null,
      updated_by: userId || null,
      updated_at: new Date(),
    };
    if (existing) {
      await db('ml_model_threshold_configs').where({ id: existing.id }).update(payload);
    } else {
      await db('ml_model_threshold_configs').insert({
        tenant_id: tenantId,
        doctor_user_id: doctorUserId,
        model_key: NOSHOW_MODEL_KEY,
        ...payload,
        created_by: userId || null,
        created_at: new Date(),
      });
    }
  }
}

export const noShowThresholdService = new NoShowThresholdService();
