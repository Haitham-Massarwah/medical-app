import Stripe from 'stripe';
import { logger } from '../config/logger';
import db from '../config/database';

/**
 * Payment Service using Stripe
 * Handles payment processing, refunds, and receipts
 */

let stripeClient: Stripe | null = null;

/**
 * Initialize Stripe client
 */
const initializeStripeClient = (): Stripe | null => {
  if (stripeClient) return stripeClient;

  const secretKey = process.env.STRIPE_SECRET_KEY;

  if (!secretKey) {
    logger.warn('Stripe secret key not configured. Payment processing will be skipped.');
    return null;
  }

  stripeClient = new Stripe(secretKey, {
      apiVersion: '2023-10-16',
    });

  return stripeClient;
};

interface CreatePaymentIntentOptions {
  amount: number;
  currency?: string;
  description?: string;
  metadata?: Record<string, string>;
  customerId?: string;
}

/**
 * Create payment intent
 */
export const createPaymentIntent = async (
  options: CreatePaymentIntentOptions
): Promise<Stripe.PaymentIntent | null> => {
  try {
    const stripe = initializeStripeClient();

    if (!stripe) {
      logger.warn('Payment creation skipped (Stripe not configured)');
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

    logger.info(`Payment intent created: ${paymentIntent.id}`);
    return paymentIntent;
  } catch (error: any) {
    logger.error('Failed to create payment intent:', error.message);
    throw new Error(`Payment creation failed: ${error.message}`);
  }
};

/**
 * Confirm payment
 */
export const confirmPayment = async (
  paymentIntentId: string
): Promise<Stripe.PaymentIntent | null> => {
  try {
    const stripe = initializeStripeClient();

    if (!stripe) {
      return null;
    }

    const paymentIntent = await stripe.paymentIntents.confirm(paymentIntentId);

    logger.info(`Payment confirmed: ${paymentIntentId}`);
    return paymentIntent;
  } catch (error: any) {
    logger.error(`Failed to confirm payment ${paymentIntentId}:`, error.message);
    throw new Error(`Payment confirmation failed: ${error.message}`);
  }
};

/**
 * Get payment status
 */
export const getPaymentStatus = async (
  paymentIntentId: string
): Promise<Stripe.PaymentIntent | null> => {
  try {
    const stripe = initializeStripeClient();

    if (!stripe) {
      return null;
    }

    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
    return paymentIntent;
  } catch (error: any) {
    logger.error(`Failed to retrieve payment ${paymentIntentId}:`, error.message);
    return null;
  }
};

/**
 * Create refund
 */
export const createRefund = async (
  paymentIntentId: string,
  amount?: number,
  reason?: string
): Promise<Stripe.Refund | null> => {
  try {
    const stripe = initializeStripeClient();

    if (!stripe) {
      logger.warn('Refund creation skipped (Stripe not configured)');
      return null;
    }

    const refundOptions: Stripe.RefundCreateParams = {
      payment_intent: paymentIntentId,
    };

    if (amount) {
      refundOptions.amount = Math.round(amount * 100); // Convert to cents
    }

    if (reason) {
      refundOptions.reason = reason as any;
    }

    const refund = await stripe.refunds.create(refundOptions);

    logger.info(`Refund created: ${refund.id} for payment ${paymentIntentId}`);
    return refund;
  } catch (error: any) {
    logger.error(`Failed to create refund for ${paymentIntentId}:`, error.message);
    throw new Error(`Refund creation failed: ${error.message}`);
  }
};

/**
 * Create customer
 */
export const createCustomer = async (
  email: string,
  name: string,
  metadata?: Record<string, string>
): Promise<Stripe.Customer | null> => {
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

    logger.info(`Stripe customer created: ${customer.id}`);
    return customer;
  } catch (error: any) {
    logger.error('Failed to create Stripe customer:', error.message);
    throw new Error(`Customer creation failed: ${error.message}`);
  }
};

/**
 * Process appointment payment
 */
export const processAppointmentPayment = async (
  appointmentId: string,
  amount: number,
  patientId: string,
  tenantId: string
): Promise<{ paymentIntent: Stripe.PaymentIntent; paymentRecord: any } | null> => {
  try {
    // Create payment intent
    const paymentIntent = await createPaymentIntent({
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
    const [paymentRecord] = await db('payments').insert({
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

    logger.info(`Appointment payment processed: ${appointmentId}`);

    return { paymentIntent, paymentRecord };
  } catch (error: any) {
    logger.error(`Failed to process appointment payment ${appointmentId}:`, error.message);
        throw error;
      }
};

/**
 * Process deposit payment
 */
export const processDepositPayment = async (
  appointmentId: string,
  depositAmount: number,
  patientId: string,
  tenantId: string
): Promise<{ paymentIntent: Stripe.PaymentIntent; paymentRecord: any } | null> => {
  try {
    const paymentIntent = await createPaymentIntent({
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

    const [paymentRecord] = await db('payments').insert({
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

    logger.info(`Deposit payment processed: ${appointmentId}`);

    return { paymentIntent, paymentRecord };
  } catch (error: any) {
    logger.error(`Failed to process deposit payment ${appointmentId}:`, error.message);
    throw error;
  }
};

/**
 * Handle webhook event
 */
export const handleWebhookEvent = async (
  event: Stripe.Event
): Promise<void> => {
  try {
      switch (event.type) {
      case 'payment_intent.succeeded':
          const paymentIntent = event.data.object as Stripe.PaymentIntent;
        await updatePaymentStatus(paymentIntent.id, 'succeeded');
        logger.info(`Payment succeeded: ${paymentIntent.id}`);
          break;

      case 'payment_intent.payment_failed':
        const failedPayment = event.data.object as Stripe.PaymentIntent;
        await updatePaymentStatus(failedPayment.id, 'failed');
        logger.info(`Payment failed: ${failedPayment.id}`);
          break;

      case 'charge.refunded':
          const charge = event.data.object as Stripe.Charge;
        if (charge.payment_intent) {
          await updatePaymentStatus(charge.payment_intent as string, 'refunded');
          logger.info(`Payment refunded: ${charge.payment_intent}`);
        }
          break;

        default:
        logger.debug(`Unhandled webhook event type: ${event.type}`);
      }
  } catch (error: any) {
    logger.error('Failed to handle webhook event:', error.message);
      throw error;
    }
};

/**
 * Update payment status in database
 */
const updatePaymentStatus = async (
  stripePaymentIntentId: string,
  status: string
): Promise<void> => {
    await db('payments')
    .where({ stripe_payment_intent_id: stripePaymentIntentId })
      .update({
      status,
        updated_at: new Date(),
      });
};

/**
 * Check payment service status
 */
export const checkPaymentServiceStatus = (): {
  configured: boolean;
  currency?: string;
} => {
  const secretKey = process.env.STRIPE_SECRET_KEY;
  const currency = process.env.STRIPE_CURRENCY || 'usd';

  return {
    configured: !!secretKey,
    currency,
  };
};

/**
 * Construct webhook event from raw body
 */
export const constructWebhookEvent = (
  payload: string | Buffer,
  signature: string
): Stripe.Event | null => {
  try {
    const stripe = initializeStripeClient();
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

    if (!stripe || !webhookSecret) {
      return null;
    }

    const event = stripe.webhooks.constructEvent(
      payload,
      signature,
      webhookSecret
    );

    return event;
  } catch (error: any) {
    logger.error('Failed to construct webhook event:', error.message);
    return null;
  }
};

// Export all functions
export const PaymentService = {
  createPaymentIntent,
  confirmPayment,
  getPaymentStatus,
  createRefund,
  createCustomer,
  processAppointmentPayment,
  processDepositPayment,
  handleWebhookEvent,
  checkPaymentServiceStatus,
  constructWebhookEvent,
};
