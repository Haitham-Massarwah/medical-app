import Stripe from 'stripe';
export interface SubscriptionPlan {
    id: string;
    name: string;
    description?: string;
    price: number;
    currency: string;
    interval: 'monthly' | 'quarterly' | 'yearly';
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
export declare class SubscriptionService {
    /**
     * Get all active subscription plans
     */
    getPlans(): Promise<SubscriptionPlan[]>;
    /**
     * Get a specific plan by ID
     */
    getPlanById(planId: string): Promise<SubscriptionPlan | null>;
    /**
     * Create or get Stripe customer for doctor
     */
    getOrCreateStripeCustomer(doctorId: string, email: string, name: string): Promise<string>;
    /**
     * Create a new subscription for a doctor
     */
    createSubscription(doctorId: string, tenantId: string, planId: string, paymentMethodId: string, email: string, name: string): Promise<{
        subscription: DoctorSubscription;
        clientSecret?: string;
    }>;
    /**
     * Get or create Stripe price for a plan
     */
    private getOrCreateStripePrice;
    /**
     * Get doctor's active subscription
     */
    getDoctorSubscription(doctorId: string): Promise<DoctorSubscription | null>;
    /**
     * Cancel subscription
     */
    cancelSubscription(subscriptionId: string, cancelAtPeriodEnd?: boolean): Promise<void>;
    /**
     * Resume a canceled subscription
     */
    resumeSubscription(subscriptionId: string): Promise<void>;
    /**
     * Update subscription plan
     */
    updateSubscriptionPlan(subscriptionId: string, newPlanId: string): Promise<void>;
    /**
     * Handle Stripe webhook events
     */
    handleWebhookEvent(event: Stripe.Event): Promise<void>;
    private handleInvoicePaid;
    private handleInvoicePaymentFailed;
    private handleSubscriptionUpdated;
    private handleSubscriptionDeleted;
    /**
     * Check if doctor can book appointment (usage limits)
     */
    canDoctorBookAppointment(doctorId: string): Promise<boolean>;
    /**
     * Increment appointment usage
     */
    incrementAppointmentUsage(doctorId: string): Promise<void>;
}
export declare const subscriptionService: SubscriptionService;
//# sourceMappingURL=subscription.service.d.ts.map