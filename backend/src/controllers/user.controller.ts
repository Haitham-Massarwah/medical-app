import { Request, Response, NextFunction } from 'express';
import { asyncHandler, NotFoundError, AuthorizationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';

export class UserController {
  /**
   * Get all users
   * GET /api/v1/users
   */
  getAllUsers = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { page, limit, offset } = (req as any).pagination;
    const { search, role, is_active } = req.query;
    const tenantId = req.tenantId!;

    let query = db('users')
      .where({ tenant_id: tenantId })
      .andWhere('deleted_at', null);

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
    if (is_active !== undefined) {
      query = query.andWhere({ is_active: is_active === 'true' });
    }

    // Get total count
    const [{ count }] = await query.clone().count('* as count');

    // Get users
    const users = await query
      .select('id', 'email', 'first_name', 'last_name', 'phone', 'role', 'is_active', 'email_verified', 'last_login', 'created_at')
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
      .andWhere('deleted_at', null)
      .select('id', 'email', 'first_name', 'last_name', 'phone', 'date_of_birth', 'gender', 'address', 'city', 'country', 'preferred_language', 'role', 'is_active', 'email_verified', 'last_login', 'created_at')
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
    } = req.body;

    // Verify user exists
    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .andWhere('deleted_at', null)
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
    if (date_of_birth) updateData.date_of_birth = date_of_birth;
    if (gender) updateData.gender = gender;
    if (address) updateData.address = address;
    if (city) updateData.city = city;
    if (country) updateData.country = country;
    if (preferred_language) updateData.preferred_language = preferred_language;

    const [updatedUser] = await db('users')
      .where({ id })
      .update(updateData)
      .returning('*');

    // Remove sensitive data
    const { password_hash, email_verification_token, password_reset_token, ...userResponse } = updatedUser;

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
      .andWhere('deleted_at', null)
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    // Soft delete
    await db('users')
      .where({ id })
      .update({
        deleted_at: new Date(),
        updated_at: new Date(),
      });

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

    // Verify user exists
    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .andWhere('deleted_at', null)
      .first();

    if (!user) {
      throw new NotFoundError('User');
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
    const tenantId = req.tenantId!;

    // Verify user exists
    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .andWhere('deleted_at', null)
      .first();

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
      .andWhere('deleted_at', null)
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


