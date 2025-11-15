import Stripe from 'stripe';
import db from '../config/database';
import { logger } from '../config/logger';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2023-10-16',
});

export interface SubscriptionPlan {
  id: string;
  name: string;
  description?: string;
  price: number;
  currency: string;
  interval: 'monthly' | 'quarterly' | 'yearly' | Stripe.PriceCreateParams.Recurring.Interval;
  interval_count: number;
  trial_days: number;
  features?: string[];
  max_appointments_per_month: number;
  is_active: boolean;
  is_popular: boolean;
  stripe_price_id?: string;
  stripe_product_id?: string;
}

export interface DoctorSubscription {
  id: string;
  doctor_id: string;
  tenant_id: string;
  plan_id: string;
  status: string;
  stripe_subscription_id?: string;
  stripe_customer_id?: string;
  current_period_start?: Date;
  current_period_end?: Date;
  trial_start?: Date;
  trial_end?: Date;
  cancel_at_period_end: boolean;
}

export class SubscriptionService {
  /**
   * Get all active subscription plans
   */
  async getPlans(): Promise<SubscriptionPlan[]> {
    try {
      const plans = await db('subscription_plans')
        .where('is_active', true)
        .orderBy('sort_order', 'asc');
      
      return plans.map((plan: any) => ({
        ...plan,
        features: plan.features ? JSON.parse(plan.features) : []
      }));
    } catch (error) {
      logger.error('Error fetching subscription plans:', error);
      throw new Error('Failed to fetch subscription plans');
    }
  }

  /**
   * Get a specific plan by ID
   */
  async getPlanById(planId: string): Promise<SubscriptionPlan | null> {
    try {
      const plan = await db('subscription_plans')
        .where('id', planId)
        .first();
      
      if (!plan) return null;
      
      return {
        ...plan,
        features: plan.features ? JSON.parse(plan.features) : []
      };
    } catch (error) {
      logger.error('Error fetching plan:', error);
      throw new Error('Failed to fetch plan');
    }
  }

  /**
   * Create or get Stripe customer for doctor
   */
  async getOrCreateStripeCustomer(
    doctorId: string,
    email: string,
    name: string
  ): Promise<string> {
    try {
      // Check if customer already exists
      const existingSubscription = await db('doctor_subscriptions')
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

      logger.info(`Created Stripe customer ${customer.id} for doctor ${doctorId}`);
      return customer.id;
    } catch (error) {
      logger.error('Error creating Stripe customer:', error);
      throw new Error('Failed to create payment customer');
    }
  }

  /**
   * Create a new subscription for a doctor
   */
  async createSubscription(
    doctorId: string,
    tenantId: string,
    planId: string,
    paymentMethodId: string,
    email: string,
    name: string
  ): Promise<{ subscription: DoctorSubscription; clientSecret?: string }> {
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
      const [subscription] = await db('doctor_subscriptions')
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
      await db('doctors')
        .where('id', doctorId)
        .update({
          active_subscription_id: subscription.id,
          subscription_status: stripeSubscription.status,
          subscription_expires_at: new Date(stripeSubscription.current_period_end * 1000),
        });

      logger.info(`Created subscription ${subscription.id} for doctor ${doctorId}`);

      // Get client secret if payment requires action
      let clientSecret;
      const latestInvoice = stripeSubscription.latest_invoice;
      if (latestInvoice && typeof latestInvoice === 'object') {
        const paymentIntent = latestInvoice.payment_intent;
        if (paymentIntent && typeof paymentIntent === 'object') {
          clientSecret = paymentIntent.client_secret;
        }
      }

      return { subscription, clientSecret: clientSecret ?? undefined };
    } catch (error) {
      logger.error('Error creating subscription:', error);
      throw new Error('Failed to create subscription');
    }
  }

  /**
   * Get or create Stripe price for a plan
   */
  private async getOrCreateStripePrice(plan: SubscriptionPlan): Promise<string> {
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
        await db('subscription_plans')
          .where('id', plan.id)
          .update({ stripe_product_id: productId });
      }

      // Create price
      const normalizedInterval =
        plan.interval === 'quarterly'
          ? 'month'
          : plan.interval === 'monthly'
            ? 'month'
            : plan.interval === 'yearly'
              ? 'year'
              : plan.interval;
      const intervalCount =
        plan.interval === 'quarterly'
          ? 3
          : plan.interval === 'monthly' || plan.interval === 'yearly'
            ? 1
            : plan.interval_count;

      const price = await stripe.prices.create({
        product: productId,
        unit_amount: Math.round(plan.price * 100), // Convert to cents
        currency: plan.currency.toLowerCase(),
        recurring: {
          interval: normalizedInterval as Stripe.PriceCreateParams.Recurring.Interval,
          interval_count: intervalCount,
        },
        metadata: {
          plan_id: plan.id
        }
      });

      // Update plan with price ID
      await db('subscription_plans')
        .where('id', plan.id)
        .update({ stripe_price_id: price.id });

      return price.id;
    } catch (error) {
      logger.error('Error creating Stripe price:', error);
      throw new Error('Failed to create payment price');
    }
  }

  /**
   * Get doctor's active subscription
   */
  async getDoctorSubscription(doctorId: string): Promise<DoctorSubscription | null> {
    try {
      const subscription = await db('doctor_subscriptions')
        .where('doctor_id', doctorId)
        .whereIn('status', ['active', 'trialing', 'past_due'])
        .orderBy('created_at', 'desc')
        .first();

      return subscription || null;
    } catch (error) {
      logger.error('Error fetching doctor subscription:', error);
      throw new Error('Failed to fetch subscription');
    }
  }

  /**
   * Cancel subscription
   */
  async cancelSubscription(
    subscriptionId: string,
    cancelAtPeriodEnd: boolean = true
  ): Promise<void> {
    try {
      const subscription = await db('doctor_subscriptions')
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
      } else {
        await stripe.subscriptions.cancel(subscription.stripe_subscription_id);
      }

      // Update database
      await db('doctor_subscriptions')
        .where('id', subscriptionId)
        .update({
          cancel_at_period_end: cancelAtPeriodEnd,
          canceled_at: new Date(),
          status: cancelAtPeriodEnd ? subscription.status : 'canceled',
        });

      if (!cancelAtPeriodEnd) {
        await db('doctors')
          .where('id', subscription.doctor_id)
          .update({
            subscription_status: 'canceled',
          });
      }

      logger.info(`Canceled subscription ${subscriptionId}`);
    } catch (error) {
      logger.error('Error canceling subscription:', error);
      throw new Error('Failed to cancel subscription');
    }
  }

  /**
   * Resume a canceled subscription
   */
  async resumeSubscription(subscriptionId: string): Promise<void> {
    try {
      const subscription = await db('doctor_subscriptions')
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
      await db('doctor_subscriptions')
        .where('id', subscriptionId)
        .update({
          cancel_at_period_end: false,
          canceled_at: null,
        });

      logger.info(`Resumed subscription ${subscriptionId}`);
    } catch (error) {
      logger.error('Error resuming subscription:', error);
      throw new Error('Failed to resume subscription');
    }
  }

  /**
   * Update subscription plan
   */
  async updateSubscriptionPlan(
    subscriptionId: string,
    newPlanId: string
  ): Promise<void> {
    try {
      const subscription = await db('doctor_subscriptions')
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
      const stripeSubscription = await stripe.subscriptions.retrieve(
        subscription.stripe_subscription_id
      );

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
      await db('doctor_subscriptions')
        .where('id', subscriptionId)
        .update({
          plan_id: newPlanId,
        });

      logger.info(`Updated subscription ${subscriptionId} to plan ${newPlanId}`);
    } catch (error) {
      logger.error('Error updating subscription plan:', error);
      throw new Error('Failed to update subscription plan');
    }
  }

  /**
   * Handle Stripe webhook events
   */
  async handleWebhookEvent(event: Stripe.Event): Promise<void> {
    try {
      switch (event.type) {
        case 'invoice.paid':
          await this.handleInvoicePaid(event.data.object as Stripe.Invoice);
          break;
        
        case 'invoice.payment_failed':
          await this.handleInvoicePaymentFailed(event.data.object as Stripe.Invoice);
          break;
        
        case 'customer.subscription.updated':
          await this.handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
          break;
        
        case 'customer.subscription.deleted':
          await this.handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
          break;
        
        default:
          logger.info(`Unhandled webhook event type: ${event.type}`);
      }
    } catch (error) {
      logger.error('Error handling webhook event:', error);
      throw error;
    }
  }

  private async handleInvoicePaid(invoice: Stripe.Invoice): Promise<void> {
    const subscriptionId = invoice.subscription as string;
    if (!subscriptionId) return;

    const subscription = await db('doctor_subscriptions')
      .where('stripe_subscription_id', subscriptionId)
      .first();

    if (!subscription) return;

    // Record transaction
    await db('subscription_transactions').insert({
      subscription_id: subscription.id,
      doctor_id: subscription.doctor_id,
      tenant_id: subscription.tenant_id,
      amount: invoice.amount_paid / 100,
      currency: invoice.currency.toUpperCase(),
      status: 'succeeded',
      type: 'payment',
      stripe_invoice_id: invoice.id,
      stripe_payment_intent_id: invoice.payment_intent as string,
      paid_at: new Date(invoice.status_transitions?.paid_at! * 1000),
      invoice_data: JSON.stringify({
        invoice_pdf: invoice.invoice_pdf,
        hosted_invoice_url: invoice.hosted_invoice_url,
      }),
    });

    logger.info(`Recorded payment for subscription ${subscription.id}`);
  }

  private async handleInvoicePaymentFailed(invoice: Stripe.Invoice): Promise<void> {
    const subscriptionId = invoice.subscription as string;
    if (!subscriptionId) return;

    const subscription = await db('doctor_subscriptions')
      .where('stripe_subscription_id', subscriptionId)
      .first();

    if (!subscription) return;

    // Update subscription status
    await db('doctor_subscriptions')
      .where('id', subscription.id)
      .update({ status: 'past_due' });

    await db('doctors')
      .where('id', subscription.doctor_id)
      .update({ subscription_status: 'past_due' });

    // Record failed transaction
    await db('subscription_transactions').insert({
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

    logger.warn(`Payment failed for subscription ${subscription.id}`);
  }

  private async handleSubscriptionUpdated(
    stripeSubscription: Stripe.Subscription
  ): Promise<void> {
    const subscription = await db('doctor_subscriptions')
      .where('stripe_subscription_id', stripeSubscription.id)
      .first();

    if (!subscription) return;

    // Update subscription
    await db('doctor_subscriptions')
      .where('id', subscription.id)
      .update({
        status: stripeSubscription.status,
        current_period_start: new Date(stripeSubscription.current_period_start * 1000),
        current_period_end: new Date(stripeSubscription.current_period_end * 1000),
        cancel_at_period_end: stripeSubscription.cancel_at_period_end,
      });

    // Update doctor status
    await db('doctors')
      .where('id', subscription.doctor_id)
      .update({
        subscription_status: stripeSubscription.status,
        subscription_expires_at: new Date(stripeSubscription.current_period_end * 1000),
      });

    logger.info(`Updated subscription ${subscription.id} status to ${stripeSubscription.status}`);
  }

  private async handleSubscriptionDeleted(
    stripeSubscription: Stripe.Subscription
  ): Promise<void> {
    const subscription = await db('doctor_subscriptions')
      .where('stripe_subscription_id', stripeSubscription.id)
      .first();

    if (!subscription) return;

    // Update subscription
    await db('doctor_subscriptions')
      .where('id', subscription.id)
      .update({
        status: 'canceled',
        ended_at: new Date(),
      });

    // Update doctor status
    await db('doctors')
      .where('id', subscription.doctor_id)
      .update({
        subscription_status: 'canceled',
        active_subscription_id: null,
      });

    logger.info(`Subscription ${subscription.id} deleted`);
  }

  /**
   * Check if doctor can book appointment (usage limits)
   */
  async canDoctorBookAppointment(doctorId: string): Promise<boolean> {
    try {
      const subscription = await this.getDoctorSubscription(doctorId);
      
      if (!subscription) return false;
      if (!['active', 'trialing'].includes(subscription.status)) return false;

      const plan = await this.getPlanById(subscription.plan_id);
      if (!plan) return false;

      // Unlimited appointments
      if (plan.max_appointments_per_month === -1) return true;

      // Check current month usage
      const now = new Date();
      const month = now.getMonth() + 1;
      const year = now.getFullYear();

      const usage = await db('subscription_usage')
        .where('subscription_id', subscription.id)
        .where('month', month)
        .where('year', year)
        .first();

      const currentCount = usage?.appointments_count || 0;
      return currentCount < plan.max_appointments_per_month;
    } catch (error) {
      logger.error('Error checking appointment limit:', error);
      return false;
    }
  }

  /**
   * Increment appointment usage
   */
  async incrementAppointmentUsage(doctorId: string): Promise<void> {
    try {
      const subscription = await this.getDoctorSubscription(doctorId);
      if (!subscription) return;

      const now = new Date();
      const month = now.getMonth() + 1;
      const year = now.getFullYear();

      await db.raw(`
        INSERT INTO subscription_usage (subscription_id, doctor_id, month, year, appointments_count)
        VALUES (?, ?, ?, ?, 1)
        ON CONFLICT (subscription_id, month, year)
        DO UPDATE SET appointments_count = subscription_usage.appointments_count + 1
      `, [subscription.id, doctorId, month, year]);
    } catch (error) {
      logger.error('Error incrementing appointment usage:', error);
    }
  }
}

export const subscriptionService = new SubscriptionService();


