import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { body, param } from 'express-validator';
import { PatientController } from '../controllers/patient.controller';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { isValidIsraeliId, validateRequest, validatePagination, validateUUID } from '../middleware/validator';
import { tenantContext } from '../middleware/tenantContext';
import { requireAccountPermission } from '../middleware/accountPermissions.middleware';
import { bodyOptionalLooseEmergencyPhone } from '../middleware/phoneValidation';

const router = Router();
const patientController = new PatientController();
const validatePatientIdParam = validateRequest([
  param('id').isUUID().withMessage('Valid patient ID is required'),
]);
const validateIsraeliIdParam = validateRequest([
  param('idNumber')
    .trim()
    .notEmpty()
    .withMessage('Israeli ID is required')
    .bail()
    .custom((value) => isValidIsraeliId(String(value)))
    .withMessage('Valid Israeli ID is required'),
]);

const allowedFileTypes = [
  'image/jpeg',
  'image/png',
  'application/pdf',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'video/mp4',
  'audio/mpeg',
];

const allowedExtensions = [
  '.jpg',
  '.jpeg',
  '.png',
  '.pdf',
  '.docx',
  '.mp4',
  '.mp3',
];

const storage = multer.diskStorage({
  destination: (req, _file, cb) => {
    const { recordId } = req.params as { recordId: string };
    const uploadPath = path.resolve(process.cwd(), 'uploads', 'medical-records', recordId);
    fs.mkdirSync(uploadPath, { recursive: true });
    cb(null, uploadPath);
  },
  filename: (_req, file, cb) => {
    const timestamp = Date.now();
    const safeName = file.originalname.replace(/[^a-zA-Z0-9.\-_]/g, '_');
    cb(null, `${timestamp}-${safeName}`);
  },
});

const upload = multer({
  storage,
  fileFilter: (_req, file, cb) => {
    if (allowedFileTypes.includes(file.mimetype)) {
      return cb(null, true);
    }
    if (file.mimetype === 'application/octet-stream') {
      const ext = path.extname(file.originalname).toLowerCase();
      if (allowedExtensions.includes(ext)) {
        return cb(null, true);
      }
    }
    return cb(new Error('Unsupported file type'));
  },
  limits: {
    fileSize: 25 * 1024 * 1024, // 25MB
    files: 10,
  },
});

// All routes require authentication
router.use(authenticate);
router.use(tenantContext);
router.use(requireAccountPermission('can_manage_doctors'));

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
 * @route   GET /api/v1/patients/me/medical-records
 * @desc    Get current patient medical records
 * @access  Private/Patient
 */
router.get(
  '/me/medical-records',
  authorize('patient'),
  patientController.getMyMedicalRecords
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
 * @route   GET /api/v1/patients/by-israeli-id/:idNumber
 * @desc    Get patient by Israeli ID
 * @access  Private
 */
router.get(
  '/by-israeli-id/:idNumber',
  validateIsraeliIdParam,
  patientController.getPatientByIsraeliId
);

/**
 * @route   GET /api/v1/patients/:id
 * @desc    Get patient by ID
 * @access  Private
 */
router.get(
  '/:id',
  validatePatientIdParam,
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
    body('id_number')
      .trim()
      .notEmpty()
      .withMessage('Israeli ID is required')
      .bail()
      .custom((value) => isValidIsraeliId(String(value)))
      .withMessage('Valid Israeli ID is required'),
    body('blood_type').optional().isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
    body('height').optional().isFloat({ min: 0 }),
    body('weight').optional().isFloat({ min: 0 }),
    body('allergies').optional().isArray(),
    body('chronic_conditions').optional().isArray(),
    body('current_medications').optional().isArray(),
    body('emergency_contact_name').optional().trim(),
    bodyOptionalLooseEmergencyPhone(),
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
  validatePatientIdParam,
  validateRequest([
    body('blood_type').optional().isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
    body('height').optional().isFloat({ min: 0 }),
    body('weight').optional().isFloat({ min: 0 }),
    body('allergies').optional().isArray(),
    body('chronic_conditions').optional().isArray(),
    body('current_medications').optional().isArray(),
    body('emergency_contact_name').optional().trim(),
    bodyOptionalLooseEmergencyPhone(),
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
  validatePatientIdParam,
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
router.post(
  '/:id/medical-records',
  authorize('doctor', 'paramedical', 'admin', 'developer'),
  validatePatientIdParam,
  validateRequest([
    body('title').trim().notEmpty(),
    body('description').trim().notEmpty(),
    body('record_type').optional().isString().trim(),
    body('appointment_id').optional().isUUID(),
    body('is_draft').optional().isBoolean(),
    body('summary_format').optional().isString().trim(),
  ]),
  patientController.addMedicalRecord
);

/**
 * @route   GET /api/v1/patients/:id/medical-records
 * @desc    Get patient medical records
 * @access  Private
 */
router.get(
  '/:id/medical-records',
  authorize('patient', 'doctor', 'paramedical', 'admin', 'developer'),
  validatePatientIdParam,
  patientController.getMedicalRecords
);

/**
 * @route   PUT /api/v1/patients/:id/medical-records/:recordId
 * @desc    Update medical record (draft/final)
 * @access  Private/Doctor/Admin
 */
router.put(
  '/:id/medical-records/:recordId',
  authorize('doctor', 'paramedical', 'admin', 'developer'),
  validatePatientIdParam,
  validateUUID('recordId'),
  validateRequest([
    body('title').optional().trim(),
    body('description').optional().trim(),
    body('record_type').optional().isString().trim(),
    body('is_draft').optional().isBoolean(),
    body('summary_format').optional().isString().trim(),
  ]),
  patientController.updateMedicalRecord
);

/**
 * @route   POST /api/v1/patients/:id/medical-records/:recordId/attachments
 * @desc    Upload attachments for medical record
 * @access  Private/Doctor/Admin
 */
router.post(
  '/:id/medical-records/:recordId/attachments',
  authorize('patient', 'doctor', 'paramedical', 'admin', 'developer'),
  validatePatientIdParam,
  validateUUID('recordId'),
  upload.array('files', 10),
  patientController.uploadMedicalRecordAttachments
);

/**
 * @route   GET /api/v1/patients/:id/medical-records/:recordId/attachments/:fileName
 * @desc    Download medical record attachment
 * @access  Private
 */
router.get(
  '/:id/medical-records/:recordId/attachments/:fileName',
  authorize('patient', 'doctor', 'paramedical', 'admin', 'developer'),
  validatePatientIdParam,
  validateUUID('recordId'),
  patientController.getMedicalRecordAttachment
);

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



