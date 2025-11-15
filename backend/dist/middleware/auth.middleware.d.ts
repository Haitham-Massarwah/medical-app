import { Request, Response, NextFunction } from 'express';
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
export declare const authenticate: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Authorization middleware
 * Checks if user has required role(s)
 * Usage: authorize('admin', 'doctor')
 */
export declare const authorize: (...allowedRoles: string[]) => (req: Request, res: Response, next: NextFunction) => void;
/**
 * Optional authentication middleware
 * Attaches user if token is present, but doesn't require it
 * Useful for endpoints that behave differently for logged-in vs anonymous users
 */
export declare const optionalAuth: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Tenant isolation middleware
 * Ensures user can only access data from their own tenant
 */
export declare const tenantIsolation: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Check if user owns the resource
 * Usage: checkOwnership('userId') - checks if req.params.userId matches req.user.userId
 */
export declare const checkOwnership: (paramName?: string) => (req: Request, res: Response, next: NextFunction) => void;
/**
 * Generate JWT token
 * Utility function to create tokens
 */
export declare const generateToken: (payload: Omit<JwtPayload, "iat" | "exp">) => string;
/**
 * Generate refresh token (longer expiry)
 */
export declare const generateRefreshToken: (payload: Omit<JwtPayload, "iat" | "exp">) => string;
//# sourceMappingURL=auth.middleware.d.ts.map