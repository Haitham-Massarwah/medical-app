"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const doctor_controller_1 = require("../controllers/doctor.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validator_1 = require("../middleware/validator");
const tenantContext_1 = require("../middleware/tenantContext");
const router = (0, express_1.Router)();
const doctorController = new doctor_controller_1.DoctorController();
/**
 * @route   GET /api/v1/doctors
 * @desc    Get all doctors (public - for browsing)
 * @access  Public
 */
router.get('/', auth_middleware_1.optionalAuth, validator_1.validatePagination, doctorController.getAllDoctors);
/**
 * @route   GET /api/v1/doctors/search
 * @desc    Search doctors by specialty, name, location
 * @access  Public
 */
router.get('/search', auth_middleware_1.optionalAuth, validator_1.validatePagination, doctorController.searchDoctors);
/**
 * @route   GET /api/v1/doctors/:id
 * @desc    Get doctor by ID
 * @access  Public
 */
router.get('/:id', auth_middleware_1.optionalAuth, (0, validator_1.validateUUID)('id'), doctorController.getDoctorById);
/**
 * @route   GET /api/v1/doctors/:id/availability
 * @desc    Get doctor availability
 * @access  Public
 */
router.get('/:id/availability', auth_middleware_1.optionalAuth, (0, validator_1.validateUUID)('id'), doctorController.getDoctorAvailability);
/**
 * @route   GET /api/v1/doctors/:id/reviews
 * @desc    Get doctor reviews
 * @access  Public
 */
router.get('/:id/reviews', auth_middleware_1.optionalAuth, (0, validator_1.validateUUID)('id'), validator_1.validatePagination, doctorController.getDoctorReviews);
// Protected routes (require authentication)
router.use(auth_middleware_1.authenticate);
router.use(tenantContext_1.tenantContext);
/**
 * @route   POST /api/v1/doctors
 * @desc    Create doctor profile
 * @access  Private/Admin
 */
router.post('/', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('user_id').isUUID().withMessage('Valid user ID required'),
    (0, express_validator_1.body)('specialty').trim().notEmpty().withMessage('Specialty required').optional(),
    (0, express_validator_1.body)('license_number').trim().notEmpty().withMessage('License number required'),
    (0, express_validator_1.body)('bio').optional().trim(),
    (0, express_validator_1.body)('education').optional().isArray(),
    (0, express_validator_1.body)('certifications').optional().isArray(),
    (0, express_validator_1.body)('languages').optional().isArray(),
]), doctorController.createDoctor);
/**
 * @route   PUT /api/v1/doctors/:id
 * @desc    Update doctor profile
 * @access  Private/Doctor/Admin
 */
router.put('/:id', (0, auth_middleware_1.authorize)('doctor', 'admin', 'developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('specialty').optional().trim().notEmpty(),
    (0, express_validator_1.body)('license_number').optional().trim().notEmpty(),
    (0, express_validator_1.body)('bio').optional().trim(),
    (0, express_validator_1.body)('education').optional().isArray(),
    (0, express_validator_1.body)('certifications').optional().isArray(),
    (0, express_validator_1.body)('languages').optional().isArray(),
]), doctorController.updateDoctor);
/**
 * @route   PUT /api/v1/doctors/:id/schedule
 * @desc    Update doctor schedule/availability
 * @access  Private/Doctor/Admin
 */
router.put('/:id/schedule', (0, auth_middleware_1.authorize)('doctor', 'admin', 'developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('working_hours').isArray().withMessage('Working hours must be an array'),
    (0, express_validator_1.body)('working_hours.*.day_of_week').isInt({ min: 0, max: 6 }),
    (0, express_validator_1.body)('working_hours.*.start_time').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
    (0, express_validator_1.body)('working_hours.*.end_time').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
]), doctorController.updateSchedule);
/**
 * @route   POST /api/v1/doctors/:id/time-off
 * @desc    Add time off / vacation
 * @access  Private/Doctor/Admin
 */
router.post('/:id/time-off', (0, auth_middleware_1.authorize)('doctor', 'admin', 'developer'), (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('start_date').isISO8601().withMessage('Valid start date required'),
    (0, express_validator_1.body)('end_date').isISO8601().withMessage('Valid end date required'),
    (0, express_validator_1.body)('reason').optional().trim(),
]), doctorController.addTimeOff);
/**
 * @route   DELETE /api/v1/doctors/:id
 * @desc    Delete doctor (soft delete)
 * @access  Private/Admin
 */
router.delete('/:id', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), doctorController.deleteDoctor);
/**
 * @route   GET /api/v1/doctors/:id/appointments
 * @desc    Get doctor's appointments
 * @access  Private/Doctor/Admin
 */
router.get('/:id/appointments', (0, auth_middleware_1.authorize)('doctor', 'admin', 'developer'), (0, validator_1.validateUUID)('id'), validator_1.validatePagination, doctorController.getDoctorAppointments);
/**
 * @route   GET /api/v1/doctors/:id/statistics
 * @desc    Get doctor statistics
 * @access  Private/Doctor/Admin
 */
router.get('/:id/statistics', (0, auth_middleware_1.authorize)('doctor', 'admin', 'developer'), (0, validator_1.validateUUID)('id'), doctorController.getDoctorStatistics);
exports.default = router;
//# sourceMappingURL=doctor.routes.js.map