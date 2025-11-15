"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const payment_controller_1 = require("../controllers/payment.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validation_middleware_1 = require("../middleware/validation.middleware");
const express_validator_1 = require("express-validator");
const router = (0, express_1.Router)();
const paymentController = new payment_controller_1.PaymentController();
/**
 * @route   POST /api/v1/payments/webhook
 * @desc    Handle Stripe webhook events
 * @access  Public (but verified by Stripe signature)
 */
router.post('/webhook', paymentController.handleWebhook.bind(paymentController));
// All other routes require authentication
router.use(auth_middleware_1.authenticate);
/**
 * @route   GET /api/v1/payments
 * @desc    Get payment history
 * @access  Private
 */
router.get('/', [
    (0, express_validator_1.query)('page').optional().isInt({ min: 1 }),
    (0, express_validator_1.query)('limit').optional().isInt({ min: 1, max: 100 }),
    validation_middleware_1.validateRequest,
], paymentController.getPaymentHistory.bind(paymentController));
/**
 * @route   POST /api/v1/payments
 * @desc    Create payment intent
 * @access  Private
 */
router.post('/', [
    (0, express_validator_1.body)('appointmentId').notEmpty().isUUID().withMessage('Valid appointment ID is required'),
    (0, express_validator_1.body)('amount').notEmpty().isFloat({ min: 0.01 }).withMessage('Valid amount is required'),
    (0, express_validator_1.body)('currency').optional().isString().isLength({ min: 3, max: 3 }),
    (0, express_validator_1.body)('metadata').optional().isObject(),
    validation_middleware_1.validateRequest,
], paymentController.createPayment.bind(paymentController));
/**
 * @route   POST /api/v1/payments/:id/process
 * @desc    Process payment
 * @access  Private
 */
router.post('/:id/process', [(0, express_validator_1.param)('id').isUUID().withMessage('Valid payment ID is required'), validation_middleware_1.validateRequest], paymentController.processPayment.bind(paymentController));
/**
 * @route   POST /api/v1/payments/:id/refund
 * @desc    Refund payment
 * @access  Private (Admin or Doctor only)
 */
router.post('/:id/refund', [
    (0, express_validator_1.param)('id').isUUID().withMessage('Valid payment ID is required'),
    (0, express_validator_1.body)('amount').optional().isFloat({ min: 0.01 }),
    (0, express_validator_1.body)('reason').notEmpty().isString().withMessage('Refund reason is required'),
    validation_middleware_1.validateRequest,
], paymentController.refundPayment.bind(paymentController));
/**
 * @route   GET /api/v1/payments/:id/receipt
 * @desc    Get payment receipt
 * @access  Private
 */
router.get('/:id/receipt', [(0, express_validator_1.param)('id').isUUID().withMessage('Valid payment ID is required'), validation_middleware_1.validateRequest], paymentController.getReceipt.bind(paymentController));
exports.default = router;
//# sourceMappingURL=payment.routes.js.map