"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const tenant_controller_1 = require("../controllers/tenant.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validator_1 = require("../middleware/validator");
const tenantContext_1 = require("../middleware/tenantContext");
const router = (0, express_1.Router)();
const tenantController = new tenant_controller_1.TenantController();
// All routes require authentication
router.use(auth_middleware_1.authenticate);
/**
 * @route   GET /api/v1/tenants
 * @desc    Get all tenants (Developer only)
 * @access  Private/Developer
 */
router.get('/', (0, auth_middleware_1.authorize)('developer'), tenantContext_1.allowCrossTenant, validator_1.validatePagination, tenantController.getAllTenants);
/**
 * @route   GET /api/v1/tenants/current
 * @desc    Get current tenant info
 * @access  Private
 */
router.get('/current', tenantController.getCurrentTenant);
/**
 * @route   GET /api/v1/tenants/:id
 * @desc    Get tenant by ID
 * @access  Private/Developer
 */
router.get('/:id', (0, auth_middleware_1.authorize)('developer'), (0, validator_1.validateUUID)('id'), tenantController.getTenantById);
/**
 * @route   POST /api/v1/tenants
 * @desc    Create new tenant
 * @access  Private/Developer
 */
router.post('/', (0, auth_middleware_1.authorize)('developer'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('name').trim().notEmpty().withMessage('Tenant name is required'),
    (0, express_validator_1.body)('subdomain').trim().notEmpty().withMessage('Subdomain is required')
        .matches(/^[a-z0-9-]+$/).withMessage('Subdomain must be lowercase alphanumeric with hyphens'),
    (0, express_validator_1.body)('contact_email').isEmail().normalizeEmail().withMessage('Valid contact email required'),
    (0, express_validator_1.body)('contact_phone').optional().isMobilePhone('any'),
    (0, express_validator_1.body)('address').optional().trim(),
    (0, express_validator_1.body)('city').optional().trim(),
    (0, express_validator_1.body)('country').optional().trim(),
    (0, express_validator_1.body)('timezone').optional().trim(),
    (0, express_validator_1.body)('plan').optional().isIn(['starter', 'professional', 'enterprise']),
]), tenantController.createTenant);
/**
 * @route   PUT /api/v1/tenants/:id
 * @desc    Update tenant
 * @access  Private/Admin/Developer
 */
router.put('/:id', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('name').optional().trim().notEmpty(),
    (0, express_validator_1.body)('contact_email').optional().isEmail().normalizeEmail(),
    (0, express_validator_1.body)('contact_phone').optional().isMobilePhone('any'),
    (0, express_validator_1.body)('address').optional().trim(),
    (0, express_validator_1.body)('city').optional().trim(),
    (0, express_validator_1.body)('country').optional().trim(),
    (0, express_validator_1.body)('timezone').optional().trim(),
]), tenantController.updateTenant);
/**
 * @route   PUT /api/v1/tenants/:id/settings
 * @desc    Update tenant settings
 * @access  Private/Admin/Developer
 */
router.put('/:id/settings', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('booking_advance_days').optional().isInt({ min: 1, max: 365 }),
    (0, express_validator_1.body)('booking_buffer_minutes').optional().isInt({ min: 0, max: 120 }),
    (0, express_validator_1.body)('cancellation_hours').optional().isInt({ min: 0, max: 72 }),
    (0, express_validator_1.body)('default_appointment_duration').optional().isInt({ min: 15, max: 240 }),
    (0, express_validator_1.body)('working_hours_start').optional().matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    (0, express_validator_1.body)('working_hours_end').optional().matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    (0, express_validator_1.body)('enable_online_payments').optional().isBoolean(),
    (0, express_validator_1.body)('enable_sms_reminders').optional().isBoolean(),
    (0, express_validator_1.body)('enable_email_reminders').optional().isBoolean(),
    (0, express_validator_1.body)('enable_whatsapp_reminders').optional().isBoolean(),
]), tenantController.updateSettings);
/**
 * @route   PUT /api/v1/tenants/:id/branding
 * @desc    Update tenant branding
 * @access  Private/Admin/Developer
 */
router.put('/:id/branding', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('logo_url').optional().isURL(),
    (0, express_validator_1.body)('primary_color').optional().matches(/^#[0-9A-F]{6}$/i),
    (0, express_validator_1.body)('secondary_color').optional().matches(/^#[0-9A-F]{6}$/i),
    (0, express_validator_1.body)('favicon_url').optional().isURL(),
]), tenantController.updateBranding);
/**
 * @route   PUT /api/v1/tenants/:id/plan
 * @desc    Update tenant plan
 * @access  Private/Developer
 */
router.put('/:id/plan', (0, auth_middleware_1.authorize)('developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('plan').isIn(['starter', 'professional', 'enterprise']).withMessage('Invalid plan'),
    (0, express_validator_1.body)('billing_cycle').optional().isIn(['monthly', 'yearly']),
]), tenantController.updatePlan);
/**
 * @route   PUT /api/v1/tenants/:id/status
 * @desc    Update tenant status (active/suspended)
 * @access  Private/Developer
 */
router.put('/:id/status', (0, auth_middleware_1.authorize)('developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('is_active').isBoolean().withMessage('is_active must be boolean'),
    (0, express_validator_1.body)('reason').optional().trim(),
]), tenantController.updateStatus);
/**
 * @route   DELETE /api/v1/tenants/:id
 * @desc    Delete tenant (soft delete)
 * @access  Private/Developer
 */
router.delete('/:id', (0, auth_middleware_1.authorize)('developer'), (0, validator_1.validateUUID)('id'), tenantController.deleteTenant);
/**
 * @route   GET /api/v1/tenants/:id/statistics
 * @desc    Get tenant statistics
 * @access  Private/Admin/Developer
 */
router.get('/:id/statistics', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), tenantController.getTenantStatistics);
exports.default = router;
//# sourceMappingURL=tenant.routes.js.map