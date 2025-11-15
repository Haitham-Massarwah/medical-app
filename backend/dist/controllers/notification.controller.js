"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationController = void 0;
const errorHandler_1 = require("../middleware/errorHandler");
const database_1 = __importDefault(require("../config/database"));
const logger_1 = require("../config/logger");
class NotificationController {
    constructor() {
        /**
         * Get user notifications
         * GET /api/v1/notifications
         */
        this.getUserNotifications = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { page, limit, offset } = req.pagination;
            const userId = req.user.userId;
            const { is_read } = req.query;
            let query = (0, database_1.default)('notifications')
                .where({ recipient_id: userId });
            if (is_read !== undefined) {
                query = query.andWhere({ is_read: is_read === 'true' });
            }
            const [{ count }] = await query.clone().count('* as count');
            const notifications = await query
                .orderBy('created_at', 'desc')
                .limit(limit)
                .offset(offset);
            res.status(200).json({
                status: 'success',
                data: {
                    notifications,
                    pagination: {
                        page,
                        limit,
                        total: parseInt(count),
                        pages: Math.ceil(parseInt(count) / limit),
                    },
                },
            });
        });
        /**
         * Get unread notifications count
         * GET /api/v1/notifications/unread
         */
        this.getUnreadCount = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const userId = req.user.userId;
            const [{ count }] = await (0, database_1.default)('notifications')
                .where({ recipient_id: userId, is_read: false })
                .count('* as count');
            res.status(200).json({
                status: 'success',
                data: {
                    unread_count: parseInt(count),
                },
            });
        });
        /**
         * Get notification by ID
         * GET /api/v1/notifications/:id
         */
        this.getNotificationById = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const userId = req.user.userId;
            const notification = await (0, database_1.default)('notifications')
                .where({ id, recipient_id: userId })
                .first();
            if (!notification) {
                throw new errorHandler_1.NotFoundError('Notification');
            }
            res.status(200).json({
                status: 'success',
                data: {
                    notification,
                },
            });
        });
        /**
         * Mark notification as read
         * PUT /api/v1/notifications/:id/read
         */
        this.markAsRead = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const userId = req.user.userId;
            const [notification] = await (0, database_1.default)('notifications')
                .where({ id, recipient_id: userId })
                .update({
                is_read: true,
                read_at: new Date(),
                updated_at: new Date(),
            })
                .returning('*');
            if (!notification) {
                throw new errorHandler_1.NotFoundError('Notification');
            }
            res.status(200).json({
                status: 'success',
                message: 'Notification marked as read',
                data: {
                    notification,
                },
            });
        });
        /**
         * Mark all notifications as read
         * PUT /api/v1/notifications/read-all
         */
        this.markAllAsRead = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const userId = req.user.userId;
            await (0, database_1.default)('notifications')
                .where({ recipient_id: userId, is_read: false })
                .update({
                is_read: true,
                read_at: new Date(),
                updated_at: new Date(),
            });
            logger_1.logger.info(`All notifications marked as read for user: ${userId}`);
            res.status(200).json({
                status: 'success',
                message: 'All notifications marked as read',
            });
        });
        /**
         * Delete notification
         * DELETE /api/v1/notifications/:id
         */
        this.deleteNotification = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const userId = req.user.userId;
            const deleted = await (0, database_1.default)('notifications')
                .where({ id, recipient_id: userId })
                .delete();
            if (!deleted) {
                throw new errorHandler_1.NotFoundError('Notification');
            }
            logger_1.logger.info(`Notification deleted: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Notification deleted',
            });
        });
        /**
         * Send notification (Admin only)
         * POST /api/v1/notifications/send
         */
        this.sendNotification = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { recipient_id, type, title, message, priority = 'medium', } = req.body;
            const [notification] = await (0, database_1.default)('notifications')
                .insert({
                recipient_id,
                type,
                title,
                message,
                priority,
                is_read: false,
                created_at: new Date(),
                updated_at: new Date(),
            })
                .returning('*');
            logger_1.logger.info(`Notification sent to user: ${recipient_id}`);
            // TODO: Implement actual sending based on type (email, SMS, push, WhatsApp)
            res.status(201).json({
                status: 'success',
                message: 'Notification sent successfully',
                data: {
                    notification,
                },
            });
        });
        /**
         * Broadcast notification to multiple users
         * POST /api/v1/notifications/broadcast
         */
        this.broadcastNotification = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { recipient_ids, type, title, message, } = req.body;
            const notifications = recipient_ids.map((recipientId) => ({
                recipient_id: recipientId,
                type,
                title,
                message,
                is_read: false,
                created_at: new Date(),
                updated_at: new Date(),
            }));
            await (0, database_1.default)('notifications').insert(notifications);
            logger_1.logger.info(`Broadcast notification sent to ${recipient_ids.length} users`);
            res.status(201).json({
                status: 'success',
                message: `Notification broadcast to ${recipient_ids.length} users`,
            });
        });
        /**
         * Get notification preferences
         * GET /api/v1/notifications/preferences/get
         */
        this.getPreferences = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const userId = req.user.userId;
            let preferences = await (0, database_1.default)('notification_preferences')
                .where({ user_id: userId })
                .first();
            // Create default preferences if not exists
            if (!preferences) {
                [preferences] = await (0, database_1.default)('notification_preferences')
                    .insert({
                    user_id: userId,
                    email_enabled: true,
                    sms_enabled: true,
                    push_enabled: true,
                    whatsapp_enabled: false,
                    appointment_reminders: true,
                    marketing_emails: false,
                    created_at: new Date(),
                    updated_at: new Date(),
                })
                    .returning('*');
            }
            res.status(200).json({
                status: 'success',
                data: {
                    preferences,
                },
            });
        });
        /**
         * Update notification preferences
         * PUT /api/v1/notifications/preferences/update
         */
        this.updatePreferences = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const userId = req.user.userId;
            const updateData = {
                ...req.body,
                updated_at: new Date(),
            };
            const [preferences] = await (0, database_1.default)('notification_preferences')
                .where({ user_id: userId })
                .update(updateData)
                .returning('*');
            if (!preferences) {
                // Create if doesn't exist
                const [newPreferences] = await (0, database_1.default)('notification_preferences')
                    .insert({
                    user_id: userId,
                    ...req.body,
                    created_at: new Date(),
                    updated_at: new Date(),
                })
                    .returning('*');
                return res.status(200).json({
                    status: 'success',
                    message: 'Notification preferences created',
                    data: {
                        preferences: newPreferences,
                    },
                });
            }
            logger_1.logger.info(`Notification preferences updated for user: ${userId}`);
            res.status(200).json({
                status: 'success',
                message: 'Notification preferences updated',
                data: {
                    preferences,
                },
            });
        });
    }
}
exports.NotificationController = NotificationController;
//# sourceMappingURL=notification.controller.js.map