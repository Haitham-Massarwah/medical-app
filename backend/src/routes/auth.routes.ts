import { Router } from 'express';
import { body } from 'express-validator';
import { AuthController } from '../controllers/auth.controller';
import { resetPasswordByToken } from '../services/passwordReset.service';
import { ValidationError } from '../middleware/errorHandler';
import { logger } from '../config/logger';
import { authenticate } from '../middleware/auth.middleware';
import { validateRequest } from '../middleware/validator';
import { bodyOptionalLoosePhone } from '../middleware/phoneValidation';
import { strictRateLimiter } from '../middleware/rateLimiter';

const router = Router();
const authController = new AuthController();

const escapeHtml = (value: string): string =>
  value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

const renderResetPasswordPage = (
  token: string,
  options?: { message?: string; isError?: boolean; hideForm?: boolean }
): string => {
  const message = options?.message ? escapeHtml(options.message) : '';
  const messageClass = options?.isError ? 'err' : 'ok';
  const hideForm = options?.hideForm === true;
  const safeToken = escapeHtml(token);
  // Absolute action URL so POST hits the same API as the email link (relative "/" can post to wrong host behind some clients/proxies).
  const publicBase = (process.env.BASE_URL || '').replace(/\/$/, '');
  const tokenSeg = encodeURIComponent(token);
  const formAction = publicBase
    ? `${publicBase}/api/v1/auth/reset-password-page/${tokenSeg}`
    : `/api/v1/auth/reset-password-page/${safeToken}`;

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Set Password</title>
  <style>
    body { font-family: Arial, sans-serif; background: #f4f6f8; margin: 0; }
    .card { max-width: 440px; margin: 60px auto; background: #fff; border-radius: 10px; padding: 24px; box-shadow: 0 8px 24px rgba(0,0,0,.08); }
    h1 { margin: 0 0 18px; font-size: 22px; }
    label { display: block; margin: 12px 0 6px; font-weight: 600; }
    .field-wrap { position: relative; margin-bottom: 4px; }
    .field-wrap input { width: 100%; box-sizing: border-box; border: 1px solid #cfd8dc; border-radius: 8px; padding: 10px 88px 10px 10px; font-size: 14px; }
    .toggle-pass { position: absolute; right: 6px; top: 50%; transform: translateY(-50%); border: 0; background: #e3f2fd; color: #1565c0; border-radius: 6px; padding: 6px 10px; font-size: 12px; font-weight: 600; cursor: pointer; }
    .toggle-pass:hover { background: #bbdefb; }
    button[type="submit"] { margin-top: 16px; width: 100%; border: 0; border-radius: 8px; padding: 12px; font-size: 15px; font-weight: 700; color: #fff; background: #1976d2; cursor: pointer; }
    .msg { margin-top: 14px; font-size: 14px; }
    .ok { color: #1b5e20; }
    .err { color: #b71c1c; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Set your password</h1>
    ${
      hideForm
        ? ''
        : `<form method="POST" action="${escapeHtml(formAction)}">
      <label for="password">New password</label>
      <div class="field-wrap">
        <input id="password" name="password" type="password" minlength="8" required autocomplete="new-password" />
        <button type="button" class="toggle-pass" data-for="password" aria-pressed="false" aria-label="Show password">Show</button>
      </div>
      <label for="confirm">Confirm password</label>
      <div class="field-wrap">
        <input id="confirm" name="confirm" type="password" minlength="8" required autocomplete="new-password" />
        <button type="button" class="toggle-pass" data-for="confirm" aria-pressed="false" aria-label="Show password">Show</button>
      </div>
      <button type="submit">Save password</button>
    </form>
    <script>
      (function () {
        document.querySelectorAll('.toggle-pass').forEach(function (btn) {
          btn.addEventListener('click', function () {
            var id = btn.getAttribute('data-for');
            var input = id ? document.getElementById(id) : null;
            if (!input) return;
            var show = input.type === 'password';
            input.type = show ? 'text' : 'password';
            btn.textContent = show ? 'Hide' : 'Show';
            btn.setAttribute('aria-pressed', show ? 'true' : 'false');
            btn.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
          });
        });
      })();
    </script>`
    }
    ${message ? `<div class="msg ${messageClass}">${message}</div>` : ''}
  </div>
</body>
</html>`;
};

/**
 * @route   POST /api/v1/auth/register
 * @desc    Register new user
 * @access  Public
 */
router.post(
  '/register',
  strictRateLimiter,
  validateRequest([
    body('email')
      .isEmail()
      .normalizeEmail({ gmail_remove_dots: false })
      .withMessage('Valid email is required'),
    body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
    body('first_name').trim().notEmpty().withMessage('First name is required'),
    body('last_name').trim().notEmpty().withMessage('Last name is required'),
    body('id_number').trim().notEmpty().withMessage('ID number is required'),
    bodyOptionalLoosePhone(),
    body('role').isIn(['patient', 'doctor']).withMessage('Invalid role'),
    body('id_number').custom((value, { req }) => {
      if (req.body.role !== 'doctor') return true;
      const digits = String(value || '').replace(/[^\d]/g, '');
      if (!/^\d{5,9}$/.test(digits)) {
        throw new Error('Doctor/Therapist business identifier must be 5-9 digits');
      }
      return true;
    }),
    body('medical_license_number')
      .optional()
      .trim()
      .isLength({ min: 3, max: 64 })
      .withMessage('Medical license number format is invalid'),
    body('tenant_id').optional().isUUID().withMessage('Invalid tenant ID'),
  ]),
  authController.register
);

/**
 * @route   POST /api/v1/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post(
  '/login',
  strictRateLimiter,
  validateRequest([
    body('email')
      .isEmail()
      .normalizeEmail({ gmail_remove_dots: false })
      .withMessage('Valid email is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ]),
  authController.login
);

/**
 * @route   GET /api/v1/auth/check-email
 * @desc    Check if email exists
 * @access  Public
 */
router.get(
  '/check-email',
  strictRateLimiter,
  authController.checkEmailExists
);

/**
 * @route   POST /api/v1/auth/forgot-password
 * @desc    Request password reset
 * @access  Public
 */
router.post(
  '/forgot-password',
  strictRateLimiter,
  validateRequest([
    body('email')
      .isEmail()
      .normalizeEmail({ gmail_remove_dots: false })
      .withMessage('Valid email is required'),
  ]),
  authController.forgotPassword
);

/**
 * @route   GET /api/v1/auth/reset-password-page/:token
 * @desc    Render password reset form
 * @access  Public
 */
router.get('/reset-password-page/:token', (req, res) => {
  const { token } = req.params;
  res.status(200).type('html').send(renderResetPasswordPage(token));
});

router.post('/reset-password-page/:token', strictRateLimiter, async (req, res) => {
  const { token } = req.params;
  const password = String(req.body?.password || '');
  const confirm = String(req.body?.confirm || '');

  if (password.length < 8) {
    return res
      .status(400)
      .type('html')
      .send(
        renderResetPasswordPage(token, {
          message: 'Password must be at least 8 characters.',
          isError: true,
        })
      );
  }

  if (password !== confirm) {
    return res
      .status(400)
      .type('html')
      .send(
        renderResetPasswordPage(token, {
          message: 'Passwords do not match.',
          isError: true,
        })
      );
  }

  try {
    await resetPasswordByToken(token, password);
    return res.status(200).type('html').send(
      renderResetPasswordPage(token, {
        message: 'Password updated successfully. You can now sign in.',
        isError: false,
        hideForm: true,
      })
    );
  } catch (e) {
    if (e instanceof ValidationError) {
      return res.status(400).type('html').send(
        renderResetPasswordPage(token, {
          message: e.message,
          isError: true,
        })
      );
    }
    logger.error('reset-password-page: unexpected error', e);
    return res.status(500).type('html').send(
      renderResetPasswordPage(token, {
        message: 'Unexpected error while setting password. Please try again.',
        isError: true,
      })
    );
  }
});

/**
 * @route   POST /api/v1/auth/reset-password
 * @desc    Reset password with token in JSON body (Flutter / Retrofit-style clients)
 * @access  Public
 */
router.post(
  '/reset-password',
  strictRateLimiter,
  validateRequest([
    body('token').notEmpty().withMessage('Reset token is required'),
    body()
      .custom((_, { req }) => {
        const p = req.body?.password ?? req.body?.newPassword;
        if (!p || String(p).length < 8) {
          throw new Error('Password must be at least 8 characters');
        }
        return true;
      })
      .withMessage('Password must be at least 8 characters'),
  ]),
  authController.resetPasswordBody
);

/**
 * @route   POST /api/v1/auth/reset-password/:token
 * @desc    Reset password with token in path
 * @access  Public
 */
router.post(
  '/reset-password/:token',
  strictRateLimiter,
  validateRequest([
    body()
      .custom((_, { req }) => {
        const p = req.body?.password ?? req.body?.newPassword;
        if (!p || String(p).length < 8) {
          throw new Error('Password must be at least 8 characters');
        }
        return true;
      })
      .withMessage('Password must be at least 8 characters'),
  ]),
  authController.resetPassword
);

/**
 * @route   POST /api/v1/auth/verify-email/:token
 * @desc    Verify email address
 * @access  Public
 */
router.post('/verify-email/:token', authController.verifyEmail);

/**
 * @route   GET /api/v1/auth/me
 * @desc    Get current user
 * @access  Private
 */
router.get('/me', authenticate, authController.getCurrentUser);

/**
 * @route   POST /api/v1/auth/logout
 * @desc    Logout user
 * @access  Private
 */
router.post('/logout', authenticate, authController.logout);

/**
 * @route   POST /api/v1/auth/refresh-token
 * @desc    Refresh access token
 * @access  Private
 */
router.post('/refresh-token', authenticate, authController.refreshToken);

/**
 * @route   PUT /api/v1/auth/change-password
 * @desc    Change password (logged in)
 * @access  Private
 */
router.put(
  '/change-password',
  authenticate,
  validateRequest([
    body('current_password').notEmpty().withMessage('Current password is required'),
    body('new_password').isLength({ min: 8 }).withMessage('New password must be at least 8 characters'),
  ]),
  authController.changePassword
);

export default router;



