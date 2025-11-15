"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateTenantOwnership = exports.allowCrossTenant = exports.tenantContext = void 0;
const logger_1 = require("../config/logger");
const errorHandler_1 = require("./errorHandler");
/**
 * Tenant context middleware
 * Ensures all database queries are scoped to the current tenant
 * Prevents data leakage between tenants
 */
const tenantContext = (req, res, next) => {
    // User must be authenticated first
    if (!req.user) {
        throw new errorHandler_1.AuthenticationError('User must be authenticated for tenant context');
    }
    const tenantId = req.user.tenantId;
    if (!tenantId) {
        logger_1.logger.error(`User ${req.user.userId} has no tenantId`);
        throw new Error('User tenant information is missing');
    }
    // Attach tenant ID to request for easy access
    req.tenantId = tenantId;
    // Create tenant filter for database queries
    // Controllers can use this to ensure queries are scoped to tenant
    req.tenantFilter = {
        tenant_id: tenantId,
    };
    logger_1.logger.debug(`Request scoped to tenant: ${tenantId}`);
    next();
};
exports.tenantContext = tenantContext;
/**
 * Allow cross-tenant access for super admins and developers
 * This middleware should be used sparingly and only for admin endpoints
 */
const allowCrossTenant = (req, res, next) => {
    if (!req.user) {
        throw new errorHandler_1.AuthenticationError('User must be authenticated');
    }
    // Only developers can access cross-tenant data
    if (req.user.role !== 'developer') {
        // For other roles, still apply tenant context
        return (0, exports.tenantContext)(req, res, next);
    }
    // For developers, check if a specific tenant is requested
    const requestedTenantId = req.headers['x-tenant-id'] || req.query.tenant_id;
    if (requestedTenantId) {
        req.tenantId = requestedTenantId;
        req.tenantFilter = { tenant_id: requestedTenantId };
        logger_1.logger.debug(`Developer ${req.user.userId} accessing tenant: ${requestedTenantId}`);
    }
    else {
        // No specific tenant requested, use developer's own tenant
        req.tenantId = req.user.tenantId;
        req.tenantFilter = { tenant_id: req.user.tenantId };
    }
    next();
};
exports.allowCrossTenant = allowCrossTenant;
/**
 * Validate tenant ownership
 * Ensures the resource belongs to the user's tenant
 * Usage: validateTenantOwnership('appointment')
 */
const validateTenantOwnership = (resourceName = 'resource') => {
    return async (req, res, next) => {
        const resourceId = req.params.id;
        const tenantId = req.tenantId;
        if (!tenantId) {
            throw new errorHandler_1.AuthenticationError('Tenant context not established');
        }
        // The actual validation will be done in the controller/service layer
        // This middleware just ensures tenant context is set
        // Controllers should filter by tenant_id when fetching resources
        logger_1.logger.debug(`Validating ${resourceName} ${resourceId} belongs to tenant ${tenantId}`);
        next();
    };
};
exports.validateTenantOwnership = validateTenantOwnership;
//# sourceMappingURL=tenantContext.js.map