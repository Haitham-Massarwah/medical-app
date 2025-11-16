import { Router } from 'express';
import { CardcomController } from '../controllers/cardcom.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validation.middleware';
import { body, param } from 'express-validator';

const router = Router();
const cardcomController = new CardcomController();

// All routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/payments/cardcom/status
 * @desc    Check Cardcom service status
 * @access  Private
 */
router.get('/status', cardcomController.checkStatus.bind(cardcomController));

/**
 * @route   POST /api/v1/payments/cardcom/test
 * @desc    Test Cardcom payment with test card
 * @access  Private (Developer/Admin only)
 */
router.post(
  '/test',
  cardcomController.testPayment.bind(cardcomController)
);

/**
 * @route   POST /api/v1/payments/cardcom/charge
 * @desc    Process payment with Cardcom
 * @access  Private
 */
router.post(
  '/charge',
  [
    body('appointmentId').notEmpty().withMessage('Appointment ID is required'),
    body('amount').notEmpty().isFloat({ min: 0.01 }).withMessage('Valid amount is required'),
    body('currency').optional().isString().isLength({ min: 3, max: 3 }),
    body('cardNumber').notEmpty().isString().withMessage('Card number is required'),
    body('cvv').notEmpty().isString().isLength({ min: 3, max: 4 }).withMessage('CVV is required'),
    body('expirationMonth').notEmpty().isString().withMessage('Expiration month is required'),
    body('expirationYear').notEmpty().isString().withMessage('Expiration year is required'),
    body('holderName').optional().isString(),
    body('holderEmail').optional().isEmail(),
    body('holderPhone').optional().isString(),
    body('holderId').optional().isString(),
    body('description').optional().isString(),
    validateRequest,
  ],
  cardcomController.charge.bind(cardcomController)
);

/**
 * @route   POST /api/v1/payments/cardcom/link
 * @desc    Create payment link (Low Profile)
 * @access  Private
 */
router.post(
  '/link',
  [
    body('appointmentId').notEmpty().withMessage('Appointment ID is required'),
    body('amount').notEmpty().isFloat({ min: 0.01 }).withMessage('Valid amount is required'),
    body('currency').optional().isString().isLength({ min: 3, max: 3 }),
    body('successUrl').notEmpty().isURL().withMessage('Valid success URL is required'),
    body('errorUrl').notEmpty().isURL().withMessage('Valid error URL is required'),
    body('cancelUrl').optional().isURL(),
    body('holderName').optional().isString(),
    body('holderEmail').optional().isEmail(),
    body('holderId').optional().isString(),
    validateRequest,
  ],
  cardcomController.createLink.bind(cardcomController)
);

/**
 * @route   POST /api/v1/payments/cardcom/refund
 * @desc    Process refund
 * @access  Private (Admin/Doctor only)
 */
router.post(
  '/refund',
  [
    body('cardcomTransactionId').notEmpty().withMessage('Cardcom transaction ID is required'),
    body('amount').optional().isFloat({ min: 0.01 }),
    body('reason').optional().isString(),
    validateRequest,
  ],
  cardcomController.refund.bind(cardcomController)
);

/**
 * @route   GET /api/v1/payments/cardcom/status/:transactionId
 * @desc    Get transaction status
 * @access  Private
 */
router.get(
  '/status/:transactionId',
  [
    param('transactionId').notEmpty().withMessage('Transaction ID is required'),
    validateRequest,
  ],
  cardcomController.getStatus.bind(cardcomController)
);

export default router;

