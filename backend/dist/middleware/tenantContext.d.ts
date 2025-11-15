import { Request, Response, NextFunction } from 'express';
/**
 * Tenant context middleware
 * Ensures all database queries are scoped to the current tenant
 * Prevents data leakage between tenants
 */
export declare const tenantContext: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Allow cross-tenant access for super admins and developers
 * This middleware should be used sparingly and only for admin endpoints
 */
export declare const allowCrossTenant: (req: Request, res: Response, next: NextFunction) => void;
/**
 * Validate tenant ownership
 * Ensures the resource belongs to the user's tenant
 * Usage: validateTenantOwnership('appointment')
 */
export declare const validateTenantOwnership: (resourceName?: string) => (req: Request, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=tenantContext.d.ts.map