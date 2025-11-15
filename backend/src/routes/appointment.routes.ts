import { Router } from 'express';
import { AppointmentController } from '../controllers/appointment.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validation.middleware';
import { requireActiveSubscription, checkAppointmentLimit } from '../middleware/subscription.middleware';
import { body, query, param } from 'express-validator';

const router = Router();
const appointmentController = new AppointmentController();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/appointments
 * @desc    Get all appointments (filtered by role)
 * @access  Private
 */
router.get(
  '/',
  [
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 }),
    query('status').optional().isIn(['scheduled', 'confirmed', 'completed', 'cancelled', 'no_show', 'rescheduled']),
    query('doctorId').optional().isUUID(),
    query('patientId').optional().isUUID(),
    query('startDate').optional().isISO8601(),
    query('endDate').optional().isISO8601(),
    validateRequest,
  ],
  appointmentController.getAppointments.bind(appointmentController)
);

/**
 * @route   GET /api/v1/appointments/available-slots
 * @desc    Get available time slots for a doctor
 * @access  Private
 */
router.get(
  '/available-slots',
  [
    query('doctorId').notEmpty().isUUID().withMessage('Valid doctor ID is required'),
    query('startDate').notEmpty().isISO8601().withMessage('Valid start date is required'),
    query('endDate').optional().isISO8601(),
    query('durationMinutes').optional().isInt({ min: 15, max: 480 }),
    validateRequest,
  ],
  appointmentController.getAvailableSlots.bind(appointmentController)
);

/**
 * @route   GET /api/v1/appointments/:id
 * @desc    Get appointment by ID
 * @access  Private
 */
router.get(
  '/:id',
  [param('id').isUUID().withMessage('Valid appointment ID is required'), validateRequest],
  appointmentController.getAppointmentById.bind(appointmentController)
);

/**
 * @route   POST /api/v1/appointments
 * @desc    Book a new appointment
 * @access  Private (requires active subscription for doctors)
 */
router.post(
  '/',
  [
    body('doctorId').notEmpty().isUUID().withMessage('Valid doctor ID is required'),
    body('appointmentDate').notEmpty().isISO8601().withMessage('Valid appointment date is required'),
    body('durationMinutes').optional().isInt({ min: 15, max: 480 }),
    body('serviceId').optional().isUUID(),
    body('notes').optional().isString().trim(),
    body('location').optional().isString().trim(),
    body('isTelehealth').optional().isBoolean(),
    body('patientId').optional().isUUID(),
    validateRequest,
  ],
  requireActiveSubscription,
  checkAppointmentLimit,
  appointmentController.bookAppointment.bind(appointmentController)
);

/**
 * @route   DELETE /api/v1/appointments/:id
 * @desc    Cancel appointment
 * @access  Private
 */
router.delete(
  '/:id',
  [
    param('id').isUUID().withMessage('Valid appointment ID is required'),
    body('reason').optional().isString().trim(),
    validateRequest,
  ],
  appointmentController.cancelAppointment.bind(appointmentController)
);

/**
 * @route   POST /api/v1/appointments/:id/reschedule
 * @desc    Reschedule appointment
 * @access  Private
 */
router.post(
  '/:id/reschedule',
  [
    param('id').isUUID().withMessage('Valid appointment ID is required'),
    body('newAppointmentDate').notEmpty().isISO8601().withMessage('Valid new appointment date is required'),
    body('durationMinutes').optional().isInt({ min: 15, max: 480 }),
    body('reason').optional().isString().trim(),
    validateRequest,
  ],
  appointmentController.rescheduleAppointment.bind(appointmentController)
);

/**
 * @route   POST /api/v1/appointments/:id/confirm
 * @desc    Confirm appointment
 * @access  Private (Patient or Doctor)
 */
router.post(
  '/:id/confirm',
  [param('id').isUUID().withMessage('Valid appointment ID is required'), validateRequest],
  appointmentController.confirmAppointment.bind(appointmentController)
);

/**
 * @route   POST /api/v1/appointments/:id/no-show
 * @desc    Mark appointment as no-show
 * @access  Private (Doctor or Admin only)
 */
router.post(
  '/:id/no-show',
  [param('id').isUUID().withMessage('Valid appointment ID is required'), validateRequest],
  appointmentController.markNoShow.bind(appointmentController)
);

export default router;
