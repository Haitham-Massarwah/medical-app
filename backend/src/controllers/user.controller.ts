import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { asyncHandler, NotFoundError, AuthorizationError, ValidationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';
import { sendEmail } from '../services/email.service';

export class UserController {
  /**
   * Get all users
   * GET /api/v1/users
   */
  getAllUsers = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { page, limit, offset } = (req as any).pagination;
    const { search, role, is_active } = req.query;
    const tenantId = req.tenantId!;

    // Some deployments may have slightly different user table schemas.
    // Detect optional columns to avoid runtime 500s (e.g., is_active).
    const columnsResult = await db('information_schema.columns')
      .where({ table_name: 'users' })
      .select('column_name');
    const columns = new Set(columnsResult.map((r: any) => (r.column_name as string)));
    const hasIsActive = columns.has('is_active');

    let query = db('users')
      .where({ tenant_id: tenantId });

    // Search by name or email
    if (search) {
      query = query.andWhere(function() {
        this.where('first_name', 'ilike', `%${search}%`)
          .orWhere('last_name', 'ilike', `%${search}%`)
          .orWhere('email', 'ilike', `%${search}%`);
      });
    }

    // Filter by role
    if (role) {
      query = query.andWhere({ role });
    }

    // Filter by status
    if (is_active !== undefined && hasIsActive) {
      query = query.andWhere({ is_active: is_active === 'true' });
    }

    // Get total count
    const [{ count }] = await query.clone().count('* as count');

    // Get users
    const users = await query
      // NOTE: Some deployments do not include `is_active` in `users`.
      .select([
        'id',
        'email',
        'first_name',
        'last_name',
        'phone',
        'role',
        ...(hasIsActive ? (['is_active'] as const) : []),
        'is_email_verified',
        'last_login_at',
        'created_at',
      ])
      .orderBy('created_at', 'desc')
      .limit(limit)
      .offset(offset);

    res.status(200).json({
      status: 'success',
      data: {
        users,
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
   * Create staff user (e.g. receptionist). Admin/Developer only. SRS Rev 02 §2.1.
   * POST /api/v1/users
   */
  createStaffUser = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const { email, password, first_name, last_name, phone, role } = req.body;

    if (role !== 'receptionist') {
      throw new ValidationError('This endpoint currently supports only the receptionist role');
    }
    if (!email || !password || !first_name || !last_name) {
      throw new ValidationError('email, password, first_name, and last_name are required');
    }

    const existing = await db('users').where({ email, tenant_id: tenantId }).first();
    if (existing) {
      throw new ValidationError('Email already registered for this tenant');
    }

    const password_hash = await bcrypt.hash(password, 12);

    const columnsResult = await db('information_schema.columns')
      .where({ table_name: 'users' })
      .select('column_name');
    const columns = new Set(columnsResult.map((r: any) => r.column_name as string));
    const hasIsActive = columns.has('is_active');

    const row: Record<string, unknown> = {
      email,
      password_hash,
      first_name,
      last_name,
      phone: phone || null,
      role: 'receptionist',
      tenant_id: tenantId,
      is_email_verified: true,
      created_at: new Date(),
      updated_at: new Date(),
    };
    if (hasIsActive) {
      row.is_active = true;
    }

    const [user] = await db('users').insert(row).returning([
      'id',
      'email',
      'first_name',
      'last_name',
      'phone',
      'role',
      'tenant_id',
      'is_email_verified',
      'created_at',
    ]);

    logger.info(`Staff user created: receptionist ${user.id}`);

    res.status(201).json({
      status: 'success',
      message: 'User created successfully',
      data: { user },
    });
  });

  /**
   * Get user by ID
   * GET /api/v1/users/:id
   */
  getUserById = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const tenantId = req.tenantId!;
    const currentUserId = req.user!.userId;
    const currentUserRole = req.user!.role;

    // Check if user can access this profile
    if (id !== currentUserId && !['admin', 'developer'].includes(currentUserRole)) {
      throw new AuthorizationError('You can only access your own profile');
    }

    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .select('id', 'email', 'first_name', 'last_name', 'phone', 'preferred_language', 'role', 'is_email_verified', 'last_login_at', 'created_at')
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    res.status(200).json({
      status: 'success',
      data: {
        user,
      },
    });
  });

  /**
   * Update user
   * PUT /api/v1/users/:id
   */
  updateUser = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const tenantId = req.tenantId!;
    const currentUserId = req.user!.userId;
    const currentUserRole = req.user!.role;

    // Check if user can update this profile
    if (id !== currentUserId && !['admin', 'developer'].includes(currentUserRole)) {
      throw new AuthorizationError('You can only update your own profile');
    }

    const {
      first_name,
      last_name,
      phone,
      date_of_birth,
      gender,
      address,
      city,
      country,
      preferred_language,
      id_number,
      zip_code,
    } = req.body;

    // Verify user exists
    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    // Update user
    const updateData: any = {
      updated_at: new Date(),
    };

    if (first_name) updateData.first_name = first_name;
    if (last_name) updateData.last_name = last_name;
    if (phone) updateData.phone = phone;
    if (preferred_language) updateData.preferred_language = preferred_language;

    const metadataUpdates: Record<string, any> = {};
    if (date_of_birth) metadataUpdates.date_of_birth = date_of_birth;
    if (gender) metadataUpdates.gender = gender;
    if (address) metadataUpdates.address = address;
    if (city) metadataUpdates.city = city;
    if (country) metadataUpdates.country = country;
    if (id_number) metadataUpdates.id_number = id_number;
    if (zip_code) metadataUpdates.zip_code = zip_code;

    if (Object.keys(metadataUpdates).length > 0) {
      const existingMetadata = user.metadata ?? {};
      updateData.metadata = {
        ...existingMetadata,
        ...metadataUpdates,
      };
    }

    const [updatedUser] = await db('users')
      .where({ id })
      .update(updateData)
      .returning('*');

    // Remove sensitive data
    const {
      password_hash: _password_hash,
      email_verification_token: _email_verification_token,
      password_reset_token: _password_reset_token,
      ...userResponse
    } = updatedUser;

    logger.info(`User updated: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'User updated successfully',
      data: {
        user: userResponse,
      },
    });
  });

  /**
   * Delete user (soft delete)
   * DELETE /api/v1/users/:id
   */
  deleteUser = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const tenantId = req.tenantId!;

    // Verify user exists
    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    // Soft delete
    await db('users')
      .where({ id })
      .delete();

    logger.info(`User deleted: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'User deleted successfully',
    });
  });

  /**
   * Update user role
   * PUT /api/v1/users/:id/role
   */
  updateUserRole = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { role } = req.body;
    const tenantId = req.tenantId!;
    const currentUserRole = req.user!.role;

    // Verify user exists
    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    // Only developers can assign admin role
    if (role === 'admin' && currentUserRole !== 'developer') {
      throw new AuthorizationError('Only developers can assign admin role');
    }

    // Update role
    await db('users')
      .where({ id })
      .update({
        role,
        updated_at: new Date(),
      });

    logger.info(`User role updated: ${id} -> ${role}`);

    res.status(200).json({
      status: 'success',
      message: 'User role updated successfully',
    });
  });

  /**
   * Update user status
   * PUT /api/v1/users/:id/status
   */
  updateUserStatus = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { is_active } = req.body;
    const tenantId = req.tenantId;

    // Verify user exists (check with or without tenant_id, as some users may not have tenant_id)
    const user = await db('users')
      .where({ id })
      .first();

    // If tenant_id is provided, also verify it matches (for multi-tenant security)
    if (tenantId && user && user.tenant_id !== tenantId) {
      // Allow if current user is developer (can approve across tenants)
      const currentUserRole = req.user?.role;
      if (currentUserRole !== 'developer') {
        throw new NotFoundError('User');
      }
    }

    if (!user) {
      throw new NotFoundError('User');
    }

    // Update status
    await db('users')
      .where({ id })
      .update({
        is_active,
        updated_at: new Date(),
      });

    // If activating a doctor user, also activate doctor profile (if exists)
    if (is_active === true && user.role === 'doctor') {
      try {
        const doctorUpdate: any = { is_active: true, updated_at: new Date() };
        const doctorQuery = db('doctors').where({ user_id: id });
        if (tenantId) {
          doctorQuery.andWhere({ tenant_id: tenantId });
        }
        await doctorQuery.update(doctorUpdate);
      } catch (e: any) {
        logger.warn(`Failed to activate doctor profile for user ${id}: ${e?.message || e}`);
      }
    }

    // Send approval email when activating (best-effort; email gate may block)
    if (is_active === true) {
      try {
        await sendEmail({
          to: user.email,
          subject: 'Your account has been approved',
          template: 'account-approved',
          data: {
            name: `${user.first_name || ''} ${user.last_name || ''}`.trim() || user.email,
          },
        });
      } catch (e: any) {
        logger.warn(`Failed to send account-approved email to ${user.email}: ${e?.message || e}`);
      }
    }

    logger.info(`User status updated: ${id} -> ${is_active ? 'active' : 'inactive'}`);

    res.status(200).json({
      status: 'success',
      message: `User ${is_active ? 'activated' : 'deactivated'} successfully`,
    });
  });

  /**
   * Get user activity log
   * GET /api/v1/users/:id/activity
   */
  getUserActivity = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { page, limit, offset } = (req as any).pagination;
    const tenantId = req.tenantId!;

    // Verify user exists
    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    // Get activity from audit_logs table
    const [{ count }] = await db('audit_logs')
      .where({ user_id: id, tenant_id: tenantId })
      .count('* as count');

    const activities = await db('audit_logs')
      .where({ user_id: id, tenant_id: tenantId })
      .orderBy('created_at', 'desc')
      .limit(limit)
      .offset(offset);

    res.status(200).json({
      status: 'success',
      data: {
        activities,
        pagination: {
          page,
          limit,
          total: parseInt(count as string),
          pages: Math.ceil(parseInt(count as string) / limit),
        },
      },
    });
  });
}


