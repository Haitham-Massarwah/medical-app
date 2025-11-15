"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentService = exports.constructWebhookEvent = exports.checkPaymentServiceStatus = exports.handleWebhookEvent = exports.processDepositPayment = exports.processAppointmentPayment = exports.createCustomer = exports.createRefund = exports.getPaymentStatus = exports.confirmPayment = exports.createPaymentIntent = void 0;
const stripe_1 = __importDefault(require("stripe"));
const logger_1 = require("../config/logger");
const database_1 = __importDefault(require("../config/database"));
/**
 * Payment Service using Stripe
 * Handles payment processing, refunds, and receipts
 */
let stripeClient = null;
/**
 * Initialize Stripe client
 */
const initializeStripeClient = () => {
    if (stripeClient)
        return stripeClient;
    const secretKey = process.env.STRIPE_SECRET_KEY;
    if (!secretKey) {
        logger_1.logger.warn('Stripe secret key not configured. Payment processing will be skipped.');
        return null;
    }
    stripeClient = new stripe_1.default(secretKey, {
        apiVersion: '2023-10-16',
    });
    return stripeClient;
};
/**
 * Create payment intent
 */
const createPaymentIntent = async (options) => {
    try {
        const stripe = initializeStripeClient();
        if (!stripe) {
            logger_1.logger.warn('Payment creation skipped (Stripe not configured)');
            return null;
        }
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(options.amount * 100), // Convert to cents
            currency: options.currency || process.env.STRIPE_CURRENCY || 'usd',
            description: options.description,
            metadata: options.metadata || {},
            customer: options.customerId,
            automatic_payment_methods: {
                enabled: true,
            },
        });
        logger_1.logger.info(`Payment intent created: ${paymentIntent.id}`);
        return paymentIntent;
    }
    catch (error) {
        logger_1.logger.error('Failed to create payment intent:', error.message);
        throw new Error(`Payment creation failed: ${error.message}`);
    }
};
exports.createPaymentIntent = createPaymentIntent;
/**
 * Confirm payment
 */
const confirmPayment = async (paymentIntentId) => {
    try {
        const stripe = initializeStripeClient();
        if (!stripe) {
            return null;
        }
        const paymentIntent = await stripe.paymentIntents.confirm(paymentIntentId);
        logger_1.logger.info(`Payment confirmed: ${paymentIntentId}`);
        return paymentIntent;
    }
    catch (error) {
        logger_1.logger.error(`Failed to confirm payment ${paymentIntentId}:`, error.message);
        throw new Error(`Payment confirmation failed: ${error.message}`);
    }
};
exports.confirmPayment = confirmPayment;
/**
 * Get payment status
 */
const getPaymentStatus = async (paymentIntentId) => {
    try {
        const stripe = initializeStripeClient();
        if (!stripe) {
            return null;
        }
        const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
        return paymentIntent;
    }
    catch (error) {
        logger_1.logger.error(`Failed to retrieve payment ${paymentIntentId}:`, error.message);
        return null;
    }
};
exports.getPaymentStatus = getPaymentStatus;
/**
 * Create refund
 */
const createRefund = async (paymentIntentId, amount, reason) => {
    try {
        const stripe = initializeStripeClient();
        if (!stripe) {
            logger_1.logger.warn('Refund creation skipped (Stripe not configured)');
            return null;
        }
        const refundOptions = {
            payment_intent: paymentIntentId,
        };
        if (amount) {
            refundOptions.amount = Math.round(amount * 100); // Convert to cents
        }
        if (reason) {
            refundOptions.reason = reason;
        }
        const refund = await stripe.refunds.create(refundOptions);
        logger_1.logger.info(`Refund created: ${refund.id} for payment ${paymentIntentId}`);
        return refund;
    }
    catch (error) {
        logger_1.logger.error(`Failed to create refund for ${paymentIntentId}:`, error.message);
        throw new Error(`Refund creation failed: ${error.message}`);
    }
};
exports.createRefund = createRefund;
/**
 * Create customer
 */
const createCustomer = async (email, name, metadata) => {
    try {
        const stripe = initializeStripeClient();
        if (!stripe) {
            return null;
        }
        const customer = await stripe.customers.create({
            email,
            name,
            metadata: metadata || {},
        });
        logger_1.logger.info(`Stripe customer created: ${customer.id}`);
        return customer;
    }
    catch (error) {
        logger_1.logger.error('Failed to create Stripe customer:', error.message);
        throw new Error(`Customer creation failed: ${error.message}`);
    }
};
exports.createCustomer = createCustomer;
/**
 * Process appointment payment
 */
const processAppointmentPayment = async (appointmentId, amount, patientId, tenantId) => {
    try {
        // Create payment intent
        const paymentIntent = await (0, exports.createPaymentIntent)({
            amount,
            description: `Appointment payment: ${appointmentId}`,
            metadata: {
                appointment_id: appointmentId,
                patient_id: patientId,
                tenant_id: tenantId,
            },
        });
        if (!paymentIntent) {
            return null;
        }
        // Create payment record in database
        const [paymentRecord] = await (0, database_1.default)('payments').insert({
            tenant_id: tenantId,
            appointment_id: appointmentId,
            patient_id: patientId,
            amount,
            currency: paymentIntent.currency,
            status: paymentIntent.status,
            stripe_payment_intent_id: paymentIntent.id,
            payment_method: 'card',
            created_at: new Date(),
            updated_at: new Date(),
        }).returning('*');
        logger_1.logger.info(`Appointment payment processed: ${appointmentId}`);
        return { paymentIntent, paymentRecord };
    }
    catch (error) {
        logger_1.logger.error(`Failed to process appointment payment ${appointmentId}:`, error.message);
        throw error;
    }
};
exports.processAppointmentPayment = processAppointmentPayment;
/**
 * Process deposit payment
 */
const processDepositPayment = async (appointmentId, depositAmount, patientId, tenantId) => {
    try {
        const paymentIntent = await (0, exports.createPaymentIntent)({
            amount: depositAmount,
            description: `Deposit for appointment: ${appointmentId}`,
            metadata: {
                appointment_id: appointmentId,
                patient_id: patientId,
                tenant_id: tenantId,
                payment_type: 'deposit',
            },
        });
        if (!paymentIntent) {
            return null;
        }
        const [paymentRecord] = await (0, database_1.default)('payments').insert({
            tenant_id: tenantId,
            appointment_id: appointmentId,
            patient_id: patientId,
            amount: depositAmount,
            currency: paymentIntent.currency,
            status: paymentIntent.status,
            stripe_payment_intent_id: paymentIntent.id,
            payment_method: 'card',
            payment_type: 'deposit',
            created_at: new Date(),
            updated_at: new Date(),
        }).returning('*');
        logger_1.logger.info(`Deposit payment processed: ${appointmentId}`);
        return { paymentIntent, paymentRecord };
    }
    catch (error) {
        logger_1.logger.error(`Failed to process deposit payment ${appointmentId}:`, error.message);
        throw error;
    }
};
exports.processDepositPayment = processDepositPayment;
/**
 * Handle webhook event
 */
const handleWebhookEvent = async (event) => {
    try {
        switch (event.type) {
            case 'payment_intent.succeeded':
                const paymentIntent = event.data.object;
                await updatePaymentStatus(paymentIntent.id, 'succeeded');
                logger_1.logger.info(`Payment succeeded: ${paymentIntent.id}`);
                break;
            case 'payment_intent.payment_failed':
                const failedPayment = event.data.object;
                await updatePaymentStatus(failedPayment.id, 'failed');
                logger_1.logger.info(`Payment failed: ${failedPayment.id}`);
                break;
            case 'charge.refunded':
                const charge = event.data.object;
                if (charge.payment_intent) {
                    await updatePaymentStatus(charge.payment_intent, 'refunded');
                    logger_1.logger.info(`Payment refunded: ${charge.payment_intent}`);
                }
                break;
            default:
                logger_1.logger.debug(`Unhandled webhook event type: ${event.type}`);
        }
    }
    catch (error) {
        logger_1.logger.error('Failed to handle webhook event:', error.message);
        throw error;
    }
};
exports.handleWebhookEvent = handleWebhookEvent;
/**
 * Update payment status in database
 */
const updatePaymentStatus = async (stripePaymentIntentId, status) => {
    await (0, database_1.default)('payments')
        .where({ stripe_payment_intent_id: stripePaymentIntentId })
        .update({
        status,
        updated_at: new Date(),
    });
};
/**
 * Check payment service status
 */
const checkPaymentServiceStatus = () => {
    const secretKey = process.env.STRIPE_SECRET_KEY;
    const currency = process.env.STRIPE_CURRENCY || 'usd';
    return {
        configured: !!secretKey,
        currency,
    };
};
exports.checkPaymentServiceStatus = checkPaymentServiceStatus;
/**
 * Construct webhook event from raw body
 */
const constructWebhookEvent = (payload, signature) => {
    try {
        const stripe = initializeStripeClient();
        const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
        if (!stripe || !webhookSecret) {
            return null;
        }
        const event = stripe.webhooks.constructEvent(payload, signature, webhookSecret);
        return event;
    }
    catch (error) {
        logger_1.logger.error('Failed to construct webhook event:', error.message);
        return null;
    }
};
exports.constructWebhookEvent = constructWebhookEvent;
// Export all functions
exports.PaymentService = {
    createPaymentIntent: exports.createPaymentIntent,
    confirmPayment: exports.confirmPayment,
    getPaymentStatus: exports.getPaymentStatus,
    createRefund: exports.createRefund,
    createCustomer: exports.createCustomer,
    processAppointmentPayment: exports.processAppointmentPayment,
    processDepositPayment: exports.processDepositPayment,
    handleWebhookEvent: exports.handleWebhookEvent,
    checkPaymentServiceStatus: exports.checkPaymentServiceStatus,
    constructWebhookEvent: exports.constructWebhookEvent,
};
//# sourceMappingURL=payment.service.js.map