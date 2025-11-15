import { Request, Response, NextFunction } from 'express';
export declare class TenantController {
    /**
     * Get all tenants (Developer only)
     * GET /api/v1/tenants
     */
    getAllTenants: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get current tenant
     * GET /api/v1/tenants/current
     */
    getCurrentTenant: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get tenant by ID
     * GET /api/v1/tenants/:id
     */
    getTenantById: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Create tenant
     * POST /api/v1/tenants
     */
    createTenant: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update tenant
     * PUT /api/v1/tenants/:id
     */
    updateTenant: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update tenant settings
     * PUT /api/v1/tenants/:id/settings
     */
    updateSettings: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update tenant branding
     * PUT /api/v1/tenants/:id/branding
     */
    updateBranding: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update tenant plan
     * PUT /api/v1/tenants/:id/plan
     */
    updatePlan: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update tenant status
     * PUT /api/v1/tenants/:id/status
     */
    updateStatus: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Delete tenant (soft delete)
     * DELETE /api/v1/tenants/:id
     */
    deleteTenant: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get tenant statistics
     * GET /api/v1/tenants/:id/statistics
     */
    getTenantStatistics: (req: Request, res: Response, next: NextFunction) => void;
}
//# sourceMappingURL=tenant.controller.d.ts.map