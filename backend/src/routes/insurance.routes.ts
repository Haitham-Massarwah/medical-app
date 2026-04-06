import { Router } from 'express';
import { InsuranceController } from '../controllers/insurance.controller';
import { authenticate } from '../middleware/auth.middleware';
import { tenantContext } from '../middleware/tenantContext';
import { body, param } from 'express-validator';
import { validateRequest } from '../middleware/validation.middleware';

const router = Router();
const insuranceController = new InsuranceController();

router.use(authenticate);
router.use(tenantContext);

router.get(
  '/patients/:patientId',
  [param('patientId').isUUID().withMessage('Valid patient ID is required'), validateRequest],
  insuranceController.getPatientInsurance.bind(insuranceController)
);

router.post(
  '/patients/:patientId/eligibility',
  [
    param('patientId').isUUID().withMessage('Valid patient ID is required'),
    body('provider').optional().isString().trim(),
    body('memberId').optional().isString().trim(),
    body('policyNumber').optional().isString().trim(),
    validateRequest,
  ],
  insuranceController.checkEligibility.bind(insuranceController)
);

router.post(
  '/claims',
  [
    body('patientId').optional().isUUID(),
    body('appointmentId').optional().isUUID(),
    body('amount').optional().isNumeric(),
    body('diagnosisCode').optional().isString().trim(),
    body('serviceCode').optional().isString().trim(),
    validateRequest,
  ],
  insuranceController.submitClaim.bind(insuranceController)
);

export default router;
