import { Router } from 'express';
import { PaymentController } from '../controllers/payment.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validation.middleware';
import { body, query, param } from 'express-validator';
import { requireAccountPermission } from '../middleware/accountPermissions.middleware';

const router = Router();
const paymentController = new PaymentController();

/**
 * @route   POST /api/v1/payments/webhook
 * @desc    Handle Stripe webhook events
 * @access  Public (but verified by Stripe signature)
 */
router.post('/webhook', paymentController.handleWebhook.bind(paymentController));
router.post('/webhooks/payment', paymentController.handleProviderWebhook.bind(paymentController));

// All other routes require authentication
router.use(authenticate);
router.use(requireAccountPermission('can_manage_payments'));

/**
 * @route   GET /api/v1/payments
 * @desc    Get payment history
 * @access  Private
 */
router.get(
  '/',
  [
    query('page').optional().isInt({ min: 1 }),
    query('limit').optional().isInt({ min: 1, max: 100 }),
    validateRequest,
  ],
  paymentController.getPaymentHistory.bind(paymentController)
);

/**
 * @route   POST /api/v1/payments
 * @desc    Create payment intent
 * @access  Private
 */
router.post(
  '/',
  [
    body('appointmentId').notEmpty().isUUID().withMessage('Valid appointment ID is required'),
    body('amount').notEmpty().isFloat({ min: 0.01 }).withMessage('Valid amount is required'),
    body('currency').optional().isString().isLength({ min: 3, max: 3 }),
    body('metadata').optional().isObject(),
    validateRequest,
  ],
  paymentController.createPayment.bind(paymentController)
);

/**
 * @route   POST /api/v1/payments/:id/process
 * @desc    Process payment
 * @access  Private
 */
router.post(
  '/:id/process',
  [param('id').isUUID().withMessage('Valid payment ID is required'), validateRequest],
  paymentController.processPayment.bind(paymentController)
);

router.post(
  '/:id/retry',
  [param('id').isUUID().withMessage('Valid payment ID is required'), validateRequest],
  paymentController.retryPayment.bind(paymentController)
);

/**
 * @route   POST /api/v1/payments/:id/refund
 * @desc    Refund payment
 * @access  Private (Admin or Doctor only)
 */
router.post(
  '/:id/refund',
  [
    param('id').isUUID().withMessage('Valid payment ID is required'),
    body('amount').optional().isFloat({ min: 0.01 }),
    body('reason').notEmpty().isString().withMessage('Refund reason is required'),
    validateRequest,
  ],
  paymentController.refundPayment.bind(paymentController)
);

/**
 * @route   GET /api/v1/payments/:id/receipt
 * @desc    Get payment receipt
 * @access  Private
 */
router.get(
  '/:id/receipt',
  [param('id').isUUID().withMessage('Valid payment ID is required'), validateRequest],
  paymentController.getReceipt.bind(paymentController)
);

export default router;
