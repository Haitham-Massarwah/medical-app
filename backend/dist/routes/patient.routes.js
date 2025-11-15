"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const patient_controller_1 = require("../controllers/patient.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validator_1 = require("../middleware/validator");
const tenantContext_1 = require("../middleware/tenantContext");
const router = (0, express_1.Router)();
const patientController = new patient_controller_1.PatientController();
// All routes require authentication
router.use(auth_middleware_1.authenticate);
router.use(tenantContext_1.tenantContext);
/**
 * @route   GET /api/v1/patients
 * @desc    Get all patients
 * @access  Private/Doctor/Admin
 */
router.get('/', (0, auth_middleware_1.authorize)('doctor', 'admin', 'developer'), validator_1.validatePagination, patientController.getAllPatients);
/**
 * @route   GET /api/v1/patients/search
 * @desc    Search patients
 * @access  Private/Doctor/Admin
 */
// TODO: Implement searchPatients method
// router.get(
//   '/search',
//   authorize('doctor', 'admin', 'developer'),
//   validatePagination,
//   patientController.searchPatients
// );
/**
 * @route   GET /api/v1/patients/:id
 * @desc    Get patient by ID
 * @access  Private
 */
router.get('/:id', (0, validator_1.validateUUID)('id'), patientController.getPatientById);
/**
 * @route   POST /api/v1/patients
 * @desc    Create patient profile
 * @access  Private
 */
router.post('/', (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('user_id').isUUID().withMessage('Valid user ID required'),
    (0, express_validator_1.body)('blood_type').optional().isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
    (0, express_validator_1.body)('height').optional().isFloat({ min: 0 }),
    (0, express_validator_1.body)('weight').optional().isFloat({ min: 0 }),
    (0, express_validator_1.body)('allergies').optional().isArray(),
    (0, express_validator_1.body)('chronic_conditions').optional().isArray(),
    (0, express_validator_1.body)('current_medications').optional().isArray(),
    (0, express_validator_1.body)('emergency_contact_name').optional().trim(),
    (0, express_validator_1.body)('emergency_contact_phone').optional().isMobilePhone('any'),
]), patientController.createPatient);
/**
 * @route   PUT /api/v1/patients/:id
 * @desc    Update patient profile
 * @access  Private
 */
router.put('/:id', (0, validator_1.validateUUID)('id'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('blood_type').optional().isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
    (0, express_validator_1.body)('height').optional().isFloat({ min: 0 }),
    (0, express_validator_1.body)('weight').optional().isFloat({ min: 0 }),
    (0, express_validator_1.body)('allergies').optional().isArray(),
    (0, express_validator_1.body)('chronic_conditions').optional().isArray(),
    (0, express_validator_1.body)('current_medications').optional().isArray(),
    (0, express_validator_1.body)('emergency_contact_name').optional().trim(),
    (0, express_validator_1.body)('emergency_contact_phone').optional().isMobilePhone('any'),
]), patientController.updatePatient);
/**
 * @route   DELETE /api/v1/patients/:id
 * @desc    Delete patient (soft delete)
 * @access  Private/Admin
 */
router.delete('/:id', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateUUID)('id'), patientController.deletePatient);
/**
 * @route   GET /api/v1/patients/:id/appointments
 * @desc    Get patient appointments
 * @access  Private
 */
// TODO: Implement getPatientAppointments method
// router.get(
//   '/:id/appointments',
//   validateUUID('id'),
//   validatePagination,
//   patientController.getPatientAppointments
// );
/**
 * @route   GET /api/v1/patients/:id/medical-history
 * @desc    Get patient medical history
 * @access  Private/Doctor/Admin
 */
// TODO: Implement getMedicalHistory method
// router.get(
//   '/:id/medical-history',
//   authorize('patient', 'doctor', 'admin', 'developer'),
//   validateUUID('id'),
//   validatePagination,
//   patientController.getMedicalHistory
// );
/**
 * @route   POST /api/v1/patients/:id/medical-records
 * @desc    Add medical record
 * @access  Private/Doctor/Admin
 */
// TODO: Implement addMedicalRecord method
// router.post(
//   '/:id/medical-records',
//   authorize('doctor', 'admin', 'developer'),
//   validateUUID('id'),
//   validateRequest([
//     body('record_type').isIn(['diagnosis', 'prescription', 'lab_result', 'imaging', 'note']),
//     body('title').trim().notEmpty(),
//     body('description').trim().notEmpty(),
//     body('doctor_id').isUUID(),
//     body('appointment_id').optional().isUUID(),
//     body('attachments').optional().isArray(),
//   ]),
//   patientController.addMedicalRecord
// );
/**
 * @route   GET /api/v1/patients/:id/medical-records
 * @desc    Get patient medical records
 * @access  Private
 */
// TODO: Implement getMedicalRecords method
// router.get(
//   '/:id/medical-records',
//   validateUUID('id'),
//   validatePagination,
//   patientController.getMedicalRecords
// );
/**
 * @route   GET /api/v1/patients/:id/statistics
 * @desc    Get patient statistics
 * @access  Private
 */
// TODO: Implement getPatientStatistics method
// router.get(
//   '/:id/statistics',
//   validateUUID('id'),
//   patientController.getPatientStatistics
// );
exports.default = router;
//# sourceMappingURL=patient.routes.js.map