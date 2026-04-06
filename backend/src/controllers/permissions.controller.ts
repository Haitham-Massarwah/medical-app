import { Request, Response, NextFunction } from 'express';
import { asyncHandler } from '../middleware/errorHandler';
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
}


