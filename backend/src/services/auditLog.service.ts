import db from '../config/database';
import { logger } from '../config/logger';

export type AuditInsertParams = {
  tenantId: string;
  actorUserId: string | null | undefined;
  entityType: string;
  entityId: string | null | undefined;
  action: string;
  summary?: string | null;
  metadata?: Record<string, unknown>;
};

/**
 * Append-only audit row (non-blocking callers should wrap in try/catch).
 */
export async function insertAuditEvent(params: AuditInsertParams): Promise<void> {
  await db('audit_events').insert({
    tenant_id: params.tenantId,
    actor_user_id: params.actorUserId ?? null,
    entity_type: params.entityType,
    entity_id: params.entityId ?? null,
    action: params.action,
    summary: params.summary ?? null,
    metadata: params.metadata ?? {},
    created_at: new Date(),
  });
}

export async function insertAuditEventSafe(params: AuditInsertParams): Promise<void> {
  try {
    await insertAuditEvent(params);
  } catch (e) {
    logger.warn('insertAuditEvent failed', { err: e, entityType: params.entityType });
  }
}
