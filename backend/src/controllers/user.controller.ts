import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { asyncHandler, NotFoundError, AuthorizationError, ValidationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';
import { sendEmail } from '../services/email.service';
import { insertAuditEventSafe } from '../services/auditLog.service';

/** Staff-created users must have tenant_id; JWT may omit it for some developers. */
async function resolveCreateUserTenantId(req: Request): Promise<string> {
  const existing = req.tenantId;
  if (existing) return existing;

  const headerTenant = String(req.headers['x-tenant-id'] || '').trim();
  if (headerTenant) {
    const row = await db('tenants').where({ id: headerTenant }).first();
    if (!row) throw new ValidationError('Invalid X-Tenant-Id header: clinic not found');
    return headerTenant;
  }

  const defaultTenant =
    (await db('tenants').where({ email: 'admin@medical-appointments.com' }).first()) ||
    (await db('tenants').first());
  const id = (defaultTenant as { id?: string } | undefined)?.id;
  if (!id) {
    throw new ValidationError(
      'No clinic (tenant) could be determined. Assign your account to a clinic in the database, or seed at least one row in tenants.',
    );
  }
  return id;
}

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
        'metadata',
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
   * Create user within strict RBAC scope.
   * POST /api/v1/users
   */
  createStaffUser = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = await resolveCreateUserTenantId(req);
    const {
      email,
      password,
      first_name,
      last_name,
      phone,
      role,
      business_file_id,
      specialty,
      languages,
      bio,
      license_number,
      pre_approved,
      app_payments_enabled,
      bank_details_enabled,
      discount_percentage,
      plan_months,
    } = req.body;
    const currentRole = req.user!.role;
    const preApproved = pre_approved === true || pre_approved === 'true';

    if (!['patient', 'doctor', 'admin'].includes(role)) {
      throw new ValidationError('This endpoint supports patient, doctor, or admin role');
    }
    if (currentRole === 'developer') {
      // Developer can create admin/doctor/patient.
    } else if (currentRole === 'admin') {
      if (!['doctor', 'patient'].includes(role)) {
        throw new AuthorizationError('Admin can create only doctor/therapist and patient accounts');
      }
    } else if (currentRole === 'doctor') {
      if (role !== 'patient') {
        throw new AuthorizationError('Doctor/Therapist can create only patient accounts');
      }
    } else {
      throw new AuthorizationError('Insufficient permissions');
    }
    if (!email || !password || !first_name || !last_name) {
      throw new ValidationError('email, password, first_name, and last_name are required');
    }

    if (role === 'doctor') {
      const normalizedBusinessId = String(business_file_id || '').replace(/[^\d]/g, '');
      if (!/^\d{5,9}$/.test(normalizedBusinessId)) {
        throw new ValidationError('Doctor/Therapist business identifier must be 5-9 digits');
      }
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
    const hasPasswordResetToken = columns.has('password_reset_token');
    const hasPasswordResetExpiry = columns.has('password_reset_expiry');

    const row: Record<string, unknown> = {
      email,
      password_hash,
      first_name,
      last_name,
      phone: phone || null,
      role,
      tenant_id: tenantId,
      is_email_verified: preApproved,
      created_at: new Date(),
      updated_at: new Date(),
    };
    if (hasIsActive) {
      row.is_active = preApproved;
    }
    row.metadata = {
      id_number: req.body.id_number || null,
      city: req.body.city || null,
      pending_email_verification: !preApproved,
      require_admin_approval: !preApproved,
      creation_source: 'staff_created',
      app_payments_enabled: app_payments_enabled === true,
      bank_details_enabled: bank_details_enabled === true,
      discount_percentage:
        typeof discount_percentage === 'number'
          ? Math.max(0, Math.min(100, Number(discount_percentage)))
          : 0,
      discount_start_at:
        typeof discount_percentage === 'number' && Number(discount_percentage) > 0
          ? new Date().toISOString()
          : null,
      discount_end_at:
        typeof discount_percentage === 'number' &&
        Number(discount_percentage) > 0 &&
        Number(plan_months || 0) > 0
          ? new Date(
              Date.now() + Number(plan_months) * 30 * 24 * 60 * 60 * 1000
            ).toISOString()
          : null,
    };
    const verificationToken =
      !preApproved && columns.has('email_verification_token')
        ? crypto.randomBytes(32).toString('hex')
        : null;
    if (verificationToken) {
      row.email_verification_token = verificationToken;
    }
    if (!preApproved && columns.has('email_verification_expiry')) {
      row.email_verification_expiry = new Date(Date.now() + 24 * 60 * 60 * 1000);
    }

    let createdUser!: Record<string, unknown>;
    let passwordSetupToken: string | undefined;

    await db.transaction(async (trx) => {
      const [user] = await trx('users')
        .insert(row)
        .returning([
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
      createdUser = user as Record<string, unknown>;
      const uid = (user as { id: string }).id;

      if (role === 'doctor') {
        const normalizedBusinessId = String(business_file_id || '').replace(/[^\d]/g, '');
        const normalizedLicense = String(license_number || '').trim();
        const primaryIdentifierValue = normalizedLicense || normalizedBusinessId;
        const primaryIdentifierType = normalizedLicense ? 'medical_license' : 'business_file_id';
        const langArr = Array.isArray(languages) && languages.length > 0 ? languages : ['עברית'];

        await trx('doctors').insert({
          user_id: uid,
          tenant_id: tenantId,
          specialty: (specialty && String(specialty).trim()) || 'General',
          license_number: normalizedLicense || null,
          business_file_id: normalizedBusinessId,
          primary_identifier_type: primaryIdentifierType,
          primary_identifier_value: primaryIdentifierValue,
          bio: bio || null,
          languages: langArr,
          is_active: preApproved,
          rating: 0,
          review_count: 0,
          created_at: new Date(),
          updated_at: new Date(),
        });
      } else if (role === 'patient') {
        try {
          await trx('patients').insert({
            user_id: uid,
            tenant_id: tenantId,
            created_at: new Date(),
            updated_at: new Date(),
          });
        } catch (e: any) {
          logger.warn('Staff patient row insert failed (non-fatal):', e?.message);
        }
      }

      if (hasPasswordResetToken && hasPasswordResetExpiry) {
        passwordSetupToken = crypto.randomBytes(32).toString('hex');
        const resetExpiry = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
        await trx('users').where({ id: uid }).update({
          password_reset_token: passwordSetupToken,
          password_reset_expiry: resetExpiry,
          updated_at: new Date(),
        });
      }
    });

    logger.info(`Staff user created: ${role} ${(createdUser as any).id}`);

    let onboardingMailSent = false;
    let onboardingMailError: string | null = null;
    try {
      if (passwordSetupToken) {
        const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
        await sendEmail({
          to: email,
          subject: 'חשבון נוצר — הגדרת סיסמה',
          template: 'staff-account-password-setup',
          data: {
            name: first_name,
            setupUrl: `${baseUrl}/api/v1/auth/reset-password-page/${passwordSetupToken}`,
          },
        });
        onboardingMailSent = true;
      } else if (verificationToken) {
        await sendEmail({
          to: email,
          subject: 'Verify your email address',
          template: 'email-verification',
          data: {
            name: first_name,
            verificationUrl: `${process.env.FRONTEND_URL || 'http://localhost:8080'}/verify-email/${verificationToken}`,
          },
        });
        onboardingMailSent = true;
      }
    } catch (error) {
      logger.error('Failed to send staff onboarding email:', error as any);
      onboardingMailError = error instanceof Error ? error.message : String(error);
    }

    const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
    const onboardingSetupUrl = passwordSetupToken
      ? `${baseUrl}/api/v1/auth/reset-password-page/${passwordSetupToken}`
      : null;

    res.status(201).json({
      status: 'success',
      message: preApproved
        ? onboardingMailSent
          ? 'User created. An email was sent to set a password before first sign-in.'
          : 'User created, but onboarding email failed to send. Use setup URL from response data.'
        : 'User created. Email verification is required before account activation.',
      data: {
        user: createdUser!,
        onboarding_mail_sent: onboardingMailSent,
        ...(onboardingMailError ? { onboarding_mail_error: onboardingMailError } : {}),
        ...(process.env.NODE_ENV !== 'production' && onboardingSetupUrl
          ? { onboarding_setup_url: onboardingSetupUrl }
          : {}),
      },
    });
  });

  /**
   * Resend staff onboarding setup email
   * POST /api/v1/users/:id/resend-setup-email
   */
  resendSetupEmail = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const tenantId = req.tenantId!;
    const actorRole = req.user!.role;
    const actorUserId = req.user!.userId;

    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    if (actorRole === 'admin' && !['doctor', 'patient'].includes(user.role)) {
      throw new AuthorizationError('Admin can resend setup email only for doctor/therapist and patient accounts');
    }
    if (!['admin', 'developer'].includes(actorRole)) {
      throw new AuthorizationError('Insufficient permissions');
    }

    const columnsResult = await db('information_schema.columns')
      .where({ table_name: 'users' })
      .select('column_name');
    const columns = new Set(columnsResult.map((r: any) => r.column_name as string));
    const hasPasswordResetToken = columns.has('password_reset_token');
    const hasPasswordResetExpiry = columns.has('password_reset_expiry');

    if (!hasPasswordResetToken || !hasPasswordResetExpiry) {
      throw new ValidationError('Password setup tokens are not supported in this database schema');
    }

    const passwordSetupToken = crypto.randomBytes(32).toString('hex');
    const resetExpiry = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    await db('users')
      .where({ id, tenant_id: tenantId })
      .update({
        password_reset_token: passwordSetupToken,
        password_reset_expiry: resetExpiry,
        updated_at: new Date(),
      });

    const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
    const setupUrl = `${baseUrl}/api/v1/auth/reset-password-page/${passwordSetupToken}`;

    await sendEmail({
      to: user.email,
      subject: 'חשבון נוצר — הגדרת סיסמה',
      template: 'staff-account-password-setup',
      data: {
        name: `${user.first_name || ''}`.trim() || user.email,
        setupUrl,
      },
    });

    await insertAuditEventSafe({
      tenantId,
      actorUserId,
      entityType: 'user',
      entityId: id,
      action: 'resend_setup_email',
      summary: 'Resent setup email',
      metadata: { target_email: user.email, target_role: user.role },
    });

    res.status(200).json({
      status: 'success',
      message: 'Setup email resent successfully',
      data: {
        user_id: id,
        email: user.email,
        ...(process.env.NODE_ENV !== 'production' ? { onboarding_setup_url: setupUrl } : {}),
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
      email,
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
    if (email && email !== user.email) {
      const existingUser = await db('users')
        .where({ email, tenant_id: tenantId })
        .whereNot({ id })
        .first();
      if (existingUser) {
        throw new ValidationError('Email already in use');
      }
      updateData.email = email;
    }
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

    await insertAuditEventSafe({
      tenantId,
      actorUserId: req.user!.userId,
      entityType: 'user',
      entityId: id,
      action: 'update',
      summary: 'User profile updated',
      metadata: {
        updated_field_keys: Object.keys(updateData).filter(
          (k) => !['password_hash', 'updated_at', 'email_verification_token', 'password_reset_token'].includes(k),
        ),
      },
    });

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
    const currentUserRole = req.user!.role;
    const currentUserId = req.user!.userId;

    // Verify user exists
    const user = await db('users')
      .where({ id, tenant_id: tenantId })
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    if (id === currentUserId) {
      throw new AuthorizationError('You cannot delete your own account');
    }

    if (currentUserRole === 'admin' && !['doctor', 'patient'].includes(user.role)) {
      throw new AuthorizationError('Admin can delete only doctor/therapist and patient accounts');
    }
    if (currentUserRole !== 'developer' && currentUserRole !== 'admin') {
      throw new AuthorizationError('Insufficient permissions');
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


