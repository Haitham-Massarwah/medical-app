import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { asyncHandler, ValidationError, AuthenticationError, NotFoundError } from '../middleware/errorHandler';
import { generateToken, generateRefreshToken } from '../middleware/auth.middleware';
import db from '../config/database';
import { logger } from '../config/logger';
import { sendEmail } from '../services/email.service';
import { resetPasswordByToken } from '../services/passwordReset.service';

export class AuthController {
  /**
   * Register new user
   * POST /api/v1/auth/register
   */
  register = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const {
      email,
      password,
      first_name,
      last_name,
      phone,
      role = 'patient',
      tenant_id,
      // Doctor-specific fields
      visa_card_number,
      card_holder_name,
      expiry_date,
      cvv,
      id_number,
      medical_license_number,
    } = req.body;
    const normalizedIdNumber = String(id_number || '').trim();
    const normalizedDoctorBusinessId = normalizedIdNumber.replace(/[^\d]/g, '');
    const normalizedMedicalLicense = String(medical_license_number || '').trim();

    if (role === 'doctor') {
      if (!/^\d{5,9}$/.test(normalizedDoctorBusinessId)) {
        throw new ValidationError('Doctor/Therapist business identifier must be 5-9 digits');
      }
    }


    // Allow patient and doctor self-registration (both require admin approval)
    if (!['patient', 'doctor'].includes(role)) {
      throw new ValidationError('Invalid registration type. Only patient and doctor roles can self-register.');
    }

    // Check if user already exists
    const existingUser = await db('users')
      .where({ email })
      .first();

    if (existingUser) {
      throw new ValidationError('Email already registered');
    }

    // If doctor, verify card details
    if (role === 'doctor' && visa_card_number && expiry_date && cvv && card_holder_name) {
      const { CardVerificationService } = await import('../services/card-verification.service');
      
      const verificationResult = await CardVerificationService.verifyCard(
        visa_card_number,
        expiry_date,
        cvv,
        card_holder_name
      );

      if (!verificationResult.isValid) {
        throw new ValidationError(
          `Card verification failed: ${verificationResult.message}`
        );
      }
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Resolve tenant for self-registration.
    // Many deployments require users.tenant_id to be non-null; if the client doesn't pass tenant_id,
    // attach the default system tenant.
    let effectiveTenantId: string | null = tenant_id || null;
    if (!effectiveTenantId) {
      try {
        const defaultTenant =
          (await db('tenants').where({ email: 'admin@medical-appointments.com' }).first()) ||
          (await db('tenants').first());
        effectiveTenantId = defaultTenant?.id || null;
      } catch (e) {
        logger.warn('Failed to resolve default tenant for registration; continuing with null tenant_id.', e as any);
      }
    }

    // Check optional columns exist (some deployments may not have run all migrations)
    const columnsResult = await db('information_schema.columns')
      .where({ table_name: 'users' })
      .select('column_name');
    const columns = new Set(columnsResult.map((r: any) => (r.column_name as string)));
    const hasEmailVerificationToken = columns.has('email_verification_token');
    const hasEmailVerificationExpiry = columns.has('email_verification_expiry');
    const hasIsActive = columns.has('is_active');

    // Generate email verification token (if columns exist)
    const verificationToken = hasEmailVerificationToken 
      ? crypto.randomBytes(32).toString('hex') 
      : null;
    const verificationExpiry = hasEmailVerificationExpiry
      ? new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
      : null;

    // Create user with pending approval status
    const userData: any = {
      email,
      password_hash: hashedPassword,
      first_name,
      last_name,
      phone,
      role,
      tenant_id: effectiveTenantId,
      is_email_verified: false,
      // Self-registrations require admin approval; keep inactive until approved (if column exists)
      ...(hasIsActive ? { is_active: false } : {}),
      created_at: new Date(),
      updated_at: new Date(),
      metadata: {
        creation_source: 'self_service',
        id_number: normalizedIdNumber,
        ...(role === 'doctor'
          ? {
              doctor_business_file_id: normalizedDoctorBusinessId,
              medical_license_number: normalizedMedicalLicense || null,
              doctor_primary_identifier:
                normalizedMedicalLicense || normalizedDoctorBusinessId,
              doctor_primary_identifier_type:
                normalizedMedicalLicense ? 'medical_license' : 'business_file_id',
            }
          : {}),
      },
    };

    // Only add email verification fields if columns exist
    if (hasEmailVerificationToken && verificationToken) {
      userData.email_verification_token = verificationToken;
    }
    if (hasEmailVerificationExpiry && verificationExpiry) {
      userData.email_verification_expiry = verificationExpiry;
    }
    
    let user;
    try {
      [user] = await db('users')
        .insert(userData)
        .returning('*');
    } catch (error: any) {
      logger.error('Failed to create user during registration:', {
        error: error.message,
        code: error.code,
        detail: error.detail,
        constraint: error.constraint,
        userData: { ...userData, password_hash: '[REDACTED]' },
      });
      throw new ValidationError(`Registration failed: ${error.detail || error.message}`);
    }

    // Create patient/doctor record if needed
    if (role === 'patient' && effectiveTenantId) {
      try {
        await db('patients').insert({
          user_id: user.id,
          tenant_id: effectiveTenantId,
          created_at: new Date(),
          updated_at: new Date(),
        });
      } catch (error: any) {
        logger.warn('Failed to create patient record during registration (non-critical):', error.message);
        // Don't fail registration if patient record creation fails
      }
    } else if (role === 'doctor' && effectiveTenantId) {
      try {
        const primaryIdentifierValue =
          normalizedMedicalLicense || normalizedDoctorBusinessId;
        const primaryIdentifierType = normalizedMedicalLicense
          ? 'medical_license'
          : 'business_file_id';

        await db('doctors').insert({
          user_id: user.id,
          tenant_id: effectiveTenantId,
          specialty: 'General',
          license_number: normalizedMedicalLicense || null,
          business_file_id: normalizedDoctorBusinessId,
          primary_identifier_type: primaryIdentifierType,
          primary_identifier_value: primaryIdentifierValue,
          is_active: false, // Pending admin approval
          created_at: new Date(),
          updated_at: new Date(),
        });
      } catch (error: any) {
        logger.warn('Failed to create doctor record during registration (non-critical):', error.message);
        // Don't fail registration if doctor record creation fails
      }
    }

    // Send verification email (only if verification token was created)
    if (verificationToken) {
      try {
        await sendEmail({
          to: email,
          subject: 'Verify your email address',
          template: 'email-verification',
          data: {
            name: first_name,
            verificationUrl: `${process.env.FRONTEND_URL}/verify-email/${verificationToken}`,
          },
        });
      } catch (error) {
        logger.error('Failed to send verification email:', error);
        // Don't fail registration if email fails
      }
    } else {
      logger.warn('Email verification columns not found; skipping verification email. Run migration 006 to enable email verification.');
    }

    // Send admin approval notification immediately on registration (for both patients and doctors)
    // This ensures admins are notified even if email verification is not completed
    // Both patients and doctors require admin approval before they can use the system
    try {
      const adminEmails = [
        'haitham.massarwah@medical-appointments.com',
        'hn.medicalapoointments@gmail.com',
      ];
      
      const roleDisplayName = role === 'doctor' ? 'Doctor' : 'Patient';
      
      for (const adminEmail of adminEmails) {
        try {
          await sendEmail({
            to: adminEmail,
            subject: `New ${roleDisplayName} Registration Requires Approval - ${first_name} ${last_name}`,
            template: 'admin-approval-required',
            data: {
              adminName: 'Admin',
              userName: `${first_name} ${last_name}`,
              userEmail: email,
              userRole: role,
              userId: user.id,
              message: `A new ${role} has registered and is waiting for approval. Email verification ${verificationToken ? 'pending' : 'not required'}.`,
            },
          });
          logger.info(`Admin approval email sent to ${adminEmail} for ${role} ${user.id}`);
        } catch (error) {
          logger.error(`Failed to send admin notification email to ${adminEmail}:`, error);
        }
      }
    } catch (error) {
      logger.error('Failed to send admin approval notifications on registration:', error);
      // Don't fail registration if notification fails
    }

    // Remove sensitive data
    const {
      password_hash: _password_hash,
      email_verification_token: _email_verification_token,
      ...userResponse
    } = user;

    logger.info(`New user registered: ${user.id} (${email})`);

    res.status(201).json({
      status: 'success',
      message:
        'Registration successful. Please verify your email, then wait for admin approval before login.',
      data: {
        user: userResponse,
      },
    });
  });

  /**
   * Login user
   * POST /api/v1/auth/login
   */
  login = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { email, password } = req.body;
    const normalizedEmail = (email || '').toLowerCase().trim();

    // Find user (prefer developer/admin if duplicate rows share the same email case-insensitively)
    const user = await db('users')
      .whereRaw('LOWER(email) = ?', [normalizedEmail])
      .orderByRaw(
        `CASE role WHEN 'developer' THEN 0 WHEN 'admin' THEN 1 WHEN 'doctor' THEN 2 WHEN 'patient' THEN 3 ELSE 4 END`
      )
      .orderBy('id', 'asc')
      .first();

    if (!user) {
      throw new AuthenticationError('Invalid email or password');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      throw new AuthenticationError('Invalid email or password');
    }

    if (user.is_email_verified === false) {
      throw new AuthenticationError('Please verify your email before logging in');
    }

    if (Object.prototype.hasOwnProperty.call(user, 'is_active') && user.is_active === false) {
      throw new AuthenticationError('Your account is pending admin approval');
    }

    // Update last login
    await db('users')
      .where({ id: user.id })
      .update({
        last_login_at: new Date(),
        updated_at: new Date(),
      });

    // Generate tokens
    const accessToken = generateToken({
      id: user.id,
      userId: user.id,
      tenantId: user.tenant_id,
      role: user.role,
      email: user.email,
    });

    const refreshToken = generateRefreshToken({
      id: user.id,
      userId: user.id,
      tenantId: user.tenant_id,
      role: user.role,
      email: user.email,
    });

    // Remove sensitive data
    const {
      password_hash: _ph,
      email_verification_token: _evt,
      password_reset_token: _prt,
      ...userResponse
    } = user;

    logger.info(`User logged in: ${user.id} (${email})`);

    res.status(200).json({
      status: 'success',
      message: 'Login successful',
      data: {
        user: userResponse,
        tokens: {
          accessToken,
          refreshToken,
        },
      },
    });
  });

  /**
   * Forgot password
   * POST /api/v1/auth/forgot-password
   */
  /**
   * Check if email exists
   * GET /api/v1/auth/check-email
   */
  checkEmailExists = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { email } = req.query;
    const normalizedEmail = (email || '').toString().toLowerCase().trim();

    if (!email) {
      throw new ValidationError('Email is required');
    }

    // Find user
    const user = await db('users')
      .whereRaw('LOWER(email) = ?', [normalizedEmail])
      .first();

    return res.status(200).json({
      exists: !!user,
    });
  });

  forgotPassword = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { email } = req.body;
    const normalizedEmail = (email || '').toString().toLowerCase().trim();

    // Find user
    const user = await db('users')
      .whereRaw('LOWER(email) = ?', [normalizedEmail])
      .first();

    if (!user) {
      // Email not found - inform user
      return res.status(200).json({
        status: 'error',
        exists: false,
        message: 'Email address not found in the system',
      });
    }

    // Check if password reset columns exist (migration 006 may not have run)
    const columnsResult = await db('information_schema.columns')
      .where({ table_name: 'users' })
      .select('column_name');
    const columns = new Set(columnsResult.map((r: any) => (r.column_name as string)));
    const hasPasswordResetToken = columns.has('password_reset_token');
    const hasPasswordResetExpiry = columns.has('password_reset_expiry');

    if (!hasPasswordResetToken || !hasPasswordResetExpiry) {
      logger.warn('Password reset columns not found. Run migration 006 to enable password reset.');
      return res.status(500).json({
        status: 'error',
        exists: true,
        message: 'Password reset is not available. Please contact support.',
      });
    }

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetExpiry = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    // Save token
    await db('users')
      .where({ id: user.id })
      .update({
        password_reset_token: resetToken,
        password_reset_expiry: resetExpiry,
        updated_at: new Date(),
      });

    // Send reset email
    try {
      await sendEmail({
        to: email,
        subject: 'Reset your password',
        template: 'password-reset',
        data: {
          name: user.first_name,
          resetUrl: `${process.env.BASE_URL || 'http://localhost:3000'}/api/v1/auth/reset-password-page/${resetToken}`,
        },
      });
    } catch (error) {
      logger.error('Failed to send password reset email:', error);
      throw new Error('Failed to send password reset email');
    }

    logger.info(`Password reset requested for user: ${user.id}`);

    res.status(200).json({
      status: 'success',
      exists: true,
      message: 'Password reset link sent to your email',
    });
  });

  /**
   * Reset password
   * POST /api/v1/auth/reset-password/:token
   */
  resetPassword = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { token } = req.params;
    const password = (req.body?.password ?? req.body?.newPassword) as string | undefined;
    await resetPasswordByToken(token, password ?? '');

    res.status(200).json({
      status: 'success',
      message: 'Password reset successful. You can now login with your new password.',
    });
  });

  /**
   * Reset password (token in JSON body — for clients that cannot put token in path)
   * POST /api/v1/auth/reset-password
   */
  resetPasswordBody = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const token = String(req.body?.token ?? '').trim();
    const password = (req.body?.password ?? req.body?.newPassword) as string | undefined;
    if (!token) {
      throw new ValidationError('Reset token is required');
    }
    await resetPasswordByToken(token, password ?? '');

    res.status(200).json({
      status: 'success',
      message: 'Password reset successful. You can now login with your new password.',
    });
  });

  /**
   * Verify email
   * POST /api/v1/auth/verify-email/:token
   */
  verifyEmail = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { token } = req.params;

    // Find user with valid token
    const user = await db('users')
      .where({ email_verification_token: token })
      .andWhere('email_verification_expiry', '>', new Date())
      .first();

    if (!user) {
      throw new ValidationError('Invalid or expired verification token');
    }

    const metadata = (user.metadata || {}) as Record<string, any>;
    const requiresAdminApproval = metadata.require_admin_approval !== false;
    const updatePayload: Record<string, any> = {
      is_email_verified: true,
      email_verification_token: null,
      email_verification_expiry: null,
      updated_at: new Date(),
      metadata: {
        ...metadata,
        pending_email_verification: false,
      },
    };
    if (!requiresAdminApproval && Object.prototype.hasOwnProperty.call(user, 'is_active')) {
      updatePayload.is_active = true;
    }

    // Update email verification status
    await db('users').where({ id: user.id }).update(updatePayload);

    logger.info(`Email verified for user: ${user.id}`);

    // Send admin notification for approval only when required.
    if (requiresAdminApproval) {
      try {
      // Get all admin and developer users
      const admins = await db('users')
        .whereIn('role', ['admin', 'developer'])
        .select('id', 'email', 'first_name', 'last_name');

      // Create notification for each admin
      const notificationPromises = admins.map(admin => 
        db('notifications').insert({
          tenant_id: user.tenant_id || null,
          user_id: admin.id,
          type: 'email', // Notification type enum: 'email', 'sms', 'whatsapp', 'push'
          title: `New ${user.role} Registration Requires Approval`,
          message: `${user.first_name} ${user.last_name} (${user.email}) has verified their email and is waiting for approval.`,
          is_read: false,
          data: {
            userId: user.id,
            userEmail: user.email,
            userRole: user.role,
            userName: `${user.first_name} ${user.last_name}`,
          },
          status: 'pending',
          created_at: new Date(),
          updated_at: new Date(),
        })
      );

      await Promise.all(notificationPromises);

      // Also send email notification to specific admin emails
      const adminEmails = [
        'haitham.massarwah@medical-appointments.com',
        'hn.medicalapoointments@gmail.com',
      ];
      
      for (const adminEmail of adminEmails) {
        try {
          await sendEmail({
            to: adminEmail,
            subject: `New ${user.role} Registration Requires Approval`,
            template: 'admin-approval-required',
            data: {
              adminName: 'Admin',
              userName: `${user.first_name} ${user.last_name}`,
              userEmail: user.email,
              userRole: user.role,
              userId: user.id,
            },
          });
          logger.info(`Admin approval email sent to ${adminEmail} for user ${user.id}`);
        } catch (error) {
          logger.error(`Failed to send admin notification email to ${adminEmail}:`, error);
        }
      }

        logger.info(`Admin notifications sent for user approval: ${user.id}`);
      } catch (error) {
        logger.error('Failed to send admin notifications:', error);
        // Don't fail email verification if notification fails
      }
    }

    res.status(200).json({
      status: 'success',
      message: requiresAdminApproval
        ? 'Email verified successfully. Your account is pending admin approval.'
        : 'Email verified successfully. Your account is now active.',
    });
  });

  /**
   * Get current user
   * GET /api/v1/auth/me
   */
  getCurrentUser = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user?.userId || req.user?.id;
    if (!userId) {
      throw new AuthenticationError('User not authenticated');
    }

    const user = await db('users')
      .where({ id: userId })
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    // Remove sensitive data
    const {
      password_hash: _ph2,
      email_verification_token: _evt2,
      password_reset_token: _prt2,
      ...userResponse
    } = user;

    res.status(200).json({
      status: 'success',
      data: {
        user: userResponse,
      },
    });
  });

  /**
   * Logout
   * POST /api/v1/auth/logout
   */
  logout = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    // In a stateless JWT system, logout is handled client-side by removing the token
    // You could implement a token blacklist using Redis if needed

    logger.info(`User logged out: ${req.user!.userId}`);

    res.status(200).json({
      status: 'success',
      message: 'Logout successful',
    });
  });

  /**
   * Refresh token
   * POST /api/v1/auth/refresh-token
   */
  refreshToken = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user!.userId;

    // Verify user still exists and is active
    const user = await db('users')
      .where({ id: userId })
      .first();

    if (!user || !user.is_active) {
      throw new AuthenticationError('User not found or inactive');
    }

    // Generate new tokens
    const accessToken = generateToken({
      id: user.id,
      userId: user.id,
      tenantId: user.tenant_id,
      role: user.role,
      email: user.email,
    });

    const refreshToken = generateRefreshToken({
      id: user.id,
      tenantId: user.tenant_id,
      role: user.role,
      email: user.email,
    });

    res.status(200).json({
      status: 'success',
      data: {
        tokens: {
          accessToken,
          refreshToken,
        },
      },
    });
  });

  /**
   * Change password
   * PUT /api/v1/auth/change-password
   */
  changePassword = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user!.userId;
    const { current_password, new_password } = req.body;

    // Get user
    const user = await db('users')
      .where({ id: userId })
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    // Verify current password
    const isPasswordValid = await bcrypt.compare(current_password, user.password_hash);

    if (!isPasswordValid) {
      throw new ValidationError('Current password is incorrect');
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(new_password, 12);

    // Update password
    await db('users')
      .where({ id: userId })
      .update({
        password_hash: hashedPassword,
        updated_at: new Date(),
      });

    logger.info(`Password changed for user: ${userId}`);

    res.status(200).json({
      status: 'success',
      message: 'Password changed successfully',
    });
  });
}


