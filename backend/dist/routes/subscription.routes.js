"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const subscription_controller_1 = require("../controllers/subscription.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const express_2 = __importDefault(require("express"));
const router = (0, express_1.Router)();
// Public routes
router.get('/plans', subscription_controller_1.subscriptionController.getPlans.bind(subscription_controller_1.subscriptionController));
router.get('/plans/:planId', subscription_controller_1.subscriptionController.getPlanById.bind(subscription_controller_1.subscriptionController));
// Webhook route (no authentication, uses Stripe signature verification)
router.post('/webhook', express_2.default.raw({ type: 'application/json' }), subscription_controller_1.subscriptionController.handleWebhook.bind(subscription_controller_1.subscriptionController));
// Protected routes (require authentication)
router.use(auth_middleware_1.authenticate);
router.post('/subscribe', subscription_controller_1.subscriptionController.createSubscription.bind(subscription_controller_1.subscriptionController));
router.get('/current', subscription_controller_1.subscriptionController.getCurrentSubscription.bind(subscription_controller_1.subscriptionController));
router.post('/cancel', subscription_controller_1.subscriptionController.cancelSubscription.bind(subscription_controller_1.subscriptionController));
router.post('/resume', subscription_controller_1.subscriptionController.resumeSubscription.bind(subscription_controller_1.subscriptionController));
router.post('/change-plan', subscription_controller_1.subscriptionController.updatePlan.bind(subscription_controller_1.subscriptionController));
router.get('/invoices', subscription_controller_1.subscriptionController.getInvoices.bind(subscription_controller_1.subscriptionController));
router.post('/create-setup-intent', subscription_controller_1.subscriptionController.createSetupIntent.bind(subscription_controller_1.subscriptionController));
router.get('/usage', subscription_controller_1.subscriptionController.getUsageStats.bind(subscription_controller_1.subscriptionController));
exports.default = router;
//# sourceMappingURL=subscription.routes.js.map