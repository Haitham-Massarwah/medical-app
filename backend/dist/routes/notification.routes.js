"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const notification_controller_1 = require("../controllers/notification.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validator_1 = require("../middleware/validator");
const tenantContext_1 = require("../middleware/tenantContext");
const router = (0, express_1.Router)();
const notificationController = new notification_controller_1.NotificationController();
// All routes require authentication
router.use(auth_middleware_1.authenticate);
router.use(tenantContext_1.tenantContext);
/**
 * @route   GET /api/v1/notifications
 * @desc    Get user notifications
 * @access  Private
 */
router.get('/', validator_1.validatePagination, notificationController.getUserNotifications);
/**
 * @route   GET /api/v1/notifications/unread
 * @desc    Get unread notifications count
 * @access  Private
 */
router.get('/unread', notificationController.getUnreadCount);
/**
 * @route   GET /api/v1/notifications/:id
 * @desc    Get notification by ID
 * @access  Private
 */
router.get('/:id', (0, validator_1.validateUUID)('id'), notificationController.getNotificationById);
/**
 * @route   PUT /api/v1/notifications/:id/read
 * @desc    Mark notification as read
 * @access  Private
 */
router.put('/:id/read', (0, validator_1.validateUUID)('id'), notificationController.markAsRead);
/**
 * @route   PUT /api/v1/notifications/read-all
 * @desc    Mark all notifications as read
 * @access  Private
 */
router.put('/read-all', notificationController.markAllAsRead);
/**
 * @route   DELETE /api/v1/notifications/:id
 * @desc    Delete notification
 * @access  Private
 */
router.delete('/:id', (0, validator_1.validateUUID)('id'), notificationController.deleteNotification);
/**
 * @route   POST /api/v1/notifications/send
 * @desc    Send notification (Admin only)
 * @access  Private/Admin
 */
router.post('/send', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('recipient_id').isUUID().withMessage('Valid recipient ID required'),
    (0, express_validator_1.body)('type').isIn(['email', 'sms', 'push', 'whatsapp']).withMessage('Invalid notification type'),
    (0, express_validator_1.body)('title').trim().notEmpty().withMessage('Title is required'),
    (0, express_validator_1.body)('message').trim().notEmpty().withMessage('Message is required'),
    (0, express_validator_1.body)('priority').optional().isIn(['low', 'medium', 'high']),
]), notificationController.sendNotification);
/**
 * @route   POST /api/v1/notifications/broadcast
 * @desc    Broadcast notification to multiple users
 * @access  Private/Admin
 */
router.post('/broadcast', (0, auth_middleware_1.authorize)('admin', 'developer'), (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('recipient_ids').isArray().withMessage('Recipients must be an array'),
    (0, express_validator_1.body)('type').isIn(['email', 'sms', 'push', 'whatsapp']).withMessage('Invalid notification type'),
    (0, express_validator_1.body)('title').trim().notEmpty().withMessage('Title is required'),
    (0, express_validator_1.body)('message').trim().notEmpty().withMessage('Message is required'),
]), notificationController.broadcastNotification);
/**
 * @route   GET /api/v1/notifications/preferences
 * @desc    Get user notification preferences
 * @access  Private
 */
router.get('/preferences/get', notificationController.getPreferences);
/**
 * @route   PUT /api/v1/notifications/preferences
 * @desc    Update notification preferences
 * @access  Private
 */
router.put('/preferences/update', (0, validator_1.validateRequest)([
    (0, express_validator_1.body)('email_enabled').optional().isBoolean(),
    (0, express_validator_1.body)('sms_enabled').optional().isBoolean(),
    (0, express_validator_1.body)('push_enabled').optional().isBoolean(),
    (0, express_validator_1.body)('whatsapp_enabled').optional().isBoolean(),
    (0, express_validator_1.body)('appointment_reminders').optional().isBoolean(),
    (0, express_validator_1.body)('marketing_emails').optional().isBoolean(),
]), notificationController.updatePreferences);
exports.default = router;
//# sourceMappingURL=notification.routes.js.map