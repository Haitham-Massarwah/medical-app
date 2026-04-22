import { Knex } from 'knex';

export type AuditTrailQuery = {
  actor_user_id?: string;
  action?: string;
  date_from?: string;
  date_to?: string;
};

/**
 * Apply tenant + optional filters to an audit_events query builder (before select/order).
 */
export function applyAuditFilters(
  qb: Knex.QueryBuilder,
  tenantId: string,
  q: AuditTrailQuery,
): Knex.QueryBuilder {
  let b = qb.where('audit_events.tenant_id', tenantId);

  const actor = q.actor_user_id?.trim();
  if (actor) {
    b = b.andWhere('audit_events.actor_user_id', actor);
  }

  const action = q.action?.trim();
  if (action) {
    b = b.andWhere('audit_events.action', action);
  }

  const from = q.date_from?.trim();
  if (from) {
    const d = new Date(from);
    if (!Number.isNaN(d.getTime())) {
      b = b.andWhere('audit_events.created_at', '>=', d);
    }
  }

  const to = q.date_to?.trim();
  if (to) {
    const d = new Date(to);
    if (!Number.isNaN(d.getTime())) {
      d.setHours(23, 59, 59, 999);
      b = b.andWhere('audit_events.created_at', '<=', d);
    }
  }

  return b;
}

export function parseAuditQuery(reqQuery: Record<string, unknown>): AuditTrailQuery {
  return {
    actor_user_id: typeof reqQuery.actor_user_id === 'string' ? reqQuery.actor_user_id : undefined,
    action: typeof reqQuery.action === 'string' ? reqQuery.action : undefined,
    date_from: typeof reqQuery.date_from === 'string' ? reqQuery.date_from : undefined,
    date_to: typeof reqQuery.date_to === 'string' ? reqQuery.date_to : undefined,
  };
}
