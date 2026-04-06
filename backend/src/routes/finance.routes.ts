import { Router } from 'express';
import { body } from 'express-validator';
import { FinanceController } from '../controllers/finance.controller';
import { authenticate } from '../middleware/auth.middleware';
import { asyncHandler } from '../middleware/errorHandler';
import { tenantContext } from '../middleware/tenantContext';
import { validateRequest, validateUUID } from '../middleware/validator';

const router = Router();
const finance = new FinanceController();

router.use(authenticate);
router.use(tenantContext);

router.get('/deposits', asyncHandler(finance.listDeposits.bind(finance)));
router.post(
  '/deposits',
  validateRequest([
    body('appointment_id').optional().isUUID(),
    body('patient_id').optional().isUUID(),
    body('amount').isFloat({ min: 0.01 }),
    body('currency').optional().isString().isLength({ min: 3, max: 10 }),
    body('method').optional().isString(),
    body('notes').optional().isString(),
  ]),
  asyncHandler(finance.createDeposit.bind(finance))
);

router.get('/refunds', asyncHandler(finance.listRefunds.bind(finance)));
router.post(
  '/refunds',
  validateRequest([
    body('payment_id').optional().isUUID(),
    body('deposit_id').optional().isUUID(),
    body('amount').isFloat({ min: 0.01 }),
    body('currency').optional().isString().isLength({ min: 3, max: 10 }),
    body('reason').isString().trim().notEmpty(),
  ]),
  asyncHandler(finance.requestRefund.bind(finance))
);
router.put(
  '/refunds/:id/process',
  validateUUID('id'),
  validateRequest([body('status').optional().isIn(['processed', 'rejected'])]),
  asyncHandler(finance.processRefund.bind(finance))
);

router.get('/payouts', asyncHandler(finance.listPayouts.bind(finance)));
router.post(
  '/payouts',
  validateRequest([
    body('provider_user_id').isUUID(),
    body('gross_amount').isFloat({ min: 0 }),
    body('commission_amount').optional().isFloat({ min: 0 }),
    body('currency').optional().isString().isLength({ min: 3, max: 10 }),
    body('period_start').optional().isISO8601(),
    body('period_end').optional().isISO8601(),
    body('notes').optional().isString(),
  ]),
  asyncHandler(finance.createPayout.bind(finance))
);
router.put('/payouts/:id/paid', validateUUID('id'), asyncHandler(finance.markPayoutPaid.bind(finance)));

router.get('/commission-rules', asyncHandler(finance.listCommissionRules.bind(finance)));
router.post(
  '/commission-rules',
  validateRequest([
    body('name').isString().trim().notEmpty(),
    body('percent').optional().isFloat({ min: 0, max: 100 }),
    body('fixed_amount').optional().isFloat({ min: 0 }),
    body('is_active').optional().isBoolean(),
  ]),
  asyncHandler(finance.createCommissionRule.bind(finance))
);

export default router;

