import { Request, Response } from 'express';
import db from '../config/database';
import { asyncHandler, AuthorizationError, NotFoundError } from '../middleware/errorHandler';

const canManageTemplates = (role: string) => ['developer', 'admin', 'doctor'].includes(role);
const canManageEmployees = (role: string) => ['developer', 'admin', 'doctor'].includes(role);

export class OperationsController {
  listReceiptTemplates = asyncHandler(async (req: Request, res: Response) => {
    const tenantId = req.tenantId!;
    const rows = await db('receipt_templates')
      .where({ tenant_id: tenantId })
      .orderBy('updated_at', 'desc');
    res.status(200).json({ status: 'success', data: rows });
  });

  createReceiptTemplate = asyncHandler(async (req: Request, res: Response) => {
    const role = req.user!.role;
    if (!canManageTemplates(role)) throw new AuthorizationError('Insufficient permissions');
    const tenantId = req.tenantId!;
    const userId = req.user!.userId;
    const payload = {
      tenant_id: tenantId,
      owner_user_id: role === 'doctor' ? userId : (req.body.owner_user_id || null),
      template_scope: req.body.template_scope || (role === 'doctor' ? 'personal' : 'clinic'),
      template_name: req.body.template_name,
      description: req.body.description || null,
      content_format: req.body.content_format || 'html',
      template_content: req.body.template_content,
      is_default: req.body.is_default === true,
      is_active: req.body.is_active !== false,
      created_by: userId,
      updated_by: userId,
    };
    const [row] = await db('receipt_templates').insert(payload).returning('*');
    res.status(201).json({ status: 'success', data: row });
  });

  updateReceiptTemplate = asyncHandler(async (req: Request, res: Response) => {
    const role = req.user!.role;
    if (!canManageTemplates(role)) throw new AuthorizationError('Insufficient permissions');
    const tenantId = req.tenantId!;
    const id = req.params.id;
    const existing = await db('receipt_templates').where({ id, tenant_id: tenantId }).first();
    if (!existing) throw new NotFoundError('Receipt template');
    if (role === 'doctor' && existing.owner_user_id !== req.user!.userId) {
      throw new AuthorizationError('Doctor can update only own templates');
    }
    const [row] = await db('receipt_templates')
      .where({ id, tenant_id: tenantId })
      .update({
        template_name: req.body.template_name ?? existing.template_name,
        description: req.body.description ?? existing.description,
        content_format: req.body.content_format ?? existing.content_format,
        template_content: req.body.template_content ?? existing.template_content,
        is_default: req.body.is_default ?? existing.is_default,
        is_active: req.body.is_active ?? existing.is_active,
        updated_by: req.user!.userId,
        updated_at: new Date(),
      })
      .returning('*');
    res.status(200).json({ status: 'success', data: row });
  });

  deleteReceiptTemplate = asyncHandler(async (req: Request, res: Response) => {
    const role = req.user!.role;
    if (!canManageTemplates(role)) throw new AuthorizationError('Insufficient permissions');
    const tenantId = req.tenantId!;
    const id = req.params.id;
    const existing = await db('receipt_templates').where({ id, tenant_id: tenantId }).first();
    if (!existing) throw new NotFoundError('Receipt template');
    if (role === 'doctor' && existing.owner_user_id !== req.user!.userId) {
      throw new AuthorizationError('Doctor can delete only own templates');
    }
    await db('receipt_templates').where({ id, tenant_id: tenantId }).delete();
    res.status(200).json({ status: 'success', message: 'Deleted' });
  });

  listReportTemplates = asyncHandler(async (req: Request, res: Response) => {
    const tenantId = req.tenantId!;
    const rows = await db('report_templates')
      .where({ tenant_id: tenantId })
      .orderBy('updated_at', 'desc');
    res.status(200).json({ status: 'success', data: rows });
  });

  createReportTemplate = asyncHandler(async (req: Request, res: Response) => {
    const role = req.user!.role;
    if (!canManageTemplates(role)) throw new AuthorizationError('Insufficient permissions');
    const tenantId = req.tenantId!;
    const userId = req.user!.userId;
    const payload = {
      tenant_id: tenantId,
      owner_user_id: role === 'doctor' ? userId : (req.body.owner_user_id || null),
      template_scope: req.body.template_scope || (role === 'doctor' ? 'personal' : 'clinic'),
      template_name: req.body.template_name,
      description: req.body.description || null,
      content_format: req.body.content_format || 'html',
      template_content: req.body.template_content,
      is_default: req.body.is_default === true,
      is_active: req.body.is_active !== false,
      created_by: userId,
      updated_by: userId,
    };
    const [row] = await db('report_templates').insert(payload).returning('*');
    res.status(201).json({ status: 'success', data: row });
  });

  updateReportTemplate = asyncHandler(async (req: Request, res: Response) => {
    const role = req.user!.role;
    if (!canManageTemplates(role)) throw new AuthorizationError('Insufficient permissions');
    const tenantId = req.tenantId!;
    const id = req.params.id;
    const existing = await db('report_templates').where({ id, tenant_id: tenantId }).first();
    if (!existing) throw new NotFoundError('Report template');
    if (role === 'doctor' && existing.owner_user_id !== req.user!.userId) {
      throw new AuthorizationError('Doctor can update only own templates');
    }
    const [row] = await db('report_templates')
      .where({ id, tenant_id: tenantId })
      .update({
        template_name: req.body.template_name ?? existing.template_name,
        description: req.body.description ?? existing.description,
        content_format: req.body.content_format ?? existing.content_format,
        template_content: req.body.template_content ?? existing.template_content,
        is_default: req.body.is_default ?? existing.is_default,
        is_active: req.body.is_active ?? existing.is_active,
        updated_by: req.user!.userId,
        updated_at: new Date(),
      })
      .returning('*');
    res.status(200).json({ status: 'success', data: row });
  });

  deleteReportTemplate = asyncHandler(async (req: Request, res: Response) => {
    const role = req.user!.role;
    if (!canManageTemplates(role)) throw new AuthorizationError('Insufficient permissions');
    const tenantId = req.tenantId!;
    const id = req.params.id;
    const existing = await db('report_templates').where({ id, tenant_id: tenantId }).first();
    if (!existing) throw new NotFoundError('Report template');
    if (role === 'doctor' && existing.owner_user_id !== req.user!.userId) {
      throw new AuthorizationError('Doctor can delete only own templates');
    }
    await db('report_templates').where({ id, tenant_id: tenantId }).delete();
    res.status(200).json({ status: 'success', message: 'Deleted' });
  });

  listEmployees = asyncHandler(async (req: Request, res: Response) => {
    if (!canManageEmployees(req.user!.role)) throw new AuthorizationError('Insufficient permissions');
    const rows = await db('employees').where({ tenant_id: req.tenantId! }).orderBy('created_at', 'desc');
    res.status(200).json({ status: 'success', data: rows });
  });

  createEmployee = asyncHandler(async (req: Request, res: Response) => {
    if (!canManageEmployees(req.user!.role)) throw new AuthorizationError('Insufficient permissions');
    const [row] = await db('employees')
      .insert({
        tenant_id: req.tenantId!,
        user_id: req.body.user_id || null,
        employee_code: req.body.employee_code || null,
        job_title: req.body.job_title || null,
        employment_type: req.body.employment_type || null,
        start_date: req.body.start_date || null,
        end_date: req.body.end_date || null,
        is_active: req.body.is_active !== false,
      })
      .returning('*');
    res.status(201).json({ status: 'success', data: row });
  });

  updateEmployee = asyncHandler(async (req: Request, res: Response) => {
    if (!canManageEmployees(req.user!.role)) throw new AuthorizationError('Insufficient permissions');
    const id = req.params.id;
    const existing = await db('employees').where({ id, tenant_id: req.tenantId! }).first();
    if (!existing) throw new NotFoundError('Employee');
    const [row] = await db('employees')
      .where({ id, tenant_id: req.tenantId! })
      .update({
        employee_code: req.body.employee_code ?? existing.employee_code,
        job_title: req.body.job_title ?? existing.job_title,
        employment_type: req.body.employment_type ?? existing.employment_type,
        start_date: req.body.start_date ?? existing.start_date,
        end_date: req.body.end_date ?? existing.end_date,
        is_active: req.body.is_active ?? existing.is_active,
        updated_at: new Date(),
      })
      .returning('*');
    res.status(200).json({ status: 'success', data: row });
  });

  deleteEmployee = asyncHandler(async (req: Request, res: Response) => {
    if (!canManageEmployees(req.user!.role)) throw new AuthorizationError('Insufficient permissions');
    const id = req.params.id;
    const existing = await db('employees').where({ id, tenant_id: req.tenantId! }).first();
    if (!existing) throw new NotFoundError('Employee');
    await db('employees').where({ id, tenant_id: req.tenantId! }).delete();
    res.status(200).json({ status: 'success', message: 'Deleted' });
  });

  listEmployeeWorkHours = asyncHandler(async (req: Request, res: Response) => {
    if (!canManageEmployees(req.user!.role)) throw new AuthorizationError('Insufficient permissions');
    const rows = await db('employee_work_hours')
      .where({ tenant_id: req.tenantId! })
      .orderBy('work_date', 'desc');
    res.status(200).json({ status: 'success', data: rows });
  });

  upsertEmployeeWorkHours = asyncHandler(async (req: Request, res: Response) => {
    if (!canManageEmployees(req.user!.role)) throw new AuthorizationError('Insufficient permissions');
    const tenantId = req.tenantId!;
    const employee_id = req.body.employee_id;
    const work_date = req.body.work_date;
    const checkIn = req.body.check_in_time ? new Date(req.body.check_in_time) : null;
    const checkOut = req.body.check_out_time ? new Date(req.body.check_out_time) : null;
    const breakMinutes = Number(req.body.break_minutes || 0);
    const totalMinutes = checkIn && checkOut
      ? Math.max(0, Math.round((checkOut.getTime() - checkIn.getTime()) / 60000) - breakMinutes)
      : req.body.total_minutes || null;

    const existing = await db('employee_work_hours')
      .where({ tenant_id: tenantId, employee_id, work_date })
      .first();
    if (existing) {
      const [row] = await db('employee_work_hours')
        .where({ id: existing.id })
        .update({
          check_in_time: checkIn,
          check_out_time: checkOut,
          break_minutes: breakMinutes,
          total_minutes: totalMinutes,
          notes: req.body.notes ?? existing.notes,
          recorded_by: req.user!.userId,
          updated_at: new Date(),
        })
        .returning('*');
      return res.status(200).json({ status: 'success', data: row });
    }

    const [row] = await db('employee_work_hours')
      .insert({
        tenant_id: tenantId,
        employee_id,
        work_date,
        check_in_time: checkIn,
        check_out_time: checkOut,
        break_minutes: breakMinutes,
        total_minutes: totalMinutes,
        notes: req.body.notes || null,
        recorded_by: req.user!.userId,
      })
      .returning('*');
    return res.status(201).json({ status: 'success', data: row });
  });

  deleteEmployeeWorkHours = asyncHandler(async (req: Request, res: Response) => {
    if (!canManageEmployees(req.user!.role)) throw new AuthorizationError('Insufficient permissions');
    const id = req.params.id;
    const existing = await db('employee_work_hours').where({ id, tenant_id: req.tenantId! }).first();
    if (!existing) throw new NotFoundError('Employee work hours');
    await db('employee_work_hours').where({ id, tenant_id: req.tenantId! }).delete();
    res.status(200).json({ status: 'success', message: 'Deleted' });
  });
}

