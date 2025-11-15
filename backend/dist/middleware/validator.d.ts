import { Request, Response, NextFunction } from 'express';
import { ValidationChain } from 'express-validator';
/**
 * Validation middleware
 * Checks express-validator results and throws error if validation fails
 */
export declare const validate: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Wrapper to run validation chains and check results
 * Usage: validateRequest([ body('email').isEmail(), body('password').isLength({ min: 8 }) ])
 */
export declare const validateRequest: (validations: ValidationChain[]) => (req: Request, res: Response, next: NextFunction) => Promise<void>;
/**
 * Sanitize request data
 * Removes any fields that aren't in the allowed list
 */
export declare const sanitizeBody: (allowedFields: string[]) => (req: Request, res: Response, next: NextFunction) => void;
/**
 * Pagination validator
 * Validates and sanitizes page and limit query parameters
 */
export declare const validatePagination: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Date range validator
 * Validates start_date and end_date query parameters
 */
export declare const validateDateRange: (req: Request, res: Response, next: NextFunction) => void;
/**
 * UUID validator
 * Validates that a parameter is a valid UUID
 */
export declare const validateUUID: (paramName: string) => (req: Request, res: Response, next: NextFunction) => void;
//# sourceMappingURL=validator.d.ts.map