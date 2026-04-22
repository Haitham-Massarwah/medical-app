/** Aligned with logistic feature vector order in training / prediction. */
export const NOSHOW_MODEL_KEY = 'no_show_prediction';

export const NOSHOW_FEATURE_KEYS = [
  'lead_time_norm',
  'hour_norm',
  'dow_norm',
  'month_norm',
  'duration_norm',
  'patient_total_norm',
  'patient_completed_norm',
  'patient_no_shows_norm',
  'patient_no_show_rate',
  'patient_recent_no_show_rate',
  'days_since_last_norm',
] as const;

export const NOSHOW_FEATURE_LABELS: Record<(typeof NOSHOW_FEATURE_KEYS)[number], string> = {
  lead_time_norm: 'Lead time (normalized)',
  hour_norm: 'Appointment hour',
  dow_norm: 'Day of week',
  month_norm: 'Month (seasonality)',
  duration_norm: 'Duration',
  patient_total_norm: 'Patient prior appointment count',
  patient_completed_norm: 'Patient prior completed count',
  patient_no_shows_norm: 'Patient prior no-show count',
  patient_no_show_rate: 'Patient historical no-show rate',
  patient_recent_no_show_rate: 'Patient recent no-show rate',
  days_since_last_norm: 'Days since last appointment',
};
