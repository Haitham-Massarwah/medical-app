import { Request, Response } from 'express';
import db from '../config/database';
import { AuthorizationError, ValidationError } from '../middleware/errorHandler';

const STAFF_ROLES = ['admin', 'developer', 'doctor', 'receptionist', 'paramedical'];

export class FormsController {
  async getTemplates(req: Request, res: Response): Promise<void> {
    const tenantId = req.tenantId;
    const role = req.user?.role || '';
    const includeInactive = req.query.includeInactive === 'true';

    if (!tenantId) {
      res.status(200).json({ status: 'success', data: { templates: [] } });
      return;
    }

    let query = db('form_templates')
      .where({ tenant_id: tenantId })
      .orderBy('created_at', 'desc');

    if (!includeInactive || !['admin', 'developer'].includes(role)) {
      query = query.andWhere({ is_active: true });
    }

    const templates = await query.select('*');
    res.status(200).json({ status: 'success', data: { templates } });
  }

  async createTemplate(req: Request, res: Response): Promise<void> {
    const tenantId = req.tenantId;
    if (!tenantId) {
      throw new ValidationError('Tenant is required');
    }
    const role = req.user?.role || '';
    if (!['admin', 'developer'].includes(role)) {
      throw new AuthorizationError('Only admin/developer can create templates');
    }

    const { title, form_type, schema_json, is_active } = req.body || {};
    if (!title || typeof title !== 'string') {
      throw new ValidationError('title is required');
    }

    const [template] = await db('form_templates')
      .insert({
        tenant_id: tenantId,
        title: title.trim(),
        form_type: (form_type || 'intake').toString(),
        schema_json: schema_json && typeof schema_json === 'object' ? schema_json : {},
        is_active: is_active !== false,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    res.status(201).json({ status: 'success', data: { template } });
  }

  async submitForm(req: Request, res: Response): Promise<void> {
    const tenantId = req.tenantId;
    const userId = req.user?.userId || req.user?.id;
    if (!tenantId || !userId) {
      throw new ValidationError('Tenant and user are required');
    }

    const {
      template_id,
      patient_user_id,
      answers_json,
      consent_name,
      signature_data,
      pdf_url,
    } = req.body || {};

    if (!template_id) {
      throw new ValidationError('template_id is required');
    }

    const template = await db('form_templates')
      .where({ id: template_id, tenant_id: tenantId, is_active: true })
      .first();
    if (!template) {
      throw new ValidationError('Template not found or inactive');
    }

    const role = req.user?.role || '';
    const targetPatientUserId = patient_user_id || userId;
    if (!STAFF_ROLES.includes(role) && targetPatientUserId !== userId) {
      throw new AuthorizationError('Patients can submit only for themselves');
    }

    const [submission] = await db('form_submissions')
      .insert({
        tenant_id: tenantId,
        template_id,
        patient_user_id: targetPatientUserId,
        submitted_by_user_id: userId,
        answers_json: answers_json && typeof answers_json === 'object' ? answers_json : {},
        consent_name: consent_name || null,
        signature_data: signature_data || null,
        signed_at: signature_data ? new Date() : null,
        pdf_url: pdf_url || null,
        status: 'submitted',
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    res.status(201).json({ status: 'success', data: { submission } });
  }

  async getMySubmissions(req: Request, res: Response): Promise<void> {
    const tenantId = req.tenantId;
    const userId = req.user?.userId || req.user?.id;
    if (!tenantId || !userId) {
      throw new ValidationError('Tenant and user are required');
    }

    const submissions = await db('form_submissions')
      .where({ tenant_id: tenantId, patient_user_id: userId })
      .orderBy('created_at', 'desc')
      .select('*');

    res.status(200).json({ status: 'success', data: { submissions } });
  }

  async listSubmissions(req: Request, res: Response): Promise<void> {
    const tenantId = req.tenantId;
    if (!tenantId) {
      res.status(200).json({ status: 'success', data: { submissions: [] } });
      return;
    }
    const role = req.user?.role || '';
    if (!STAFF_ROLES.includes(role)) {
      throw new AuthorizationError('Insufficient permissions');
    }

    const submissions = await db('form_submissions as fs')
      .leftJoin('form_templates as ft', 'fs.template_id', 'ft.id')
      .leftJoin('users as u', 'fs.patient_user_id', 'u.id')
      .where('fs.tenant_id', tenantId)
      .orderBy('fs.created_at', 'desc')
      .select(
        'fs.*',
        'ft.title as template_title',
        db.raw("TRIM(CONCAT(COALESCE(u.first_name,''), ' ', COALESCE(u.last_name,''))) as patient_name")
      );

    res.status(200).json({ status: 'success', data: { submissions } });
  }
}

