"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentController = void 0;
const payment_service_1 = require("../services/payment.service");
const logger_1 = require("../config/logger");
const apiError_1 = require("../utils/apiError");
class PaymentController {
    constructor() {
        this.paymentService = payment_service_1.PaymentService;
        // PaymentService is already initialized
    }
    /**
     * Create payment intent
     * @route POST /api/v1/payments
     */
    async createPayment(req, res, next) {
        try {
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id;
            const { appointmentId, amount, currency = 'ILS', metadata } = req.body;
            if (!appointmentId || !amount) {
                throw new apiError_1.ApiError(400, 'Appointment ID and amount are required');
            }
            const result = await this.paymentService.createPaymentIntent({
                amount: Number(amount),
                currency,
                metadata: {
                    ...metadata,
                    appointmentId,
                    tenantId,
                    patientId: userId,
                },
            });
            res.status(201).json({
                success: true,
                data: result,
                message: 'Payment intent created successfully',
            });
        }
        catch (error) {
            logger_1.logger.error('Error creating payment:', error);
            next(error);
        }
    }
    /**
     * Process payment
     * @route POST /api/v1/payments/:id/process
     */
    async processPayment(req, res, next) {
        try {
            const { id } = req.params;
            const tenantId = req.headers['x-tenant-id'];
            const payment = await this.paymentService.processPayment(id, tenantId);
            res.status(200).json({
                success: true,
                data: payment,
                message: 'Payment processed successfully',
            });
        }
        catch (error) {
            logger_1.logger.error('Error processing payment:', error);
            next(error);
        }
    }
    /**
     * Refund payment
     * @route POST /api/v1/payments/:id/refund
     */
    async refundPayment(req, res, next) {
        try {
            const { id } = req.params;
            const { amount, reason } = req.body;
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id;
            if (!reason) {
                throw new apiError_1.ApiError(400, 'Refund reason is required');
            }
            const payment = await this.paymentService.refundPayment({
                paymentId: id,
                amount: amount ? Number(amount) : undefined,
                reason,
                tenantId,
                userId: userId,
            });
            res.status(200).json({
                success: true,
                data: payment,
                message: 'Payment refunded successfully',
            });
        }
        catch (error) {
            logger_1.logger.error('Error refunding payment:', error);
            next(error);
        }
    }
    /**
     * Get payment receipt
     * @route GET /api/v1/payments/:id/receipt
     */
    async getReceipt(req, res, next) {
        try {
            const { id } = req.params;
            const tenantId = req.headers['x-tenant-id'];
            const receipt = await this.paymentService.generateReceipt(id, tenantId);
            res.status(200).json({
                success: true,
                data: receipt,
            });
        }
        catch (error) {
            logger_1.logger.error('Error getting receipt:', error);
            next(error);
        }
    }
    /**
     * Get payment history
     * @route GET /api/v1/payments
     */
    async getPaymentHistory(req, res, next) {
        try {
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id;
            const role = req.user?.role;
            const { page = 1, limit = 20 } = req.query;
            const result = await this.paymentService.getPaymentHistory({
                tenantId,
                userId: userId,
                role: role,
                page: Number(page),
                limit: Number(limit),
            });
            res.status(200).json({
                success: true,
                data: result.data,
                pagination: {
                    page: result.page,
                    limit: result.limit,
                    total: result.total,
                    totalPages: Math.ceil(result.total / result.limit),
                },
            });
        }
        catch (error) {
            logger_1.logger.error('Error getting payment history:', error);
            next(error);
        }
    }
    /**
     * Handle Stripe webhook
     * @route POST /api/v1/payments/webhook
     */
    async handleWebhook(req, res, next) {
        try {
            const sig = req.headers['stripe-signature'];
            const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
            if (!webhookSecret) {
                throw new apiError_1.ApiError(500, 'Webhook secret not configured');
            }
            // Verify webhook signature
            const stripe = new (require('stripe'))(process.env.STRIPE_SECRET_KEY);
            const event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
            const tenantId = event.data.object.metadata?.tenantId;
            await this.paymentService.handleWebhook(event, tenantId);
            res.status(200).json({ received: true });
        }
        catch (error) {
            logger_1.logger.error('Webhook error:', error);
            res.status(400).json({ error: 'Webhook error' });
        }
    }
}
exports.PaymentController = PaymentController;
//# sourceMappingURL=payment.controller.js.map