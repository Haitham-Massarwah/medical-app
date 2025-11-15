"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getNotificationServiceStatus = exports.sendBulkNotifications = exports.scheduleAppointmentReminder = exports.sendNotification = void 0;
const email_service_1 = require("./email.service");
const sms_service_1 = require("./sms.service");
const whatsapp_service_1 = require("./whatsapp.service");
const database_1 = __importDefault(require("../config/database"));
const logger_1 = require("../config/logger");
/**
 * Send notification through multiple channels based on user preferences
 */
const sendNotification = async (notification) => {
    try {
        // Get user preferences
        const preferences = await getUserNotificationPreferences(notification.userId);
        // Determine which channels to use
        const channels = notification.channels || ['email', 'sms'];
        const enabledChannels = channels.filter(channel => {
            switch (channel) {
                case 'email':
                    return preferences.email_enabled;
                case 'sms':
                    return preferences.sms_enabled;
                case 'whatsapp':
                    return preferences.whatsapp_enabled;
                case 'push':
                    return preferences.push_enabled;
                default:
                    return false;
            }
        });
        // Get user contact information
        const user = await (0, database_1.default)('users').where({ id: notification.userId }).first();
        if (!user) {
            logger_1.logger.error(`User not found: ${notification.userId}`);
            return;
        }
        // Send through each enabled channel
        const sendPromises = [];
        if (enabledChannels.includes('email') && user.email) {
            sendPromises.push(sendEmailNotification(notification.type, user.email, notification.data));
        }
        if (enabledChannels.includes('sms') && user.phone) {
            sendPromises.push(sendSMSNotification(notification.type, user.phone, notification.data));
        }
        if (enabledChannels.includes('whatsapp') && user.phone) {
            sendPromises.push(sendWhatsAppNotification(notification.type, user.phone, notification.data));
        }
        if (enabledChannels.includes('push')) {
            sendPromises.push(sendPushNotification(notification.userId, notification.type, notification.data));
        }
        // Wait for all notifications to be sent
        await Promise.allSettled(sendPromises);
        // Log notification in database
        await logNotification(notification);
        logger_1.logger.info(`Notification sent to user ${notification.userId} via ${enabledChannels.join(', ')}`);
    }
    catch (error) {
        logger_1.logger.error(`Failed to send notification to user ${notification.userId}:`, error.message);
    }
};
exports.sendNotification = sendNotification;
/**
 * Send email notification based on type
 */
const sendEmailNotification = async (type, email, data) => {
    switch (type) {
        case 'appointment_confirmation':
            await (0, email_service_1.sendAppointmentConfirmation)(email, data);
            break;
        case 'appointment_reminder':
            await (0, email_service_1.sendAppointmentReminder)(email, data);
            break;
        default:
            await (0, email_service_1.sendEmail)({
                to: email,
                subject: data.subject || 'Notification',
                template: 'general',
                data,
            });
    }
};
/**
 * Send SMS notification based on type
 */
const sendSMSNotification = async (type, phone, data) => {
    switch (type) {
        case 'appointment_confirmation':
            await (0, sms_service_1.sendAppointmentConfirmationSMS)(phone, data);
            break;
        case 'appointment_reminder':
            await (0, sms_service_1.sendAppointmentReminderSMS)(phone, data);
            break;
        default:
            await (0, sms_service_1.sendSMS)({
                to: phone,
                message: data.message || 'You have a new notification',
            });
    }
};
/**
 * Send WhatsApp notification based on type
 */
const sendWhatsAppNotification = async (type, phone, data) => {
    switch (type) {
        case 'appointment_confirmation':
            await (0, whatsapp_service_1.sendAppointmentConfirmationWhatsApp)(phone, data);
            break;
        case 'appointment_reminder':
            await (0, whatsapp_service_1.sendAppointmentReminderWhatsApp)(phone, data);
            break;
        default:
            await (0, whatsapp_service_1.sendWhatsApp)({
                to: phone,
                message: data.message || 'You have a new notification',
            });
    }
};
/**
 * Send push notification (placeholder - requires Firebase implementation)
 */
const sendPushNotification = async (userId, type, data) => {
    // TODO: Implement Firebase Cloud Messaging
    logger_1.logger.info(`Push notification would be sent to user ${userId}: ${type}`);
};
/**
 * Get user notification preferences
 */
const getUserNotificationPreferences = async (userId) => {
    let preferences = await (0, database_1.default)('notification_preferences')
        .where({ user_id: userId })
        .first();
    // Return default preferences if not found
    if (!preferences) {
        preferences = {
            email_enabled: true,
            sms_enabled: true,
            push_enabled: true,
            whatsapp_enabled: false,
            appointment_reminders: true,
            marketing_emails: false,
        };
    }
    return preferences;
};
/**
 * Log notification in database
 */
const logNotification = async (notification) => {
    try {
        await (0, database_1.default)('notifications').insert({
            recipient_id: notification.userId,
            type: notification.type,
            title: notification.data.title || notification.type.replace(/_/g, ' '),
            message: notification.data.message || JSON.stringify(notification.data),
            is_read: false,
            created_at: new Date(),
            updated_at: new Date(),
        });
    }
    catch (error) {
        logger_1.logger.error('Failed to log notification:', error.message);
    }
};
/**
 * Schedule appointment reminder
 */
const scheduleAppointmentReminder = async (appointmentId, hoursBeforeAppointment = 24) => {
    try {
        // Get appointment details
        const appointment = await (0, database_1.default)('appointments')
            .join('patients', 'appointments.patient_id', 'patients.id')
            .join('users as patient_users', 'patients.user_id', 'patient_users.id')
            .join('doctors', 'appointments.doctor_id', 'doctors.id')
            .join('users as doctor_users', 'doctors.user_id', 'doctor_users.id')
            .where('appointments.id', appointmentId)
            .select('appointments.*', 'patient_users.id as patient_user_id', 'patient_users.first_name as patient_first_name', 'patient_users.last_name as patient_last_name', database_1.default.raw("CONCAT(doctor_users.first_name, ' ', doctor_users.last_name) as doctor_name"))
            .first();
        if (!appointment) {
            logger_1.logger.error(`Appointment not found: ${appointmentId}`);
            return;
        }
        // Calculate reminder time
        const appointmentDateTime = new Date(`${appointment.appointment_date} ${appointment.start_time}`);
        const reminderTime = new Date(appointmentDateTime.getTime() - hoursBeforeAppointment * 60 * 60 * 1000);
        // TODO: Schedule with job queue (Agenda/Bull)
        // For now, just log
        logger_1.logger.info(`Reminder scheduled for appointment ${appointmentId} at ${reminderTime}`);
        // If reminder is due now or in the past, send immediately
        if (reminderTime <= new Date()) {
            await (0, exports.sendNotification)({
                userId: appointment.patient_user_id,
                type: 'appointment_reminder',
                data: {
                    patientName: appointment.patient_first_name,
                    doctorName: appointment.doctor_name,
                    date: appointment.appointment_date,
                    time: appointment.start_time,
                    hoursUntil: hoursBeforeAppointment,
                },
            });
        }
    }
    catch (error) {
        logger_1.logger.error(`Failed to schedule reminder for appointment ${appointmentId}:`, error.message);
    }
};
exports.scheduleAppointmentReminder = scheduleAppointmentReminder;
/**
 * Send bulk notifications
 */
const sendBulkNotifications = async (userIds, type, data) => {
    const sendPromises = userIds.map(userId => (0, exports.sendNotification)({
        userId,
        type: type,
        data,
    }));
    await Promise.allSettled(sendPromises);
    logger_1.logger.info(`Bulk notifications sent to ${userIds.length} users`);
};
exports.sendBulkNotifications = sendBulkNotifications;
/**
 * Get notification service status
 */
const getNotificationServiceStatus = () => {
    return {
        email: {
            configured: !!(process.env.SMTP_USER && process.env.SMTP_PASSWORD),
            provider: process.env.SMTP_HOST,
        },
        sms: {
            configured: !!(process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN),
            provider: 'Twilio',
        },
        whatsapp: {
            configured: !!(process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_WHATSAPP_NUMBER),
            provider: 'Twilio WhatsApp',
        },
        push: {
            configured: false, // TODO: Implement Firebase
            provider: 'Firebase (Not configured)',
        },
    };
};
exports.getNotificationServiceStatus = getNotificationServiceStatus;
//# sourceMappingURL=notification.service.js.map