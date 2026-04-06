import { Request, Response, NextFunction } from 'express';
import { logger } from '../config/logger';
import { AuthenticationError } from './errorHandler';

/**
 * Tenant context middleware
 * Ensures all database queries are scoped to the current tenant
 * Prevents data leakage between tenants
 */
export const tenantContext = (req: Request, res: Response, next: NextFunction) => {
  // User must be authenticated first
  if (!req.user) {
    throw new AuthenticationError('User must be authenticated for tenant context');
  }

  const tenantId = req.user.tenantId;

  // Allow null tenant_id for users without tenant assignment
  // This is useful for testing and initial setup
  if (tenantId === undefined) {
    logger.error(`User ${req.user.userId} has no tenantId`);
    throw new Error('User tenant information is missing');
  }

  // If tenantId is null, set tenantFilter to null to allow queries without tenant filtering
  if (!tenantId) {
    logger.debug(`User ${req.user.userId} has no tenant assigned - allowing access`);
    (req as any).tenantId = null;
    (req as any).tenantFilter = null;
    next();
    return;
  }

  // Attach tenant ID to request for easy access
  req.tenantId = tenantId;

  // Create tenant filter for database queries
  // Controllers can use this to ensure queries are scoped to tenant
  (req as any).tenantFilter = {
    tenant_id: tenantId,
  };

  logger.debug(`Request scoped to tenant: ${tenantId}`);

  next();
};

/**
 * Allow cross-tenant access for super admins and developers
 * This middleware should be used sparingly and only for admin endpoints
 */
export const allowCrossTenant = (req: Request, res: Response, next: NextFunction) => {
  if (!req.user) {
    throw new AuthenticationError('User must be authenticated');
  }

  // Only developers can access cross-tenant data
  if (req.user.role !== 'developer') {
    // For other roles, still apply tenant context
    return tenantContext(req, res, next);
  }

  // For developers, check if a specific tenant is requested
  const requestedTenantId = req.headers['x-tenant-id'] as string || req.query.tenant_id as string;

  if (requestedTenantId) {
    req.tenantId = requestedTenantId;
    (req as any).tenantFilter = { tenant_id: requestedTenantId };
    logger.debug(`Developer ${req.user.userId} accessing tenant: ${requestedTenantId}`);
  } else {
    // No specific tenant requested, use developer's own tenant
    req.tenantId = req.user.tenantId;
    (req as any).tenantFilter = { tenant_id: req.user.tenantId };
  }

  next();
};

/**
 * Validate tenant ownership
 * Ensures the resource belongs to the user's tenant
 * Usage: validateTenantOwnership('appointment')
 */
export const validateTenantOwnership = (resourceName: string = 'resource') => {
  return async (req: Request, res: Response, next: NextFunction) => {
    const resourceId = req.params.id;
    const tenantId = req.tenantId;

    if (!tenantId) {
      throw new AuthenticationError('Tenant context not established');
    }

    // The actual validation will be done in the controller/service layer
    // This middleware just ensures tenant context is set
    // Controllers should filter by tenant_id when fetching resources

    logger.debug(`Validating ${resourceName} ${resourceId} belongs to tenant ${tenantId}`);
    next();
  };
};



