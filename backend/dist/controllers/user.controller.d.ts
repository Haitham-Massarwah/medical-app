import { Request, Response, NextFunction } from 'express';
export declare class UserController {
    /**
     * Get all users
     * GET /api/v1/users
     */
    getAllUsers: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get user by ID
     * GET /api/v1/users/:id
     */
    getUserById: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update user
     * PUT /api/v1/users/:id
     */
    updateUser: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Delete user (soft delete)
     * DELETE /api/v1/users/:id
     */
    deleteUser: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update user role
     * PUT /api/v1/users/:id/role
     */
    updateUserRole: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update user status
     * PUT /api/v1/users/:id/status
     */
    updateUserStatus: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get user activity log
     * GET /api/v1/users/:id/activity
     */
    getUserActivity: (req: Request, res: Response, next: NextFunction) => void;
}
//# sourceMappingURL=user.controller.d.ts.map