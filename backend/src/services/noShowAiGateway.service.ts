/**
 * Optional Python FastAPI + XGBoost service. When `AI_SERVICE_BASE_URL` is unset, callers use in-process Node prediction.
 */
export async function predictNoShowViaAiService(payload: {
  tenantId: string;
  appointmentId: string;
  actorRole: string;
  actorUserId: string;
  doctorUserId?: string | null;
  features?: number[];
  featuresMap?: Record<string, number>;
}): Promise<Record<string, unknown> | null> {
  const base = (process.env.AI_SERVICE_BASE_URL || '').trim().replace(/\/$/, '');
  if (!base) return null;

  const res = await fetch(`${base}/predict-one`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      tenant_id: payload.tenantId,
      appointment_id: payload.appointmentId,
      actor_role: payload.actorRole,
      actor_user_id: payload.actorUserId,
      doctor_user_id: payload.doctorUserId ?? undefined,
      feature_vector: payload.features ?? [],
      features_map: payload.featuresMap ?? {},
    }),
  });

  if (!res.ok) {
    throw new Error(`AI service error: ${res.status} ${await res.text()}`);
  }
  return (await res.json()) as Record<string, unknown>;
}
