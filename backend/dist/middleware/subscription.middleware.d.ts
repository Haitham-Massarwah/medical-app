import { Request, Response, NextFunction } from 'express';
/**
 * Middleware to check if doctor has an active subscription
 * This should be applied to routes that require a valid subscription
 */
export declare function requireActiveSubscription(req: Request, res: Response, next: NextFunction): Promise<void>;
/**
 * Middleware to check if doctor can book appointment based on usage limits
 */
export declare function checkAppointmentLimit(req: Request, res: Response, next: NextFunction): Promise<void>;
/**
 * Middleware to allow graceful degradation (warning but allow access)
 * Useful for non-critical features during subscription issues
 */
export declare function warnIfNoSubscription(req: Request, res: Response, next: NextFunction): Promise<void>;
declare global {
    namespace Express {
        interface Request {
            doctor?: any;
        }
    }
}
//# sourceMappingURL=subscription.middleware.d.ts.map