"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const appointment_controller_1 = require("../controllers/appointment.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validation_middleware_1 = require("../middleware/validation.middleware");
const subscription_middleware_1 = require("../middleware/subscription.middleware");
const express_validator_1 = require("express-validator");
const router = (0, express_1.Router)();
const appointmentController = new appointment_controller_1.AppointmentController();
// All routes require authentication
router.use(auth_middleware_1.authenticate);
/**
 * @route   GET /api/v1/appointments
 * @desc    Get all appointments (filtered by role)
 * @access  Private
 */
router.get('/', [
    (0, express_validator_1.query)('page').optional().isInt({ min: 1 }),
    (0, express_validator_1.query)('limit').optional().isInt({ min: 1, max: 100 }),
    (0, express_validator_1.query)('status').optional().isIn(['scheduled', 'confirmed', 'completed', 'cancelled', 'no_show', 'rescheduled']),
    (0, express_validator_1.query)('doctorId').optional().isUUID(),
    (0, express_validator_1.query)('patientId').optional().isUUID(),
    (0, express_validator_1.query)('startDate').optional().isISO8601(),
    (0, express_validator_1.query)('endDate').optional().isISO8601(),
    validation_middleware_1.validateRequest,
], appointmentController.getAppointments.bind(appointmentController));
/**
 * @route   GET /api/v1/appointments/available-slots
 * @desc    Get available time slots for a doctor
 * @access  Private
 */
router.get('/available-slots', [
    (0, express_validator_1.query)('doctorId').notEmpty().isUUID().withMessage('Valid doctor ID is required'),
    (0, express_validator_1.query)('startDate').notEmpty().isISO8601().withMessage('Valid start date is required'),
    (0, express_validator_1.query)('endDate').optional().isISO8601(),
    (0, express_validator_1.query)('durationMinutes').optional().isInt({ min: 15, max: 480 }),
    validation_middleware_1.validateRequest,
], appointmentController.getAvailableSlots.bind(appointmentController));
/**
 * @route   GET /api/v1/appointments/:id
 * @desc    Get appointment by ID
 * @access  Private
 */
router.get('/:id', [(0, express_validator_1.param)('id').isUUID().withMessage('Valid appointment ID is required'), validation_middleware_1.validateRequest], appointmentController.getAppointmentById.bind(appointmentController));
/**
 * @route   POST /api/v1/appointments
 * @desc    Book a new appointment
 * @access  Private (requires active subscription for doctors)
 */
router.post('/', [
    (0, express_validator_1.body)('doctorId').notEmpty().isUUID().withMessage('Valid doctor ID is required'),
    (0, express_validator_1.body)('appointmentDate').notEmpty().isISO8601().withMessage('Valid appointment date is required'),
    (0, express_validator_1.body)('durationMinutes').optional().isInt({ min: 15, max: 480 }),
    (0, express_validator_1.body)('serviceId').optional().isUUID(),
    (0, express_validator_1.body)('notes').optional().isString().trim(),
    (0, express_validator_1.body)('location').optional().isString().trim(),
    (0, express_validator_1.body)('isTelehealth').optional().isBoolean(),
    (0, express_validator_1.body)('patientId').optional().isUUID(),
    validation_middleware_1.validateRequest,
], subscription_middleware_1.requireActiveSubscription, subscription_middleware_1.checkAppointmentLimit, appointmentController.bookAppointment.bind(appointmentController));
/**
 * @route   DELETE /api/v1/appointments/:id
 * @desc    Cancel appointment
 * @access  Private
 */
router.delete('/:id', [
    (0, express_validator_1.param)('id').isUUID().withMessage('Valid appointment ID is required'),
    (0, express_validator_1.body)('reason').optional().isString().trim(),
    validation_middleware_1.validateRequest,
], appointmentController.cancelAppointment.bind(appointmentController));
/**
 * @route   POST /api/v1/appointments/:id/reschedule
 * @desc    Reschedule appointment
 * @access  Private
 */
router.post('/:id/reschedule', [
    (0, express_validator_1.param)('id').isUUID().withMessage('Valid appointment ID is required'),
    (0, express_validator_1.body)('newAppointmentDate').notEmpty().isISO8601().withMessage('Valid new appointment date is required'),
    (0, express_validator_1.body)('durationMinutes').optional().isInt({ min: 15, max: 480 }),
    (0, express_validator_1.body)('reason').optional().isString().trim(),
    validation_middleware_1.validateRequest,
], appointmentController.rescheduleAppointment.bind(appointmentController));
/**
 * @route   POST /api/v1/appointments/:id/confirm
 * @desc    Confirm appointment
 * @access  Private (Patient or Doctor)
 */
router.post('/:id/confirm', [(0, express_validator_1.param)('id').isUUID().withMessage('Valid appointment ID is required'), validation_middleware_1.validateRequest], appointmentController.confirmAppointment.bind(appointmentController));
/**
 * @route   POST /api/v1/appointments/:id/no-show
 * @desc    Mark appointment as no-show
 * @access  Private (Doctor or Admin only)
 */
router.post('/:id/no-show', [(0, express_validator_1.param)('id').isUUID().withMessage('Valid appointment ID is required'), validation_middleware_1.validateRequest], appointmentController.markNoShow.bind(appointmentController));
exports.default = router;
//# sourceMappingURL=appointment.routes.js.map