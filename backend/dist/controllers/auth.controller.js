"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const crypto_1 = __importDefault(require("crypto"));
const errorHandler_1 = require("../middleware/errorHandler");
const auth_middleware_1 = require("../middleware/auth.middleware");
const database_1 = __importDefault(require("../config/database"));
const logger_1 = require("../config/logger");
const email_service_1 = require("../services/email.service");
class AuthController {
    constructor() {
        /**
         * Register new user
         * POST /api/v1/auth/register
         */
        this.register = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { email, password, first_name, last_name, phone, role = 'patient', tenant_id, } = req.body;
            // Prevent patient self-registration
            // Patients must be created by doctors/admins
            if (role === 'patient') {
                throw new errorHandler_1.ValidationError('Patient accounts must be created by a doctor or administrator. Please contact your healthcare provider.');
            }
            // Only allow doctor and admin self-registration (or developer with special key)
            if (!['doctor', 'admin'].includes(role)) {
                throw new errorHandler_1.ValidationError('Invalid registration type');
            }
            // Check if user already exists
            const existingUser = await (0, database_1.default)('users')
                .where({ email })
                .first();
            if (existingUser) {
                throw new errorHandler_1.ValidationError('Email already registered');
            }
            // Hash password
            const hashedPassword = await bcryptjs_1.default.hash(password, 12);
            // Generate email verification token
            const verificationToken = crypto_1.default.randomBytes(32).toString('hex');
            const verificationExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours
            // Create user
            const [user] = await (0, database_1.default)('users')
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
                await (0, email_service_1.sendEmail)({
                    to: email,
                    subject: 'Verify your email address',
                    template: 'email-verification',
                    data: {
                        name: first_name,
                        verificationUrl: `${process.env.FRONTEND_URL}/verify-email/${verificationToken}`,
                    },
                });
            }
            catch (error) {
                logger_1.logger.error('Failed to send verification email:', error);
                // Don't fail registration if email fails
            }
            // Generate tokens
            const accessToken = (0, auth_middleware_1.generateToken)({
                id: user.id,
                tenantId: user.tenant_id,
                role: user.role,
                email: user.email,
            });
            const refreshToken = (0, auth_middleware_1.generateRefreshToken)({
                id: user.id,
                tenantId: user.tenant_id,
                role: user.role,
                email: user.email,
            });
            // Remove sensitive data
            const { password_hash, email_verification_token, ...userResponse } = user;
            logger_1.logger.info(`New user registered: ${user.id} (${email})`);
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
        this.login = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { email, password } = req.body;
            // Find user
            const user = await (0, database_1.default)('users')
                .where({ email })
                .first();
            if (!user) {
                throw new errorHandler_1.AuthenticationError('Invalid email or password');
            }
            // Verify password
            const isPasswordValid = await bcryptjs_1.default.compare(password, user.password_hash);
            if (!isPasswordValid) {
                throw new errorHandler_1.AuthenticationError('Invalid email or password');
            }
            // Update last login
            await (0, database_1.default)('users')
                .where({ id: user.id })
                .update({
                last_login_at: new Date(),
                updated_at: new Date(),
            });
            // Generate tokens
            const accessToken = (0, auth_middleware_1.generateToken)({
                id: user.id,
                tenantId: user.tenant_id,
                role: user.role,
                email: user.email,
            });
            const refreshToken = (0, auth_middleware_1.generateRefreshToken)({
                id: user.id,
                tenantId: user.tenant_id,
                role: user.role,
                email: user.email,
            });
            // Remove sensitive data
            const { password_hash, email_verification_token, password_reset_token, ...userResponse } = user;
            logger_1.logger.info(`User logged in: ${user.id} (${email})`);
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
        this.forgotPassword = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { email } = req.body;
            // Find user
            const user = await (0, database_1.default)('users')
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
            const resetToken = crypto_1.default.randomBytes(32).toString('hex');
            const resetExpiry = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
            // Save token
            await (0, database_1.default)('users')
                .where({ id: user.id })
                .update({
                password_reset_token: resetToken,
                password_reset_expiry: resetExpiry,
                updated_at: new Date(),
            });
            // Send reset email
            try {
                await (0, email_service_1.sendEmail)({
                    to: email,
                    subject: 'Reset your password',
                    template: 'password-reset',
                    data: {
                        name: user.first_name,
                        resetUrl: `${process.env.FRONTEND_URL}/reset-password/${resetToken}`,
                    },
                });
            }
            catch (error) {
                logger_1.logger.error('Failed to send password reset email:', error);
                throw new Error('Failed to send password reset email');
            }
            logger_1.logger.info(`Password reset requested for user: ${user.id}`);
            res.status(200).json({
                status: 'success',
                message: 'Password reset link sent to your email',
            });
        });
        /**
         * Reset password
         * POST /api/v1/auth/reset-password/:token
         */
        this.resetPassword = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { token } = req.params;
            const { password } = req.body;
            // Find user with valid token
            const user = await (0, database_1.default)('users')
                .where({ password_reset_token: token })
                .andWhere('password_reset_expiry', '>', new Date())
                .first();
            if (!user) {
                throw new errorHandler_1.ValidationError('Invalid or expired reset token');
            }
            // Hash new password
            const hashedPassword = await bcryptjs_1.default.hash(password, 12);
            // Update password and clear reset token
            await (0, database_1.default)('users')
                .where({ id: user.id })
                .update({
                password_hash: hashedPassword,
                password_reset_token: null,
                password_reset_expiry: null,
                updated_at: new Date(),
            });
            logger_1.logger.info(`Password reset successful for user: ${user.id}`);
            res.status(200).json({
                status: 'success',
                message: 'Password reset successful. You can now login with your new password.',
            });
        });
        /**
         * Verify email
         * POST /api/v1/auth/verify-email/:token
         */
        this.verifyEmail = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { token } = req.params;
            // Find user with valid token
            const user = await (0, database_1.default)('users')
                .where({ email_verification_token: token })
                .andWhere('email_verification_expiry', '>', new Date())
                .first();
            if (!user) {
                throw new errorHandler_1.ValidationError('Invalid or expired verification token');
            }
            // Update email verification status
            await (0, database_1.default)('users')
                .where({ id: user.id })
                .update({
                email_verified: true,
                email_verification_token: null,
                email_verification_expiry: null,
                updated_at: new Date(),
            });
            logger_1.logger.info(`Email verified for user: ${user.id}`);
            res.status(200).json({
                status: 'success',
                message: 'Email verified successfully',
            });
        });
        /**
         * Get current user
         * GET /api/v1/auth/me
         */
        this.getCurrentUser = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const userId = req.user.userId;
            const user = await (0, database_1.default)('users')
                .where({ id: userId })
                .first();
            if (!user) {
                throw new errorHandler_1.NotFoundError('User');
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
        this.logout = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            // In a stateless JWT system, logout is handled client-side by removing the token
            // You could implement a token blacklist using Redis if needed
            logger_1.logger.info(`User logged out: ${req.user.userId}`);
            res.status(200).json({
                status: 'success',
                message: 'Logout successful',
            });
        });
        /**
         * Refresh token
         * POST /api/v1/auth/refresh-token
         */
        this.refreshToken = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const userId = req.user.userId;
            // Verify user still exists and is active
            const user = await (0, database_1.default)('users')
                .where({ id: userId })
                .first();
            if (!user || !user.is_active) {
                throw new errorHandler_1.AuthenticationError('User not found or inactive');
            }
            // Generate new tokens
            const accessToken = (0, auth_middleware_1.generateToken)({
                id: user.id,
                tenantId: user.tenant_id,
                role: user.role,
                email: user.email,
            });
            const refreshToken = (0, auth_middleware_1.generateRefreshToken)({
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
        this.changePassword = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const userId = req.user.userId;
            const { current_password, new_password } = req.body;
            // Get user
            const user = await (0, database_1.default)('users')
                .where({ id: userId })
                .first();
            if (!user) {
                throw new errorHandler_1.NotFoundError('User');
            }
            // Verify current password
            const isPasswordValid = await bcryptjs_1.default.compare(current_password, user.password_hash);
            if (!isPasswordValid) {
                throw new errorHandler_1.ValidationError('Current password is incorrect');
            }
            // Hash new password
            const hashedPassword = await bcryptjs_1.default.hash(new_password, 12);
            // Update password
            await (0, database_1.default)('users')
                .where({ id: userId })
                .update({
                password_hash: hashedPassword,
                updated_at: new Date(),
            });
            logger_1.logger.info(`Password changed for user: ${userId}`);
            res.status(200).json({
                status: 'success',
                message: 'Password changed successfully',
            });
        });
    }
}
exports.AuthController = AuthController;
//# sourceMappingURL=auth.controller.js.map