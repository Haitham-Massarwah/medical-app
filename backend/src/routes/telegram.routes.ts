import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import {
  createTelegramLinkUrl,
  getTelegramStatus,
  telegramTestSend,
  telegramWebhook,
  unlinkTelegram,
} from '../controllers/telegram.controller';

const router = Router();

/**
 * PUBLIC webhook — called by Telegram. Verified by the
 * X-Telegram-Bot-Api-Secret-Token header when TELEGRAM_WEBHOOK_SECRET is set.
 * MUST be declared BEFORE `router.use(authenticate)`.
 */
router.post('/webhook', telegramWebhook);

// Everything below requires an authenticated application user.
router.use(authenticate);

router.get('/status', getTelegramStatus);
router.post('/link-url', createTelegramLinkUrl);
router.delete('/link', unlinkTelegram);
router.post('/test-send', telegramTestSend);

export default router;
