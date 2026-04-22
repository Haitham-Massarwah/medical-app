import bcrypt from 'bcryptjs';
import db from '../config/database';
import { logger } from '../config/logger';
import { DatabaseError, ValidationError } from '../middleware/errorHandler';

/**
 * Normalize token from URL path, JSON, or email clients (line breaks, encoding).
 */
export function normalizeResetToken(raw: string | undefined): string {
  let s = String(raw ?? '').trim();
  try {
    s = decodeURIComponent(s);
  } catch {
    /* invalid % sequences — use raw after trim */
  }
  s = s.replace(/\s+/g, '');
  return s;
}

function assertValidResetTokenFormat(cleaned: string): void {
  /** Expected: crypto.randomBytes(32).toString('hex') → 64 hex chars; allow 32–128 hex for forward compatibility */
  if (!cleaned || cleaned.length < 32 || cleaned.length > 128 || !/^[a-fA-F0-9]+$/i.test(cleaned)) {
    throw new ValidationError('Invalid or expired reset token');
  }
}

function pgErr(e: unknown): { code?: string; detail?: string; message: string } {
  const err = e as { code?: string; detail?: string; message?: string };
  return {
    code: err.code,
    detail: err.detail,
    message: err.message || String(e),
  };
}

/**
 * Apply a new password for a user holding a valid, non-expired password_reset token.
 * Used by the public API and by the HTML reset page (no HTTP self-fetch).
 */
export async function resetPasswordByToken(rawToken: string, plainPassword: string): Promise<void> {
  const password = String(plainPassword ?? '').trim();
  if (password.length < 8) {
    throw new ValidationError('Password must be at least 8 characters');
  }

  const cleaned = normalizeResetToken(rawToken).toLowerCase();
  assertValidResetTokenFormat(cleaned);

  let user: { id: string } | undefined;
  try {
    user = await db('users')
      .whereRaw('LOWER(TRIM(password_reset_token)) = ?', [cleaned])
      .andWhere('password_reset_expiry', '>', new Date())
      .first();
  } catch (e) {
    const p = pgErr(e);
    logger.error('resetPasswordByToken: lookup failed', { code: p.code, message: p.message });
    if (p.code === '42703') {
      throw new DatabaseError('Password reset is not available on this server. Contact support.');
    }
    throw new DatabaseError('Unable to verify reset token. Please try again.');
  }

  if (!user) {
    throw new ValidationError('Invalid or expired reset token');
  }

  let hashedPassword: string;
  try {
    hashedPassword = await bcrypt.hash(password, 12);
  } catch (e) {
    logger.error('resetPasswordByToken: bcrypt failed', e);
    throw new DatabaseError('Unable to hash password. Please try a different password.');
  }

  try {
    // Email-based reset proves access to the mailbox; allow login without a separate verification step.
    const updated = await db('users').where({ id: user.id }).update({
      password_hash: hashedPassword,
      password_reset_token: null,
      password_reset_expiry: null,
      is_email_verified: true,
      updated_at: new Date(),
    });

    if (!updated || updated < 1) {
      logger.warn('resetPasswordByToken: update touched 0 rows', { userId: user.id });
      throw new ValidationError('Could not update password. Please request a new reset link.');
    }
  } catch (e) {
    if (e instanceof ValidationError) {
      throw e;
    }
    const p = pgErr(e);
    logger.error('resetPasswordByToken: update failed', { code: p.code, message: p.message, userId: user.id });
    if (p.code === '23514' || p.code === '23505') {
      throw new ValidationError('Could not save password. Please try a different password.');
    }
    if (p.code === '42703') {
      throw new DatabaseError('Password reset storage error. Contact support.');
    }
    throw new DatabaseError('Unable to save password. Please try again.');
  }

  logger.info(`Password reset successful for user: ${user.id}`);
}
