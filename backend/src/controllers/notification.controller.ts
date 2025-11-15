import { Request, Response, NextFunction } from 'express';
import { asyncHandler, NotFoundError, AuthorizationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';

export class NotificationController {
  /**
   * Get user notifications
   * GET /api/v1/notifications
   */
  getUserNotifications = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { page, limit, offset } = (req as any).pagination;
    const userId = req.user!.userId;
    const { is_read } = req.query;

    let query = db('notifications')
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
          total: parseInt(count as string),
          pages: Math.ceil(parseInt(count as string) / limit),
        },
      },
    });
  });

  /**
   * Get unread notifications count
   * GET /api/v1/notifications/unread
   */
  getUnreadCount = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user!.userId;

    const [{ count }] = await db('notifications')
      .where({ recipient_id: userId, is_read: false })
      .count('* as count');

    res.status(200).json({
      status: 'success',
      data: {
        unread_count: parseInt(count as string),
      },
    });
  });

  /**
   * Get notification by ID
   * GET /api/v1/notifications/:id
   */
  getNotificationById = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const userId = req.user!.userId;

    const notification = await db('notifications')
      .where({ id, recipient_id: userId })
      .first();

    if (!notification) {
      throw new NotFoundError('Notification');
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
  markAsRead = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const userId = req.user!.userId;

    const [notification] = await db('notifications')
      .where({ id, recipient_id: userId })
      .update({
        is_read: true,
        read_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    if (!notification) {
      throw new NotFoundError('Notification');
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
  markAllAsRead = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user!.userId;

    await db('notifications')
      .where({ recipient_id: userId, is_read: false })
      .update({
        is_read: true,
        read_at: new Date(),
        updated_at: new Date(),
      });

    logger.info(`All notifications marked as read for user: ${userId}`);

    res.status(200).json({
      status: 'success',
      message: 'All notifications marked as read',
    });
  });

  /**
   * Delete notification
   * DELETE /api/v1/notifications/:id
   */
  deleteNotification = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const userId = req.user!.userId;

    const deleted = await db('notifications')
      .where({ id, recipient_id: userId })
      .delete();

    if (!deleted) {
      throw new NotFoundError('Notification');
    }

    logger.info(`Notification deleted: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Notification deleted',
    });
  });

  /**
   * Send notification (Admin only)
   * POST /api/v1/notifications/send
   */
  sendNotification = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const {
      recipient_id,
      type,
      title,
      message,
      priority = 'medium',
    } = req.body;

    const [notification] = await db('notifications')
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

    logger.info(`Notification sent to user: ${recipient_id}`);

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
  broadcastNotification = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const {
      recipient_ids,
      type,
      title,
      message,
    } = req.body;

    const notifications = recipient_ids.map((recipientId: string) => ({
      recipient_id: recipientId,
      type,
      title,
      message,
      is_read: false,
      created_at: new Date(),
      updated_at: new Date(),
    }));

    await db('notifications').insert(notifications);

    logger.info(`Broadcast notification sent to ${recipient_ids.length} users`);

    res.status(201).json({
      status: 'success',
      message: `Notification broadcast to ${recipient_ids.length} users`,
    });
  });

  /**
   * Get notification preferences
   * GET /api/v1/notifications/preferences/get
   */
  getPreferences = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user!.userId;

    let preferences = await db('notification_preferences')
      .where({ user_id: userId })
      .first();

    // Create default preferences if not exists
    if (!preferences) {
      [preferences] = await db('notification_preferences')
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
  updatePreferences = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user!.userId;
    const updateData = {
      ...req.body,
      updated_at: new Date(),
    };

    const [preferences] = await db('notification_preferences')
      .where({ user_id: userId })
      .update(updateData)
      .returning('*');

    if (!preferences) {
      // Create if doesn't exist
      const [newPreferences] = await db('notification_preferences')
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

    logger.info(`Notification preferences updated for user: ${userId}`);

    res.status(200).json({
      status: 'success',
      message: 'Notification preferences updated',
      data: {
        preferences,
      },
    });
  });
}


