import rateLimit from 'express-rate-limit';

const WINDOW_MS = Math.max(
  60_000,
  parseInt(process.env.RATE_LIMIT_WINDOW_MS || `${15 * 60 * 1000}`, 10) || 15 * 60 * 1000
);

/** All /api traffic (per IP). Default 400 — 100 was easy to hit during admin UI + create-user flows. */
const GENERAL_MAX = Math.max(
  50,
  parseInt(process.env.RATE_LIMIT_MAX || '400', 10) || 400
);

/**
 * Login / register / check-email / forgot-password (per IP).
 * Default 50 — 5 blocked legitimate admin-driven doctor/patient creation quickly.
 */
const STRICT_MAX = Math.max(
  5,
  parseInt(process.env.RATE_LIMIT_STRICT_MAX || '50', 10) || 50
);

/**
 * General rate limiter for all API endpoints (applied under /api in server.ts).
 */
export const rateLimiter = rateLimit({
  windowMs: WINDOW_MS,
  max: GENERAL_MAX,
  message: {
    error: 'Too many requests',
    message: 'Too many requests from this IP, please try again later.',
    retryAfter: `${Math.round(WINDOW_MS / 60000)} minutes`,
  },
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: false,
  skipFailedRequests: false,
});

/**
 * Strict rate limiter for sensitive unauthenticated endpoints.
 */
export const strictRateLimiter = rateLimit({
  windowMs: WINDOW_MS,
  max: STRICT_MAX,
  message: {
    error: 'Too many attempts',
    message: 'Too many attempts from this IP, please try again later.',
    retryAfter: `${Math.round(WINDOW_MS / 60000)} minutes`,
  },
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: false,
  skipFailedRequests: true, // failed logins/registers do not consume quota
});

/**
 * Moderate rate limiter for data modification endpoints (when used).
 */
export const moderateRateLimiter = rateLimit({
  windowMs: WINDOW_MS,
  max: Math.max(10, parseInt(process.env.RATE_LIMIT_MODERATE_MAX || '60', 10) || 60),
  message: {
    error: 'Too many requests',
    message: 'Too many modification requests, please slow down.',
    retryAfter: `${Math.round(WINDOW_MS / 60000)} minutes`,
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Payment rate limiter - very strict for payment endpoints
 */
export const paymentRateLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: Math.max(5, parseInt(process.env.RATE_LIMIT_PAYMENT_MAX || '10', 10) || 10),
  message: {
    error: 'Too many payment attempts',
    message: 'Too many payment attempts, please contact support.',
    retryAfter: '1 hour',
  },
  standardHeaders: true,
  legacyHeaders: false,
});
