import { Router } from 'express';
import { subscriptionController } from '../controllers/subscription.controller';
import { authenticate } from '../middleware/auth.middleware';
import express from 'express';

const router = Router();

// Public routes
router.get('/plans', subscriptionController.getPlans.bind(subscriptionController));
router.get('/plans/:planId', subscriptionController.getPlanById.bind(subscriptionController));

// Webhook route (no authentication, uses Stripe signature verification)
router.post(
  '/webhook',
  express.raw({ type: 'application/json' }),
  subscriptionController.handleWebhook.bind(subscriptionController)
);

// Protected routes (require authentication)
router.use(authenticate);

router.post('/subscribe', subscriptionController.createSubscription.bind(subscriptionController));
router.get('/current', subscriptionController.getCurrentSubscription.bind(subscriptionController));
router.post('/cancel', subscriptionController.cancelSubscription.bind(subscriptionController));
router.post('/resume', subscriptionController.resumeSubscription.bind(subscriptionController));
router.post('/change-plan', subscriptionController.updatePlan.bind(subscriptionController));
router.get('/invoices', subscriptionController.getInvoices.bind(subscriptionController));
router.post('/create-setup-intent', subscriptionController.createSetupIntent.bind(subscriptionController));
router.get('/usage', subscriptionController.getUsageStats.bind(subscriptionController));

export default router;


