"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.subscriptionController = exports.SubscriptionController = void 0;
const subscription_service_1 = require("../services/subscription.service");
const logger_1 = require("../config/logger");
const stripe_1 = __importDefault(require("stripe"));
const stripe = new stripe_1.default(process.env.STRIPE_SECRET_KEY || '', {
    apiVersion: '2024-12-18.acacia',
});
class SubscriptionController {
    /**
     * Get all available subscription plans
     * GET /api/v1/subscriptions/plans
     */
    async getPlans(req, res) {
        try {
            const plans = await subscription_service_1.subscriptionService.getPlans();
            res.json({
                success: true,
                data: plans,
            });
        }
        catch (error) {
            logger_1.logger.error('Error getting subscription plans:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch subscription plans',
            });
        }
    }
    /**
     * Get a specific plan by ID
     * GET /api/v1/subscriptions/plans/:planId
     */
    async getPlanById(req, res) {
        try {
            const { planId } = req.params;
            const plan = await subscription_service_1.subscriptionService.getPlanById(planId);
            if (!plan) {
                res.status(404).json({
                    success: false,
                    message: 'Plan not found',
                });
                return;
            }
            res.json({
                success: true,
                data: plan,
            });
        }
        catch (error) {
            logger_1.logger.error('Error getting plan:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch plan',
            });
        }
    }
    /**
     * Create a new subscription for the authenticated doctor
     * POST /api/v1/subscriptions/subscribe
     */
    async createSubscription(req, res) {
        try {
            const { planId, paymentMethodId } = req.body;
            const userId = req.user?.id;
            const tenantId = req.user?.tenant_id;
            if (!userId || !tenantId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            if (!planId || !paymentMethodId) {
                res.status(400).json({
                    success: false,
                    message: 'Plan ID and payment method are required',
                });
                return;
            }
            // Get doctor record
            const { db } = await Promise.resolve().then(() => __importStar(require('../config/database')));
            const doctor = await db('doctors')
                .where('user_id', userId)
                .first();
            if (!doctor) {
                res.status(404).json({
                    success: false,
                    message: 'Doctor profile not found',
                });
                return;
            }
            // Get user details for Stripe customer
            const user = await db('users')
                .where('id', userId)
                .first();
            const email = user.email;
            const name = `${user.first_name} ${user.last_name}`;
            // Create subscription
            const result = await subscription_service_1.subscriptionService.createSubscription(doctor.id, tenantId, planId, paymentMethodId, email, name);
            res.status(201).json({
                success: true,
                data: result.subscription,
                clientSecret: result.clientSecret,
                message: 'Subscription created successfully',
            });
        }
        catch (error) {
            logger_1.logger.error('Error creating subscription:', error);
            res.status(500).json({
                success: false,
                message: error instanceof Error ? error.message : 'Failed to create subscription',
            });
        }
    }
    /**
     * Get current doctor's subscription
     * GET /api/v1/subscriptions/current
     */
    async getCurrentSubscription(req, res) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { db } = await Promise.resolve().then(() => __importStar(require('../config/database')));
            const doctor = await db('doctors')
                .where('user_id', userId)
                .first();
            if (!doctor) {
                res.status(404).json({
                    success: false,
                    message: 'Doctor profile not found',
                });
                return;
            }
            const subscription = await subscription_service_1.subscriptionService.getDoctorSubscription(doctor.id);
            if (!subscription) {
                res.json({
                    success: true,
                    data: null,
                    message: 'No active subscription found',
                });
                return;
            }
            // Get plan details
            const plan = await subscription_service_1.subscriptionService.getPlanById(subscription.plan_id);
            res.json({
                success: true,
                data: {
                    ...subscription,
                    plan,
                },
            });
        }
        catch (error) {
            logger_1.logger.error('Error getting current subscription:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch subscription',
            });
        }
    }
    /**
     * Cancel subscription
     * POST /api/v1/subscriptions/cancel
     */
    async cancelSubscription(req, res) {
        try {
            const { subscriptionId, cancelAtPeriodEnd = true } = req.body;
            const userId = req.user?.id;
            if (!userId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            if (!subscriptionId) {
                res.status(400).json({
                    success: false,
                    message: 'Subscription ID is required',
                });
                return;
            }
            // Verify subscription belongs to this doctor
            const { db } = await Promise.resolve().then(() => __importStar(require('../config/database')));
            const doctor = await db('doctors')
                .where('user_id', userId)
                .first();
            if (!doctor) {
                res.status(404).json({
                    success: false,
                    message: 'Doctor profile not found',
                });
                return;
            }
            const subscription = await db('doctor_subscriptions')
                .where('id', subscriptionId)
                .where('doctor_id', doctor.id)
                .first();
            if (!subscription) {
                res.status(404).json({
                    success: false,
                    message: 'Subscription not found',
                });
                return;
            }
            await subscription_service_1.subscriptionService.cancelSubscription(subscriptionId, cancelAtPeriodEnd);
            res.json({
                success: true,
                message: cancelAtPeriodEnd
                    ? 'Subscription will be canceled at the end of the billing period'
                    : 'Subscription canceled immediately',
            });
        }
        catch (error) {
            logger_1.logger.error('Error canceling subscription:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to cancel subscription',
            });
        }
    }
    /**
     * Resume a canceled subscription
     * POST /api/v1/subscriptions/resume
     */
    async resumeSubscription(req, res) {
        try {
            const { subscriptionId } = req.body;
            const userId = req.user?.id;
            if (!userId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            if (!subscriptionId) {
                res.status(400).json({
                    success: false,
                    message: 'Subscription ID is required',
                });
                return;
            }
            // Verify subscription belongs to this doctor
            const { db } = await Promise.resolve().then(() => __importStar(require('../config/database')));
            const doctor = await db('doctors')
                .where('user_id', userId)
                .first();
            if (!doctor) {
                res.status(404).json({
                    success: false,
                    message: 'Doctor profile not found',
                });
                return;
            }
            const subscription = await db('doctor_subscriptions')
                .where('id', subscriptionId)
                .where('doctor_id', doctor.id)
                .first();
            if (!subscription) {
                res.status(404).json({
                    success: false,
                    message: 'Subscription not found',
                });
                return;
            }
            await subscription_service_1.subscriptionService.resumeSubscription(subscriptionId);
            res.json({
                success: true,
                message: 'Subscription resumed successfully',
            });
        }
        catch (error) {
            logger_1.logger.error('Error resuming subscription:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to resume subscription',
            });
        }
    }
    /**
     * Update subscription plan
     * POST /api/v1/subscriptions/change-plan
     */
    async updatePlan(req, res) {
        try {
            const { subscriptionId, newPlanId } = req.body;
            const userId = req.user?.id;
            if (!userId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            if (!subscriptionId || !newPlanId) {
                res.status(400).json({
                    success: false,
                    message: 'Subscription ID and new plan ID are required',
                });
                return;
            }
            // Verify subscription belongs to this doctor
            const { db } = await Promise.resolve().then(() => __importStar(require('../config/database')));
            const doctor = await db('doctors')
                .where('user_id', userId)
                .first();
            if (!doctor) {
                res.status(404).json({
                    success: false,
                    message: 'Doctor profile not found',
                });
                return;
            }
            const subscription = await db('doctor_subscriptions')
                .where('id', subscriptionId)
                .where('doctor_id', doctor.id)
                .first();
            if (!subscription) {
                res.status(404).json({
                    success: false,
                    message: 'Subscription not found',
                });
                return;
            }
            await subscription_service_1.subscriptionService.updateSubscriptionPlan(subscriptionId, newPlanId);
            res.json({
                success: true,
                message: 'Subscription plan updated successfully',
            });
        }
        catch (error) {
            logger_1.logger.error('Error updating subscription plan:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to update subscription plan',
            });
        }
    }
    /**
     * Get subscription invoices/transactions
     * GET /api/v1/subscriptions/invoices
     */
    async getInvoices(req, res) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { db } = await Promise.resolve().then(() => __importStar(require('../config/database')));
            const doctor = await db('doctors')
                .where('user_id', userId)
                .first();
            if (!doctor) {
                res.status(404).json({
                    success: false,
                    message: 'Doctor profile not found',
                });
                return;
            }
            const transactions = await db('subscription_transactions')
                .where('doctor_id', doctor.id)
                .orderBy('created_at', 'desc')
                .limit(50);
            res.json({
                success: true,
                data: transactions,
            });
        }
        catch (error) {
            logger_1.logger.error('Error getting invoices:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch invoices',
            });
        }
    }
    /**
     * Create Stripe payment intent for setup
     * POST /api/v1/subscriptions/create-setup-intent
     */
    async createSetupIntent(req, res) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { db } = await Promise.resolve().then(() => __importStar(require('../config/database')));
            const doctor = await db('doctors')
                .where('user_id', userId)
                .first();
            if (!doctor) {
                res.status(404).json({
                    success: false,
                    message: 'Doctor profile not found',
                });
                return;
            }
            const user = await db('users')
                .where('id', userId)
                .first();
            // Get or create Stripe customer
            const customerId = await subscription_service_1.subscriptionService.getOrCreateStripeCustomer(doctor.id, user.email, `${user.first_name} ${user.last_name}`);
            // Create setup intent
            const setupIntent = await stripe.setupIntents.create({
                customer: customerId,
                payment_method_types: ['card'],
            });
            res.json({
                success: true,
                data: {
                    clientSecret: setupIntent.client_secret,
                },
            });
        }
        catch (error) {
            logger_1.logger.error('Error creating setup intent:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to create payment setup',
            });
        }
    }
    /**
     * Stripe webhook handler
     * POST /api/v1/subscriptions/webhook
     */
    async handleWebhook(req, res) {
        const sig = req.headers['stripe-signature'];
        const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
        if (!webhookSecret) {
            res.status(500).send('Webhook secret not configured');
            return;
        }
        try {
            const event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
            await subscription_service_1.subscriptionService.handleWebhookEvent(event);
            res.json({ received: true });
        }
        catch (error) {
            logger_1.logger.error('Webhook error:', error);
            res.status(400).send(`Webhook Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
        }
    }
    /**
     * Get subscription usage statistics
     * GET /api/v1/subscriptions/usage
     */
    async getUsageStats(req, res) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { db } = await Promise.resolve().then(() => __importStar(require('../config/database')));
            const doctor = await db('doctors')
                .where('user_id', userId)
                .first();
            if (!doctor) {
                res.status(404).json({
                    success: false,
                    message: 'Doctor profile not found',
                });
                return;
            }
            const subscription = await subscription_service_1.subscriptionService.getDoctorSubscription(doctor.id);
            if (!subscription) {
                res.json({
                    success: true,
                    data: null,
                    message: 'No active subscription',
                });
                return;
            }
            const now = new Date();
            const month = now.getMonth() + 1;
            const year = now.getFullYear();
            const usage = await db('subscription_usage')
                .where('subscription_id', subscription.id)
                .where('month', month)
                .where('year', year)
                .first();
            const plan = await subscription_service_1.subscriptionService.getPlanById(subscription.plan_id);
            res.json({
                success: true,
                data: {
                    current_usage: usage?.appointments_count || 0,
                    limit: plan?.max_appointments_per_month || -1,
                    unlimited: plan?.max_appointments_per_month === -1,
                    period_start: subscription.current_period_start,
                    period_end: subscription.current_period_end,
                },
            });
        }
        catch (error) {
            logger_1.logger.error('Error getting usage stats:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch usage statistics',
            });
        }
    }
}
exports.SubscriptionController = SubscriptionController;
exports.subscriptionController = new SubscriptionController();
//# sourceMappingURL=subscription.controller.js.map