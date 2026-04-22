import crypto from 'crypto';
import db from '../config/database';
import { getTelegramBotUsername, isTelegramConfigured } from './telegram.service';

/** Default for outbound SMS/WhatsApp invites (longer than in-app link from settings). */
const DEFAULT_INVITE_TTL_MS = 7 * 24 * 60 * 60 * 1000;

export function getTelegramInviteTtlMs(): number {
  const raw = process.env.TELEGRAM_LINK_INVITE_TTL_MS;
  if (raw && !Number.isNaN(Number(raw))) return Number(raw);
  return DEFAULT_INVITE_TTL_MS;
}

/**
 * Create a one-time deep link for linking Telegram to a user row.
 * Used by POST /telegram/link-url (short TTL) and by SMS/WhatsApp invite fallback.
 */
export async function createTelegramLinkUrlForUser(
  userId: string,
  ttlMs?: number,
): Promise<{ url: string; token: string; expires_at: Date } | null> {
  if (!isTelegramConfigured()) return null;
  const bot = getTelegramBotUsername();
  if (!bot) return null;

  const ttl = ttlMs ?? getTelegramInviteTtlMs();
  const token = crypto.randomBytes(24).toString('base64url');
  const expiresAt = new Date(Date.now() + ttl);

  await db('telegram_link_tokens').insert({
    user_id: userId,
    token,
    expires_at: expiresAt,
  });

  const url = `https://t.me/${bot}?start=${token}`;
  return { url, token, expires_at: expiresAt };
}
