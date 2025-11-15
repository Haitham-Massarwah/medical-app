import { sendEmail, sendAppointmentConfirmation, sendAppointmentReminder } from './email.service';
import { sendSMS, sendAppointmentConfirmationSMS, sendAppointmentReminderSMS } from './sms.service';
import { sendWhatsApp, sendAppointmentConfirmationWhatsApp, sendAppointmentReminderWhatsApp } from './whatsapp.service';
import db from '../config/database';
import { logger } from '../config/logger';

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
export const sendNotification = async (notification: NotificationData): Promise<void> => {
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
    const user = await db('users').where({ id: notification.userId }).first();

    if (!user) {
      logger.error(`User not found: ${notification.userId}`);
      return;
    }

    // Send through each enabled channel
    const sendPromises: Promise<any>[] = [];

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

    logger.info(`Notification sent to user ${notification.userId} via ${enabledChannels.join(', ')}`);
  } catch (error: any) {
    logger.error(`Failed to send notification to user ${notification.userId}:`, error.message);
  }
};

/**
 * Send email notification based on type
 */
const sendEmailNotification = async (
  type: string,
  email: string,
  data: any
): Promise<void> => {
  switch (type) {
    case 'appointment_confirmation':
      await sendAppointmentConfirmation(email, data);
      break;
    case 'appointment_reminder':
      await sendAppointmentReminder(email, data);
      break;
    default:
      await sendEmail({
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
const sendSMSNotification = async (
  type: string,
  phone: string,
  data: any
): Promise<void> => {
  switch (type) {
    case 'appointment_confirmation':
      await sendAppointmentConfirmationSMS(phone, data);
      break;
    case 'appointment_reminder':
      await sendAppointmentReminderSMS(phone, data);
      break;
    default:
      await sendSMS({
        to: phone,
        message: data.message || 'You have a new notification',
      });
  }
};

/**
 * Send WhatsApp notification based on type
 */
const sendWhatsAppNotification = async (
  type: string,
  phone: string,
  data: any
): Promise<void> => {
  switch (type) {
    case 'appointment_confirmation':
      await sendAppointmentConfirmationWhatsApp(phone, data);
      break;
    case 'appointment_reminder':
      await sendAppointmentReminderWhatsApp(phone, data);
      break;
    default:
      await sendWhatsApp({
        to: phone,
        message: data.message || 'You have a new notification',
      });
  }
};

/**
 * Send push notification (placeholder - requires Firebase implementation)
 */
const sendPushNotification = async (
  userId: string,
  type: string,
  data: any
): Promise<void> => {
  // TODO: Implement Firebase Cloud Messaging
  logger.info(`Push notification would be sent to user ${userId}: ${type}`);
};

/**
 * Get user notification preferences
 */
const getUserNotificationPreferences = async (userId: string): Promise<any> => {
  let preferences = await db('notification_preferences')
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
const logNotification = async (notification: NotificationData): Promise<void> => {
  try {
    await db('notifications').insert({
      recipient_id: notification.userId,
      type: notification.type,
      title: notification.data.title || notification.type.replace(/_/g, ' '),
      message: notification.data.message || JSON.stringify(notification.data),
      is_read: false,
      created_at: new Date(),
      updated_at: new Date(),
    });
  } catch (error: any) {
    logger.error('Failed to log notification:', error.message);
  }
};

/**
 * Schedule appointment reminder
 */
export const scheduleAppointmentReminder = async (
  appointmentId: string,
  hoursBeforeAppointment: number = 24
): Promise<void> => {
  try {
    // Get appointment details
      const appointment = await db('appointments')
      .join('patients', 'appointments.patient_id', 'patients.id')
      .join('users as patient_users', 'patients.user_id', 'patient_users.id')
      .join('doctors', 'appointments.doctor_id', 'doctors.id')
      .join('users as doctor_users', 'doctors.user_id', 'doctor_users.id')
      .where('appointments.id', appointmentId)
      .select(
        'appointments.*',
        'patient_users.id as patient_user_id',
        'patient_users.first_name as patient_first_name',
        'patient_users.last_name as patient_last_name',
        db.raw("CONCAT(doctor_users.first_name, ' ', doctor_users.last_name) as doctor_name")
      )
        .first();

      if (!appointment) {
      logger.error(`Appointment not found: ${appointmentId}`);
      return;
    }

    // Calculate reminder time
    const appointmentDateTime = new Date(`${appointment.appointment_date} ${appointment.start_time}`);
    const reminderTime = new Date(appointmentDateTime.getTime() - hoursBeforeAppointment * 60 * 60 * 1000);

    // TODO: Schedule with job queue (Agenda/Bull)
    // For now, just log
    logger.info(`Reminder scheduled for appointment ${appointmentId} at ${reminderTime}`);

    // If reminder is due now or in the past, send immediately
    if (reminderTime <= new Date()) {
      await sendNotification({
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
  } catch (error: any) {
    logger.error(`Failed to schedule reminder for appointment ${appointmentId}:`, error.message);
  }
};

/**
 * Send bulk notifications
 */
export const sendBulkNotifications = async (
  userIds: string[],
  type: string,
  data: any
): Promise<void> => {
  const sendPromises = userIds.map(userId =>
    sendNotification({
      userId,
      type: type as any,
      data,
    })
  );

  await Promise.allSettled(sendPromises);

  logger.info(`Bulk notifications sent to ${userIds.length} users`);
};

/**
 * Get notification service status
 */
export const getNotificationServiceStatus = () => {
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
