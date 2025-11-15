"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateUUID = exports.validateDateRange = exports.validatePagination = exports.sanitizeBody = exports.validateRequest = exports.validate = void 0;
const express_validator_1 = require("express-validator");
const errorHandler_1 = require("./errorHandler");
/**
 * Validation middleware
 * Checks express-validator results and throws error if validation fails
 */
const validate = (req, res, next) => {
    const errors = (0, express_validator_1.validationResult)(req);
    if (!errors.isEmpty()) {
        const errorMessages = errors.array().map(error => {
            return `${error.type === 'field' ? error.path : 'validation'}: ${error.msg}`;
        });
        throw new errorHandler_1.ValidationError(errorMessages.join(', '));
    }
    next();
};
exports.validate = validate;
/**
 * Wrapper to run validation chains and check results
 * Usage: validateRequest([ body('email').isEmail(), body('password').isLength({ min: 8 }) ])
 */
const validateRequest = (validations) => {
    return async (req, res, next) => {
        // Run all validations
        await Promise.all(validations.map(validation => validation.run(req)));
        // Check for errors
        const errors = (0, express_validator_1.validationResult)(req);
        if (!errors.isEmpty()) {
            const errorMessages = errors.array().map(error => {
                const field = error.type === 'field' ? error.path : 'validation';
                return `${field}: ${error.msg}`;
            });
            return next(new errorHandler_1.ValidationError(errorMessages.join(', ')));
        }
        next();
    };
};
exports.validateRequest = validateRequest;
/**
 * Sanitize request data
 * Removes any fields that aren't in the allowed list
 */
const sanitizeBody = (allowedFields) => {
    return (req, res, next) => {
        if (req.body && typeof req.body === 'object') {
            const sanitized = {};
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
exports.sanitizeBody = sanitizeBody;
/**
 * Pagination validator
 * Validates and sanitizes page and limit query parameters
 */
const validatePagination = (req, res, next) => {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    // Ensure reasonable limits
    const sanitizedPage = Math.max(1, page);
    const sanitizedLimit = Math.min(Math.max(1, limit), 100); // Max 100 items per page
    // Attach to request
    req.pagination = {
        page: sanitizedPage,
        limit: sanitizedLimit,
        offset: (sanitizedPage - 1) * sanitizedLimit,
    };
    next();
};
exports.validatePagination = validatePagination;
/**
 * Date range validator
 * Validates start_date and end_date query parameters
 */
const validateDateRange = (req, res, next) => {
    const startDate = req.query.start_date;
    const endDate = req.query.end_date;
    if (startDate && isNaN(Date.parse(startDate))) {
        throw new errorHandler_1.ValidationError('Invalid start_date format. Use ISO 8601 format (YYYY-MM-DD)');
    }
    if (endDate && isNaN(Date.parse(endDate))) {
        throw new errorHandler_1.ValidationError('Invalid end_date format. Use ISO 8601 format (YYYY-MM-DD)');
    }
    if (startDate && endDate && new Date(startDate) > new Date(endDate)) {
        throw new errorHandler_1.ValidationError('start_date must be before end_date');
    }
    next();
};
exports.validateDateRange = validateDateRange;
/**
 * UUID validator
 * Validates that a parameter is a valid UUID
 */
const validateUUID = (paramName) => {
    return (req, res, next) => {
        const value = req.params[paramName];
        const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
        if (!uuidRegex.test(value)) {
            throw new errorHandler_1.ValidationError(`Invalid ${paramName}: must be a valid UUID`);
        }
        next();
    };
};
exports.validateUUID = validateUUID;
//# sourceMappingURL=validator.js.map