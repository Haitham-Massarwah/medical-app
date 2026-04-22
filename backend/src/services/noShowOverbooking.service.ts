import db from '../config/database';

/**
 * Smart overbooking: high predicted no-show risk may allow an extra booking in the same slot.
 * Rules are per-tenant (doctor_id null) or per-doctor override.
 */
export class NoShowOverbookingService {
  async getRule(tenantId: string, doctorId: string | null): Promise<Record<string, unknown> | undefined> {
    if (doctorId) {
      const doc = await db('no_show_overbooking_rules')
        .where({ tenant_id: tenantId, doctor_id: doctorId })
        .first();
      if (doc) return doc;
    }
    return db('no_show_overbooking_rules').where({ tenant_id: tenantId }).whereNull('doctor_id').first();
  }

  async upsertRule(
    tenantId: string,
    body: {
      doctor_id?: string | null;
      risk_threshold: number;
      max_extra_slots: number;
      is_enabled: boolean;
    },
  ): Promise<void> {
    const thr = Number(body.risk_threshold);
    const maxExtra = Math.max(0, Math.min(10, Math.floor(Number(body.max_extra_slots))));
    if (thr < 0 || thr > 1) throw new Error('risk_threshold must be between 0 and 1');

    const doctorId = body.doctor_id || null;
    const payload = {
      risk_threshold: thr,
      max_extra_slots: maxExtra,
      is_enabled: body.is_enabled === true,
      updated_at: new Date(),
    };

    if (doctorId) {
      const existing = await db('no_show_overbooking_rules')
        .where({ tenant_id: tenantId, doctor_id: doctorId })
        .first();
      if (existing) {
        await db('no_show_overbooking_rules').where({ id: existing.id }).update(payload);
      } else {
        await db('no_show_overbooking_rules').insert({
          tenant_id: tenantId,
          doctor_id: doctorId,
          ...payload,
          created_at: new Date(),
        });
      }
    } else {
      const existing = await db('no_show_overbooking_rules')
        .where({ tenant_id: tenantId })
        .whereNull('doctor_id')
        .first();
      if (existing) {
        await db('no_show_overbooking_rules').where({ id: existing.id }).update(payload);
      } else {
        await db('no_show_overbooking_rules').insert({
          tenant_id: tenantId,
          doctor_id: null,
          ...payload,
          created_at: new Date(),
        });
      }
    }
  }

  /** Full diagnostics for API / UI (Hebrew copy can map `reason`). */
  async evaluateDetailed(
    tenantId: string,
    doctorId: string | null,
    riskScore: number,
    currentExtraInSlot: number,
  ): Promise<{
    allowed: boolean;
    reason: string;
    rule_enabled: boolean;
    risk_threshold: number | null;
    max_extra_slots: number | null;
    risk_score: number;
    current_extra_in_slot: number;
  }> {
    const rule = await this.getRule(tenantId, doctorId);
    if (!rule || rule.is_enabled !== true) {
      return {
        allowed: false,
        reason: 'overbooking_disabled',
        rule_enabled: false,
        risk_threshold: null,
        max_extra_slots: null,
        risk_score: riskScore,
        current_extra_in_slot: currentExtraInSlot,
      };
    }
    const threshold = Number(rule.risk_threshold ?? 0.7);
    const maxExtra = Number(rule.max_extra_slots ?? 0);
    if (riskScore < threshold) {
      return {
        allowed: false,
        reason: 'risk_below_threshold',
        rule_enabled: true,
        risk_threshold: threshold,
        max_extra_slots: maxExtra,
        risk_score: riskScore,
        current_extra_in_slot: currentExtraInSlot,
      };
    }
    if (currentExtraInSlot >= maxExtra) {
      return {
        allowed: false,
        reason: 'max_extra_reached',
        rule_enabled: true,
        risk_threshold: threshold,
        max_extra_slots: maxExtra,
        risk_score: riskScore,
        current_extra_in_slot: currentExtraInSlot,
      };
    }
    return {
      allowed: true,
      reason: 'ok',
      rule_enabled: true,
      risk_threshold: threshold,
      max_extra_slots: maxExtra,
      risk_score: riskScore,
      current_extra_in_slot: currentExtraInSlot,
    };
  }

  /** Booking layer can call this before allowing a second patient in the same slot. */
  async evaluate(
    tenantId: string,
    doctorId: string | null,
    riskScore: number,
    currentExtraInSlot: number,
  ): Promise<{ allowed: boolean; reason: string }> {
    const d = await this.evaluateDetailed(tenantId, doctorId, riskScore, currentExtraInSlot);
    return { allowed: d.allowed, reason: d.reason };
  }
}

export const noShowOverbookingService = new NoShowOverbookingService();
