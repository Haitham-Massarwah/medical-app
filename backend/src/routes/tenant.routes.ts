import { Router } from 'express';
import { body } from 'express-validator';
import { TenantController } from '../controllers/tenant.controller';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { validateRequest, validatePagination, validateUUID } from '../middleware/validator';
import { allowCrossTenant } from '../middleware/tenantContext';
import { bodyOptionalLooseContactPhone } from '../middleware/phoneValidation';

const router = Router();
const tenantController = new TenantController();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/tenants
 * @desc    Get all tenants (Developer only)
 * @access  Private/Developer
 */
router.get(
  '/',
  authorize('developer'),
  allowCrossTenant,
  validatePagination,
  tenantController.getAllTenants
);

/**
 * @route   GET /api/v1/tenants/current
 * @desc    Get current tenant info
 * @access  Private
 */
router.get(
  '/current',
  tenantController.getCurrentTenant
);

/**
 * @route   GET /api/v1/tenants/:id
 * @desc    Get tenant by ID
 * @access  Private/Developer
 */
router.get(
  '/:id',
  authorize('developer'),
  validateUUID('id'),
  tenantController.getTenantById
);

/**
 * @route   POST /api/v1/tenants
 * @desc    Create new tenant
 * @access  Private/Developer
 */
router.post(
  '/',
  authorize('developer'),
  validateRequest([
    body('name').trim().notEmpty().withMessage('Tenant name is required'),
    body('subdomain').trim().notEmpty().withMessage('Subdomain is required')
      .matches(/^[a-z0-9-]+$/).withMessage('Subdomain must be lowercase alphanumeric with hyphens'),
    body('contact_email').isEmail().normalizeEmail().withMessage('Valid contact email required'),
    bodyOptionalLooseContactPhone(),
    body('address').optional().trim(),
    body('city').optional().trim(),
    body('country').optional().trim(),
    body('timezone').optional().trim(),
    body('plan').optional().isIn(['starter', 'professional', 'enterprise']),
  ]),
  tenantController.createTenant
);

/**
 * @route   PUT /api/v1/tenants/:id
 * @desc    Update tenant
 * @access  Private/Admin/Developer
 */
router.put(
  '/:id',
  authorize('admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('name').optional().trim().notEmpty(),
    body('contact_email').optional().isEmail().normalizeEmail(),
    bodyOptionalLooseContactPhone(),
    body('address').optional().trim(),
    body('city').optional().trim(),
    body('country').optional().trim(),
    body('timezone').optional().trim(),
  ]),
  tenantController.updateTenant
);

/**
 * @route   PUT /api/v1/tenants/:id/settings
 * @desc    Update tenant settings
 * @access  Private/Admin/Developer
 */
router.put(
  '/:id/settings',
  authorize('admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('booking_advance_days').optional().isInt({ min: 1, max: 365 }),
    body('booking_buffer_minutes').optional().isInt({ min: 0, max: 120 }),
    body('cancellation_hours').optional().isInt({ min: 0, max: 72 }),
    body('default_appointment_duration').optional().isInt({ min: 15, max: 240 }),
    body('working_hours_start').optional().matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    body('working_hours_end').optional().matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    body('enable_online_payments').optional().isBoolean(),
    body('enable_sms_reminders').optional().isBoolean(),
    body('enable_email_reminders').optional().isBoolean(),
    body('enable_whatsapp_reminders').optional().isBoolean(),
  ]),
  tenantController.updateSettings
);

/**
 * @route   PUT /api/v1/tenants/:id/branding
 * @desc    Update tenant branding
 * @access  Private/Admin/Developer
 */
router.put(
  '/:id/branding',
  authorize('admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('logo_url').optional().isURL(),
    body('primary_color').optional().matches(/^#[0-9A-F]{6}$/i),
    body('secondary_color').optional().matches(/^#[0-9A-F]{6}$/i),
    body('favicon_url').optional().isURL(),
  ]),
  tenantController.updateBranding
);

/**
 * @route   PUT /api/v1/tenants/:id/plan
 * @desc    Update tenant plan
 * @access  Private/Developer
 */
router.put(
  '/:id/plan',
  authorize('developer'),
  validateUUID('id'),
  validateRequest([
    body('plan').isIn(['starter', 'professional', 'enterprise']).withMessage('Invalid plan'),
    body('billing_cycle').optional().isIn(['monthly', 'yearly']),
  ]),
  tenantController.updatePlan
);

/**
 * @route   PUT /api/v1/tenants/:id/status
 * @desc    Update tenant status (active/suspended)
 * @access  Private/Developer
 */
router.put(
  '/:id/status',
  authorize('developer'),
  validateUUID('id'),
  validateRequest([
    body('is_active').isBoolean().withMessage('is_active must be boolean'),
    body('reason').optional().trim(),
  ]),
  tenantController.updateStatus
);

/**
 * @route   DELETE /api/v1/tenants/:id
 * @desc    Delete tenant (soft delete)
 * @access  Private/Developer
 */
router.delete(
  '/:id',
  authorize('developer'),
  validateUUID('id'),
  tenantController.deleteTenant
);

/**
 * @route   GET /api/v1/tenants/:id/statistics
 * @desc    Get tenant statistics
 * @access  Private/Admin/Developer
 */
router.get(
  '/:id/statistics',
  authorize('admin', 'developer'),
  validateUUID('id'),
  tenantController.getTenantStatistics
);

export default router;



