import { Request, Response } from 'express';
import db from '../config/database';
import { logger } from '../config/logger';
import { createTelegramLinkUrlForUser } from '../services/telegramLink.service';
import { appointmentSmsAutomationService } from '../services/appointmentSmsAutomation.service';
import {
  getTelegramBotUsername,
  getTelegramWebhookSecret,
  isTelegramConfigured,
  sendTelegramMessage,
} from '../services/telegram.service';

/**
 * Telegram bot linking controller.
 *
 * Flow:
 *   1. Authenticated user calls POST /telegram/link-url → server issues a
 *      one-time token + deep-link `https://t.me/<bot>?start=<token>`.
 *   2. User opens the deep-link on their phone and presses Start.
 *   3. Telegram posts an update to POST /telegram/webhook containing
 *      `/start <token>`; the controller validates the token and saves
 *      chat_id + username against users.telegram_chat_id.
 *   4. GET /telegram/status returns whether the authenticated user has linked.
 */

/** In-app link from settings: short TTL. */
const APP_LINK_TOKEN_TTL_MS = 30 * 60 * 1000; // 30 minutes

/** GET /telegram/status */
export const getTelegramStatus = async (req: Request, res: Response): Promise<void> => {
  try {
    if (!req.user?.id) {
      res.status(401).json({ success: false, message: 'Unauthenticated' });
      return;
    }
    const row = await db('users')
      .select('telegram_chat_id', 'telegram_username', 'telegram_linked_at')
      .where('id', req.user.id)
      .first();
    const linked = !!row?.telegram_chat_id;
    res.json({
      success: true,
      data: {
        configured: isTelegramConfigured(),
        bot: getTelegramBotUsername(),
        linked,
        username: row?.telegram_username ?? null,
        linked_at: row?.telegram_linked_at ?? null,
      },
    });
  } catch (err: any) {
    logger.error('getTelegramStatus failed', { message: err?.message });
    res.status(500).json({ success: false, message: 'Internal error' });
  }
};

/** POST /telegram/link-url → returns { url, token } */
export const createTelegramLinkUrl = async (req: Request, res: Response): Promise<void> => {
  try {
    if (!req.user?.id) {
      res.status(401).json({ success: false, message: 'Unauthenticated' });
      return;
    }
    if (!isTelegramConfigured()) {
      res.status(503).json({ success: false, message: 'Telegram bot not configured' });
      return;
    }
    const bot = getTelegramBotUsername();
    if (!bot) {
      res.status(503).json({ success: false, message: 'Telegram bot username missing' });
      return;
    }

    const link = await createTelegramLinkUrlForUser(req.user.id, APP_LINK_TOKEN_TTL_MS);
    if (!link) {
      res.status(500).json({ success: false, message: 'Failed to create link token' });
      return;
    }

    res.json({
      success: true,
      data: {
        url: link.url,
        token: link.token,
        expires_at: link.expires_at.toISOString(),
        bot,
      },
    });
  } catch (err: any) {
    logger.error('createTelegramLinkUrl failed', { message: err?.message });
    res.status(500).json({ success: false, message: 'Internal error' });
  }
};

/** DELETE /telegram/link → clear the link for the current user */
export const unlinkTelegram = async (req: Request, res: Response): Promise<void> => {
  try {
    if (!req.user?.id) {
      res.status(401).json({ success: false, message: 'Unauthenticated' });
      return;
    }
    await db('users')
      .where('id', req.user.id)
      .update({
        telegram_chat_id: null,
        telegram_username: null,
        telegram_linked_at: null,
      });
    res.json({ success: true, data: { linked: false } });
  } catch (err: any) {
    logger.error('unlinkTelegram failed', { message: err?.message });
    res.status(500).json({ success: false, message: 'Internal error' });
  }
};

/**
 * POST /telegram/webhook
 *
 * Public endpoint called by Telegram. Validates the secret header when
 * TELEGRAM_WEBHOOK_SECRET is configured. Handles only `/start <token>`.
 */
export const telegramWebhook = async (req: Request, res: Response): Promise<void> => {
  const expectedSecret = getTelegramWebhookSecret();
  if (expectedSecret) {
    const provided = req.header('x-telegram-bot-api-secret-token');
    if (provided !== expectedSecret) {
      res.status(401).end();
      return;
    }
  }

  // Always acknowledge Telegram quickly; process best-effort.
  try {
    const update = req.body as any;
    const msg = update?.message;
    const text: string | undefined = msg?.text;
    const chat = msg?.chat;
    const chatId: string | undefined = chat?.id ? String(chat.id) : undefined;
    const username: string | undefined = chat?.username;

    if (!text || !chatId) {
      res.status(200).end();
      return;
    }

    const startMatch = /^\/start(?:\s+(\S+))?/.exec(text.trim());
    if (!startMatch) {
      res.status(200).end();
      return;
    }
    const token = startMatch[1];

    if (!token) {
      await sendTelegramMessage(
        chatId,
        'שלום! כדי לקשר את החשבון שלך עם המערכת, יש לפתוח את הקישור מתוך הגדרות האפליקציה.',
      );
      res.status(200).end();
      return;
    }

    const tokenRow = await db('telegram_link_tokens')
      .where({ token })
      .first();

    if (!tokenRow) {
      await sendTelegramMessage(chatId, 'קישור לא תקין. יש לפתוח מחדש את הגדרות האפליקציה.');
      res.status(200).end();
      return;
    }
    if (tokenRow.consumed_at) {
      await sendTelegramMessage(chatId, 'הקישור כבר שומש. יש להפיק קישור חדש מהאפליקציה.');
      res.status(200).end();
      return;
    }
    if (new Date(tokenRow.expires_at).getTime() < Date.now()) {
      await sendTelegramMessage(chatId, 'הקישור פג תוקף. יש להפיק קישור חדש מהאפליקציה.');
      res.status(200).end();
      return;
    }

    await db.transaction(async (trx) => {
      await trx('users')
        .where('id', tokenRow.user_id)
        .update({
          telegram_chat_id: chatId,
          telegram_username: username ?? null,
          telegram_linked_at: new Date(),
        });
      await trx('telegram_link_tokens')
        .where('id', tokenRow.id)
        .update({ consumed_at: new Date() });
    });

    await sendTelegramMessage(
      chatId,
      'הקישור בוצע בהצלחה. מעכשיו תקבלו כאן הודעות על תורים ותזכורות.',
    );

    try {
      await appointmentSmsAutomationService.resendLastBookingConfirmationToTelegramAfterLink(
        String(tokenRow.user_id),
        chatId,
      );
    } catch (resendErr: unknown) {
      const message = resendErr instanceof Error ? resendErr.message : String(resendErr);
      logger.warn('Telegram resend last booking after link failed', { message });
    }

    logger.info('Telegram user linked', { userId: tokenRow.user_id, chatId });

    res.status(200).end();
  } catch (err: any) {
    logger.error('telegramWebhook failed', { message: err?.message });
    // Still return 200 so Telegram does not retry-storm.
    res.status(200).end();
  }
};

/** POST /telegram/test-send   body: { message } — sends to the caller's own chat */
export const telegramTestSend = async (req: Request, res: Response): Promise<void> => {
  try {
    if (!req.user?.id) {
      res.status(401).json({ success: false, message: 'Unauthenticated' });
      return;
    }
    const message = String(req.body?.message ?? '').trim();
    if (!message) {
      res.status(400).json({ success: false, message: 'message required' });
      return;
    }
    const row = await db('users')
      .select('telegram_chat_id')
      .where('id', req.user.id)
      .first();
    if (!row?.telegram_chat_id) {
      res.status(409).json({ success: false, message: 'Telegram not linked for this user' });
      return;
    }
    const ok = await sendTelegramMessage(String(row.telegram_chat_id), message);
    res.json({ success: ok });
  } catch (err: any) {
    logger.error('telegramTestSend failed', { message: err?.message });
    res.status(500).json({ success: false, message: 'Internal error' });
  }
};
