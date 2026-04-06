import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AuthenticationError, AuthorizationError, asyncHandler } from './errorHandler';
import { logger } from '../config/logger';

/**
 * JWT Payload interface
 */
export interface JwtPayload {
  id: string;
  userId?: string;
  tenantId: string;
  tenant_id?: string;
  role: string;
  email: string;
  iat?: number;
  exp?: number;
}

/**
 * Extend Express Request to include user
 */
declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
      tenantId?: string;
    }
  }
}

/**
 * Authentication middleware
 * Verifies JWT token and attaches user to request
 */
export const authenticate = asyncHandler(
  async (req: Request, res: Response, next: NextFunction) => {
    // Get token from header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AuthenticationError('No token provided. Please include Bearer token in Authorization header.');
    }

    const token = authHeader.split(' ')[1];

    if (!token) {
      throw new AuthenticationError('Invalid token format');
    }

    try {
      // Verify token
      const jwtSecret = process.env.JWT_SECRET;
      
      if (!jwtSecret) {
        logger.error('JWT_SECRET not configured in environment variables');
        throw new Error('Server configuration error');
      }

      const decoded = jwt.verify(token, jwtSecret) as JwtPayload & {
        user_id?: string;
        tenant_id?: string;
      };

      // Attach user to request
      decoded.userId = decoded.userId || decoded.id || decoded.user_id;
      const resolvedTenantId = decoded.tenantId || decoded.tenant_id;
      if (resolvedTenantId) {
        decoded.tenantId = resolvedTenantId;
      }
      req.user = decoded;
      req.tenantId = decoded.tenantId;

      logger.debug(`User authenticated: ${decoded.id || decoded.userId} (${decoded.role})`);

      next();
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new AuthenticationError('Token has expired. Please login again.');
      } else if (error instanceof jwt.JsonWebTokenError) {
        throw new AuthenticationError('Invalid token. Please login again.');
      } else {
        throw error;
      }
    }
  }
);

/**
 * Authorization middleware
 * Checks if user has required role(s)
 * Usage: authorize('admin', 'doctor')
 */
export const authorize = (...allowedRoles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new AuthenticationError('User not authenticated');
    }

    const userRole = req.user.role;

    if (!allowedRoles.includes(userRole)) {
      logger.warn(
        `Authorization failed: User ${req.user.userId} with role "${userRole}" ` +
        `attempted to access resource requiring roles: ${allowedRoles.join(', ')}`
      );
      
      throw new AuthorizationError(
        `Access denied. Required roles: ${allowedRoles.join(' or ')}`
      );
    }

    logger.debug(`User ${req.user.userId} authorized with role: ${userRole}`);
    next();
  };
};

/**
 * Optional authentication middleware
 * Attaches user if token is present, but doesn't require it
 * Useful for endpoints that behave differently for logged-in vs anonymous users
 */
export const optionalAuth = asyncHandler(
  async (req: Request, res: Response, next: NextFunction) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      // No token, continue without authentication
      return next();
    }

    const token = authHeader.split(' ')[1];

    try {
      const jwtSecret = process.env.JWT_SECRET;
      
      if (jwtSecret) {
        const decoded = jwt.verify(token, jwtSecret) as JwtPayload;
        req.user = decoded;
        req.tenantId = decoded.tenantId;
      }
    } catch (error) {
      // Token is invalid, but we don't throw error
      // Just continue without authentication
      logger.debug('Optional auth: Invalid token, continuing without authentication');
    }

    next();
  }
);

/**
 * Tenant isolation middleware
 * Ensures user can only access data from their own tenant
 */
export const tenantIsolation = (req: Request, res: Response, next: NextFunction) => {
  if (!req.user) {
    throw new AuthenticationError('User not authenticated');
  }

  if (!req.tenantId) {
    throw new Error('Tenant ID not found in request');
  }

  // Attach tenant filter to request for use in queries
  (req as any).tenantFilter = { tenant_id: req.tenantId };

  next();
};

/**
 * Check if user owns the resource
 * Usage: checkOwnership('userId') - checks if req.params.userId matches req.user.userId
 */
export const checkOwnership = (paramName: string = 'id') => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      throw new AuthenticationError('User not authenticated');
    }

    const resourceId = req.params[paramName];
    const userId = req.user.userId;

    if (resourceId !== userId) {
      // Allow admins and developers to access any resource
      if (!['admin', 'developer'].includes(req.user.role)) {
        throw new AuthorizationError('You can only access your own resources');
      }
    }

    next();
  };
};

/**
 * Generate JWT token
 * Utility function to create tokens
 */
export const generateToken = (payload: Omit<JwtPayload, 'iat' | 'exp'>): string => {
  const jwtSecret = process.env.JWT_SECRET;

  if (!jwtSecret) {
    throw new Error('JWT_SECRET not configured');
  }

  return jwt.sign(payload, jwtSecret, {
    expiresIn: '7d',
  });
};

/**
 * Generate refresh token (longer expiry)
 */
export const generateRefreshToken = (payload: Omit<JwtPayload, 'iat' | 'exp'>): string => {
  const jwtSecret = process.env.JWT_SECRET;

  if (!jwtSecret) {
    throw new Error('JWT_SECRET not configured');
  }

  return jwt.sign(payload, jwtSecret, {
    expiresIn: '30d', // Refresh tokens last 30 days
  });
};


