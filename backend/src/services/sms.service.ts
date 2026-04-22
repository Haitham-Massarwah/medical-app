import twilio from 'twilio';
import { logger } from '../config/logger';
import { getSMSTemplate, getDoctorLanguage, Language } from './sms-templates.service';
import { getSMSPriceForDoctor } from './price-calculator.service';

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
  doctorId?: string; // Optional: for doctor-specific SMS billing
  appointmentId?: string; // Optional: link SMS to appointment
  smsType?: 'reminder' | 'confirmation' | 'cancellation' | 'payment' | 'verification' | 'general';
}

/**
 * Send SMS message
 * If doctorId is provided, checks doctor SMS settings and deducts balance
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
      logger.error('Twilio phone number not configured. Set TWILIO_PHONE_NUMBER in environment variables.');
      logger.error(`Current TWILIO_PHONE_NUMBER value: ${process.env.TWILIO_PHONE_NUMBER || 'undefined'}`);
      return false;
    }

    // If doctorId is provided, check SMS settings and balance
    if (options.doctorId) {
      const db = require('../config/database').default;
      const settings = await db('doctor_sms_settings')
        .where({ doctor_id: options.doctorId, is_active: true })
        .first();

      if (!settings || !settings.sms_enabled) {
        logger.warn(`SMS sending skipped - doctor ${options.doctorId} has SMS disabled`);
        return false;
      }

      // Check balance for prepaid accounts
      if (settings.billing_method === 'prepaid') {
        // Calculate dynamic price: Twilio cost × multiplier
        const db = require('../config/database').default;
        const priceInfo = await getSMSPriceForDoctor(options.doctorId, db);
        const cost = priceInfo.price;
        const balance = parseFloat(settings.prepaid_balance.toString());

        if (balance < cost) {
          logger.warn(`SMS sending skipped - insufficient balance for doctor ${options.doctorId}. Balance: ${balance}, Cost: ${cost} ${priceInfo.currency}`);
          
          // Check if auto-recharge is enabled
          if (settings.auto_recharge && settings.auto_recharge_amount) {
            logger.info(`Auto-recharge enabled but not implemented yet for doctor ${options.doctorId}`);
          }
          
          return false;
        }
      }
    }

    logger.debug(`Sending SMS from ${fromNumber} to ${options.to}`);

    // Format phone number to match Twilio verified format
    // Remove any spaces, dashes, or parentheses first
    let toNumber = options.to.trim().replace(/[\s\-\(\)]/g, '');
    
    if (!toNumber.startsWith('+')) {
      // Assume Israeli number if no country code
      if (toNumber.startsWith('0')) {
        // For Israeli numbers, Twilio verifies as +9720XXXXXXXX (with 0)
        // Keep the 0: +972 + 0XXXXXXXX = +9720XXXXXXXX
        toNumber = `+972${toNumber}`;
      } else if (toNumber.startsWith('972')) {
        toNumber = `+${toNumber}`;
      } else {
        // Add country code with 0: +9720XXXXXXXX
        toNumber = `+9720${toNumber}`;
      }
    } else {
      // Already has +, but check if it's Israeli number without 0 after +972
      // If user sends +972526027636, Twilio needs +9720526027636
      if (toNumber.startsWith('+972') && !toNumber.startsWith('+9720') && toNumber.length === 13) {
        // +972XXXXXXXXXX -> +9720XXXXXXXXXX (add 0 after country code)
        toNumber = `+9720${toNumber.substring(4)}`;
        logger.debug(`Added missing 0 for Israeli number: ${toNumber}`);
      }
    }
    
    // Twilio verified format for Israeli numbers: +9720XXXXXXXX
    // Don't remove the 0 if it exists after +972
    logger.debug(`Formatted phone number: ${toNumber} (original: ${options.to})`);

    logger.info(`Attempting to send SMS from ${fromNumber} to ${toNumber}`);
    
    // Try using Messaging Service if configured (better for trial accounts)
    const messagingServiceSid = process.env.TWILIO_MESSAGING_SERVICE_SID;
    
    const messageParams: any = {
      body: options.message,
      to: toNumber,
    };
    
    if (messagingServiceSid) {
      logger.info(`Using Twilio Messaging Service: ${messagingServiceSid}`);
      messageParams.messagingServiceSid = messagingServiceSid;
    } else {
      messageParams.from = fromNumber;
    }
    
    const message = await client.messages.create(messageParams);

    logger.info(`SMS sent successfully to ${toNumber}: ${message.sid}`);

    // If doctorId is provided, record usage and deduct balance
    if (options.doctorId) {
      const db = require('../config/database').default;
      const settings = await db('doctor_sms_settings')
        .where({ doctor_id: options.doctorId })
        .first();

      if (settings) {
        // Calculate dynamic price: Twilio cost × multiplier
        const priceInfo = await getSMSPriceForDoctor(options.doctorId, db);
        const cost = priceInfo.price;
        const currency = priceInfo.currency;

        // Record usage
        await db('doctor_sms_usage').insert({
          doctor_id: options.doctorId,
          tenant_id: settings.tenant_id,
          appointment_id: options.appointmentId || null,
          to_phone: toNumber,
          message: options.message.substring(0, 1000), // Limit message length
          sms_type: options.smsType || 'general',
          twilio_message_sid: message.sid,
          twilio_status: message.status,
          cost,
          currency,
          sent_successfully: true,
          sent_at: new Date(),
          created_at: new Date(),
          updated_at: new Date(),
        });

        // Deduct balance for prepaid accounts
        if (settings.billing_method === 'prepaid') {
          const balanceBefore = parseFloat(settings.prepaid_balance.toString());
          const balanceAfter = balanceBefore - cost;

          await db('doctor_sms_settings')
            .where({ doctor_id: options.doctorId })
            .update({
              prepaid_balance: balanceAfter,
              updated_at: new Date(),
            });

          // Record billing transaction
          await db('doctor_sms_billing').insert({
            doctor_id: options.doctorId,
            tenant_id: settings.tenant_id,
            billing_type: 'usage',
            amount: -cost, // Negative for deduction
            currency,
            balance_before: balanceBefore,
            balance_after: balanceAfter,
            description: `SMS sent to ${toNumber} (${options.smsType || 'general'})`,
            billing_date: new Date(),
            created_at: new Date(),
            updated_at: new Date(),
          });

          logger.info(`Deducted ${cost} ${currency} from doctor ${options.doctorId} SMS balance. New balance: ${balanceAfter}`);
        }
      }
    }

    return true;
  } catch (error: any) {
    const errorDetails = {
      message: error.message,
      code: error.code,
      status: error.status,
      moreInfo: error.moreInfo,
      twilioError: error.twilioError,
    };
    
    logger.error(`Failed to send SMS to ${options.to}:`, errorDetails);
    logger.error(`Full error: ${JSON.stringify(errorDetails, null, 2)}`);
    
    // Handle specific Twilio error codes
    if (error.code === 21608) {
      logger.error('Twilio Error 21608: Number appears unverified. This is a Twilio trial account restriction.');
      logger.error('Solution: Upgrade Twilio account or ensure number is verified in exact format.');
    }
    
    // Log the actual Twilio error if available
    if (error.twilioError) {
      logger.error(`Twilio error details: ${JSON.stringify(error.twilioError, null, 2)}`);
    }

    // If doctorId is provided, record failed attempt
    if (options.doctorId) {
      try {
        const db = require('../config/database').default;
        const settings = await db('doctor_sms_settings')
          .where({ doctor_id: options.doctorId })
          .first();

        if (settings) {
          await db('doctor_sms_usage').insert({
            doctor_id: options.doctorId,
            tenant_id: settings.tenant_id,
            appointment_id: options.appointmentId || null,
            to_phone: options.to,
            message: options.message.substring(0, 1000),
            sms_type: options.smsType || 'general',
            cost: parseFloat(settings.sms_cost_per_message.toString()),
            currency: settings.currency || 'USD',
            sent_successfully: false,
            error_message: error.message,
            sent_at: new Date(),
            created_at: new Date(),
            updated_at: new Date(),
          });
        }
      } catch (dbError: any) {
        logger.error(`Failed to record SMS usage: ${dbError.message}`);
      }
    }
    
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
    doctorId?: string;
    appointmentId?: string;
  }
): Promise<boolean> => {
  // Get doctor's preferred language
  let language: Language = 'he';
  let customTemplates: any = undefined;
  
  if (data.doctorId) {
    language = await getDoctorLanguage(data.doctorId);
    
    // Get custom templates if they exist
    const db = require('../config/database').default;
    const settings = await db('doctor_sms_settings')
      .where({ doctor_id: data.doctorId })
      .first();
    
    if (settings && settings.custom_templates) {
      customTemplates = settings.custom_templates;
    }
  }

  const message = getSMSTemplate('confirmation', language, {
    patientName: data.patientName,
    doctorName: data.doctorName,
    date: data.date,
    time: data.time,
    location: data.location,
  }, customTemplates);

  return sendSMS({
    to: phoneNumber,
    message,
    doctorId: data.doctorId,
    appointmentId: data.appointmentId,
    smsType: 'confirmation',
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
    doctorId?: string;
    appointmentId?: string;
  }
): Promise<boolean> => {
  // Get doctor's preferred language
  let language: Language = 'he';
  let customTemplates: any = undefined;
  
  if (data.doctorId) {
    language = await getDoctorLanguage(data.doctorId);
    
    // Get custom templates if they exist
    const db = require('../config/database').default;
    const settings = await db('doctor_sms_settings')
      .where({ doctor_id: data.doctorId })
      .first();
    
    if (settings && settings.custom_templates) {
      customTemplates = settings.custom_templates;
    }
  }

  const message = getSMSTemplate('reminder', language, {
    patientName: data.patientName,
    doctorName: data.doctorName,
    date: data.date,
    time: data.time,
    hoursUntil: data.hoursUntil,
  }, customTemplates);

  return sendSMS({
    to: phoneNumber,
    message,
    doctorId: data.doctorId,
    appointmentId: data.appointmentId,
    smsType: 'reminder',
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
    doctorId?: string;
    appointmentId?: string;
  }
): Promise<boolean> => {
  // Get doctor's preferred language
  let language: Language = 'he';
  let customTemplates: any = undefined;
  
  if (data.doctorId) {
    language = await getDoctorLanguage(data.doctorId);
    
    // Get custom templates if they exist
    const db = require('../config/database').default;
    const settings = await db('doctor_sms_settings')
      .where({ doctor_id: data.doctorId })
      .first();
    
    if (settings && settings.custom_templates) {
      customTemplates = settings.custom_templates;
    }
  }

  const message = getSMSTemplate('cancellation', language, {
    patientName: data.patientName,
    doctorName: data.doctorName,
    date: data.date,
    time: data.time,
    reason: data.reason,
  }, customTemplates);

  return sendSMS({
    to: phoneNumber,
    message,
    doctorId: data.doctorId,
    appointmentId: data.appointmentId,
    smsType: 'cancellation',
  });
};

/**
 * Send verification code SMS
 */
export const sendVerificationCodeSMS = async (
  phoneNumber: string,
  code: string,
  doctorId?: string
): Promise<boolean> => {
  // Get doctor's preferred language
  let language: Language = 'he';
  if (doctorId) {
    language = await getDoctorLanguage(doctorId);
  }

  const message = getSMSTemplate('verification', language, {
    code,
  });

  return sendSMS({
    to: phoneNumber,
    message,
    doctorId,
    smsType: 'verification',
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
    doctorId?: string;
    appointmentId?: string;
  }
): Promise<boolean> => {
  // Get doctor's preferred language
  let language: Language = 'he';
  let customTemplates: any = undefined;
  
  if (data.doctorId) {
    language = await getDoctorLanguage(data.doctorId);
    
    // Get custom templates if they exist
    const db = require('../config/database').default;
    const settings = await db('doctor_sms_settings')
      .where({ doctor_id: data.doctorId })
      .first();
    
    if (settings && settings.custom_templates) {
      customTemplates = settings.custom_templates;
    }
  }

  const message = getSMSTemplate('payment', language, {
    amount: data.amount,
    currency: data.currency,
    transactionId: data.transactionId,
  }, customTemplates);

  return sendSMS({
    to: phoneNumber,
    message,
    doctorId: data.doctorId,
    appointmentId: data.appointmentId,
    smsType: 'payment',
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

/** True when Twilio can send (account + from number or messaging service). */
export function isTwilioSmsConfigured(): boolean {
  return !!(
    process.env.TWILIO_ACCOUNT_SID &&
    process.env.TWILIO_AUTH_TOKEN &&
    (process.env.TWILIO_PHONE_NUMBER || process.env.TWILIO_MESSAGING_SERVICE_SID)
  );
}

/** Short templates for manual no-show AI actions (English). */
export function buildNoShowSmsBody(
  kind: 'reminder' | 'confirm',
  patientFirstName: string,
  appointmentHint?: string,
): string {
  const name = patientFirstName.trim() || 'there';
  const hint = appointmentHint?.trim() ? ` ${appointmentHint.trim()}` : '';
  if (kind === 'confirm') {
    return `Hi ${name}, please confirm your upcoming appointment.${hint} Reply YES or call the clinic.`;
  }
  return `Reminder: you have an appointment coming up.${hint} We look forward to seeing you, ${name}.`;
}














