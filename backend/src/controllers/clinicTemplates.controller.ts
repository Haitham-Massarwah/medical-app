import { Request, Response, NextFunction } from 'express';
import path from 'path';
import fs from 'fs';
import db from '../config/database';
import { asyncHandler, AuthorizationError, NotFoundError, ValidationError } from '../middleware/errorHandler';

export class ClinicTemplatesController {
  list = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    const rows = await db('clinic_file_templates')
      .where({ tenant_id: req.tenantId! })
      .orderBy('created_at', 'desc');
    res.status(200).json({ status: 'success', data: rows });
  });

  listAssignments = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    const rows = await db('doctor_template_assignments as a')
      .join('doctors as d', 'a.doctor_id', 'd.id')
      .join('clinic_file_templates as t', 'a.template_id', 't.id')
      .where('a.tenant_id', req.tenantId!)
      .select(
        'a.id',
        'a.doctor_id',
        'a.template_id',
        'a.created_at',
        'd.id as doctor_table_id',
        't.name as template_name',
        't.template_type',
      )
      .orderBy('a.created_at', 'desc');
    res.status(200).json({ status: 'success', data: rows });
  });

  assign = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    const doctorId = req.body?.doctor_id as string;
    const templateId = req.body?.template_id as string;
    if (!doctorId || !templateId) throw new ValidationError('doctor_id and template_id are required');
    const doc = await db('doctors').where({ id: doctorId, tenant_id: req.tenantId! }).first();
    if (!doc) throw new ValidationError('Doctor not found');
    const tpl = await db('clinic_file_templates')
      .where({ id: templateId, tenant_id: req.tenantId! })
      .first();
    if (!tpl) throw new ValidationError('Template not found');
    await db('doctor_template_assignments')
      .insert({
        tenant_id: req.tenantId!,
        doctor_id: doctorId,
        template_id: templateId,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .onConflict(['doctor_id', 'template_id'])
      .ignore();
    res.status(200).json({ status: 'success', message: 'Assigned' });
  });

  unassign = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    const id = req.params.id;
    const n = await db('doctor_template_assignments').where({ id, tenant_id: req.tenantId! }).delete();
    if (!n) throw new NotFoundError('Assignment');
    res.status(200).json({ status: 'success', message: 'Removed' });
  });

  upload = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    const file = req.file;
    if (!file) throw new ValidationError('file is required');
    const templateType = String(req.body?.template_type || 'pdf').slice(0, 30);
    const name = String(req.body?.name || file.originalname).slice(0, 255);
    const description = req.body?.description ? String(req.body.description).slice(0, 2000) : null;
    const rel = path.join('clinic-templates', req.tenantId!, file.filename).replace(/\\/g, '/');
    const userId = (req.user?.userId || req.user?.id) as string | undefined;
    const [row] = await db('clinic_file_templates')
      .insert({
        tenant_id: req.tenantId!,
        template_type: templateType,
        name,
        description,
        storage_path: rel,
        original_filename: file.originalname,
        mime_type: file.mimetype,
        file_size: file.size,
        created_by: userId || null,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    res.status(201).json({ status: 'success', data: row });
  });

  remove = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    const row = await db('clinic_file_templates')
      .where({ id: req.params.id, tenant_id: req.tenantId! })
      .first();
    if (!row) throw new NotFoundError('Template');
    const abs = path.resolve(process.cwd(), 'uploads', row.storage_path);
    const uploadsRoot = path.resolve(process.cwd(), 'uploads');
    if (!abs.startsWith(uploadsRoot)) throw new ValidationError('Invalid path');
    if (fs.existsSync(abs)) fs.unlinkSync(abs);
    await db('doctor_template_assignments').where({ template_id: row.id }).delete();
    await db('clinic_file_templates').where({ id: row.id }).delete();
    res.status(200).json({ status: 'success', message: 'Deleted' });
  });

  download = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const role = req.user?.role || '';
    if (!['developer', 'admin'].includes(role)) {
      throw new AuthorizationError('Insufficient permissions');
    }
    const row = await db('clinic_file_templates')
      .where({ id: req.params.id, tenant_id: req.tenantId! })
      .first();
    if (!row) throw new NotFoundError('Template');
    const abs = path.resolve(process.cwd(), 'uploads', row.storage_path);
    const uploadsRoot = path.resolve(process.cwd(), 'uploads');
    if (!abs.startsWith(uploadsRoot) || !fs.existsSync(abs)) throw new NotFoundError('File');
    res.download(abs, row.original_filename as string);
  });
}

export const clinicTemplatesController = new ClinicTemplatesController();
