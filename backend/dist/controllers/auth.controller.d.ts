import { Request, Response, NextFunction } from 'express';
export declare class AuthController {
    /**
     * Register new user
     * POST /api/v1/auth/register
     */
    register: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Login user
     * POST /api/v1/auth/login
     */
    login: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Forgot password
     * POST /api/v1/auth/forgot-password
     */
    forgotPassword: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Reset password
     * POST /api/v1/auth/reset-password/:token
     */
    resetPassword: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Verify email
     * POST /api/v1/auth/verify-email/:token
     */
    verifyEmail: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get current user
     * GET /api/v1/auth/me
     */
    getCurrentUser: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Logout
     * POST /api/v1/auth/logout
     */
    logout: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Refresh token
     * POST /api/v1/auth/refresh-token
     */
    refreshToken: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Change password
     * PUT /api/v1/auth/change-password
     */
    changePassword: (req: Request, res: Response, next: NextFunction) => void;
}
//# sourceMappingURL=auth.controller.d.ts.map