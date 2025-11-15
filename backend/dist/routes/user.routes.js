"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const user_controller_1 = require("../controllers/user.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validator_1 = require("../middleware/validator");
const tenantContext_1 = require("../middleware/tenantContext");
const router = (0, express_1.Router)();
const userController = new user_controller_1.UserController();
// All routes require authentication
router.use(auth_middleware_1.authenticate);
router.use(tenantContext_1.tenantContext);
/**
 * @route   GET /api/v1/users
 * @desc    Get all users (admins only)
 * @access  Private/Admin
 */
router.get('/', (0, auth_middleware_1.authorize)('admin', 'developer'), validator_1.validatePagination, userController.getAllUsers);
/**
 * @route   GET /api/v1/users/:id
 * @desc    Get user by ID
 * @access  Private
 */
router.get('/:id', (0, validator_1.validateUUID)('id'), userController.getUserById);
/**
 * @route   PUT /api/v1/users/:id
 * @desc    Update user
 * @access  Private
 */
router.put('/:id', (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('first_name').optional().trim().notEmpty(),
    (0, express_validator_1.body)('last_name').optional().trim().notEmpty(),
    (0, express_validator_1.body)('email').optional().isEmail().normalizeEmail(),
    (0, express_validator_1.body)('phone').optional().isMobilePhone('any'),
    (0, express_validator_1.body)('date_of_birth').optional().isISO8601(),
    (0, express_validator_1.body)('gender').optional().isIn(['male', 'female', 'other']),
    (0, express_validator_1.body)('address').optional().trim(),
    (0, express_validator_1.body)('city').optional().trim(),
    (0, express_validator_1.body)('country').optional().trim(),
    (0, express_validator_1.body)('preferred_language').optional().isIn(['en', 'he', 'ar']),
]), userController.updateUser);
/**
 * @route   DELETE /api/v1/users/:id
 * @desc    Delete user (soft delete)
 * @access  Private/Admin
 */
router.delete('/:id', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), userController.deleteUser);
/**
 * @route   PUT /api/v1/users/:id/role
 * @desc    Update user role
 * @access  Private/Admin
 */
router.put('/:id/role', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('role').isIn(['patient', 'doctor', 'admin', 'developer']).withMessage('Invalid role'),
]), userController.updateUserRole);
/**
 * @route   PUT /api/v1/users/:id/status
 * @desc    Update user status (active/inactive)
 * @access  Private/Admin
 */
router.put('/:id/status', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('is_active').isBoolean().withMessage('is_active must be boolean'),
]), userController.updateUserStatus);
/**
 * @route   GET /api/v1/users/:id/activity
 * @desc    Get user activity log
 * @access  Private/Admin
 */
router.get('/:id/activity', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), validator_1.validatePagination, userController.getUserActivity);
exports.default = router;
//# sourceMappingURL=user.routes.js.map