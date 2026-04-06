import { Request, Response } from 'express';
import db from '../config/database';
import { AuthorizationError, ValidationError } from '../middleware/errorHandler';

const STAFF_ROLES = ['admin', 'developer', 'receptionist', 'doctor'];
const ADMIN_ROLES = ['admin', 'developer'];

export class FinanceController {
  private tenant(req: Request): string {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant is required');
    return tenantId;
  }

  private role(req: Request): string {
    return req.user?.role || '';
  }

  private ensureStaff(req: Request): void {
    if (!STAFF_ROLES.includes(this.role(req))) {
      throw new AuthorizationError('Insufficient permissions');
    }
  }

  private ensureAdmin(req: Request): void {
    if (!ADMIN_ROLES.includes(this.role(req))) {
      throw new AuthorizationError('Insufficient permissions');
    }
  }

  async listDeposits(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.tenant(req);
    const status = req.query.status as string | undefined;
    let q = db('finance_deposits').where({ tenant_id: tenantId }).orderBy('created_at', 'desc');
    if (status) q = q.andWhere({ status });
    const deposits = await q.select('*');
    res.status(200).json({ status: 'success', data: { deposits } });
  }

  async createDeposit(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.tenant(req);
    const { appointment_id, patient_id, amount, currency, method, notes } = req.body || {};
    if (!amount) throw new ValidationError('amount is required');
    const [deposit] = await db('finance_deposits')
      .insert({
        tenant_id: tenantId,
        appointment_id: appointment_id || null,
        patient_id: patient_id || null,
        amount: Number(amount),
        currency: currency || 'ILS',
        status: 'paid',
        method: method || 'card',
        notes: notes || null,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    res.status(201).json({ status: 'success', data: { deposit } });
  }

  async listRefunds(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.tenant(req);
    const status = req.query.status as string | undefined;
    let q = db('finance_refunds').where({ tenant_id: tenantId }).orderBy('created_at', 'desc');
    if (status) q = q.andWhere({ status });
    const refunds = await q.select('*');
    res.status(200).json({ status: 'success', data: { refunds } });
  }

  async requestRefund(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.tenant(req);
    const userId = req.user?.userId || req.user?.id || null;
    const { payment_id, deposit_id, amount, currency, reason } = req.body || {};
    if (!amount || !reason) throw new ValidationError('amount and reason are required');

    const [refund] = await db('finance_refunds')
      .insert({
        tenant_id: tenantId,
        payment_id: payment_id || null,
        deposit_id: deposit_id || null,
        amount: Number(amount),
        currency: currency || 'ILS',
        status: 'requested',
        reason,
        requested_by_user_id: userId,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    res.status(201).json({ status: 'success', data: { refund } });
  }

  async processRefund(req: Request, res: Response): Promise<void> {
    this.ensureAdmin(req);
    const tenantId = this.tenant(req);
    const userId = req.user?.userId || req.user?.id || null;
    const { id } = req.params;
    const { status } = req.body || {};
    const resolved = status === 'rejected' ? 'rejected' : 'processed';
    const [refund] = await db('finance_refunds')
      .where({ id, tenant_id: tenantId })
      .update({
        status: resolved,
        approved_by_user_id: userId,
        processed_at: resolved === 'processed' ? new Date() : null,
        updated_at: new Date(),
      })
      .returning('*');
    if (!refund) throw new ValidationError('Refund not found');
    res.status(200).json({ status: 'success', data: { refund } });
  }

  async listPayouts(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.tenant(req);
    const status = req.query.status as string | undefined;
    let q = db('finance_payouts').where({ tenant_id: tenantId }).orderBy('created_at', 'desc');
    if (status) q = q.andWhere({ status });
    const payouts = await q.select('*');
    res.status(200).json({ status: 'success', data: { payouts } });
  }

  async createPayout(req: Request, res: Response): Promise<void> {
    this.ensureAdmin(req);
    const tenantId = this.tenant(req);
    const { provider_user_id, gross_amount, commission_amount, currency, period_start, period_end, notes } = req.body || {};
    if (!provider_user_id || gross_amount === undefined) {
      throw new ValidationError('provider_user_id and gross_amount are required');
    }
    const gross = Number(gross_amount);
    const commission = Number(commission_amount || 0);
    const net = gross - commission;
    const [payout] = await db('finance_payouts')
      .insert({
        tenant_id: tenantId,
        provider_user_id,
        gross_amount: gross,
        commission_amount: commission,
        net_amount: net,
        currency: currency || 'ILS',
        status: 'scheduled',
        period_start: period_start || null,
        period_end: period_end || null,
        notes: notes || null,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    res.status(201).json({ status: 'success', data: { payout } });
  }

  async markPayoutPaid(req: Request, res: Response): Promise<void> {
    this.ensureAdmin(req);
    const tenantId = this.tenant(req);
    const { id } = req.params;
    const [payout] = await db('finance_payouts')
      .where({ id, tenant_id: tenantId })
      .update({
        status: 'paid',
        paid_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    if (!payout) throw new ValidationError('Payout not found');
    res.status(200).json({ status: 'success', data: { payout } });
  }

  async listCommissionRules(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.tenant(req);
    const rules = await db('finance_commission_rules')
      .where({ tenant_id: tenantId })
      .orderBy('created_at', 'desc')
      .select('*');
    res.status(200).json({ status: 'success', data: { rules } });
  }

  async createCommissionRule(req: Request, res: Response): Promise<void> {
    this.ensureAdmin(req);
    const tenantId = this.tenant(req);
    const { name, percent, fixed_amount, is_active } = req.body || {};
    if (!name) throw new ValidationError('name is required');
    const [rule] = await db('finance_commission_rules')
      .insert({
        tenant_id: tenantId,
        name: name.toString().trim(),
        percent: Number(percent || 0),
        fixed_amount: Number(fixed_amount || 0),
        is_active: is_active !== false,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    res.status(201).json({ status: 'success', data: { rule } });
  }
}

