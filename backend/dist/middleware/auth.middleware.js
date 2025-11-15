"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateRefreshToken = exports.generateToken = exports.checkOwnership = exports.tenantIsolation = exports.optionalAuth = exports.authorize = exports.authenticate = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const errorHandler_1 = require("./errorHandler");
const logger_1 = require("../config/logger");
/**
 * Authentication middleware
 * Verifies JWT token and attaches user to request
 */
exports.authenticate = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
    // Get token from header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        throw new errorHandler_1.AuthenticationError('No token provided. Please include Bearer token in Authorization header.');
    }
    const token = authHeader.split(' ')[1];
    if (!token) {
        throw new errorHandler_1.AuthenticationError('Invalid token format');
    }
    try {
        // Verify token
        const jwtSecret = process.env.JWT_SECRET;
        if (!jwtSecret) {
            logger_1.logger.error('JWT_SECRET not configured in environment variables');
            throw new Error('Server configuration error');
        }
        const decoded = jsonwebtoken_1.default.verify(token, jwtSecret);
        // Attach user to request
        req.user = decoded;
        req.tenantId = decoded.tenantId;
        logger_1.logger.debug(`User authenticated: ${decoded.userId} (${decoded.role})`);
        next();
    }
    catch (error) {
        if (error instanceof jsonwebtoken_1.default.TokenExpiredError) {
            throw new errorHandler_1.AuthenticationError('Token has expired. Please login again.');
        }
        else if (error instanceof jsonwebtoken_1.default.JsonWebTokenError) {
            throw new errorHandler_1.AuthenticationError('Invalid token. Please login again.');
        }
        else {
            throw error;
        }
    }
});
/**
 * Authorization middleware
 * Checks if user has required role(s)
 * Usage: authorize('admin', 'doctor')
 */
const authorize = (...allowedRoles) => {
    return (req, res, next) => {
        if (!req.user) {
            throw new errorHandler_1.AuthenticationError('User not authenticated');
        }
        const userRole = req.user.role;
        if (!allowedRoles.includes(userRole)) {
            logger_1.logger.warn(`Authorization failed: User ${req.user.userId} with role "${userRole}" ` +
                `attempted to access resource requiring roles: ${allowedRoles.join(', ')}`);
            throw new errorHandler_1.AuthorizationError(`Access denied. Required roles: ${allowedRoles.join(' or ')}`);
        }
        logger_1.logger.debug(`User ${req.user.userId} authorized with role: ${userRole}`);
        next();
    };
};
exports.authorize = authorize;
/**
 * Optional authentication middleware
 * Attaches user if token is present, but doesn't require it
 * Useful for endpoints that behave differently for logged-in vs anonymous users
 */
exports.optionalAuth = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        // No token, continue without authentication
        return next();
    }
    const token = authHeader.split(' ')[1];
    try {
        const jwtSecret = process.env.JWT_SECRET;
        if (jwtSecret) {
            const decoded = jsonwebtoken_1.default.verify(token, jwtSecret);
            req.user = decoded;
            req.tenantId = decoded.tenantId;
        }
    }
    catch (error) {
        // Token is invalid, but we don't throw error
        // Just continue without authentication
        logger_1.logger.debug('Optional auth: Invalid token, continuing without authentication');
    }
    next();
});
/**
 * Tenant isolation middleware
 * Ensures user can only access data from their own tenant
 */
const tenantIsolation = (req, res, next) => {
    if (!req.user) {
        throw new errorHandler_1.AuthenticationError('User not authenticated');
    }
    if (!req.tenantId) {
        throw new Error('Tenant ID not found in request');
    }
    // Attach tenant filter to request for use in queries
    req.tenantFilter = { tenant_id: req.tenantId };
    next();
};
exports.tenantIsolation = tenantIsolation;
/**
 * Check if user owns the resource
 * Usage: checkOwnership('userId') - checks if req.params.userId matches req.user.userId
 */
const checkOwnership = (paramName = 'id') => {
    return (req, res, next) => {
        if (!req.user) {
            throw new errorHandler_1.AuthenticationError('User not authenticated');
        }
        const resourceId = req.params[paramName];
        const userId = req.user.userId;
        if (resourceId !== userId) {
            // Allow admins and developers to access any resource
            if (!['admin', 'developer'].includes(req.user.role)) {
                throw new errorHandler_1.AuthorizationError('You can only access your own resources');
            }
        }
        next();
    };
};
exports.checkOwnership = checkOwnership;
/**
 * Generate JWT token
 * Utility function to create tokens
 */
const generateToken = (payload) => {
    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
        throw new Error('JWT_SECRET not configured');
    }
    return jsonwebtoken_1.default.sign(payload, jwtSecret, {
        expiresIn: '7d',
    });
};
exports.generateToken = generateToken;
/**
 * Generate refresh token (longer expiry)
 */
const generateRefreshToken = (payload) => {
    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
        throw new Error('JWT_SECRET not configured');
    }
    return jsonwebtoken_1.default.sign(payload, jwtSecret, {
        expiresIn: '30d', // Refresh tokens last 30 days
    });
};
exports.generateRefreshToken = generateRefreshToken;
//# sourceMappingURL=auth.middleware.js.map