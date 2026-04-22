import { Request } from 'express';
import db from '../config/database';
import { AuthorizationError } from '../middleware/errorHandler';
import type { AuditTrailQuery } from './auditQuery.util';

/**
 * Resolves audit query filters for the current user.
 * - developer: full tenant filters from query
 * - admin: full tenant filters if can_view_audit (per account row)
 * - doctor/paramedical: forced to own actor_user_id only
 */
export async function resolveAuditTrailQuery(
  req: Request,
  parsed: AuditTrailQuery,
): Promise<AuditTrailQuery> {
  const role = req.user?.role || '';
  const userId = String(req.user?.userId || req.user?.id || '');
  const tenantId = req.tenantId!;

  if (!userId) {
    throw new AuthorizationError('Not authenticated');
  }

  if (role === 'developer') {
    return parsed;
  }

  if (role === 'doctor' || role === 'paramedical') {
    return {
      ...parsed,
      actor_user_id: userId,
    };
  }

  if (role === 'admin') {
    const row = await db('user_account_permissions')
      .where({ tenant_id: tenantId, user_id: userId })
      .first();

    if (row && row.can_view_audit === false) {
      throw new AuthorizationError('Permission denied: can_view_audit');
    }
    return parsed;
  }

  throw new AuthorizationError('Not allowed to view audit trail');
}
