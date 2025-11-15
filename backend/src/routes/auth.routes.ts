import { Router } from 'express';
import { body } from 'express-validator';
import { AuthController } from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validator';
import { strictRateLimiter } from '../middleware/rateLimiter';

const router = Router();
const authController = new AuthController();

/**
 * @route   POST /api/v1/auth/register
 * @desc    Register new user
 * @access  Public
 */
router.post(
  '/register',
  strictRateLimiter,
  validateRequest([
    body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
    body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
    body('first_name').trim().notEmpty().withMessage('First name is required'),
    body('last_name').trim().notEmpty().withMessage('Last name is required'),
    body('phone').optional().isMobilePhone('any').withMessage('Valid phone number required'),
    body('role').isIn(['patient', 'doctor', 'admin']).withMessage('Invalid role'),
    body('tenant_id').optional().isUUID().withMessage('Invalid tenant ID'),
  ]),
  authController.register
);

/**
 * @route   POST /api/v1/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post(
  '/login',
  strictRateLimiter,
  validateRequest([
    body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ]),
  authController.login
);

/**
 * @route   POST /api/v1/auth/forgot-password
 * @desc    Request password reset
 * @access  Public
 */
router.post(
  '/forgot-password',
  strictRateLimiter,
  validateRequest([
    body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  ]),
  authController.forgotPassword
);

/**
 * @route   POST /api/v1/auth/reset-password/:token
 * @desc    Reset password with token
 * @access  Public
 */
router.post(
  '/reset-password/:token',
  strictRateLimiter,
  validateRequest([
    body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
  ]),
  authController.resetPassword
);

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
router.get('/me', authenticate, authController.getCurrentUser);

/**
 * @route   POST /api/v1/auth/logout
 * @desc    Logout user
 * @access  Private
 */
router.post('/logout', authenticate, authController.logout);

/**
 * @route   POST /api/v1/auth/refresh-token
 * @desc    Refresh access token
 * @access  Private
 */
router.post('/refresh-token', authenticate, authController.refreshToken);

/**
 * @route   PUT /api/v1/auth/change-password
 * @desc    Change password (logged in)
 * @access  Private
 */
router.put(
  '/change-password',
  authenticate,
  validateRequest([
    body('current_password').notEmpty().withMessage('Current password is required'),
    body('new_password').isLength({ min: 8 }).withMessage('New password must be at least 8 characters'),
  ]),
  authController.changePassword
);

export default router;



