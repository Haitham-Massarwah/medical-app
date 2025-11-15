import { Request, Response, NextFunction } from 'express';
import { asyncHandler, NotFoundError, ValidationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';

export class TenantController {
  /**
   * Get all tenants (Developer only)
   * GET /api/v1/tenants
   */
  getAllTenants = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { page, limit, offset } = (req as any).pagination;
    const { search, is_active } = req.query;

    let query = db('tenants').where('deleted_at', null);

    // Search by name or subdomain
    if (search) {
      query = query.andWhere(function() {
        this.where('name', 'ilike', `%${search}%`)
          .orWhere('subdomain', 'ilike', `%${search}%`);
      });
    }

    // Filter by status
    if (is_active !== undefined) {
      query = query.andWhere({ is_active: is_active === 'true' });
    }

    const [{ count }] = await query.clone().count('* as count');

    const tenants = await query
      .orderBy('created_at', 'desc')
      .limit(limit)
      .offset(offset);

    res.status(200).json({
      status: 'success',
      data: {
        tenants,
        pagination: {
          page,
          limit,
          total: parseInt(count as string),
          pages: Math.ceil(parseInt(count as string) / limit),
        },
      },
    });
  });

  /**
   * Get current tenant
   * GET /api/v1/tenants/current
   */
  getCurrentTenant = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;

    const tenant = await db('tenants')
      .where({ id: tenantId })
      .andWhere('deleted_at', null)
      .first();

    if (!tenant) {
      throw new NotFoundError('Tenant');
    }

    res.status(200).json({
      status: 'success',
      data: {
        tenant,
      },
    });
  });

  /**
   * Get tenant by ID
   * GET /api/v1/tenants/:id
   */
  getTenantById = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;

    const tenant = await db('tenants')
      .where({ id })
      .andWhere('deleted_at', null)
      .first();

    if (!tenant) {
      throw new NotFoundError('Tenant');
    }

    res.status(200).json({
      status: 'success',
      data: {
        tenant,
      },
    });
  });

  /**
   * Create tenant
   * POST /api/v1/tenants
   */
  createTenant = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const {
      name,
      subdomain,
      contact_email,
      contact_phone,
      address,
      city,
      country,
      timezone = 'UTC',
      plan = 'starter',
    } = req.body;

    // Check if subdomain is already taken
    const existing = await db('tenants')
      .where({ subdomain })
      .andWhere('deleted_at', null)
      .first();

    if (existing) {
      throw new ValidationError('Subdomain is already taken');
    }

    const [tenant] = await db('tenants')
      .insert({
        name,
        subdomain,
        contact_email,
        contact_phone,
        address,
        city,
        country,
        timezone,
        plan,
        is_active: true,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    logger.info(`Tenant created: ${tenant.id} (${name})`);

    res.status(201).json({
      status: 'success',
      message: 'Tenant created successfully',
      data: {
        tenant,
      },
    });
  });

  /**
   * Update tenant
   * PUT /api/v1/tenants/:id
   */
  updateTenant = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;

    const updateData = {
      ...req.body,
      updated_at: new Date(),
    };

    const [tenant] = await db('tenants')
      .where({ id })
      .andWhere('deleted_at', null)
      .update(updateData)
      .returning('*');

    if (!tenant) {
      throw new NotFoundError('Tenant');
    }

    logger.info(`Tenant updated: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Tenant updated successfully',
      data: {
        tenant,
      },
    });
  });

  /**
   * Update tenant settings
   * PUT /api/v1/tenants/:id/settings
   */
  updateSettings = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;

    const settings = {
      booking_advance_days: req.body.booking_advance_days,
      booking_buffer_minutes: req.body.booking_buffer_minutes,
      cancellation_hours: req.body.cancellation_hours,
      default_appointment_duration: req.body.default_appointment_duration,
      working_hours_start: req.body.working_hours_start,
      working_hours_end: req.body.working_hours_end,
      enable_online_payments: req.body.enable_online_payments,
      enable_sms_reminders: req.body.enable_sms_reminders,
      enable_email_reminders: req.body.enable_email_reminders,
      enable_whatsapp_reminders: req.body.enable_whatsapp_reminders,
    };

    const [tenant] = await db('tenants')
      .where({ id })
      .andWhere('deleted_at', null)
      .update({
        settings: JSON.stringify(settings),
        updated_at: new Date(),
      })
      .returning('*');

    if (!tenant) {
      throw new NotFoundError('Tenant');
    }

    logger.info(`Tenant settings updated: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Tenant settings updated successfully',
      data: {
        tenant,
      },
    });
  });

  /**
   * Update tenant branding
   * PUT /api/v1/tenants/:id/branding
   */
  updateBranding = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { logo_url, primary_color, secondary_color, favicon_url } = req.body;

    const branding = {
      logo_url,
      primary_color,
      secondary_color,
      favicon_url,
    };

    const [tenant] = await db('tenants')
      .where({ id })
      .andWhere('deleted_at', null)
      .update({
        branding: JSON.stringify(branding),
        updated_at: new Date(),
      })
      .returning('*');

    if (!tenant) {
      throw new NotFoundError('Tenant');
    }

    logger.info(`Tenant branding updated: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Tenant branding updated successfully',
      data: {
        tenant,
      },
    });
  });

  /**
   * Update tenant plan
   * PUT /api/v1/tenants/:id/plan
   */
  updatePlan = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { plan, billing_cycle = 'monthly' } = req.body;

    const [tenant] = await db('tenants')
      .where({ id })
      .andWhere('deleted_at', null)
      .update({
        plan,
        billing_cycle,
        updated_at: new Date(),
      })
      .returning('*');

    if (!tenant) {
      throw new NotFoundError('Tenant');
    }

    logger.info(`Tenant plan updated: ${id} -> ${plan}`);

    res.status(200).json({
      status: 'success',
      message: 'Tenant plan updated successfully',
      data: {
        tenant,
      },
    });
  });

  /**
   * Update tenant status
   * PUT /api/v1/tenants/:id/status
   */
  updateStatus = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { is_active, reason } = req.body;

    const [tenant] = await db('tenants')
      .where({ id })
      .andWhere('deleted_at', null)
      .update({
        is_active,
        updated_at: new Date(),
      })
      .returning('*');

    if (!tenant) {
      throw new NotFoundError('Tenant');
    }

    logger.info(`Tenant status updated: ${id} -> ${is_active ? 'active' : 'inactive'}`);

    res.status(200).json({
      status: 'success',
      message: `Tenant ${is_active ? 'activated' : 'suspended'} successfully`,
      data: {
        tenant,
      },
    });
  });

  /**
   * Delete tenant (soft delete)
   * DELETE /api/v1/tenants/:id
   */
  deleteTenant = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;

    await db('tenants')
      .where({ id })
      .update({
        deleted_at: new Date(),
        updated_at: new Date(),
      });

    logger.info(`Tenant deleted: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Tenant deleted successfully',
    });
  });

  /**
   * Get tenant statistics
   * GET /api/v1/tenants/:id/statistics
   */
  getTenantStatistics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;

    // Get various statistics
    const [userCount] = await db('users')
      .where({ tenant_id: id })
      .andWhere('deleted_at', null)
      .count('* as count');

    const [doctorCount] = await db('doctors')
      .where({ tenant_id: id })
      .andWhere('deleted_at', null)
      .count('* as count');

    const [patientCount] = await db('patients')
      .where({ tenant_id: id })
      .andWhere('deleted_at', null)
      .count('* as count');

    const appointmentCountResult = await db('appointments')
      .where({ tenant_id: id })
      .count('* as count');
    const appointmentCount = appointmentCountResult[0];

    const revenueResult = await db('payments')
      .where({ tenant_id: id })
      .andWhere('status', 'succeeded')
      .sum('amount as total_revenue')
      .first();
    const revenueData = revenueResult;

    res.status(200).json({
      status: 'success',
      data: {
        statistics: {
          total_users: parseInt(userCount.count as string),
          total_doctors: parseInt(doctorCount.count as string),
          total_patients: parseInt(patientCount.count as string),
          total_appointments: parseInt(appointmentCount.count as string),
          total_revenue: revenueData?.total_revenue || 0,
        },
      },
    });
  });
}


