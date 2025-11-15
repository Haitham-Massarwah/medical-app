import twilio from 'twilio';
import { logger } from '../config/logger';

/**
 * WhatsApp Service using Twilio WhatsApp Business API
 * Sends WhatsApp messages for notifications
 */

let twilioClient: twilio.Twilio | null = null;

/**
 * Initialize Twilio client for WhatsApp
 */
const initializeTwilioClient = () => {
  if (twilioClient) return twilioClient;

  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;

  if (!accountSid || !authToken) {
    logger.warn('Twilio credentials not configured. WhatsApp sending will be skipped.');
    return null;
  }

  twilioClient = twilio(accountSid, authToken);
  return twilioClient;
};

interface WhatsAppOptions {
  to: string;
  message: string;
  mediaUrl?: string;
}

/**
 * Send WhatsApp message
 */
export const sendWhatsApp = async (options: WhatsAppOptions): Promise<boolean> => {
  try {
    const client = initializeTwilioClient();

    if (!client) {
      logger.warn(`WhatsApp sending skipped (not configured): ${options.to}`);
      return false;
    }

    const fromNumber = process.env.TWILIO_WHATSAPP_NUMBER;

    if (!fromNumber) {
      logger.error('Twilio WhatsApp number not configured');
      return false;
    }

    // Format WhatsApp number (must start with whatsapp:+)
    let toNumber = options.to.trim();
    if (!toNumber.startsWith('whatsapp:')) {
      if (!toNumber.startsWith('+')) {
        // Assume Israeli number if no country code
        toNumber = `+972${toNumber.replace(/^0/, '')}`;
      }
      toNumber = `whatsapp:${toNumber}`;
    }

    const messageOptions: any = {
      body: options.message,
      from: fromNumber,
      to: toNumber,
    };

    // Add media if provided
    if (options.mediaUrl) {
      messageOptions.mediaUrl = [options.mediaUrl];
    }

    const message = await client.messages.create(messageOptions);

    logger.info(`WhatsApp sent successfully to ${toNumber}: ${message.sid}`);
    return true;
  } catch (error: any) {
    logger.error(`Failed to send WhatsApp to ${options.to}:`, error.message);
    return false;
  }
};

/**
 * Send appointment confirmation WhatsApp
 */
export const sendAppointmentConfirmationWhatsApp = async (
  phoneNumber: string,
  data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    location: string;
  }
): Promise<boolean> => {
  const message = `*Appointment Confirmed* ✅\n\nHi ${data.patientName}!\n\n👨‍⚕️ Doctor: ${data.doctorName}\n📅 Date: ${data.date}\n🕐 Time: ${data.time}\n📍 Location: ${data.location}\n\nSee you there!`;

  return sendWhatsApp({
    to: phoneNumber,
    message,
  });
};

/**
 * Send appointment reminder WhatsApp
 */
export const sendAppointmentReminderWhatsApp = async (
  phoneNumber: string,
  data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    hoursUntil: number;
  }
): Promise<boolean> => {
  const message = `*Appointment Reminder* 🔔\n\nHi ${data.patientName}!\n\nYou have an appointment in *${data.hoursUntil} hours*\n\n👨‍⚕️ Doctor: ${data.doctorName}\n🕐 Time: ${data.time}\n\nSee you soon!`;

  return sendWhatsApp({
    to: phoneNumber,
    message,
  });
};

/**
 * Send appointment cancellation WhatsApp
 */
export const sendAppointmentCancellationWhatsApp = async (
  phoneNumber: string,
  data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    reason?: string;
  }
): Promise<boolean> => {
  let message = `*Appointment Cancelled* ❌\n\nHi ${data.patientName},\n\nYour appointment has been cancelled.\n\n👨‍⚕️ Doctor: ${data.doctorName}\n📅 Date: ${data.date}\n🕐 Time: ${data.time}`;

  if (data.reason) {
    message += `\n\n📝 Reason: ${data.reason}`;
  }

  message += '\n\nPlease contact us to reschedule.';

  return sendWhatsApp({
    to: phoneNumber,
    message,
  });
};

/**
 * Send payment confirmation WhatsApp
 */
export const sendPaymentConfirmationWhatsApp = async (
  phoneNumber: string,
  data: {
    patientName: string;
    amount: number;
    currency: string;
    transactionId: string;
  }
): Promise<boolean> => {
  const message = `*Payment Received* ✅\n\nThank you, ${data.patientName}!\n\n💰 Amount: ${data.amount} ${data.currency}\n🔖 Transaction ID: ${data.transactionId}\n\nReceipt sent to your email.`;

  return sendWhatsApp({
    to: phoneNumber,
    message,
  });
};

/**
 * Check WhatsApp service status
 */
export const checkWhatsAppServiceStatus = (): {
  configured: boolean;
  accountSid?: string;
  phoneNumber?: string;
} => {
  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const phoneNumber = process.env.TWILIO_WHATSAPP_NUMBER;

  return {
    configured: !!(accountSid && process.env.TWILIO_AUTH_TOKEN && phoneNumber),
    accountSid: accountSid?.substring(0, 10) + '...',
    phoneNumber,
  };
};














