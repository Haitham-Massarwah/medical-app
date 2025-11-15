"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const auth_controller_1 = require("../controllers/auth.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validator_1 = require("../middleware/validator");
const rateLimiter_1 = require("../middleware/rateLimiter");
const router = (0, express_1.Router)();
const authController = new auth_controller_1.AuthController();
/**
 * @route   POST /api/v1/auth/register
 * @desc    Register new user
 * @access  Public
 */
router.post('/register', rateLimiter_1.strictRateLimiter, (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
    (0, express_validator_1.body)('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
    (0, express_validator_1.body)('first_name').trim().notEmpty().withMessage('First name is required'),
    (0, express_validator_1.body)('last_name').trim().notEmpty().withMessage('Last name is required'),
    (0, express_validator_1.body)('phone').optional().isMobilePhone('any').withMessage('Valid phone number required'),
    (0, express_validator_1.body)('role').isIn(['patient', 'doctor', 'admin']).withMessage('Invalid role'),
    (0, express_validator_1.body)('tenant_id').optional().isUUID().withMessage('Invalid tenant ID'),
]), authController.register);
/**
 * @route   POST /api/v1/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post('/login', rateLimiter_1.strictRateLimiter, (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
    (0, express_validator_1.body)('password').notEmpty().withMessage('Password is required'),
]), authController.login);
/**
 * @route   POST /api/v1/auth/forgot-password
 * @desc    Request password reset
 * @access  Public
 */
router.post('/forgot-password', rateLimiter_1.strictRateLimiter, (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
]), authController.forgotPassword);
/**
 * @route   POST /api/v1/auth/reset-password/:token
 * @desc    Reset password with token
 * @access  Public
 */
router.post('/reset-password/:token', rateLimiter_1.strictRateLimiter, (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
]), authController.resetPassword);
/**
 * @route   POST /api/v1/auth/verify-email/:token
 * @desc    Verify email address
 * @access  Public
 */
router.post('/verify-email/:token', authController.verifyEmail);
/**
 * @route   GET /api/v1/auth/me
 * @desc    Get current user
 * @access  Private
 */
router.get('/me', auth_middleware_1.authenticate, authController.getCurrentUser);
/**
 * @route   POST /api/v1/auth/logout
 * @desc    Logout user
 * @access  Private
 */
router.post('/logout', auth_middleware_1.authenticate, authController.logout);
/**
 * @route   POST /api/v1/auth/refresh-token
 * @desc    Refresh access token
 * @access  Private
 */
router.post('/refresh-token', auth_middleware_1.authenticate, authController.refreshToken);
/**
 * @route   PUT /api/v1/auth/change-password
 * @desc    Change password (logged in)
 * @access  Private
 */
router.put('/change-password', auth_middleware_1.authenticate, (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('current_password').notEmpty().withMessage('Current password is required'),
    (0, express_validator_1.body)('new_password').isLength({ min: 8 }).withMessage('New password must be at least 8 characters'),
]), authController.changePassword);
exports.default = router;
//# sourceMappingURL=auth.routes.js.map