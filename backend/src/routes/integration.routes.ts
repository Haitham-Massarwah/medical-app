import { Router } from 'express';
import { body } from 'express-validator';
import { authenticate } from '../middleware/auth.middleware';
import { asyncHandler } from '../middleware/errorHandler';
import { tenantContext } from '../middleware/tenantContext';
import { validateRequest } from '../middleware/validator';
import { IntegrationController } from '../controllers/integration.controller';

const router = Router();
const integration = new IntegrationController();

router.use(authenticate);
router.use(tenantContext);

router.get('/connections', asyncHandler(integration.listConnections.bind(integration)));
router.put(
  '/connections',
  validateRequest([
    body('provider').isString().trim().notEmpty(),
    body('scope').optional().isIn(['tenant', 'user']),
    body('user_id').optional().isUUID(),
    body('status').optional().isIn(['connected', 'disconnected', 'error']),
    body('last_sync_at').optional().isISO8601(),
    body('last_error_code').optional().isString(),
    body('last_error_message').optional().isString(),
  ]),
  asyncHandler(integration.upsertConnection.bind(integration))
);

router.get('/events', asyncHandler(integration.listEvents.bind(integration)));
router.post(
  '/events',
  validateRequest([
    body('provider').isString().trim().notEmpty(),
    body('event_type').isString().trim().notEmpty(),
    body('severity').optional().isIn(['info', 'warn', 'error']),
    body('status').optional().isIn(['ok', 'failed', 'retried']),
    body('message').isString().trim().notEmpty(),
    body('payload').optional().isObject(),
  ]),
  asyncHandler(integration.createEvent.bind(integration))
);

export default router;

