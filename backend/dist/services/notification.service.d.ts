/**
 * Notification Orchestrator Service
 * Coordinates sending notifications across multiple channels
 */
export interface NotificationData {
    userId: string;
    type: 'appointment_confirmation' | 'appointment_reminder' | 'appointment_cancellation' | 'payment_confirmation' | 'general';
    channels?: ('email' | 'sms' | 'whatsapp' | 'push')[];
    data: any;
}
/**
 * Send notification through multiple channels based on user preferences
 */
export declare const sendNotification: (notification: NotificationData) => Promise<void>;
/**
 * Schedule appointment reminder
 */
export declare const scheduleAppointmentReminder: (appointmentId: string, hoursBeforeAppointment?: number) => Promise<void>;
/**
 * Send bulk notifications
 */
export declare const sendBulkNotifications: (userIds: string[], type: string, data: any) => Promise<void>;
/**
 * Get notification service status
 */
export declare const getNotificationServiceStatus: () => {
    email: {
        configured: boolean;
        provider: string | undefined;
    };
    sms: {
        configured: boolean;
        provider: string;
    };
    whatsapp: {
        configured: boolean;
        provider: string;
    };
    push: {
        configured: boolean;
        provider: string;
    };
};
//# sourceMappingURL=notification.service.d.ts.map