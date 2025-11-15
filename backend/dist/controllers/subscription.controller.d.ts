import { Request, Response } from 'express';
export declare class SubscriptionController {
    /**
     * Get all available subscription plans
     * GET /api/v1/subscriptions/plans
     */
    getPlans(req: Request, res: Response): Promise<void>;
    /**
     * Get a specific plan by ID
     * GET /api/v1/subscriptions/plans/:planId
     */
    getPlanById(req: Request, res: Response): Promise<void>;
    /**
     * Create a new subscription for the authenticated doctor
     * POST /api/v1/subscriptions/subscribe
     */
    createSubscription(req: Request, res: Response): Promise<void>;
    /**
     * Get current doctor's subscription
     * GET /api/v1/subscriptions/current
     */
    getCurrentSubscription(req: Request, res: Response): Promise<void>;
    /**
     * Cancel subscription
     * POST /api/v1/subscriptions/cancel
     */
    cancelSubscription(req: Request, res: Response): Promise<void>;
    /**
     * Resume a canceled subscription
     * POST /api/v1/subscriptions/resume
     */
    resumeSubscription(req: Request, res: Response): Promise<void>;
    /**
     * Update subscription plan
     * POST /api/v1/subscriptions/change-plan
     */
    updatePlan(req: Request, res: Response): Promise<void>;
    /**
     * Get subscription invoices/transactions
     * GET /api/v1/subscriptions/invoices
     */
    getInvoices(req: Request, res: Response): Promise<void>;
    /**
     * Create Stripe payment intent for setup
     * POST /api/v1/subscriptions/create-setup-intent
     */
    createSetupIntent(req: Request, res: Response): Promise<void>;
    /**
     * Stripe webhook handler
     * POST /api/v1/subscriptions/webhook
     */
    handleWebhook(req: Request, res: Response): Promise<void>;
    /**
     * Get subscription usage statistics
     * GET /api/v1/subscriptions/usage
     */
    getUsageStats(req: Request, res: Response): Promise<void>;
}
export declare const subscriptionController: SubscriptionController;
//# sourceMappingURL=subscription.controller.d.ts.map