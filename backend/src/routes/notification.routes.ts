import { Router } from 'express';
import { body } from 'express-validator';
import { NotificationController } from '../controllers/notification.controller';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { validateRequest, validatePagination, validateUUID } from '../middleware/validator';
import { tenantContext } from '../middleware/tenantContext';

const router = Router();
const notificationController = new NotificationController();

// All routes require authentication
router.use(authenticate);
router.use(tenantContext);

/**
 * @route   GET /api/v1/notifications
 * @desc    Get user notifications
 * @access  Private
 */
router.get(
  '/',
  validatePagination,
  notificationController.getUserNotifications
);

/**
 * @route   GET /api/v1/notifications/unread
 * @desc    Get unread notifications count
 * @access  Private
 */
router.get(
  '/unread',
  notificationController.getUnreadCount
);

/**
 * @route   GET /api/v1/notifications/:id
 * @desc    Get notification by ID
 * @access  Private
 */
router.get(
  '/:id',
  validateUUID('id'),
  notificationController.getNotificationById
);

/**
 * @route   PUT /api/v1/notifications/:id/read
 * @desc    Mark notification as read
 * @access  Private
 */
router.put(
  '/:id/read',
  validateUUID('id'),
  notificationController.markAsRead
);

/**
 * @route   PUT /api/v1/notifications/read-all
 * @desc    Mark all notifications as read
 * @access  Private
 */
router.put(
  '/read-all',
  notificationController.markAllAsRead
);

/**
 * @route   DELETE /api/v1/notifications/:id
 * @desc    Delete notification
 * @access  Private
 */
router.delete(
  '/:id',
  validateUUID('id'),
  notificationController.deleteNotification
);

/**
 * @route   POST /api/v1/notifications/send
 * @desc    Send notification (Admin only)
 * @access  Private/Admin
 */
router.post(
  '/send',
  authorize('admin', 'developer'),
  validateRequest([
    body('recipient_id').isUUID().withMessage('Valid recipient ID required'),
    body('type').isIn(['email', 'sms', 'push', 'whatsapp']).withMessage('Invalid notification type'),
    body('title').trim().notEmpty().withMessage('Title is required'),
    body('message').trim().notEmpty().withMessage('Message is required'),
    body('priority').optional().isIn(['low', 'medium', 'high']),
  ]),
  notificationController.sendNotification
);

/**
 * @route   POST /api/v1/notifications/broadcast
 * @desc    Broadcast notification to multiple users
 * @access  Private/Admin
 */
router.post(
  '/broadcast',
  authorize('admin', 'developer'),
  validateRequest([
    body('recipient_ids').isArray().withMessage('Recipients must be an array'),
    body('type').isIn(['email', 'sms', 'push', 'whatsapp']).withMessage('Invalid notification type'),
    body('title').trim().notEmpty().withMessage('Title is required'),
    body('message').trim().notEmpty().withMessage('Message is required'),
  ]),
  notificationController.broadcastNotification
);

/**
 * @route   GET /api/v1/notifications/preferences
 * @desc    Get user notification preferences
 * @access  Private
 */
router.get(
  '/preferences/get',
  notificationController.getPreferences
);

/**
 * @route   PUT /api/v1/notifications/preferences
 * @desc    Update notification preferences
 * @access  Private
 */
router.put(
  '/preferences/update',
  validateRequest([
    body('email_enabled').optional().isBoolean(),
    body('sms_enabled').optional().isBoolean(),
    body('push_enabled').optional().isBoolean(),
    body('whatsapp_enabled').optional().isBoolean(),
    body('appointment_reminders').optional().isBoolean(),
    body('marketing_emails').optional().isBoolean(),
  ]),
  notificationController.updatePreferences
);

export default router;



