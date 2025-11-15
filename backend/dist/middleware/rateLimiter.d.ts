/**
 * General rate limiter for all API endpoints
 * Limits: 100 requests per 15 minutes per IP
 */
export declare const rateLimiter: import("express-rate-limit").RateLimitRequestHandler;
/**
 * Strict rate limiter for sensitive endpoints (login, register, password reset)
 * Limits: 5 requests per 15 minutes per IP
 */
export declare const strictRateLimiter: import("express-rate-limit").RateLimitRequestHandler;
/**
 * Moderate rate limiter for data modification endpoints
 * Limits: 30 requests per 15 minutes per IP
 */
export declare const moderateRateLimiter: import("express-rate-limit").RateLimitRequestHandler;
/**
 * Payment rate limiter - very strict for payment endpoints
 * Limits: 10 requests per hour per IP
 */
export declare const paymentRateLimiter: import("express-rate-limit").RateLimitRequestHandler;
//# sourceMappingURL=rateLimiter.d.ts.map