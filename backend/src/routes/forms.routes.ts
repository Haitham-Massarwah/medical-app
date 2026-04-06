import { Router } from 'express';
import { body } from 'express-validator';
import { FormsController } from '../controllers/forms.controller';
import { authenticate } from '../middleware/auth.middleware';
import { asyncHandler } from '../middleware/errorHandler';
import { tenantContext } from '../middleware/tenantContext';
import { validateRequest } from '../middleware/validation.middleware';

const router = Router();
const formsController = new FormsController();

router.use(authenticate);
router.use(tenantContext);

router.get('/templates', asyncHandler(formsController.getTemplates.bind(formsController)));

router.post(
  '/templates',
  [
    body('title').isString().trim().notEmpty().withMessage('title is required'),
    body('form_type').optional().isString().trim(),
    body('schema_json').optional().isObject(),
    body('is_active').optional().isBoolean(),
    validateRequest,
  ],
  asyncHandler(formsController.createTemplate.bind(formsController))
);

router.post(
  '/submit',
  [
    body('template_id').isUUID().withMessage('template_id is required'),
    body('patient_user_id').optional().isUUID(),
    body('answers_json').optional().isObject(),
    body('consent_name').optional().isString().trim(),
    body('signature_data').optional().isString(),
    body('pdf_url').optional().isString().trim(),
    validateRequest,
  ],
  asyncHandler(formsController.submitForm.bind(formsController))
);

router.get('/my-submissions', asyncHandler(formsController.getMySubmissions.bind(formsController)));
router.get('/submissions', asyncHandler(formsController.listSubmissions.bind(formsController)));

export default router;

