import { Request, Response } from 'express';
import db from '../config/database';
import { logger } from '../config/logger';
import {
  VALID_MESSAGING_CHANNELS,
  MessagingChannelPreference,
  resolveWhatsAppProvider,
} from '../services/whatsapp.service';
import { isTelegramConfigured, getTelegramBotUsername } from '../services/telegram.service';
import { isMetaWhatsAppConfigured } from '../services/metaWhatsapp.service';

/**
 * GET /users/me/messaging-preference
 *
 * Returns the authenticated user's current preference plus a summary of
 * which channels are configured on the server, so the UI can show only
 * the options that can actually deliver.
 */
export const getMessagingPreference = async (req: Request, res: Response): Promise<void> => {
  try {
    if (!req.user?.id) {
      res.status(401).json({ success: false, message: 'Unauthenticated' });
      return;
    }

    const row = await db('users')
      .select('preferred_messaging_channel', 'telegram_chat_id')
      .where('id', req.user.id)
      .first();

    const preference = (row?.preferred_messaging_channel as MessagingChannelPreference | null) ?? 'default';
    const telegramLinked = !!row?.telegram_chat_id;

    const provider = resolveWhatsAppProvider();
    const whatsappConfigured = isMetaWhatsAppConfigured()
      || !!(process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN && process.env.TWILIO_WHATSAPP_NUMBER)
      || provider === 'mock';

    res.json({
      success: true,
      data: {
        preference,
        whatsapp: {
          configured: whatsappConfigured,
          provider,
        },
        telegram: {
          configured: isTelegramConfigured(),
          bot: getTelegramBotUsername(),
          linked: telegramLinked,
        },
        validChannels: VALID_MESSAGING_CHANNELS,
      },
    });
  } catch (err: any) {
    logger.error('getMessagingPreference failed', { message: err?.message });
    res.status(500).json({ success: false, message: 'Internal error' });
  }
};

/**
 * PUT /users/me/messaging-preference
 * Body: { preference: 'default' | 'whatsapp' | 'telegram' | 'both' | 'none' }
 */
export const setMessagingPreference = async (req: Request, res: Response): Promise<void> => {
  try {
    if (!req.user?.id) {
      res.status(401).json({ success: false, message: 'Unauthenticated' });
      return;
    }
    const raw = String(req.body?.preference ?? '').trim().toLowerCase();
    if (!VALID_MESSAGING_CHANNELS.includes(raw as MessagingChannelPreference)) {
      res.status(400).json({
        success: false,
        message: `preference must be one of: ${VALID_MESSAGING_CHANNELS.join(', ')}`,
      });
      return;
    }

    await db('users')
      .where('id', req.user.id)
      .update({ preferred_messaging_channel: raw });

    res.json({ success: true, data: { preference: raw } });
  } catch (err: any) {
    logger.error('setMessagingPreference failed', { message: err?.message });
    res.status(500).json({ success: false, message: 'Internal error' });
  }
};
