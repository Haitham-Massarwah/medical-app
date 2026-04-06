import { Router } from 'express';
import { LabController } from '../controllers/lab.controller';
import { authenticate } from '../middleware/auth.middleware';
import { tenantContext } from '../middleware/tenantContext';
import { body, param } from 'express-validator';
import { validateRequest } from '../middleware/validation.middleware';

const router = Router();
const labController = new LabController();

router.use(authenticate);
router.use(tenantContext);

router.get(
  '/patients/:patientId/results',
  [param('patientId').isUUID().withMessage('Valid patient ID is required'), validateRequest],
  labController.getPatientResults.bind(labController)
);

router.post(
  '/patients/:patientId/results',
  [
    param('patientId').isUUID().withMessage('Valid patient ID is required'),
    body('testName').optional().isString().trim(),
    body('resultValue').optional().isString().trim(),
    body('unit').optional().isString().trim(),
    body('referenceRange').optional().isString().trim(),
    body('labName').optional().isString().trim(),
    validateRequest,
  ],
  labController.createResult.bind(labController)
);

export default router;
