import { Request, Response } from 'express';
import db from '../config/database';
import { AuthorizationError, ValidationError } from '../middleware/errorHandler';
import { sendEmail } from '../services/email.service';

const STAFF_ROLES = ['admin', 'developer', 'doctor', 'paramedical'];
const TEMPLATE_ADMIN_ROLES = ['admin', 'developer'];

export class CrmController {
  private ensureTenant(req: Request): string {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant is required');
    return tenantId;
  }

  private ensureStaff(req: Request): void {
    const role = req.user?.role || '';
    if (!STAFF_ROLES.includes(role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
  }

  async listLeads(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.ensureTenant(req);
    const status = (req.query.status as string | undefined)?.trim();

    let q = db('crm_leads').where({ tenant_id: tenantId }).orderBy('created_at', 'desc');
    if (status) q = q.andWhere({ status });

    const leads = await q.select('*');
    res.status(200).json({ status: 'success', data: { leads } });
  }

  async createLead(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.ensureTenant(req);
    const userId = req.user?.userId || req.user?.id || null;
    const { full_name, email, phone, source, status, notes, owner_user_id } = req.body || {};
    if (!full_name || typeof full_name !== 'string') {
      throw new ValidationError('full_name is required');
    }
    const [lead] = await db('crm_leads')
      .insert({
        tenant_id: tenantId,
        full_name: full_name.trim(),
        email: email || null,
        phone: phone || null,
        source: source || 'manual',
        status: status || 'new',
        notes: notes || null,
        owner_user_id: owner_user_id || userId,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    res.status(201).json({ status: 'success', data: { lead } });
  }

  async updateLead(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.ensureTenant(req);
    const { id } = req.params;
    const patch: Record<string, unknown> = { updated_at: new Date() };
    for (const f of ['full_name', 'email', 'phone', 'source', 'status', 'notes', 'owner_user_id']) {
      if (req.body?.[f] !== undefined) patch[f] = req.body[f];
    }
    const [lead] = await db('crm_leads').where({ id, tenant_id: tenantId }).update(patch).returning('*');
    if (!lead) throw new ValidationError('Lead not found');
    res.status(200).json({ status: 'success', data: { lead } });
  }

  async listFollowups(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.ensureTenant(req);
    const { lead_id, status } = req.query;
    let q = db('crm_followups as f')
      .leftJoin('crm_leads as l', 'f.lead_id', 'l.id')
      .where('f.tenant_id', tenantId)
      .orderBy('f.created_at', 'desc')
      .select('f.*', 'l.full_name as lead_name');
    if (lead_id) q = q.andWhere('f.lead_id', lead_id as string);
    if (status) q = q.andWhere('f.status', status as string);
    const followups = await q;
    res.status(200).json({ status: 'success', data: { followups } });
  }

  async createFollowup(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.ensureTenant(req);
    const userId = req.user?.userId || req.user?.id || null;
    const { lead_id, channel, message, due_at } = req.body || {};
    if (!lead_id || !message) throw new ValidationError('lead_id and message are required');

    const lead = await db('crm_leads').where({ id: lead_id, tenant_id: tenantId }).first();
    if (!lead) throw new ValidationError('Lead not found');

    const selectedChannel = (channel || 'sms').toString();

    let [followup] = await db('crm_followups')
      .insert({
        tenant_id: tenantId,
        lead_id,
        channel: selectedChannel,
        message,
        due_at: due_at || null,
        status: 'pending',
        created_by_user_id: userId,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    if (selectedChannel === 'email') {
      const recipientEmail = (lead.email || '').toString().trim();
      if (!recipientEmail) {
        throw new ValidationError('Lead has no email address');
      }

      try {
        await sendEmail({
          to: recipientEmail,
          subject: `מעקב מהמזכירות - ${lead.full_name || 'Lead'}`,
          template: 'crm-followup',
          data: {
            leadName: lead.full_name || 'Lead',
            message,
          },
        });

        const [updated] = await db('crm_followups')
          .where({ id: followup.id, tenant_id: tenantId })
          .update({
            status: 'completed',
            completed_at: new Date(),
            updated_at: new Date(),
          })
          .returning('*');
        if (updated) followup = updated;
      } catch (_error) {
        await db('crm_followups')
          .where({ id: followup.id, tenant_id: tenantId })
          .update({
            status: 'failed',
            updated_at: new Date(),
          });
        throw new ValidationError('Failed to send email follow-up');
      }
    }

    res.status(201).json({ status: 'success', data: { followup } });
  }

  async completeFollowup(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.ensureTenant(req);
    const { id } = req.params;
    const [followup] = await db('crm_followups')
      .where({ id, tenant_id: tenantId })
      .update({
        status: 'completed',
        completed_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    if (!followup) throw new ValidationError('Follow-up not found');
    res.status(200).json({ status: 'success', data: { followup } });
  }

  async listTemplates(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.ensureTenant(req);
    const channel = req.query.channel as string | undefined;
    let q = db('communication_templates').where({ tenant_id: tenantId, is_active: true }).orderBy('created_at', 'desc');
    if (channel) q = q.andWhere({ channel });
    const templates = await q.select('*');
    res.status(200).json({ status: 'success', data: { templates } });
  }

  async createTemplate(req: Request, res: Response): Promise<void> {
    const role = req.user?.role || '';
    if (!TEMPLATE_ADMIN_ROLES.includes(role)) {
      throw new AuthorizationError('Only admin/developer can create templates');
    }
    const tenantId = this.ensureTenant(req);
    const { name, channel, subject, body } = req.body || {};
    if (!name || !body) throw new ValidationError('name and body are required');
    const [template] = await db('communication_templates')
      .insert({
        tenant_id: tenantId,
        name,
        channel: channel || 'sms',
        subject: subject || null,
        body,
        is_active: true,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    res.status(201).json({ status: 'success', data: { template } });
  }
}

