import db from '../config/database';
import { logger } from '../config/logger';
import { NotFoundError } from '../middleware/errorHandler';
import { NOSHOW_FEATURE_KEYS, NOSHOW_MODEL_KEY } from './noShowFeatureConfig';
import { noShowTrainingService } from './noShowTraining.service';

const MODEL_TYPE = 'no_show_prediction';

export class NoShowDriftService {
  private zWarning(): number {
    return Number(process.env.NOSHOW_DRIFT_Z_WARNING || 2);
  }

  private zCritical(): number {
    return Number(process.env.NOSHOW_DRIFT_Z_CRITICAL || 3);
  }

  private windowDays(): number {
    return Math.max(1, Number(process.env.NOSHOW_DRIFT_WINDOW_DAYS || 14));
  }

  async listSnapshots(tenantId: string, limit = 50): Promise<Record<string, unknown>[]> {
    return db('ml_drift_snapshots')
      .where({ tenant_id: tenantId, model_key: NOSHOW_MODEL_KEY })
      .orderBy('created_at', 'desc')
      .limit(Math.min(200, Math.max(1, limit)));
  }

  async listAlerts(tenantId: string, onlyUnacked: boolean, limit = 100): Promise<Record<string, unknown>[]> {
    let q = db('ml_alert_events')
      .where({ tenant_id: tenantId, model_key: NOSHOW_MODEL_KEY })
      .orderBy('created_at', 'desc')
      .limit(Math.min(200, Math.max(1, limit)));
    if (onlyUnacked) q = q.andWhere({ is_acknowledged: false });
    return q;
  }

  async acknowledgeAlert(tenantId: string, alertId: string, userId: string | undefined): Promise<void> {
    const row = await db('ml_alert_events')
      .where({ id: alertId, tenant_id: tenantId })
      .first();
    if (!row) throw new NotFoundError('Alert');
    await db('ml_alert_events')
      .where({ id: alertId })
      .update({
        is_acknowledged: true,
        acknowledged_by: userId || null,
        acknowledged_at: new Date(),
      });
  }

  /** Compare recent completed/no-show appointments to training baselines for the active model. */
  async runFeatureDriftCheck(tenantId: string): Promise<Record<string, unknown>> {
    const active = await db('ml_model_versions')
      .where({ tenant_id: tenantId, model_type: MODEL_TYPE, is_active: true })
      .first();
    if (!active) {
      return { ok: false, reason: 'No active model' };
    }

    const baselines = await db('ml_feature_distribution_baselines')
      .where({ tenant_id: tenantId, model_version_id: active.id })
      .select('feature_name', 'baseline_json', 'sample_size');

    if (!baselines.length) {
      return {
        ok: false,
        reason: 'No feature baselines for active model; run training after upgrade',
        model_version_id: active.id,
      };
    }

    const baselineByName = new Map<string, { mean: number; std: number }>();
    for (const b of baselines as any[]) {
      const j = b.baseline_json || {};
      baselineByName.set(String(b.feature_name), {
        mean: Number(j.mean || 0),
        std: Math.max(Number(j.std || 0), 1e-9),
      });
    }

    const fullDataset = await noShowTrainingService.buildTrainingDataset(tenantId);
    const days = this.windowDays();
    const cutoff = Date.now() - days * 24 * 3600000;
    const recent = fullDataset.filter((r) => r.appointment_date.getTime() >= cutoff);
    if (recent.length < 20) {
      return {
        ok: false,
        reason: `Not enough recent rows in window (${recent.length}); need at least 20`,
        window_days: days,
      };
    }

    const dim = recent[0].features.length;
    const windowStart = new Date(cutoff);
    const windowEnd = new Date();
    const zw = this.zWarning();
    const zc = this.zCritical();
    let criticalCount = 0;
    const perFeature: any[] = [];
    const snapshotRows: Record<string, unknown>[] = [];

    for (let i = 0; i < dim; i += 1) {
      const fname = NOSHOW_FEATURE_KEYS[i] || `feature_${i}`;
      const base = baselineByName.get(fname);
      if (!base) continue;
      const vals = recent.map((r) => r.features[i]);
      const meanCur = vals.reduce((a, v) => a + v, 0) / vals.length;
      const zScore = Math.abs(meanCur - base.mean) / base.std;
      let status = 'ok';
      if (zScore >= zc) {
        status = 'critical';
        criticalCount += 1;
      } else if (zScore >= zw) {
        status = 'warning';
      }
      perFeature.push({ feature: fname, z_score: zScore, mean_current: meanCur, status });

      snapshotRows.push({
        tenant_id: tenantId,
        model_key: NOSHOW_MODEL_KEY,
        model_version_id: active.id,
        snapshot_type: 'feature_drift',
        detection_window_start: windowStart,
        detection_window_end: windowEnd,
        baseline_window_start: active.data_range_from || null,
        baseline_window_end: active.data_range_to || null,
        status,
        drift_score: zScore,
        threshold_value: zw,
        metric_name: 'mean_shift_z',
        metric_value: meanCur,
        baseline_metric_value: base.mean,
        affected_feature: fname,
        details_json: {
          window_days: days,
          recent_sample_size: recent.length,
          z_score: zScore,
          baseline_std: base.std,
        },
        recommendation_json:
          status === 'critical'
            ? { action: 'retrain_or_review', message: 'Strong shift vs training baseline' }
            : {},
        created_at: new Date(),
      });
    }

    if (snapshotRows.length) {
      await db('ml_drift_snapshots').insert(snapshotRows);
    }

    if (criticalCount > 0) {
      await db('ml_alert_events').insert({
        tenant_id: tenantId,
        model_key: NOSHOW_MODEL_KEY,
        model_version_id: active.id,
        alert_type: 'drift_detected',
        severity: 'critical',
        title: 'No-show model feature drift',
        message: `${criticalCount} feature(s) exceeded critical drift threshold (z >= ${zc}).`,
        source_ref_type: 'drift_snapshot',
        source_ref_id: null,
        details_json: { features: perFeature.filter((p) => p.status === 'critical') },
        created_at: new Date(),
      });
    }

    logger.info('No-show drift check completed', {
      tenantId,
      modelVersionId: active.id,
      snapshots: perFeature.length,
      criticalFeatures: criticalCount,
    });

    return {
      ok: true,
      tenant_id: tenantId,
      model_key: NOSHOW_MODEL_KEY,
      model_version_id: active.id,
      overall_status: criticalCount > 0 ? 'critical' : perFeature.some((p) => p.status === 'warning') ? 'warning' : 'ok',
      snapshots_created: perFeature.length,
      window_days: days,
      features: perFeature,
    };
  }
}

export const noShowDriftService = new NoShowDriftService();
