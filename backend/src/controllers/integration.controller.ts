import { Request, Response } from 'express';
import db from '../config/database';
import { AuthorizationError, ValidationError } from '../middleware/errorHandler';

const STAFF = ['admin', 'developer', 'receptionist', 'doctor', 'paramedical'];
const ADMIN = ['admin', 'developer'];

export class IntegrationController {
  private tenant(req: Request): string {
    const t = req.tenantId;
    if (!t) throw new ValidationError('Tenant is required');
    return t;
  }

  private ensureStaff(req: Request): void {
    const role = req.user?.role || '';
    if (!STAFF.includes(role)) throw new AuthorizationError('Insufficient permissions');
  }

  private ensureAdmin(req: Request): void {
    const role = req.user?.role || '';
    if (!ADMIN.includes(role)) throw new AuthorizationError('Insufficient permissions');
  }

  async listConnections(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.tenant(req);
    const provider = req.query.provider as string | undefined;
    let q = db('integration_connections').where({ tenant_id: tenantId }).orderBy('updated_at', 'desc');
    if (provider) q = q.andWhere({ provider });
    const connections = await q.select('*');
    res.status(200).json({ status: 'success', data: { connections } });
  }

  async upsertConnection(req: Request, res: Response): Promise<void> {
    this.ensureAdmin(req);
    const tenantId = this.tenant(req);
    const { provider, scope, user_id, status, last_sync_at, last_error_code, last_error_message } = req.body || {};
    if (!provider) throw new ValidationError('provider is required');

    const existing = await db('integration_connections')
      .where({
        tenant_id: tenantId,
        provider,
        scope: scope || 'tenant',
        user_id: user_id || null,
      })
      .first();

    let connection: any;
    if (existing) {
      [connection] = await db('integration_connections')
        .where({ id: existing.id })
        .update({
          status: status || existing.status,
          last_sync_at: last_sync_at || null,
          last_error_code: last_error_code || null,
          last_error_message: last_error_message || null,
          updated_at: new Date(),
        })
        .returning('*');
    } else {
      [connection] = await db('integration_connections')
        .insert({
          tenant_id: tenantId,
          provider,
          scope: scope || 'tenant',
          user_id: user_id || null,
          status: status || 'connected',
          last_sync_at: last_sync_at || null,
          last_error_code: last_error_code || null,
          last_error_message: last_error_message || null,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');
    }
    res.status(200).json({ status: 'success', data: { connection } });
  }

  async listEvents(req: Request, res: Response): Promise<void> {
    this.ensureStaff(req);
    const tenantId = this.tenant(req);
    const provider = req.query.provider as string | undefined;
    const severity = req.query.severity as string | undefined;

    let q = db('integration_events').where({ tenant_id: tenantId }).orderBy('created_at', 'desc').limit(200);
    if (provider) q = q.andWhere({ provider });
    if (severity) q = q.andWhere({ severity });
    const events = await q.select('*');
    res.status(200).json({ status: 'success', data: { events } });
  }

  async createEvent(req: Request, res: Response): Promise<void> {
    this.ensureAdmin(req);
    const tenantId = this.tenant(req);
    const { provider, event_type, severity, status, message, payload } = req.body || {};
    if (!provider || !event_type || !message) {
      throw new ValidationError('provider, event_type and message are required');
    }
    const [event] = await db('integration_events')
      .insert({
        tenant_id: tenantId,
        provider,
        event_type,
        severity: severity || 'info',
        status: status || 'ok',
        message,
        payload: payload && typeof payload === 'object' ? payload : {},
        created_at: new Date(),
      })
      .returning('*');
    res.status(201).json({ status: 'success', data: { event } });
  }
}

