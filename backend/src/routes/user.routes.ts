import { Router } from 'express';
import { body } from 'express-validator';
import { UserController } from '../controllers/user.controller';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { validateRequest, validatePagination, validateUUID } from '../middleware/validator';
import { tenantContext } from '../middleware/tenantContext';

const router = Router();
const userController = new UserController();

// All routes require authentication
router.use(authenticate);
router.use(tenantContext);

/**
 * @route   GET /api/v1/users
 * @desc    Get all users (admins only)
 * @access  Private/Admin
 */
router.get(
  '/',
  authorize('admin', 'developer'),
  validatePagination,
  userController.getAllUsers
);

/**
 * @route   POST /api/v1/users
 * @desc    Create staff user (receptionist)
 * @access  Private/Admin/Developer
 */
router.post(
  '/',
  authorize('admin', 'developer'),
  validateRequest([
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
    body('first_name').trim().notEmpty(),
    body('last_name').trim().notEmpty(),
    body('phone').optional().isMobilePhone('any'),
    body('role').equals('receptionist').withMessage('role must be receptionist'),
  ]),
  userController.createStaffUser
);

/**
 * @route   GET /api/v1/users/:id
 * @desc    Get user by ID
 * @access  Private
 */
router.get(
  '/:id',
  validateUUID('id'),
  userController.getUserById
);

/**
 * @route   PUT /api/v1/users/:id
 * @desc    Update user
 * @access  Private
 */
router.put(
  '/:id',
  validateUUID('id'),
  validateRequest([
    body('first_name').optional().trim().notEmpty(),
    body('last_name').optional().trim().notEmpty(),
    body('email').optional().isEmail().normalizeEmail(),
    body('phone').optional().isMobilePhone('any'),
    body('date_of_birth').optional().isISO8601(),
    body('gender').optional().isIn(['male', 'female', 'other']),
    body('address').optional().trim(),
    body('city').optional().trim(),
    body('country').optional().trim(),
    body('id_number').optional().trim(),
    body('zip_code').optional().trim(),
    body('preferred_language').optional().isIn(['en', 'he', 'ar']),
  ]),
  userController.updateUser
);

/**
 * @route   DELETE /api/v1/users/:id
 * @desc    Delete user (soft delete)
 * @access  Private/Admin
 */
router.delete(
  '/:id',
  authorize('admin', 'developer'),
  validateUUID('id'),
  userController.deleteUser
);

/**
 * @route   PUT /api/v1/users/:id/role
 * @desc    Update user role
 * @access  Private/Admin
 */
router.put(
  '/:id/role',
  authorize('admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('role')
      .isIn(['patient', 'doctor', 'admin', 'developer', 'receptionist'])
      .withMessage('Invalid role'),
  ]),
  userController.updateUserRole
);

/**
 * @route   PUT /api/v1/users/:id/status
 * @desc    Update user status (active/inactive)
 * @access  Private/Admin
 */
router.put(
  '/:id/status',
  authorize('admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('is_active').isBoolean().withMessage('is_active must be boolean'),
  ]),
  userController.updateUserStatus
);

/**
 * @route   GET /api/v1/users/:id/activity
 * @desc    Get user activity log
 * @access  Private/Admin
 */
router.get(
  '/:id/activity',
  authorize('admin', 'developer'),
  validateUUID('id'),
  validatePagination,
  userController.getUserActivity
);

export default router;



