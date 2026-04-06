import { Router } from 'express';
import { body } from 'express-validator';
import { CrmController } from '../controllers/crm.controller';
import { authenticate } from '../middleware/auth.middleware';
import { asyncHandler } from '../middleware/errorHandler';
import { tenantContext } from '../middleware/tenantContext';
import { validateRequest, validateUUID } from '../middleware/validator';

const router = Router();
const crm = new CrmController();

router.use(authenticate);
router.use(tenantContext);

router.get('/leads', asyncHandler(crm.listLeads.bind(crm)));
router.post(
  '/leads',
  validateRequest([
    body('full_name').isString().trim().notEmpty(),
    body('email').optional().isEmail().normalizeEmail(),
    body('phone').optional().isString().trim(),
    body('source').optional().isString().trim(),
    body('status').optional().isString().trim(),
    body('notes').optional().isString(),
    body('owner_user_id').optional().isUUID(),
  ]),
  asyncHandler(crm.createLead.bind(crm))
);
router.put(
  '/leads/:id',
  validateUUID('id'),
  validateRequest([
    body('full_name').optional().isString().trim().notEmpty(),
    body('email').optional().isEmail().normalizeEmail(),
    body('phone').optional().isString().trim(),
    body('source').optional().isString().trim(),
    body('status').optional().isString().trim(),
    body('notes').optional().isString(),
    body('owner_user_id').optional().isUUID(),
  ]),
  asyncHandler(crm.updateLead.bind(crm))
);

router.get('/followups', asyncHandler(crm.listFollowups.bind(crm)));
router.post(
  '/followups',
  validateRequest([
    body('lead_id').isUUID(),
    body('channel').optional().isIn(['sms', 'email', 'whatsapp', 'call']),
    body('message').isString().trim().notEmpty(),
    body('due_at').optional().isISO8601(),
  ]),
  asyncHandler(crm.createFollowup.bind(crm))
);
router.put('/followups/:id/complete', validateUUID('id'), asyncHandler(crm.completeFollowup.bind(crm)));

router.get('/templates', asyncHandler(crm.listTemplates.bind(crm)));
router.post(
  '/templates',
  validateRequest([
    body('name').isString().trim().notEmpty(),
    body('channel').optional().isIn(['sms', 'email', 'whatsapp']),
    body('subject').optional().isString().trim(),
    body('body').isString().trim().notEmpty(),
  ]),
  asyncHandler(crm.createTemplate.bind(crm))
);

export default router;

