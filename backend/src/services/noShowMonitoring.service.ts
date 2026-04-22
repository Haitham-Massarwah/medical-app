import db from '../config/database';
import { NOSHOW_MODEL_KEY } from './noShowFeatureConfig';

const MODEL_TYPE = 'no_show_prediction';

export class NoShowMonitoringService {
  async listDaily(tenantId: string, days: number): Promise<Record<string, unknown>[]> {
    const d = Math.min(730, Math.max(1, Math.floor(days)));
    const since = new Date();
    since.setUTCDate(since.getUTCDate() - d);
    const sinceStr = since.toISOString().slice(0, 10);
    return db('ml_prediction_monitoring_daily')
      .where({ tenant_id: tenantId, model_key: NOSHOW_MODEL_KEY })
      .andWhere('stat_date', '>=', sinceStr)
      .orderBy('stat_date', 'desc');
  }

  /**
   * Aggregate predictions recorded on `statDate` (UTC date) into ml_prediction_monitoring_daily.
   */
  async rollupForStatDate(tenantId: string, statDate: string): Promise<Record<string, unknown>> {
    const active = await db('ml_model_versions')
      .where({ tenant_id: tenantId, model_type: MODEL_TYPE, is_active: true })
      .first();

    const preds = await db('appointment_no_show_predictions')
      .where({ tenant_id: tenantId })
      .whereRaw('predicted_at::date = ?::date', [statDate]);

    const rows = preds as { risk_score: unknown; risk_level: string }[];
    const n = rows.length;
    if (n === 0) {
      return { stat_date: statDate, predictions_count: 0, message: 'No predictions that day' };
    }

    const avgScore = rows.reduce((a, r) => a + Number(r.risk_score || 0), 0) / n;
    const pct = (lvl: string) => rows.filter((r) => r.risk_level === lvl).length / n;

    const payload = {
      tenant_id: tenantId,
      model_key: NOSHOW_MODEL_KEY,
      model_version_id: active?.id || null,
      stat_date: statDate,
      predictions_count: n,
      actuals_available_count: 0,
      avg_score: Number(avgScore.toFixed(6)),
      pct_high_risk: Number(pct('high').toFixed(6)),
      pct_medium_risk: Number(pct('medium').toFixed(6)),
      pct_low_risk: Number(pct('low').toFixed(6)),
      updated_at: new Date(),
    };

    await db('ml_prediction_monitoring_daily')
      .insert({ ...payload, created_at: new Date() })
      .onConflict(['tenant_id', 'model_key', 'stat_date'])
      .merge({
        model_version_id: payload.model_version_id,
        predictions_count: payload.predictions_count,
        actuals_available_count: payload.actuals_available_count,
        avg_score: payload.avg_score,
        pct_high_risk: payload.pct_high_risk,
        pct_medium_risk: payload.pct_medium_risk,
        pct_low_risk: payload.pct_low_risk,
        updated_at: payload.updated_at,
      });

    return { stat_date: statDate, predictions_count: n, merged: true };
  }
}

export const noShowMonitoringService = new NoShowMonitoringService();
