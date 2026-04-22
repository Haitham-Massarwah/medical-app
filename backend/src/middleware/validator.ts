import { Request, Response, NextFunction } from 'express';
import { validationResult, ValidationChain } from 'express-validator';
import { ValidationError } from './errorHandler';

/**
 * Validation middleware
 * Checks express-validator results and throws error if validation fails
 */
export const validate = (req: Request, res: Response, next: NextFunction) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const details = errors.array().map(error => {
      const field = error.type === 'field' ? (error as any).path : 'validation';
      return {
        field,
        error: String(error.msg),
      };
    });
    throw new ValidationError('Validation failed', details);
  }

  next();
};

/**
 * Wrapper to run validation chains and check results
 * Usage: validateRequest([ body('email').isEmail(), body('password').isLength({ min: 8 }) ])
 */
export const validateRequest = (validations: ValidationChain[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    // Run all validations
    await Promise.all(validations.map(validation => validation.run(req)));

    // Check for errors
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
      const details = errors.array().map(error => {
        const field = error.type === 'field' ? (error as any).path : 'validation';
        return {
          field,
          error: String(error.msg),
        };
      });
      return next(new ValidationError('Validation failed', details));
    }

    next();
  };
};

/**
 * Sanitize request data
 * Removes any fields that aren't in the allowed list
 */
export const sanitizeBody = (allowedFields: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (req.body && typeof req.body === 'object') {
      const sanitized: any = {};

      allowedFields.forEach(field => {
        if (req.body[field] !== undefined) {
          sanitized[field] = req.body[field];
        }
      });

      req.body = sanitized;
    }

    next();
  };
};

/**
 * Pagination validator
 * Validates and sanitizes page and limit query parameters
 */
export const validatePagination = (req: Request, res: Response, next: NextFunction) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;

  // Ensure reasonable limits
  const sanitizedPage = Math.max(1, page);
  const sanitizedLimit = Math.min(Math.max(1, limit), 100); // Max 100 items per page

  // Attach to request
  (req as any).pagination = {
    page: sanitizedPage,
    limit: sanitizedLimit,
    offset: (sanitizedPage - 1) * sanitizedLimit,
  };

  next();
};

/**
 * Date range validator
 * Validates start_date and end_date query parameters
 */
export const validateDateRange = (req: Request, res: Response, next: NextFunction) => {
  const startDate = req.query.start_date as string;
  const endDate = req.query.end_date as string;

  if (startDate && isNaN(Date.parse(startDate))) {
    throw new ValidationError('Invalid start_date format. Use ISO 8601 format (YYYY-MM-DD)');
  }

  if (endDate && isNaN(Date.parse(endDate))) {
    throw new ValidationError('Invalid end_date format. Use ISO 8601 format (YYYY-MM-DD)');
  }

  if (startDate && endDate && new Date(startDate) > new Date(endDate)) {
    throw new ValidationError('start_date must be before end_date');
  }

  next();
};

/**
 * UUID validator
 * Validates that a parameter is a valid UUID
 */
export const validateUUID = (paramName: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const value = req.params[paramName];
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

    if (!uuidRegex.test(value)) {
      throw new ValidationError(`Invalid ${paramName}: must be a valid UUID`);
    }

    next();
  };
};

/**
 * Israeli ID (Teudat Zehut) validator
 * Accepts 5-9 digits and validates checksum after left-padding to 9 digits.
 */
export const isValidIsraeliId = (id: string): boolean => {
  if (!id) return false;
  const digitsOnly = id.replace(/\D/g, '');
  if (digitsOnly.length < 5 || digitsOnly.length > 9) return false;

  const normalized = digitsOnly.padStart(9, '0');
  let sum = 0;

  for (let i = 0; i < normalized.length; i++) {
    let num = Number(normalized[i]) * ((i % 2) + 1);
    if (num > 9) num -= 9;
    sum += num;
  }

  return sum % 10 === 0;
};



