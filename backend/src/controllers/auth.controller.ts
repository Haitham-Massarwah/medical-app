import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { asyncHandler, ValidationError, AuthenticationError, NotFoundError } from '../middleware/errorHandler';
import { generateToken, generateRefreshToken } from '../middleware/auth.middleware';
import db from '../config/database';
import { logger } from '../config/logger';
import { sendEmail } from '../services/email.service';

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
    } = req.body;

    // Prevent patient self-registration
    // Patients must be created by doctors/admins
    if (role === 'patient') {
      throw new ValidationError('Patient accounts must be created by a doctor or administrator. Please contact your healthcare provider.');
    }

    // Only allow doctor and admin self-registration (or developer with special key)
    if (!['doctor', 'admin'].includes(role)) {
      throw new ValidationError('Invalid registration type');
    }

    // Check if user already exists
    const existingUser = await db('users')
      .where({ email })
      .first();

    if (existingUser) {
      throw new ValidationError('Email already registered');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Generate email verification token
    const verificationToken = crypto.randomBytes(32).toString('hex');
    const verificationExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    // Create user
    const [user] = await db('users')
      .insert({
        email,
        password_hash: hashedPassword,
        first_name,
        last_name,
        phone,
        role,
        tenant_id: tenant_id || null,
        email_verified: false,
        email_verification_token: verificationToken,
        email_verification_expiry: verificationExpiry,
        is_active: true,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    // Send verification email
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

    // Generate tokens
    const accessToken = generateToken({
      id: user.id,
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

    // Remove sensitive data
    const { password_hash, email_verification_token, ...userResponse } = user;

    logger.info(`New user registered: ${user.id} (${email})`);

    res.status(201).json({
      status: 'success',
      message: 'Registration successful. Please check your email to verify your account.',
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
   * Login user
   * POST /api/v1/auth/login
   */
  login = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { email, password } = req.body;

    // Find user
    const user = await db('users')
      .where({ email })
      .first();

    if (!user) {
      throw new AuthenticationError('Invalid email or password');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      throw new AuthenticationError('Invalid email or password');
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

    // Remove sensitive data
    const { password_hash, email_verification_token, password_reset_token, ...userResponse } = user;

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
  forgotPassword = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { email } = req.body;

    // Find user
    const user = await db('users')
      .where({ email })
      .first();

    if (!user) {
      // Don't reveal if email exists
      return res.status(200).json({
        status: 'success',
        message: 'If an account exists with this email, you will receive a password reset link.',
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
          resetUrl: `${process.env.FRONTEND_URL}/reset-password/${resetToken}`,
        },
      });
    } catch (error) {
      logger.error('Failed to send password reset email:', error);
      throw new Error('Failed to send password reset email');
    }

    logger.info(`Password reset requested for user: ${user.id}`);

    res.status(200).json({
      status: 'success',
      message: 'Password reset link sent to your email',
    });
  });

  /**
   * Reset password
   * POST /api/v1/auth/reset-password/:token
   */
  resetPassword = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { token } = req.params;
    const { password } = req.body;

    // Find user with valid token
    const user = await db('users')
      .where({ password_reset_token: token })
      .andWhere('password_reset_expiry', '>', new Date())
      .first();

    if (!user) {
      throw new ValidationError('Invalid or expired reset token');
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Update password and clear reset token
    await db('users')
      .where({ id: user.id })
      .update({
        password_hash: hashedPassword,
        password_reset_token: null,
        password_reset_expiry: null,
        updated_at: new Date(),
      });

    logger.info(`Password reset successful for user: ${user.id}`);

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

    // Update email verification status
    await db('users')
      .where({ id: user.id })
      .update({
        email_verified: true,
        email_verification_token: null,
        email_verification_expiry: null,
        updated_at: new Date(),
      });

    logger.info(`Email verified for user: ${user.id}`);

    res.status(200).json({
      status: 'success',
      message: 'Email verified successfully',
    });
  });

  /**
   * Get current user
   * GET /api/v1/auth/me
   */
  getCurrentUser = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user!.userId;

    const user = await db('users')
      .where({ id: userId })
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    // Remove sensitive data
    const { password_hash, email_verification_token, password_reset_token, ...userResponse } = user;

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


