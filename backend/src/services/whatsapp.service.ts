import twilio from 'twilio';
import db from '../config/database';
import { logger } from '../config/logger';
import {
  isMetaWhatsAppConfigured,
  sendMetaWhatsAppText,
  sendMetaWhatsAppTemplate,
  buildBodyTextComponent,
} from './metaWhatsapp.service';
import { sendSMS } from './sms.service';
import { createTelegramLinkUrlForUser } from './telegramLink.service';
import { isTelegramConfigured, sendTelegramMessage } from './telegram.service';

/**
 * Messaging service (WhatsApp + Telegram).
 *
 * The SERVER-WIDE WhatsApp provider is selected by WHATSAPP_PROVIDER:
 *   - "mock"     : do not call any provider, log the message only
 *   - "meta"     : Meta WhatsApp Cloud API (graph.facebook.com)
 *   - "twilio"   : Twilio WhatsApp Business API
 *   - "telegram" : Default routing for users with no explicit preference.
 *
 * PER-USER CHANNEL SELECTION is stored in users.preferred_messaging_channel:
 *   - 'default' / NULL  → follow WHATSAPP_PROVIDER
 *   - 'whatsapp'        → send only via the configured WhatsApp provider
 *   - 'telegram'        → send only via Telegram (requires linking)
 *   - 'both'            → send via WhatsApp AND Telegram
 *   - 'none'            → do not send messages
 *
 * If WHATSAPP_PROVIDER is unset:
 *   - WHATSAPP_MOCK_MODE=true     → mock
 *   - META_WA_TOKEN configured    → meta
 *   - otherwise                   → twilio (legacy behavior)
 */

type WhatsAppProvider = 'mock' | 'meta' | 'twilio' | 'telegram';

export type MessagingChannelPreference =
  | 'default'
  | 'whatsapp'
  | 'telegram'
  | 'both'
  | 'none';

export const VALID_MESSAGING_CHANNELS: MessagingChannelPreference[] = [
  'default',
  'whatsapp',
  'telegram',
  'both',
  'none',
];

type ActiveChannel = 'whatsapp' | 'telegram';

let twilioClient: twilio.Twilio | null = null;

/** When true, no provider is called; messages are logged only (for local/testing). */
export const isWhatsAppMockMode = (): boolean =>
  String(process.env.WHATSAPP_MOCK_MODE ?? '').toLowerCase() === 'true';

/** Resolve the active WhatsApp provider for the current process. */
export const resolveWhatsAppProvider = (): WhatsAppProvider => {
  const explicit = String(process.env.WHATSAPP_PROVIDER ?? '').trim().toLowerCase();
  if (explicit === 'mock' || explicit === 'meta' || explicit === 'twilio' || explicit === 'telegram') {
    return explicit as WhatsAppProvider;
  }
  if (isWhatsAppMockMode()) return 'mock';
  if (isMetaWhatsAppConfigured()) return 'meta';
  return 'twilio';
};

/**
 * Look up user preferences and Telegram chat_id.
 * Callers may pass either a DB user id or a phone number.
 */
interface RecipientLookupResult {
  telegramChatId: string | null;
  preference: MessagingChannelPreference;
}

const lookupRecipient = async (
  opts: { userId?: string | null; phone?: string | null },
): Promise<RecipientLookupResult> => {
  const result: RecipientLookupResult = {
    telegramChatId: null,
    preference: 'default',
  };
  try {
    const q = db('users')
      .select('telegram_chat_id', 'preferred_messaging_channel')
      .first();
    let row: any = null;
    if (opts.userId) {
      row = await q.clone().andWhere('id', opts.userId);
    }
    if (!row && opts.phone) {
      const normalized = opts.phone.replace(/\s|-|\(|\)/g, '');
      row = await q.clone().andWhere('phone', normalized);
    }
    if (row) {
      if (row.telegram_chat_id) result.telegramChatId = String(row.telegram_chat_id);
      const pref = row.preferred_messaging_channel as string | null;
      if (pref && VALID_MESSAGING_CHANNELS.includes(pref as MessagingChannelPreference)) {
        result.preference = pref as MessagingChannelPreference;
      }
    }
    return result;
  } catch (err: any) {
    logger.warn('lookupRecipient failed', { message: err?.message });
    return result;
  }
};

/**
 * Decide which concrete channel(s) to use for a specific recipient, taking
 * into account the user's saved preference and the server-wide WHATSAPP_PROVIDER.
 */
const resolveActiveChannels = (
  preference: MessagingChannelPreference,
): ActiveChannel[] => {
  switch (preference) {
    case 'whatsapp': return ['whatsapp'];
    case 'telegram': return ['telegram'];
    case 'both':     return ['whatsapp', 'telegram'];
    case 'none':     return [];
    case 'default':
    default: {
      const provider = resolveWhatsAppProvider();
      return [provider === 'telegram' ? 'telegram' : 'whatsapp'];
    }
  }
};

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
  /** Optional DB users.id. Required for Telegram dispatch and for honoring the
   *  per-user channel preference. If omitted, legacy behavior applies: the
   *  server-wide WHATSAPP_PROVIDER decides, and Telegram is attempted only
   *  when the recipient has a linked chat_id matching the phone. */
  recipientUserId?: string;
}

/**
 * Low-level: send free-form text via the server-wide WhatsApp provider.
 * Does not consult any per-user preference.
 */
const sendViaWhatsAppProvider = async (
  to: string,
  message: string,
  mediaUrl?: string,
): Promise<boolean> => {
  const provider = resolveWhatsAppProvider();

  if (provider === 'mock') {
    logger.info('[WhatsApp MOCK] message not sent to provider', {
      to,
      bodyPreview: message.length > 800 ? `${message.slice(0, 800)}…` : message,
    });
    return true;
  }

  if (provider === 'meta') {
    if (mediaUrl) logger.warn('Meta WhatsApp provider does not forward mediaUrl; sending text only');
    return sendMetaWhatsAppText(to, message);
  }

  if (provider === 'telegram') {
    // Global provider says telegram but caller didn't provide a user id.
    // Try phone-based lookup only.
    const chatId = await lookupRecipient({ phone: to }).then(r => r.telegramChatId);
    if (!chatId) {
      logger.warn('Telegram send skipped: recipient not linked and no user id provided', { to });
      return false;
    }
    return sendTelegramMessage(chatId, message);
  }

  // Twilio (legacy default)
  return sendTwilioWhatsApp(to, message, mediaUrl);
};

/**
 * Low-level: attempt Telegram delivery using the (pre-looked-up) chat id.
 * Returns false if the recipient has not linked Telegram.
 */
const sendViaTelegramForChatId = async (
  chatId: string | null,
  message: string,
): Promise<boolean> => {
  if (!chatId) {
    logger.warn('Telegram send skipped: recipient has not linked Telegram');
    return false;
  }
  return sendTelegramMessage(chatId, message);
};

/**
 * Public: send a free-form WhatsApp/Telegram message, honoring the recipient's
 * channel preference (if a user id is provided).
 *
 * Returns true if at least one of the resolved channels succeeded.
 */
export const sendWhatsApp = async (options: WhatsAppOptions): Promise<boolean> => {
  try {
    const recipient = await lookupRecipient({
      userId: options.recipientUserId,
      phone: options.to,
    });
    const channels = resolveActiveChannels(recipient.preference);
    if (channels.length === 0) {
      logger.debug('Messaging skipped per recipient preference', {
        to: options.to,
        userId: options.recipientUserId,
        preference: recipient.preference,
      });
      return false;
    }

    const results = await Promise.all(
      channels.map(async (channel) => {
        if (channel === 'telegram') {
          return sendViaTelegramForChatId(recipient.telegramChatId, options.message);
        }
        return sendViaWhatsAppProvider(options.to, options.message, options.mediaUrl);
      }),
    );
    return results.some(Boolean);
  } catch (error: any) {
    logger.error(`Failed to send message to ${options.to}:`, error.message);
    return false;
  }
};

/**
 * Low-level: send a WhatsApp message via Twilio WhatsApp Business API.
 */
const sendTwilioWhatsApp = async (
  to: string,
  message: string,
  mediaUrl?: string,
): Promise<boolean> => {
  const client = initializeTwilioClient();
  if (!client) {
    logger.warn(`Twilio WhatsApp sending skipped (not configured): ${to}`);
    return false;
  }
  const fromNumber = process.env.TWILIO_WHATSAPP_NUMBER;
  if (!fromNumber) {
    logger.error('Twilio WhatsApp number not configured');
    return false;
  }

  let toNumber = to.trim();
  if (!toNumber.startsWith('whatsapp:')) {
    if (!toNumber.startsWith('+')) {
      toNumber = `+972${toNumber.replace(/^0/, '')}`;
    }
    toNumber = `whatsapp:${toNumber}`;
  }

  const messageOptions: any = { body: message, from: fromNumber, to: toNumber };
  if (mediaUrl) messageOptions.mediaUrl = [mediaUrl];

  try {
    const sent = await client.messages.create(messageOptions);
    logger.info(`Twilio WhatsApp sent to ${toNumber}: ${sent.sid}`);
    return true;
  } catch (error: any) {
    logger.error(`Twilio WhatsApp failed to ${toNumber}: ${error.message}`);
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

/* ---------------------------------------------------------------------------
 * Approved-template senders for Meta WhatsApp Cloud API.
 * Templates live in WhatsApp Manager and must be approved before use.
 * Variable order is positional ({{1}}..{{6}}) and MUST match the approved body.
 * ------------------------------------------------------------------------- */

export interface AppointmentTemplateData {
  /** {{1}} שם המטופל */
  patientName: string;
  /** {{2}} שם הרופא */
  doctorName: string;
  /** {{3}} שם המרפאה */
  clinicName: string;
  /** {{4}} כתובת המרפאה */
  clinicAddress: string;
  /** {{5}} תאריך התור */
  date: string;
  /** {{6}} שעת התור */
  time: string;
}

const DEFAULT_CONFIRM_TEMPLATE =
  process.env.META_WA_TEMPLATE_APPOINTMENT_CONFIRMATION || 'appointment_confirmation';
const DEFAULT_REMINDER_TEMPLATE =
  process.env.META_WA_TEMPLATE_APPOINTMENT_REMINDER || 'appointment_reminder';
const DEFAULT_TEMPLATE_LANGUAGE = process.env.META_WA_TEMPLATE_LANGUAGE || 'he';

const buildAppointmentParams = (data: AppointmentTemplateData): string[] => [
  data.patientName,
  data.doctorName,
  data.clinicName,
  data.clinicAddress,
  data.date,
  data.time,
];

/** Render the approved Hebrew confirmation body as plain text (for non-Meta providers). */
const renderConfirmationBody = (data: AppointmentTemplateData): string => [
  `שלום ${data.patientName},`,
  'התור שלך נקבע בהצלחה.',
  '',
  `רופא/ה: ${data.doctorName}`,
  `מרפאה: ${data.clinicName}`,
  `כתובת: ${data.clinicAddress}`,
  `תאריך: ${data.date}`,
  `שעה: ${data.time}`,
  '',
  'נשמח לראותך.',
].join('\n');

/** Render the approved Hebrew reminder body as plain text (for non-Meta providers). */
const renderReminderBody = (data: AppointmentTemplateData): string => [
  `שלום ${data.patientName},`,
  'זוהי תזכורת לתור הקרוב שלך.',
  '',
  `רופא/ה: ${data.doctorName}`,
  `מרפאה: ${data.clinicName}`,
  `כתובת: ${data.clinicAddress}`,
  `תאריך: ${data.date}`,
  `שעה: ${data.time}`,
  '',
  'אנא ודא/י הגעה בזמן.',
].join('\n');

/**
 * When Telegram is preferred but the user has not linked, send SMS or WhatsApp
 * with the same deep-link used in-app so the patient can connect without opening settings.
 */
const sendTelegramInviteFallback = async (
  phoneNumber: string,
  userId: string,
  opts: { whatsappAlreadySent: boolean; appointmentBody: string },
): Promise<boolean> => {
  const link = await createTelegramLinkUrlForUser(userId);
  if (!link) {
    logger.warn('Telegram invite fallback skipped: could not create link', { userId });
    return false;
  }
  const linkLine = `לחיבור לטלגרם לקבלת עדכונים: ${link.url}`;
  const body = opts.whatsappAlreadySent
    ? linkLine
    : `${opts.appointmentBody}\n\n${linkLine}`;

  let sent = false;
  if (process.env.TWILIO_WHATSAPP_NUMBER) {
    sent = await sendTwilioWhatsApp(phoneNumber, body);
  }
  if (!sent && resolveWhatsAppProvider() === 'meta') {
    sent = await sendMetaWhatsAppText(phoneNumber, body);
  }
  if (!sent) {
    sent = await sendSMS({ to: phoneNumber, message: body, smsType: 'general' });
  }
  if (sent) {
    logger.info('Telegram connect invite sent (SMS/WhatsApp)', { userId });
  }
  return sent;
};

/**
 * Dispatch an appointment-type message, honoring the per-user channel
 * preference. WhatsApp channel uses the Meta approved template when the
 * server-wide provider is 'meta'; otherwise it sends the rendered text body.
 */
const dispatchAppointmentMessage = async (
  phoneNumber: string,
  data: AppointmentTemplateData,
  recipientUserId: string | undefined,
  metaTemplateName: string,
  textBody: string,
): Promise<boolean> => {
  const recipient = await lookupRecipient({ userId: recipientUserId, phone: phoneNumber });
  const channels = resolveActiveChannels(recipient.preference);
  if (channels.length === 0) {
    logger.debug('Appointment message skipped per recipient preference', {
      to: phoneNumber, userId: recipientUserId, preference: recipient.preference,
    });
    return false;
  }

  const globalProvider = resolveWhatsAppProvider();
  let telegramOk = false;
  let whatsappOk = false;

  for (const channel of channels) {
    if (channel === 'telegram') {
      telegramOk = await sendViaTelegramForChatId(recipient.telegramChatId, textBody);
    } else if (globalProvider === 'meta') {
      whatsappOk =
        (await sendMetaWhatsAppTemplate(
          phoneNumber,
          metaTemplateName,
          DEFAULT_TEMPLATE_LANGUAGE,
          [buildBodyTextComponent(buildAppointmentParams(data))],
        )) || whatsappOk;
    } else {
      whatsappOk = (await sendViaWhatsAppProvider(phoneNumber, textBody)) || whatsappOk;
    }
  }

  const inviteFallbackEnabled =
    String(process.env.TELEGRAM_INVITE_FALLBACK_ENABLED ?? 'true').toLowerCase() !== 'false';
  let inviteSent = false;
  if (
    inviteFallbackEnabled &&
    channels.includes('telegram') &&
    !telegramOk &&
    recipientUserId &&
    phoneNumber.trim()
  ) {
    inviteSent = await sendTelegramInviteFallback(phoneNumber, recipientUserId, {
      whatsappAlreadySent: whatsappOk,
      appointmentBody: textBody,
    });
  }

  return telegramOk || whatsappOk || inviteSent;
};

/**
 * Send appointment confirmation honoring per-user channel preference.
 */
export const sendAppointmentConfirmationTemplate = async (
  phoneNumber: string,
  data: AppointmentTemplateData,
  recipientUserId?: string,
): Promise<boolean> =>
  dispatchAppointmentMessage(
    phoneNumber,
    data,
    recipientUserId,
    DEFAULT_CONFIRM_TEMPLATE,
    renderConfirmationBody(data),
  );

/**
 * Send appointment reminder honoring per-user channel preference.
 */
export const sendAppointmentReminderTemplate = async (
  phoneNumber: string,
  data: AppointmentTemplateData,
  recipientUserId?: string,
): Promise<boolean> =>
  dispatchAppointmentMessage(
    phoneNumber,
    data,
    recipientUserId,
    DEFAULT_REMINDER_TEMPLATE,
    renderReminderBody(data),
  );

/**
 * Check WhatsApp service status
 */
export const checkWhatsAppServiceStatus = (): {
  configured: boolean;
  provider: WhatsAppProvider;
  accountSid?: string;
  phoneNumber?: string;
} => {
  const provider = resolveWhatsAppProvider();

  if (provider === 'mock') {
    return { configured: true, provider, accountSid: 'MOCK', phoneNumber: 'MOCK' };
  }

  if (provider === 'meta') {
    const phoneNumberId = process.env.META_WA_PHONE_NUMBER_ID;
    return {
      configured: isMetaWhatsAppConfigured(),
      provider,
      accountSid: process.env.META_WA_BUSINESS_ID,
      phoneNumber: phoneNumberId,
    };
  }

  if (provider === 'telegram') {
    return {
      configured: isTelegramConfigured(),
      provider,
      accountSid: process.env.TELEGRAM_BOT_USERNAME,
      phoneNumber: process.env.TELEGRAM_BOT_USERNAME,
    };
  }

  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const phoneNumber = process.env.TWILIO_WHATSAPP_NUMBER;

  return {
    configured: !!(accountSid && process.env.TWILIO_AUTH_TOKEN && phoneNumber),
    provider,
    accountSid: accountSid ? `${accountSid.substring(0, 10)}...` : undefined,
    phoneNumber,
  };
};














