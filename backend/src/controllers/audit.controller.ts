import { Request, Response, NextFunction } from 'express';
import { asyncHandler } from '../middleware/errorHandler';
import db from '../config/database';
import { applyAuditFilters, parseAuditQuery } from '../utils/auditQuery.util';
import { resolveAuditTrailQuery } from '../utils/auditAccess.util';

function escapeCsvCell(value: unknown): string {
  const s = value == null ? '' : String(value);
  if (/[",\r\n]/.test(s)) {
    return `"${s.replace(/"/g, '""')}"`;
  }
  return s;
}

export class AuditController {
  /**
   * GET /api/v1/admin/audit-trail/export.csv
   * UTF-8 BOM for Excel; same filters as audit-trail.
   */
  exportAuditTrailCsv = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const tenantId = req.tenantId!;
    const raw = parseAuditQuery(req.query as Record<string, unknown>);
    const q = await resolveAuditTrailQuery(req, raw);

    const base = applyAuditFilters(
      db('audit_events').leftJoin('users', 'audit_events.actor_user_id', 'users.id'),
      tenantId,
      q,
    );

    const rows = await base
      .clone()
      .select(
        'audit_events.created_at',
        'audit_events.actor_user_id',
        'users.email as actor_email',
        db.raw(
          "TRIM(CONCAT(COALESCE(users.first_name,''),' ',COALESCE(users.last_name,''))) as actor_name",
        ),
        'audit_events.action',
        'audit_events.entity_type',
        'audit_events.entity_id',
        'audit_events.summary',
      )
      .orderBy('audit_events.created_at', 'desc')
      .limit(10_000);

    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="audit-trail.csv"');
    res.write('\ufeff');
    const header = [
      'created_at',
      'actor_user_id',
      'actor_email',
      'actor_name',
      'action',
      'entity_type',
      'entity_id',
      'summary',
    ];
    res.write(header.map(escapeCsvCell).join(',') + '\n');
    for (const row of rows) {
      res.write(
        [
          escapeCsvCell((row as any).created_at),
          escapeCsvCell((row as any).actor_user_id),
          escapeCsvCell((row as any).actor_email),
          escapeCsvCell((row as any).actor_name),
          escapeCsvCell((row as any).action),
          escapeCsvCell((row as any).entity_type),
          escapeCsvCell((row as any).entity_id),
          escapeCsvCell((row as any).summary),
        ].join(',') + '\n',
      );
    }
    res.end();
  });

  /**
   * GET /api/v1/admin/audit-trail
   * Who changed what and when (tenant-scoped).
   * Query: actor_user_id, action, date_from, date_to (YYYY-MM-DD), page, limit
   */
  getAuditTrail = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    const tenantId = req.tenantId!;
    const page = parseInt(String(req.query.page ?? '1'), 10) || 1;
    const limitRaw = parseInt(String(req.query.limit ?? '50'), 10) || 50;
    const limit = Math.min(Math.max(limitRaw, 1), 200);
    const offset = (page - 1) * limit;
    const raw = parseAuditQuery(req.query as Record<string, unknown>);
    const q = await resolveAuditTrailQuery(req, raw);

    const filtered = applyAuditFilters(
      db('audit_events').leftJoin('users', 'audit_events.actor_user_id', 'users.id'),
      tenantId,
      q,
    );

    const rows = await filtered
      .clone()
      .select(
        'audit_events.id',
        'audit_events.tenant_id',
        'audit_events.actor_user_id',
        'audit_events.entity_type',
        'audit_events.entity_id',
        'audit_events.action',
        'audit_events.summary',
        'audit_events.metadata',
        'audit_events.created_at',
        db.raw(
          "TRIM(CONCAT(COALESCE(users.first_name,''),' ',COALESCE(users.last_name,''))) as actor_name",
        ),
        'users.email as actor_email',
      )
      .orderBy('audit_events.created_at', 'desc')
      .limit(limit)
      .offset(offset);

    const countRow = await applyAuditFilters(db('audit_events'), tenantId, q).count('* as c').first();
    const total = Number((countRow as { c?: string | number })?.c ?? 0);

    res.status(200).json({
      success: true,
      data: rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.max(1, Math.ceil(total / limit)),
      },
    });
  });
}

export const auditController = new AuditController();
