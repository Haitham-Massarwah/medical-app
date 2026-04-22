import db from '../config/database';
import { logger } from '../config/logger';
import { utcToZonedTime } from 'date-fns-tz';
import { noShowTrainingService } from './noShowTraining.service';

export class NoShowCronService {
  private intervalHandle: NodeJS.Timeout | null = null;

  /** Last local calendar day (tenant TZ) we ran training for, per tenant. */
  private lastTenantLocalDay = new Map<string, string>();

  async runScheduledRetrainingForTenant(tenantId: string): Promise<void> {
    await noShowTrainingService.trainTenantModel(String(tenantId), 'cron', {
      activateIfBetter: true,
      force: false,
    });
  }

  private async tickTenantWindows(targetHour: number, targetDow: number): Promise<void> {
    const tenants = await db('tenants').select('id', 'timezone');
    const nowUtc = new Date();
    for (const t of tenants as { id: string; timezone?: string | null }[]) {
      const tz = (t.timezone && String(t.timezone).trim()) || 'UTC';
      let local: Date;
      try {
        local = utcToZonedTime(nowUtc, tz);
      } catch {
        logger.warn('Invalid tenant timezone; using UTC for no-show cron', { tenantId: t.id, tz });
        local = nowUtc;
      }
      if (local.getHours() !== targetHour || local.getDay() !== targetDow) continue;

      const dayKey = `${local.getFullYear()}-${String(local.getMonth() + 1).padStart(2, '0')}-${String(local.getDate()).padStart(2, '0')}`;
      if (this.lastTenantLocalDay.get(t.id) === dayKey) continue;
      this.lastTenantLocalDay.set(t.id, dayKey);

      try {
        await this.runScheduledRetrainingForTenant(String(t.id));
      } catch (e: unknown) {
        const err = e as { message?: string };
        logger.error('No-show cron training failed for tenant', {
          tenantId: String(t.id),
          error: err?.message || String(e),
        });
      }
    }
  }

  start(): void {
    const enabled = String(process.env.NOSHOW_CRON_ENABLED || 'true').toLowerCase() === 'true';
    if (!enabled) return;

    const tickMs = Math.max(60_000, Number(process.env.NOSHOW_CRON_TICK_MS || 900_000));
    const targetHour = Math.max(0, Math.min(23, Number(process.env.NOSHOW_CRON_HOUR_LOCAL ?? 2)));
    const targetDow = Math.max(0, Math.min(6, Number(process.env.NOSHOW_CRON_WEEKDAY_LOCAL ?? 0)));

    if (this.intervalHandle) return;
    this.intervalHandle = setInterval(() => {
      this.tickTenantWindows(targetHour, targetDow).catch((e) => {
        logger.error('No-show scheduled retraining tick error', e as Error);
      });
    }, tickMs);
    logger.info('No-show retraining scheduler started (tenant-local window)', {
      tickMs,
      targetHourLocal: targetHour,
      targetWeekdayLocal: targetDow,
      note: '0=Sunday .. 6=Saturday in tenant timezone',
    });
  }
}

export const noShowCronService = new NoShowCronService();
