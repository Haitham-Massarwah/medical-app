import { Request, Response, NextFunction } from 'express';
export declare class NotificationController {
    /**
     * Get user notifications
     * GET /api/v1/notifications
     */
    getUserNotifications: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get unread notifications count
     * GET /api/v1/notifications/unread
     */
    getUnreadCount: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get notification by ID
     * GET /api/v1/notifications/:id
     */
    getNotificationById: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Mark notification as read
     * PUT /api/v1/notifications/:id/read
     */
    markAsRead: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Mark all notifications as read
     * PUT /api/v1/notifications/read-all
     */
    markAllAsRead: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Delete notification
     * DELETE /api/v1/notifications/:id
     */
    deleteNotification: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Send notification (Admin only)
     * POST /api/v1/notifications/send
     */
    sendNotification: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Broadcast notification to multiple users
     * POST /api/v1/notifications/broadcast
     */
    broadcastNotification: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get notification preferences
     * GET /api/v1/notifications/preferences/get
     */
    getPreferences: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update notification preferences
     * PUT /api/v1/notifications/preferences/update
     */
    updatePreferences: (req: Request, res: Response, next: NextFunction) => void;
}
//# sourceMappingURL=notification.controller.d.ts.map