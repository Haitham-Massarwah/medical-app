import { Router } from 'express';
import { body } from 'express-validator';
import { DoctorController } from '../controllers/doctor.controller';
import { authenticate, authorize, optionalAuth } from '../middleware/auth.middleware';
import { validateRequest, validatePagination, validateUUID } from '../middleware/validator';
import { tenantContext } from '../middleware/tenantContext';

const router = Router();
const doctorController = new DoctorController();

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
 * @route   GET /api/v1/doctors/:id
 * @desc    Get doctor by ID
 * @access  Public
 */
router.get(
  '/:id',
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
  '/:id/availability',
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
  '/:id/reviews',
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
    body('license_number').trim().notEmpty().withMessage('License number required'),
    body('bio').optional().trim(),
    body('education').optional().isArray(),
    body('certifications').optional().isArray(),
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
  '/:id',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('specialty').optional().trim().notEmpty(),
    body('license_number').optional().trim().notEmpty(),
    body('bio').optional().trim(),
    body('education').optional().isArray(),
    body('certifications').optional().isArray(),
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
  '/:id/schedule',
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
  '/:id/time-off',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  validateRequest([
    body('start_date').isISO8601().withMessage('Valid start date required'),
    body('end_date').isISO8601().withMessage('Valid end date required'),
    body('reason').optional().trim(),
  ]),
  doctorController.addTimeOff
);

/**
 * @route   DELETE /api/v1/doctors/:id
 * @desc    Delete doctor (soft delete)
 * @access  Private/Admin
 */
router.delete(
  '/:id',
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
  '/:id/appointments',
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
  '/:id/statistics',
  authorize('doctor', 'admin', 'developer'),
  validateUUID('id'),
  doctorController.getDoctorStatistics
);

export default router;



