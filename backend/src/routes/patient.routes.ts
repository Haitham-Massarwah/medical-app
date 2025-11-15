import { Router } from 'express';
import { body } from 'express-validator';
import { PatientController } from '../controllers/patient.controller';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { validateRequest, validatePagination, validateUUID } from '../middleware/validator';
import { tenantContext } from '../middleware/tenantContext';

const router = Router();
const patientController = new PatientController();

// All routes require authentication
router.use(authenticate);
router.use(tenantContext);

/**
 * @route   GET /api/v1/patients
 * @desc    Get all patients
 * @access  Private/Doctor/Admin
 */
router.get(
  '/',
  authorize('doctor', 'admin', 'developer'),
  validatePagination,
  patientController.getAllPatients
);

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
router.get(
  '/:id',
  validateUUID('id'),
  patientController.getPatientById
);

/**
 * @route   POST /api/v1/patients
 * @desc    Create patient profile
 * @access  Private
 */
router.post(
  '/',
  validateRequest([
    body('user_id').isUUID().withMessage('Valid user ID required'),
    body('blood_type').optional().isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
    body('height').optional().isFloat({ min: 0 }),
    body('weight').optional().isFloat({ min: 0 }),
    body('allergies').optional().isArray(),
    body('chronic_conditions').optional().isArray(),
    body('current_medications').optional().isArray(),
    body('emergency_contact_name').optional().trim(),
    body('emergency_contact_phone').optional().isMobilePhone('any'),
  ]),
  patientController.createPatient
);

/**
 * @route   PUT /api/v1/patients/:id
 * @desc    Update patient profile
 * @access  Private
 */
router.put(
  '/:id',
  validateUUID('id'),
  validateRequest([
    body('blood_type').optional().isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
    body('height').optional().isFloat({ min: 0 }),
    body('weight').optional().isFloat({ min: 0 }),
    body('allergies').optional().isArray(),
    body('chronic_conditions').optional().isArray(),
    body('current_medications').optional().isArray(),
    body('emergency_contact_name').optional().trim(),
    body('emergency_contact_phone').optional().isMobilePhone('any'),
  ]),
  patientController.updatePatient
);

/**
 * @route   DELETE /api/v1/patients/:id
 * @desc    Delete patient (soft delete)
 * @access  Private/Admin
 */
router.delete(
  '/:id',
  authorize('admin', 'developer'),
  validateUUID('id'),
  patientController.deletePatient
);

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

export default router;



