"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.corsOptions = void 0;
// Default allowed origins
const defaultOrigins = [
    'http://localhost:3000',
    'http://localhost:8080',
    'http://localhost:5000',
    'http://localhost:3001',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:8080',
];
// Parse allowed origins from environment
const envOrigins = process.env.CORS_ORIGIN?.split(',').map(o => o.trim()).filter(Boolean) || [];
const allowedOrigins = [...defaultOrigins, ...envOrigins];
// Add common production variants
const productionOrigins = [
    'https://medical-appointments.com',
    'https://www.medical-appointments.com',
    'http://medical-appointments.com', // For development/testing before SSL
    'http://www.medical-appointments.com',
    'https://api.medical-appointments.com',
    'http://api.medical-appointments.com',
];
// In production, add production origins; in development, be more permissive
if (process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'staging') {
    allowedOrigins.push(...productionOrigins);
}
exports.corsOptions = {
    origin: (origin, callback) => {
        // Allow requests with no origin (like mobile apps, Postman, curl, etc.)
        if (!origin) {
            return callback(null, true);
        }
        // In development, be very permissive to avoid CORS issues during development
        if (process.env.NODE_ENV === 'development') {
            // Log for debugging
            if (process.env.LOG_CORS === 'true') {
                console.log(`[CORS] Allowing origin in development: ${origin}`);
            }
            return callback(null, true);
        }
        // Check if origin is in allowed list
        const isAllowed = allowedOrigins.some(allowed => {
            // Exact match
            if (origin === allowed)
                return true;
            // Allow subdomains for medical-appointments.com
            if (allowed.includes('medical-appointments.com')) {
                try {
                    const originUrl = new URL(origin);
                    const allowedUrl = new URL(allowed);
                    if (originUrl.hostname.endsWith(allowedUrl.hostname) ||
                        originUrl.hostname.endsWith('.' + allowedUrl.hostname)) {
                        return true;
                    }
                }
                catch (e) {
                    // If URL parsing fails, just check string match
                    if (origin.includes('medical-appointments.com'))
                        return true;
                }
            }
            return false;
        });
        if (isAllowed) {
            callback(null, true);
        }
        else {
            console.warn(`[CORS] Blocked origin: ${origin}`);
            callback(new Error(`Not allowed by CORS. Origin: ${origin}`));
        }
    },
    credentials: process.env.CORS_CREDENTIALS === 'true' || process.env.NODE_ENV === 'development',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS', 'HEAD'],
    allowedHeaders: [
        'Content-Type',
        'Authorization',
        'X-Tenant-ID',
        'X-Requested-With',
        'Accept',
        'Origin',
        'Access-Control-Request-Method',
        'Access-Control-Request-Headers',
    ],
    exposedHeaders: ['X-Total-Count', 'X-Page-Count', 'X-Request-ID'],
    maxAge: 86400, // 24 hours
    preflightContinue: false,
    optionsSuccessStatus: 204,
};
//# sourceMappingURL=cors.js.map