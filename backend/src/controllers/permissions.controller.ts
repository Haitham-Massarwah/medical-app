import { Request, Response, NextFunction } from 'express';
import { asyncHandler, AuthorizationError } from '../middleware/errorHandler';
import db from '../config/database';

export class PermissionsController {
  /**
   * Get system permissions
   * GET /api/v1/admin/permissions
   */
  getPermissions = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;

    // Get permissions from database (or default if not set)
    let permissions = await db('system_permissions')
      .where({ tenant_id: tenantId })
      .first();

    if (!permissions) {
      // Create default permissions
      const [newPermissions] = await db('system_permissions')
        .insert({
          tenant_id: tenantId,
          doctor_payments_enabled: true,
          patient_payments_enabled: true,
          sms_enabled: true,
          email_notifications_enabled: true,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');
      permissions = newPermissions;
    }

    res.status(200).json({
      status: 'success',
      data: permissions,
    });
  });

  /**
   * Update system permissions
   * PUT /api/v1/admin/permissions
   */
  updatePermissions = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    if (req.user?.role !== 'developer') {
      throw new AuthorizationError('Only the developer role may change system-wide permissions');
    }
    const tenantId = req.tenantId!;
    const {
      doctor_payments_enabled,
      patient_payments_enabled,
      sms_enabled,
      email_notifications_enabled,
    } = req.body;

    // Check if permissions exist
    let permissions = await db('system_permissions')
      .where({ tenant_id: tenantId })
      .first();

    if (!permissions) {
      // Create new permissions
      const [newPermissions] = await db('system_permissions')
        .insert({
          tenant_id: tenantId,
          doctor_payments_enabled: doctor_payments_enabled ?? true,
          patient_payments_enabled: patient_payments_enabled ?? true,
          sms_enabled: sms_enabled ?? true,
          email_notifications_enabled: email_notifications_enabled ?? true,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');
      permissions = newPermissions;
    } else {
      // Update existing permissions
      const updateData: any = {
        updated_at: new Date(),
      };

      if (doctor_payments_enabled !== undefined) {
        updateData.doctor_payments_enabled = doctor_payments_enabled;
      }
      if (patient_payments_enabled !== undefined) {
        updateData.patient_payments_enabled = patient_payments_enabled;
      }
      if (sms_enabled !== undefined) {
        updateData.sms_enabled = sms_enabled;
      }
      if (email_notifications_enabled !== undefined) {
        updateData.email_notifications_enabled = email_notifications_enabled;
      }

      await db('system_permissions')
        .where({ tenant_id: tenantId })
        .update(updateData);

      permissions = await db('system_permissions')
        .where({ tenant_id: tenantId })
        .first();
    }

    res.status(200).json({
      status: 'success',
      data: permissions,
      message: 'Permissions updated successfully',
    });
  });

  /**
   * Get account-level permissions
   * GET /api/v1/admin/permissions/accounts
   */
  listAccountPermissions = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const role = req.user?.role || '';

    let q = db('users as u')
      .leftJoin('user_account_permissions as p', function () {
        this.on('u.id', '=', 'p.user_id').andOn('p.tenant_id', '=', db.raw('?', [tenantId]));
      })
      .where('u.tenant_id', tenantId);

    // Admins manage per-account permissions for doctors and patients only (not system admins).
    if (role === 'admin') {
      q = q.whereIn('u.role', ['doctor', 'patient']);
    }

    const rows = await q
      .select(
        'u.id',
        'u.first_name',
        'u.last_name',
        'u.email',
        'u.role',
        'p.can_manage_users',
        'p.can_manage_doctors',
        'p.can_view_payments',
        'p.can_manage_payments',
        'p.can_manage_permissions',
        'p.can_view_audit'
      )
      .orderBy('u.created_at', 'desc');

    res.status(200).json({
      status: 'success',
      data: rows,
    });
  });

  /**
   * Update account-level permissions
   * PUT /api/v1/admin/permissions/accounts/:userId
   */
  upsertAccountPermissions = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const { userId } = req.params;
    const actorRole = req.user?.role || '';

    const targetUser = await db('users')
      .where({ id: userId, tenant_id: tenantId })
      .first();

    if (!targetUser) {
      return res.status(404).json({ status: 'error', message: 'User not found' });
    }

    if (actorRole === 'admin') {
      if (!['doctor', 'patient'].includes(String(targetUser.role))) {
        throw new AuthorizationError('Admin may change permissions only for doctor and patient accounts');
      }
    }

    const payload = {
      can_manage_users: req.body.can_manage_users === true,
      can_manage_doctors: req.body.can_manage_doctors === true,
      can_view_payments: req.body.can_view_payments === true,
      can_manage_payments: req.body.can_manage_payments === true,
      can_manage_permissions:
        actorRole === 'developer' ? req.body.can_manage_permissions === true : false,
      can_view_audit: req.body.can_view_audit === true,
      updated_at: new Date(),
    };

    if (actorRole === 'admin' && payload.can_manage_permissions) {
      payload.can_manage_permissions = false;
    }

    const existing = await db('user_account_permissions')
      .where({ tenant_id: tenantId, user_id: userId })
      .first();

    if (!existing) {
      await db('user_account_permissions').insert({
        id: db.raw('gen_random_uuid()'),
        tenant_id: tenantId,
        user_id: userId,
        ...payload,
        created_at: new Date(),
      });
    } else {
      await db('user_account_permissions')
        .where({ tenant_id: tenantId, user_id: userId })
        .update(payload);
    }

    const updated = await db('user_account_permissions')
      .where({ tenant_id: tenantId, user_id: userId })
      .first();

    res.status(200).json({
      status: 'success',
      message: 'Account permissions updated successfully',
      data: updated,
    });
  });
}


