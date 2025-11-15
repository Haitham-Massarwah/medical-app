"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.subscriptionService = exports.SubscriptionService = void 0;
const stripe_1 = __importDefault(require("stripe"));
const database_1 = require("../config/database");
const logger_1 = require("../config/logger");
const stripe = new stripe_1.default(process.env.STRIPE_SECRET_KEY || '', {
    apiVersion: '2024-12-18.acacia',
});
class SubscriptionService {
    /**
     * Get all active subscription plans
     */
    async getPlans() {
        try {
            const plans = await (0, database_1.db)('subscription_plans')
                .where('is_active', true)
                .orderBy('sort_order', 'asc');
            return plans.map(plan => ({
                ...plan,
                features: plan.features ? JSON.parse(plan.features) : []
            }));
        }
        catch (error) {
            logger_1.logger.error('Error fetching subscription plans:', error);
            throw new Error('Failed to fetch subscription plans');
        }
    }
    /**
     * Get a specific plan by ID
     */
    async getPlanById(planId) {
        try {
            const plan = await (0, database_1.db)('subscription_plans')
                .where('id', planId)
                .first();
            if (!plan)
                return null;
            return {
                ...plan,
                features: plan.features ? JSON.parse(plan.features) : []
            };
        }
        catch (error) {
            logger_1.logger.error('Error fetching plan:', error);
            throw new Error('Failed to fetch plan');
        }
    }
    /**
     * Create or get Stripe customer for doctor
     */
    async getOrCreateStripeCustomer(doctorId, email, name) {
        try {
            // Check if customer already exists
            const existingSubscription = await (0, database_1.db)('doctor_subscriptions')
                .where('doctor_id', doctorId)
                .whereNotNull('stripe_customer_id')
                .first();
            if (existingSubscription?.stripe_customer_id) {
                return existingSubscription.stripe_customer_id;
            }
            // Create new Stripe customer
            const customer = await stripe.customers.create({
                email,
                name,
                metadata: {
                    doctor_id: doctorId
                }
            });
            logger_1.logger.info(`Created Stripe customer ${customer.id} for doctor ${doctorId}`);
            return customer.id;
        }
        catch (error) {
            logger_1.logger.error('Error creating Stripe customer:', error);
            throw new Error('Failed to create payment customer');
        }
    }
    /**
     * Create a new subscription for a doctor
     */
    async createSubscription(doctorId, tenantId, planId, paymentMethodId, email, name) {
        try {
            // Get the plan
            const plan = await this.getPlanById(planId);
            if (!plan) {
                throw new Error('Invalid subscription plan');
            }
            // Create or get Stripe customer
            const customerId = await this.getOrCreateStripeCustomer(doctorId, email, name);
            // Attach payment method to customer
            await stripe.paymentMethods.attach(paymentMethodId, {
                customer: customerId,
            });
            // Set as default payment method
            await stripe.customers.update(customerId, {
                invoice_settings: {
                    default_payment_method: paymentMethodId,
                },
            });
            // Create Stripe subscription
            const stripeSubscription = await stripe.subscriptions.create({
                customer: customerId,
                items: [
                    {
                        price: plan.stripe_price_id || await this.getOrCreateStripePrice(plan),
                    },
                ],
                trial_period_days: plan.trial_days > 0 ? plan.trial_days : undefined,
                expand: ['latest_invoice.payment_intent'],
                metadata: {
                    doctor_id: doctorId,
                    tenant_id: tenantId,
                    plan_id: planId,
                },
            });
            // Save subscription to database
            const [subscription] = await (0, database_1.db)('doctor_subscriptions')
                .insert({
                doctor_id: doctorId,
                tenant_id: tenantId,
                plan_id: planId,
                status: stripeSubscription.status,
                stripe_subscription_id: stripeSubscription.id,
                stripe_customer_id: customerId,
                current_period_start: new Date(stripeSubscription.current_period_start * 1000),
                current_period_end: new Date(stripeSubscription.current_period_end * 1000),
                trial_start: stripeSubscription.trial_start
                    ? new Date(stripeSubscription.trial_start * 1000)
                    : null,
                trial_end: stripeSubscription.trial_end
                    ? new Date(stripeSubscription.trial_end * 1000)
                    : null,
                cancel_at_period_end: false,
            })
                .returning('*');
            // Update doctor's subscription status
            await (0, database_1.db)('doctors')
                .where('id', doctorId)
                .update({
                active_subscription_id: subscription.id,
                subscription_status: stripeSubscription.status,
                subscription_expires_at: new Date(stripeSubscription.current_period_end * 1000),
            });
            logger_1.logger.info(`Created subscription ${subscription.id} for doctor ${doctorId}`);
            // Get client secret if payment requires action
            let clientSecret;
            const latestInvoice = stripeSubscription.latest_invoice;
            if (latestInvoice && typeof latestInvoice === 'object') {
                const paymentIntent = latestInvoice.payment_intent;
                if (paymentIntent && typeof paymentIntent === 'object') {
                    clientSecret = paymentIntent.client_secret;
                }
            }
            return { subscription, clientSecret };
        }
        catch (error) {
            logger_1.logger.error('Error creating subscription:', error);
            throw new Error('Failed to create subscription');
        }
    }
    /**
     * Get or create Stripe price for a plan
     */
    async getOrCreateStripePrice(plan) {
        try {
            if (plan.stripe_price_id) {
                return plan.stripe_price_id;
            }
            // Create product if doesn't exist
            let productId = plan.stripe_product_id;
            if (!productId) {
                const product = await stripe.products.create({
                    name: plan.name,
                    description: plan.description,
                    metadata: {
                        plan_id: plan.id
                    }
                });
                productId = product.id;
                // Update plan with product ID
                await (0, database_1.db)('subscription_plans')
                    .where('id', plan.id)
                    .update({ stripe_product_id: productId });
            }
            // Create price
            const price = await stripe.prices.create({
                product: productId,
                unit_amount: Math.round(plan.price * 100), // Convert to cents
                currency: plan.currency.toLowerCase(),
                recurring: {
                    interval: plan.interval === 'quarterly' ? 'month' : plan.interval,
                    interval_count: plan.interval === 'quarterly' ? 3 : plan.interval_count,
                },
                metadata: {
                    plan_id: plan.id
                }
            });
            // Update plan with price ID
            await (0, database_1.db)('subscription_plans')
                .where('id', plan.id)
                .update({ stripe_price_id: price.id });
            return price.id;
        }
        catch (error) {
            logger_1.logger.error('Error creating Stripe price:', error);
            throw new Error('Failed to create payment price');
        }
    }
    /**
     * Get doctor's active subscription
     */
    async getDoctorSubscription(doctorId) {
        try {
            const subscription = await (0, database_1.db)('doctor_subscriptions')
                .where('doctor_id', doctorId)
                .whereIn('status', ['active', 'trialing', 'past_due'])
                .orderBy('created_at', 'desc')
                .first();
            return subscription || null;
        }
        catch (error) {
            logger_1.logger.error('Error fetching doctor subscription:', error);
            throw new Error('Failed to fetch subscription');
        }
    }
    /**
     * Cancel subscription
     */
    async cancelSubscription(subscriptionId, cancelAtPeriodEnd = true) {
        try {
            const subscription = await (0, database_1.db)('doctor_subscriptions')
                .where('id', subscriptionId)
                .first();
            if (!subscription) {
                throw new Error('Subscription not found');
            }
            if (!subscription.stripe_subscription_id) {
                throw new Error('No Stripe subscription found');
            }
            // Cancel in Stripe
            if (cancelAtPeriodEnd) {
                await stripe.subscriptions.update(subscription.stripe_subscription_id, {
                    cancel_at_period_end: true,
                });
            }
            else {
                await stripe.subscriptions.cancel(subscription.stripe_subscription_id);
            }
            // Update database
            await (0, database_1.db)('doctor_subscriptions')
                .where('id', subscriptionId)
                .update({
                cancel_at_period_end: cancelAtPeriodEnd,
                canceled_at: new Date(),
                status: cancelAtPeriodEnd ? subscription.status : 'canceled',
            });
            if (!cancelAtPeriodEnd) {
                await (0, database_1.db)('doctors')
                    .where('id', subscription.doctor_id)
                    .update({
                    subscription_status: 'canceled',
                });
            }
            logger_1.logger.info(`Canceled subscription ${subscriptionId}`);
        }
        catch (error) {
            logger_1.logger.error('Error canceling subscription:', error);
            throw new Error('Failed to cancel subscription');
        }
    }
    /**
     * Resume a canceled subscription
     */
    async resumeSubscription(subscriptionId) {
        try {
            const subscription = await (0, database_1.db)('doctor_subscriptions')
                .where('id', subscriptionId)
                .first();
            if (!subscription) {
                throw new Error('Subscription not found');
            }
            if (!subscription.stripe_subscription_id) {
                throw new Error('No Stripe subscription found');
            }
            // Resume in Stripe
            await stripe.subscriptions.update(subscription.stripe_subscription_id, {
                cancel_at_period_end: false,
            });
            // Update database
            await (0, database_1.db)('doctor_subscriptions')
                .where('id', subscriptionId)
                .update({
                cancel_at_period_end: false,
                canceled_at: null,
            });
            logger_1.logger.info(`Resumed subscription ${subscriptionId}`);
        }
        catch (error) {
            logger_1.logger.error('Error resuming subscription:', error);
            throw new Error('Failed to resume subscription');
        }
    }
    /**
     * Update subscription plan
     */
    async updateSubscriptionPlan(subscriptionId, newPlanId) {
        try {
            const subscription = await (0, database_1.db)('doctor_subscriptions')
                .where('id', subscriptionId)
                .first();
            if (!subscription) {
                throw new Error('Subscription not found');
            }
            const newPlan = await this.getPlanById(newPlanId);
            if (!newPlan) {
                throw new Error('Invalid subscription plan');
            }
            if (!subscription.stripe_subscription_id) {
                throw new Error('No Stripe subscription found');
            }
            // Get current subscription from Stripe
            const stripeSubscription = await stripe.subscriptions.retrieve(subscription.stripe_subscription_id);
            // Update subscription in Stripe
            await stripe.subscriptions.update(subscription.stripe_subscription_id, {
                items: [
                    {
                        id: stripeSubscription.items.data[0].id,
                        price: newPlan.stripe_price_id || await this.getOrCreateStripePrice(newPlan),
                    },
                ],
                proration_behavior: 'always_invoice',
            });
            // Update database
            await (0, database_1.db)('doctor_subscriptions')
                .where('id', subscriptionId)
                .update({
                plan_id: newPlanId,
            });
            logger_1.logger.info(`Updated subscription ${subscriptionId} to plan ${newPlanId}`);
        }
        catch (error) {
            logger_1.logger.error('Error updating subscription plan:', error);
            throw new Error('Failed to update subscription plan');
        }
    }
    /**
     * Handle Stripe webhook events
     */
    async handleWebhookEvent(event) {
        try {
            switch (event.type) {
                case 'invoice.paid':
                    await this.handleInvoicePaid(event.data.object);
                    break;
                case 'invoice.payment_failed':
                    await this.handleInvoicePaymentFailed(event.data.object);
                    break;
                case 'customer.subscription.updated':
                    await this.handleSubscriptionUpdated(event.data.object);
                    break;
                case 'customer.subscription.deleted':
                    await this.handleSubscriptionDeleted(event.data.object);
                    break;
                default:
                    logger_1.logger.info(`Unhandled webhook event type: ${event.type}`);
            }
        }
        catch (error) {
            logger_1.logger.error('Error handling webhook event:', error);
            throw error;
        }
    }
    async handleInvoicePaid(invoice) {
        const subscriptionId = invoice.subscription;
        if (!subscriptionId)
            return;
        const subscription = await (0, database_1.db)('doctor_subscriptions')
            .where('stripe_subscription_id', subscriptionId)
            .first();
        if (!subscription)
            return;
        // Record transaction
        await (0, database_1.db)('subscription_transactions').insert({
            subscription_id: subscription.id,
            doctor_id: subscription.doctor_id,
            tenant_id: subscription.tenant_id,
            amount: invoice.amount_paid / 100,
            currency: invoice.currency.toUpperCase(),
            status: 'succeeded',
            type: 'payment',
            stripe_invoice_id: invoice.id,
            stripe_payment_intent_id: invoice.payment_intent,
            paid_at: new Date(invoice.status_transition.paid_at * 1000),
            invoice_data: JSON.stringify({
                invoice_pdf: invoice.invoice_pdf,
                hosted_invoice_url: invoice.hosted_invoice_url,
            }),
        });
        logger_1.logger.info(`Recorded payment for subscription ${subscription.id}`);
    }
    async handleInvoicePaymentFailed(invoice) {
        const subscriptionId = invoice.subscription;
        if (!subscriptionId)
            return;
        const subscription = await (0, database_1.db)('doctor_subscriptions')
            .where('stripe_subscription_id', subscriptionId)
            .first();
        if (!subscription)
            return;
        // Update subscription status
        await (0, database_1.db)('doctor_subscriptions')
            .where('id', subscription.id)
            .update({ status: 'past_due' });
        await (0, database_1.db)('doctors')
            .where('id', subscription.doctor_id)
            .update({ subscription_status: 'past_due' });
        // Record failed transaction
        await (0, database_1.db)('subscription_transactions').insert({
            subscription_id: subscription.id,
            doctor_id: subscription.doctor_id,
            tenant_id: subscription.tenant_id,
            amount: invoice.amount_due / 100,
            currency: invoice.currency.toUpperCase(),
            status: 'failed',
            type: 'payment',
            stripe_invoice_id: invoice.id,
            failure_reason: 'Payment failed',
        });
        logger_1.logger.warn(`Payment failed for subscription ${subscription.id}`);
    }
    async handleSubscriptionUpdated(stripeSubscription) {
        const subscription = await (0, database_1.db)('doctor_subscriptions')
            .where('stripe_subscription_id', stripeSubscription.id)
            .first();
        if (!subscription)
            return;
        // Update subscription
        await (0, database_1.db)('doctor_subscriptions')
            .where('id', subscription.id)
            .update({
            status: stripeSubscription.status,
            current_period_start: new Date(stripeSubscription.current_period_start * 1000),
            current_period_end: new Date(stripeSubscription.current_period_end * 1000),
            cancel_at_period_end: stripeSubscription.cancel_at_period_end,
        });
        // Update doctor status
        await (0, database_1.db)('doctors')
            .where('id', subscription.doctor_id)
            .update({
            subscription_status: stripeSubscription.status,
            subscription_expires_at: new Date(stripeSubscription.current_period_end * 1000),
        });
        logger_1.logger.info(`Updated subscription ${subscription.id} status to ${stripeSubscription.status}`);
    }
    async handleSubscriptionDeleted(stripeSubscription) {
        const subscription = await (0, database_1.db)('doctor_subscriptions')
            .where('stripe_subscription_id', stripeSubscription.id)
            .first();
        if (!subscription)
            return;
        // Update subscription
        await (0, database_1.db)('doctor_subscriptions')
            .where('id', subscription.id)
            .update({
            status: 'canceled',
            ended_at: new Date(),
        });
        // Update doctor status
        await (0, database_1.db)('doctors')
            .where('id', subscription.doctor_id)
            .update({
            subscription_status: 'canceled',
            active_subscription_id: null,
        });
        logger_1.logger.info(`Subscription ${subscription.id} deleted`);
    }
    /**
     * Check if doctor can book appointment (usage limits)
     */
    async canDoctorBookAppointment(doctorId) {
        try {
            const subscription = await this.getDoctorSubscription(doctorId);
            if (!subscription)
                return false;
            if (!['active', 'trialing'].includes(subscription.status))
                return false;
            const plan = await this.getPlanById(subscription.plan_id);
            if (!plan)
                return false;
            // Unlimited appointments
            if (plan.max_appointments_per_month === -1)
                return true;
            // Check current month usage
            const now = new Date();
            const month = now.getMonth() + 1;
            const year = now.getFullYear();
            const usage = await (0, database_1.db)('subscription_usage')
                .where('subscription_id', subscription.id)
                .where('month', month)
                .where('year', year)
                .first();
            const currentCount = usage?.appointments_count || 0;
            return currentCount < plan.max_appointments_per_month;
        }
        catch (error) {
            logger_1.logger.error('Error checking appointment limit:', error);
            return false;
        }
    }
    /**
     * Increment appointment usage
     */
    async incrementAppointmentUsage(doctorId) {
        try {
            const subscription = await this.getDoctorSubscription(doctorId);
            if (!subscription)
                return;
            const now = new Date();
            const month = now.getMonth() + 1;
            const year = now.getFullYear();
            await database_1.db.raw(`
        INSERT INTO subscription_usage (subscription_id, doctor_id, month, year, appointments_count)
        VALUES (?, ?, ?, ?, 1)
        ON CONFLICT (subscription_id, month, year)
        DO UPDATE SET appointments_count = subscription_usage.appointments_count + 1
      `, [subscription.id, doctorId, month, year]);
        }
        catch (error) {
            logger_1.logger.error('Error incrementing appointment usage:', error);
        }
    }
}
exports.SubscriptionService = SubscriptionService;
exports.subscriptionService = new SubscriptionService();
//# sourceMappingURL=subscription.service.js.map