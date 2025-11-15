import { Request, Response, NextFunction } from 'express';
/**
 * Custom Application Error class
 * Used for operational errors that we can anticipate
 */
export declare class AppError extends Error {
    statusCode: number;
    isOperational: boolean;
    code?: string;
    constructor(message: string, statusCode: number, code?: string);
}
/**
 * Validation Error - 400
 */
export declare class ValidationError extends AppError {
    constructor(message: string);
}
/**
 * Authentication Error - 401
 */
export declare class AuthenticationError extends AppError {
    constructor(message?: string);
}
/**
 * Authorization Error - 403
 */
export declare class AuthorizationError extends AppError {
    constructor(message?: string);
}
/**
 * Not Found Error - 404
 */
export declare class NotFoundError extends AppError {
    constructor(resource?: string);
}
/**
 * Conflict Error - 409
 */
export declare class ConflictError extends AppError {
    constructor(message: string);
}
/**
 * Database Error - 500
 */
export declare class DatabaseError extends AppError {
    constructor(message?: string);
}
/**
 * Global error handler middleware
 * Catches all errors and sends appropriate response
 */
export declare const errorHandler: (err: Error | AppError, req: Request, res: Response, next: NextFunction) => void;
/**
 * Async handler wrapper
 * Wraps async route handlers and passes errors to error handler
 * Usage: asyncHandler(async (req, res, next) => { ... })
 */
export declare const asyncHandler: (fn: Function) => (req: Request, res: Response, next: NextFunction) => void;
/**
 * Not found handler for undefined routes
 */
export declare const notFoundHandler: (req: Request, res: Response, next: NextFunction) => void;
//# sourceMappingURL=errorHandler.d.ts.map