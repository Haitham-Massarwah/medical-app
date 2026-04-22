import { Router } from 'express';
import { body } from 'express-validator';
import { OperationsController } from '../controllers/operations.controller';
import { authenticate } from '../middleware/auth.middleware';
import { tenantContext } from '../middleware/tenantContext';
import { validateRequest, validateUUID } from '../middleware/validator';

const router = Router();
const controller = new OperationsController();

router.use(authenticate);
router.use(tenantContext);

router.get('/receipt-templates', controller.listReceiptTemplates);
router.post(
  '/receipt-templates',
  validateRequest([
    body('template_name').isString().trim().notEmpty(),
    body('template_content').isString().trim().notEmpty(),
    body('template_scope').optional().isIn(['global', 'clinic', 'personal']),
    body('content_format').optional().isIn(['html', 'json', 'markdown']),
    body('is_default').optional().isBoolean(),
    body('is_active').optional().isBoolean(),
  ]),
  controller.createReceiptTemplate
);
router.put(
  '/receipt-templates/:id',
  validateUUID('id'),
  controller.updateReceiptTemplate
);
router.delete('/receipt-templates/:id', validateUUID('id'), controller.deleteReceiptTemplate);

router.get('/report-templates', controller.listReportTemplates);
router.post(
  '/report-templates',
  validateRequest([
    body('template_name').isString().trim().notEmpty(),
    body('template_content').isString().trim().notEmpty(),
    body('template_scope').optional().isIn(['clinic', 'personal']),
    body('content_format').optional().isIn(['html', 'json', 'markdown']),
    body('is_default').optional().isBoolean(),
    body('is_active').optional().isBoolean(),
  ]),
  controller.createReportTemplate
);
router.put('/report-templates/:id', validateUUID('id'), controller.updateReportTemplate);
router.delete('/report-templates/:id', validateUUID('id'), controller.deleteReportTemplate);

router.get('/employees', controller.listEmployees);
router.post(
  '/employees',
  validateRequest([
    body('user_id').optional().isUUID(),
    body('employee_code').optional().isString(),
    body('job_title').optional().isString(),
    body('employment_type').optional().isIn(['full_time', 'part_time', 'contractor']),
    body('start_date').optional().isISO8601(),
    body('end_date').optional().isISO8601(),
    body('is_active').optional().isBoolean(),
  ]),
  controller.createEmployee
);
router.put('/employees/:id', validateUUID('id'), controller.updateEmployee);
router.delete('/employees/:id', validateUUID('id'), controller.deleteEmployee);

router.get('/employee-work-hours', controller.listEmployeeWorkHours);
router.post(
  '/employee-work-hours',
  validateRequest([
    body('employee_id').isUUID(),
    body('work_date').isISO8601(),
    body('check_in_time').optional().isISO8601(),
    body('check_out_time').optional().isISO8601(),
    body('break_minutes').optional().isInt({ min: 0 }),
    body('total_minutes').optional().isInt({ min: 0 }),
    body('notes').optional().isString(),
  ]),
  controller.upsertEmployeeWorkHours
);
router.delete('/employee-work-hours/:id', validateUUID('id'), controller.deleteEmployeeWorkHours);

export default router;

