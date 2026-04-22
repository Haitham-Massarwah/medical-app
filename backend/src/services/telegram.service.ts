import { logger } from '../config/logger';

/**
 * Telegram Bot API client.
 *
 * Reference:
 *   https://core.telegram.org/bots/api
 *
 * Required environment variables:
 *   TELEGRAM_BOT_TOKEN      Token from @BotFather (looks like "12345:ABC...").
 *   TELEGRAM_BOT_USERNAME   Bot username without '@' (e.g. "medical_appts_bot").
 *
 * Optional:
 *   TELEGRAM_WEBHOOK_SECRET One-shot secret required by Telegram webhook
 *                           calls via the header
 *                           X-Telegram-Bot-Api-Secret-Token.
 *   TELEGRAM_WEBHOOK_URL    Absolute public URL of the webhook. When present,
 *                           the service can register it at startup.
 */

const API_BASE = 'https://api.telegram.org';

interface TelegramConfig {
  token: string;
  botUsername: string;
  webhookSecret: string | null;
  webhookUrl: string | null;
}

const getConfig = (): TelegramConfig | null => {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  const botUsername = process.env.TELEGRAM_BOT_USERNAME;
  if (!token || !botUsername) return null;
  return {
    token,
    botUsername,
    webhookSecret: process.env.TELEGRAM_WEBHOOK_SECRET ?? null,
    webhookUrl: process.env.TELEGRAM_WEBHOOK_URL ?? null,
  };
};

export const isTelegramConfigured = (): boolean => getConfig() !== null;

export const getTelegramBotUsername = (): string | null =>
  getConfig()?.botUsername ?? null;

export const getTelegramWebhookSecret = (): string | null =>
  getConfig()?.webhookSecret ?? null;

/** Send a message as plain text to a chat ID. */
export const sendTelegramMessage = async (
  chatId: string,
  text: string,
): Promise<boolean> => {
  const cfg = getConfig();
  if (!cfg) {
    logger.warn('Telegram not configured; skipping send');
    return false;
  }
  if (!chatId) {
    logger.warn('Telegram chat_id missing; skipping send');
    return false;
  }

  const url = `${API_BASE}/bot${cfg.token}/sendMessage`;
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text,
        disable_web_page_preview: true,
      }),
    });
    const data: any = await response.json().catch(() => ({}));
    if (!response.ok || data?.ok === false) {
      logger.error('Telegram sendMessage failed', {
        status: response.status,
        description: data?.description,
        error_code: data?.error_code,
      });
      return false;
    }
    logger.info('Telegram message accepted', {
      messageId: data?.result?.message_id,
      chatId,
    });
    return true;
  } catch (err: any) {
    logger.error('Telegram network error', { message: err?.message });
    return false;
  }
};

/** Register the bot webhook URL with Telegram. Idempotent. */
export const setTelegramWebhook = async (): Promise<boolean> => {
  const cfg = getConfig();
  if (!cfg || !cfg.webhookUrl) {
    logger.info('Telegram webhook URL not configured; not registering');
    return false;
  }
  const url = `${API_BASE}/bot${cfg.token}/setWebhook`;
  const body: Record<string, unknown> = {
    url: cfg.webhookUrl,
    allowed_updates: ['message'],
  };
  if (cfg.webhookSecret) body.secret_token = cfg.webhookSecret;

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    const data: any = await response.json().catch(() => ({}));
    if (!response.ok || data?.ok === false) {
      logger.error('Telegram setWebhook failed', {
        status: response.status,
        description: data?.description,
      });
      return false;
    }
    logger.info('Telegram webhook registered', { url: cfg.webhookUrl });
    return true;
  } catch (err: any) {
    logger.error('Telegram setWebhook error', { message: err?.message });
    return false;
  }
};
