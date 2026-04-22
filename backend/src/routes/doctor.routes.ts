import { Router } from 'express';
import { body } from 'express-validator';
import { DoctorController } from '../controllers/doctor.controller';
import { DoctorSMSController } from '../controllers/doctor-sms.controller';
import { DoctorSMSTemplatesController } from '../controllers/doctor-sms-templates.controller';
import { authenticate, authorize, optionalAuth } from '../middleware/auth.middleware';
import { validateRequest, validatePagination, validateUUID } from '../middleware/validator';
import { tenantContext } from '../middleware/tenantContext';

const router = Router();
const doctorController = new DoctorController();
const doctorSMSController = new DoctorSMSController();
const doctorSMSTemplatesController = new DoctorSMSTemplatesController();

/**
 * @route   GET /api/v1/doctors
 * @desc    Get all doctors (public - for browsing)
 * @access  Public
 */
router.get(
  '/',
  optionalAuth,
  validatePagination,
  doctorController.getAllDoctors
);

/**
 * @route   GET /api/v1/doctors/search
 * @desc    Search doctors by specialty, name, location
 * @access  Public
 */
router.get(
  '/search',
  optionalAuth,
  validatePagination,
  doctorController.searchDoctors
);

/**
 * @route   GET /api/v1/doctors/me
 * @desc    Get current doctor's profile
 * @access  Private/Doctor
 */
router.get(
  '/me',
  authenticate,
  tenantContext,
  doctorController.getMyDoctorProfile
);

/**
 * @route   GET /api/v1/doctors/:id
 * @desc    Get doctor by ID
 * @access  Public
 */
router.get(
  '/:id([0-9a-fA-F-]{36})',
  optionalAuth,
  validateUUID('id'),
  doctorController.getDoctorById
);

/**
 * @route   GET /api/v1/doctors/:id/availability
 * @desc    Get doctor availability
 * @access  Public
 */
router.get(
  '/:id([0-9a-fA-F-]{36})/availability',
  optionalAuth,
  validateUUID('id'),
  doctorController.getDoctorAvailability
);

/**
 * @route   GET /api/v1/doctors/:id/reviews
 * @desc    Get doctor reviews
 * @access  Public
 */
router.get(
  '/:id([0-9a-fA-F-]{36})/reviews',
  optionalAuth,
  validateUUID('id'),
  validatePagination,
  doctorController.getDoctorReviews
);

// Protected routes (require authentication)
router.use(authenticate);
router.use(tenantContext);

/**
 * @route   POST /api/v1/doctors
 * @desc    Create doctor profile
 * @access  Private/Admin
 */
router.post(
  '/',
  authorize('admin', 'developer'),
  validateRequest([
    body('user_id').isUUID().withMessage('Valid user ID required'),
    body('specialty').trim().notEmpty().withMessage('Specialty required').optional(),
    body('business_file_id')
      .trim()
      .notEmpty()
      .withMessage('Business identifier is required')
      .matches(/^\d{5,9}$/)
      .withMessage('Business identifier must be 5-9 digits'),
    body('license_number').optional().trim().isLength({ min: 3, max: 64 }),
    body('bio').optional().trim(),
    body('education')
      .optional()
      .custom((value) => Array.isArray(value) || typeof value === 'string'),
    body('certifications')
      .optional()
      .custom((value) => Array.isArray(value) || typeof value === 'string'),
    body('languages').optional().isArray(),
  ]),
  doctorController.createDoctor
);

/**
 * @route   PUT /api/v1/doctors/:id
 * @desc    Update doctor profile
 * @access  Private/Doctor/Admin
 */
router.put(
  '/:id([0-9a-fA-F-]{36})',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('specialty').optional().trim().notEmpty(),
    body('business_file_id').optional().trim().matches(/^\d{5,9}$/).withMessage('Business identifier must be 5-9 digits'),
    body('license_number').optional().trim().notEmpty(),
    body('bio').optional().trim(),
    body('education')
      .optional()
      .custom((value) => Array.isArray(value) || typeof value === 'string'),
    body('certifications')
      .optional()
      .custom((value) => Array.isArray(value) || typeof value === 'string'),
    body('languages').optional().isArray(),
  ]),
  doctorController.updateDoctor
);

/**
 * @route   PUT /api/v1/doctors/:id/schedule
 * @desc    Update doctor schedule/availability
 * @access  Private/Doctor/Admin
 */
router.put(
  '/:id([0-9a-fA-F-]{36})/schedule',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('working_hours').isArray().withMessage('Working hours must be an array'),
    body('working_hours.*.day_of_week').isInt({ min: 0, max: 6 }),
    body('working_hours.*.start_time').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    body('working_hours.*.end_time').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  ]),
  doctorController.updateSchedule
);

/**
 * @route   POST /api/v1/doctors/:id/time-off
 * @desc    Add time off / vacation
 * @access  Private/Doctor/Admin
 */
router.post(
  '/:id([0-9a-fA-F-]{36})/time-off',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('start_date').isISO8601().withMessage('Valid start date required'),
    body('end_date').isISO8601().withMessage('Valid end date required'),
    body('is_holiday').optional().isBoolean(),
    body('reason').optional().trim(),
  ]),
  doctorController.addTimeOff
);

/**
 * @route   GET /api/v1/doctors/:id/schedule-settings
 * @desc    Get doctor schedule settings (hours/breaks/time-off)
 * @access  Private/Doctor/Admin
 */
router.get(
  '/:id([0-9a-fA-F-]{36})/schedule-settings',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  doctorController.getScheduleSettings
);

/**
 * @route   PUT /api/v1/doctors/:id/schedule-settings
 * @desc    Save doctor schedule settings (hours/breaks/time-off)
 * @access  Private/Doctor/Admin
 */
router.put(
  '/:id([0-9a-fA-F-]{36})/schedule-settings',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('working_hours').isArray(),
    body('working_hours.*.day_of_week').isInt({ min: 0, max: 6 }),
    body('working_hours.*.start_time').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    body('working_hours.*.end_time').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    body('breaks').optional().isArray(),
    body('breaks.*.day_of_week').optional().isInt({ min: 0, max: 6 }),
    body('breaks.*.start_time').optional().matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    body('breaks.*.end_time').optional().matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    body('time_off').optional().isArray(),
    body('time_off.*.start_date').optional().isISO8601(),
    body('time_off.*.end_date').optional().isISO8601(),
    body('time_off.*.is_holiday').optional().isBoolean(),
    body('time_off.*.reason').optional().isString(),
  ]),
  doctorController.saveScheduleSettings
);

/**
 * @route   DELETE /api/v1/doctors/:id
 * @desc    Delete doctor (soft delete)
 * @access  Private/Admin
 */
router.delete(
  '/:id([0-9a-fA-F-]{36})',
  authorize('admin', 'developer'),
  validateUUID('id'),
  doctorController.deleteDoctor
);

/**
 * @route   GET /api/v1/doctors/:id/appointments
 * @desc    Get doctor's appointments
 * @access  Private/Doctor/Admin
 */
router.get(
  '/:id([0-9a-fA-F-]{36})/appointments',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  validatePagination,
  doctorController.getDoctorAppointments
);

/**
 * @route   GET /api/v1/doctors/:id/statistics
 * @desc    Get doctor statistics
 * @access  Private/Doctor/Admin
 */
router.get(
  '/:id([0-9a-fA-F-]{36})/statistics',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  doctorController.getDoctorStatistics
);

/**
 * @route   GET /api/v1/doctors/:doctorId/sms/settings
 * @desc    Get doctor SMS settings
 * @access  Private/Doctor/Admin
 */
router.get(
  '/:doctorId([0-9a-fA-F-]{36})/sms/settings',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('doctorId'),
  doctorSMSController.getSMSSettings
);

/**
 * @route   PUT /api/v1/doctors/:doctorId/sms/settings
 * @desc    Update doctor SMS settings
 * @access  Private/Doctor/Admin
 * @note    Only admin/developer can enable/disable SMS. Doctors can update preferences only.
 */
router.put(
  '/:doctorId([0-9a-fA-F-]{36})/sms/settings',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('doctorId'),
  validateRequest([
    body('sms_enabled').optional().isBoolean(), // Admin/Developer only
    body('send_appointment_reminders').optional().isBoolean(),
    body('send_appointment_confirmations').optional().isBoolean(),
    body('send_appointment_cancellations').optional().isBoolean(),
    body('send_payment_receipts').optional().isBoolean(),
    body('monthly_limit').optional().isNumeric(),
    body('auto_recharge').optional().isBoolean(),
    body('auto_recharge_amount').optional().isNumeric(),
    body('low_balance_threshold').optional().isNumeric(),
    body('has_discount').optional().isBoolean(), // Admin/Developer only - Enable/disable discount
    body('discount_percentage').optional().isFloat({ min: 0, max: 100 }).withMessage('Discount percentage must be between 0 and 100'), // Admin/Developer only
  ]),
  doctorSMSController.updateSMSSettings
);

/**
 * @route   POST /api/v1/doctors/:doctorId/sms/recharge
 * @desc    Recharge doctor SMS balance
 * @access  Private/Doctor/Admin
 */
router.post(
  '/:doctorId([0-9a-fA-F-]{36})/sms/recharge',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('doctorId'),
  validateRequest([
    body('amount').isNumeric().withMessage('Amount must be a number').isFloat({ min: 0.01 }).withMessage('Amount must be greater than 0'),
    body('payment_method').optional().isString(),
    body('payment_reference').optional().isString(),
  ]),
  doctorSMSController.rechargeBalance
);

/**
 * @route   GET /api/v1/doctors/:doctorId/sms/usage
 * @desc    Get doctor SMS usage history
 * @access  Private/Doctor/Admin
 */
router.get(
  '/:doctorId([0-9a-fA-F-]{36})/sms/usage',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('doctorId'),
  validatePagination,
  doctorSMSController.getUsageHistory
);

/**
 * @route   GET /api/v1/doctors/:doctorId/sms/billing
 * @desc    Get doctor SMS billing history
 * @access  Private/Doctor/Admin
 */
router.get(
  '/:doctorId([0-9a-fA-F-]{36})/sms/billing',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('doctorId'),
  validatePagination,
  doctorSMSController.getBillingHistory
);

/**
 * @route   GET /api/v1/doctors/:doctorId/sms/templates
 * @desc    Get doctor SMS templates (custom + defaults)
 * @access  Private/Doctor/Admin
 */
router.get(
  '/:doctorId([0-9a-fA-F-]{36})/sms/templates',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('doctorId'),
  doctorSMSTemplatesController.getTemplates
);

/**
 * @route   PUT /api/v1/doctors/:doctorId/sms/templates
 * @desc    Update doctor SMS template
 * @access  Private/Doctor/Admin
 */
router.put(
  '/:doctorId([0-9a-fA-F-]{36})/sms/templates',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('doctorId'),
  validateRequest([
    body('language').isIn(['he', 'ar', 'en']).withMessage('Language must be: he, ar, or en'),
    body('smsType').isIn(['reminder', 'confirmation', 'cancellation', 'payment', 'verification', 'general']).withMessage('SMS type must be: reminder, confirmation, cancellation, payment, verification, or general'),
    body('template').isString().notEmpty().withMessage('Template must be a non-empty string'),
  ]),
  doctorSMSTemplatesController.updateTemplate
);

/**
 * @route   DELETE /api/v1/doctors/:doctorId/sms/templates/:language/:smsType
 * @desc    Reset template to default
 * @access  Private/Doctor/Admin
 */
router.delete(
  '/:doctorId([0-9a-fA-F-]{36})/sms/templates/:language/:smsType',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('doctorId'),
  doctorSMSTemplatesController.resetTemplate
);

export default router;



