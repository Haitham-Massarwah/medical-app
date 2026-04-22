import { Request, Response, NextFunction } from 'express';
import db from '../config/database';
import { AuthenticationError, AuthorizationError, asyncHandler } from './errorHandler';

type AccountPermissionKey =
  | 'can_manage_users'
  | 'can_manage_doctors'
  | 'can_view_payments'
  | 'can_manage_payments'
  | 'can_manage_permissions'
  | 'can_view_audit';

/**
 * Enforces per-account permission flags for admin/developer accounts.
 * Developer bypasses account-level restrictions by design.
 */
export const requireAccountPermission = (permission: AccountPermissionKey) =>
  asyncHandler(async (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user || !req.tenantId) {
      throw new AuthenticationError('User not authenticated');
    }

    if (req.user.role === 'developer') {
      return next();
    }

    if (req.user.role !== 'admin') {
      // Only admin/developer roles are subject to account-level permission rows.
      // Other authenticated roles are governed by route-level authorization rules.
      return next();
    }

    const userId = req.user.userId || req.user.id;
    const row = await db('user_account_permissions')
      .where({ tenant_id: req.tenantId, user_id: userId })
      .first();

    const strictAdminPermissions =
      String(process.env.ACCOUNT_PERMISSIONS_STRICT || '')
        .trim()
        .toLowerCase() === 'true' || process.env.NODE_ENV === 'production';

    if (!row) {
      if (strictAdminPermissions) {
        throw new AuthorizationError(`Permission denied: ${permission}`);
      }
      return next();
    }

    if (row[permission] !== true) {
      throw new AuthorizationError(`Permission denied: ${permission}`);
    }

    next();
  });

