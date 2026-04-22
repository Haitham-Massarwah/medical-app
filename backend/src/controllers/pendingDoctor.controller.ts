import { Request, Response, NextFunction } from 'express';
import { asyncHandler, NotFoundError, ValidationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';

/**
 * Self-service doctor registrations that still need admin/developer activation.
 */
export class PendingDoctorController {
  listPending = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const tenantId = req.tenantId!;

    const rows = await db('users as u')
      .join('doctors as d', 'd.user_id', 'u.id')
      .where('u.tenant_id', tenantId)
      .andWhere('u.role', 'doctor')
      .andWhere('d.is_active', false)
      .andWhereRaw("coalesce(u.metadata->>'creation_source','') <> 'staff_created'")
      .select(
        'u.id',
        'u.email',
        'u.first_name',
        'u.last_name',
        'u.phone',
        'u.created_at',
        'd.id as doctor_id',
        'd.specialty',
        'd.business_file_id'
      )
      .orderBy('u.created_at', 'asc');

    res.status(200).json({
      status: 'success',
      data: { pending: rows },
    });
  });

  approve = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const tenantId = req.tenantId!;
    const { userId } = req.params;

    const user = await db('users').where({ id: userId, tenant_id: tenantId, role: 'doctor' }).first();
    if (!user) {
      throw new NotFoundError('User');
    }

    const doctor = await db('doctors').where({ user_id: userId, tenant_id: tenantId }).first();
    if (!doctor) {
      throw new ValidationError('Doctor profile not found');
    }

    const columnsResult = await db('information_schema.columns')
      .where({ table_name: 'users' })
      .select('column_name');
    const columns = new Set(columnsResult.map((r: any) => (r.column_name as string)));
    const hasIsActive = columns.has('is_active');

    const userPatch: Record<string, unknown> = {
      updated_at: new Date(),
      is_email_verified: true,
    };
    if (hasIsActive) {
      userPatch.is_active = true;
    }

    await db('users').where({ id: userId }).update(userPatch);

    await db('doctors').where({ id: doctor.id }).update({
      is_active: true,
      updated_at: new Date(),
    });

    logger.info(`Doctor registration approved: user ${userId}`);

    res.status(200).json({
      status: 'success',
      message: 'Doctor approved successfully',
      data: { user_id: userId, doctor_id: doctor.id },
    });
  });
}
