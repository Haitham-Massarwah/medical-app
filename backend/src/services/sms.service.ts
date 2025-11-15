import twilio from 'twilio';
import { logger } from '../config/logger';

/**
 * SMS Service using Twilio
 * Sends SMS messages for notifications and reminders
 */

let twilioClient: twilio.Twilio | null = null;

/**
 * Initialize Twilio client
 */
const initializeTwilioClient = () => {
  if (twilioClient) return twilioClient;

  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;

  if (!accountSid || !authToken) {
    logger.warn('Twilio credentials not configured. SMS sending will be skipped.');
    return null;
  }

  twilioClient = twilio(accountSid, authToken);
  return twilioClient;
};

interface SMSOptions {
  to: string;
  message: string;
  from?: string;
}

/**
 * Send SMS message
 */
export const sendSMS = async (options: SMSOptions): Promise<boolean> => {
  try {
    const client = initializeTwilioClient();

    if (!client) {
      logger.warn(`SMS sending skipped (not configured): ${options.to}`);
      return false;
    }

    const fromNumber = options.from || process.env.TWILIO_PHONE_NUMBER;

    if (!fromNumber) {
      logger.error('Twilio phone number not configured');
      return false;
    }

    // Format phone number (ensure it starts with +)
    let toNumber = options.to.trim();
    if (!toNumber.startsWith('+')) {
      // Assume Israeli number if no country code
      toNumber = `+972${toNumber.replace(/^0/, '')}`;
    }

    const message = await client.messages.create({
      body: options.message,
      from: fromNumber,
      to: toNumber,
    });

    logger.info(`SMS sent successfully to ${toNumber}: ${message.sid}`);
    return true;
  } catch (error: any) {
    logger.error(`Failed to send SMS to ${options.to}:`, error.message);
    return false;
  }
};

/**
 * Send appointment confirmation SMS
 */
export const sendAppointmentConfirmationSMS = async (
  phoneNumber: string,
  data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    location: string;
  }
): Promise<boolean> => {
  const message = `Hi ${data.patientName},\n\nYour appointment is confirmed!\n\nDoctor: ${data.doctorName}\nDate: ${data.date}\nTime: ${data.time}\nLocation: ${data.location}\n\nSee you there!`;

  return sendSMS({
    to: phoneNumber,
    message,
  });
};

/**
 * Send appointment reminder SMS
 */
export const sendAppointmentReminderSMS = async (
  phoneNumber: string,
  data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    hoursUntil: number;
  }
): Promise<boolean> => {
  const message = `Reminder: You have an appointment in ${data.hoursUntil} hours!\n\nDoctor: ${data.doctorName}\nTime: ${data.time}\n\nSee you soon!`;

  return sendSMS({
    to: phoneNumber,
    message,
  });
};

/**
 * Send appointment cancellation SMS
 */
export const sendAppointmentCancellationSMS = async (
  phoneNumber: string,
  data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    reason?: string;
  }
): Promise<boolean> => {
  let message = `Hi ${data.patientName},\n\nYour appointment has been cancelled.\n\nDoctor: ${data.doctorName}\nDate: ${data.date}\nTime: ${data.time}`;

  if (data.reason) {
    message += `\n\nReason: ${data.reason}`;
  }

  message += '\n\nPlease contact us to reschedule.';

  return sendSMS({
    to: phoneNumber,
    message,
  });
};

/**
 * Send verification code SMS
 */
export const sendVerificationCodeSMS = async (
  phoneNumber: string,
  code: string
): Promise<boolean> => {
  const message = `Your verification code is: ${code}\n\nThis code expires in 10 minutes.`;

  return sendSMS({
    to: phoneNumber,
    message,
  });
};

/**
 * Send payment receipt SMS
 */
export const sendPaymentReceiptSMS = async (
  phoneNumber: string,
  data: {
    patientName: string;
    amount: number;
    currency: string;
    transactionId: string;
  }
): Promise<boolean> => {
  const message = `Payment received!\n\nAmount: ${data.amount} ${data.currency}\nTransaction ID: ${data.transactionId}\n\nThank you!`;

  return sendSMS({
    to: phoneNumber,
    message,
  });
};

/**
 * Check SMS service status
 */
export const checkSMSServiceStatus = (): {
  configured: boolean;
  accountSid?: string;
  phoneNumber?: string;
} => {
  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const phoneNumber = process.env.TWILIO_PHONE_NUMBER;

  return {
    configured: !!(accountSid && process.env.TWILIO_AUTH_TOKEN),
    accountSid: accountSid?.substring(0, 10) + '...',
    phoneNumber,
  };
};














