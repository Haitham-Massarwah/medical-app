import { Knex } from 'knex';

/**
 * Sample rows for Forms, CRM, Finance, Integrations, Audit — visible on demo/staff screens.
 * Idempotent: skips if marker template title already exists.
 */
export async function seed(knex: Knex): Promise<void> {
  const tenant =
    (await knex('tenants').where('email', 'admin@medical-appointments.com').first()) ||
    (await knex('tenants').orderBy('created_at', 'asc').first());
  if (!tenant) {
    console.log('demo_module_screen_samples: no tenant, skip');
    return;
  }
  const tenantId = tenant.id;

  const patient = await knex('users').whereRaw('LOWER(email) = ?', ['patient.example@medical-appointments.com']).first();
  const doctor = await knex('users').whereRaw('LOWER(email) = ?', ['doctor.example@medical-appointments.com']).first();
  const admin = await knex('users').whereRaw('LOWER(email) = ?', ['admin@medical-appointments.com']).first();

  const marker = await knex('form_templates').where({ tenant_id: tenantId, title: 'דמו: טופס הסכמה' }).first();
  if (marker) {
    console.log('demo_module_screen_samples: already seeded, skip');
    return;
  }

  const [t1] = await knex('form_templates')
    .insert({
      tenant_id: tenantId,
      title: 'דמו: טופס הסכמה',
      form_type: 'consent',
      schema_json: JSON.stringify({ fields: [{ key: 'notes', type: 'textarea', label: 'הערות' }] }),
      is_active: true,
      created_at: new Date(),
      updated_at: new Date(),
    })
    .returning('*');

  await knex('form_templates').insert({
    tenant_id: tenantId,
    title: 'דמו: שאלון כניסה',
    form_type: 'questionnaire',
    schema_json: JSON.stringify({ fields: [] }),
    is_active: true,
    created_at: new Date(),
    updated_at: new Date(),
  });

  if (patient && t1) {
    await knex('form_submissions').insert({
      tenant_id: tenantId,
      template_id: t1.id,
      patient_user_id: patient.id,
      submitted_by_user_id: patient.id,
      answers_json: JSON.stringify({ notes: 'דוגמה: חתימה דמו' }),
      consent_name: 'דמו מטופל',
      status: 'submitted',
      created_at: new Date(),
      updated_at: new Date(),
    });
  }

  const [lead1] = await knex('crm_leads')
    .insert({
      tenant_id: tenantId,
      full_name: 'דמו: יעל כהן — פנייה טלפונית',
      email: 'demo.lead1@example.com',
      phone: '+972-50-1112233',
      source: 'phone',
      status: 'new',
      notes: 'מעוניינת בבדיקה כללית — דמו',
      owner_user_id: doctor?.id ?? null,
      created_at: new Date(),
      updated_at: new Date(),
    })
    .returning('*');

  await knex('crm_leads').insert({
    tenant_id: tenantId,
    full_name: 'דמו: אבי לוי — אתר',
    email: 'demo.lead2@example.com',
    phone: '+972-52-9988776',
    source: 'web',
    status: 'contacted',
    notes: 'השאיר פרטים בטופס יצירת קשר',
    owner_user_id: admin?.id ?? null,
    created_at: new Date(),
    updated_at: new Date(),
  });

  if (lead1) {
    await knex('crm_followups').insert([
      {
        tenant_id: tenantId,
        lead_id: lead1.id,
        channel: 'sms',
        message: 'דמו: לשלוח SMS תזכורת לתור',
        status: 'pending',
        due_at: new Date(Date.now() + 86400000),
        created_by_user_id: doctor?.id ?? null,
        created_at: new Date(),
        updated_at: new Date(),
      },
      {
        tenant_id: tenantId,
        lead_id: lead1.id,
        channel: 'call',
        message: 'דמו: שיחת מעקב — בוצעה',
        status: 'completed',
        completed_at: new Date(),
        created_by_user_id: doctor?.id ?? null,
        created_at: new Date(),
        updated_at: new Date(),
      },
    ]);
  }

  await knex('communication_templates').insert({
    tenant_id: tenantId,
    name: 'דמו: תזכורת תור SMS',
    channel: 'sms',
    subject: null,
    body: 'שלום {name}, התור שלך מחר ב-{time}. להזמנות: המרפאה.',
    is_active: true,
    created_at: new Date(),
    updated_at: new Date(),
  });

  const [dep] = await knex('finance_deposits')
    .insert({
      tenant_id: tenantId,
      appointment_id: null,
      patient_id: patient?.id ?? null,
      amount: 250.0,
      currency: 'ILS',
      status: 'paid',
      method: 'card',
      notes: 'דמו: מקדמה לטיפול',
      created_at: new Date(),
      updated_at: new Date(),
    })
    .returning('*');

  await knex('finance_deposits').insert({
    tenant_id: tenantId,
    patient_id: patient?.id ?? null,
    amount: 120.5,
    currency: 'ILS',
    status: 'paid',
    method: 'manual',
    notes: 'דמו: אגרת ביקור',
    created_at: new Date(),
    updated_at: new Date(),
  });

  if (dep) {
    await knex('finance_refunds').insert({
      tenant_id: tenantId,
      deposit_id: dep.id,
      amount: 50.0,
      currency: 'ILS',
      status: 'requested',
      reason: 'דמו: בקשת החזר חלקי',
      requested_by_user_id: admin?.id ?? null,
      created_at: new Date(),
      updated_at: new Date(),
    });
  }

  if (doctor) {
    await knex('finance_payouts').insert({
      tenant_id: tenantId,
      provider_user_id: doctor.id,
      gross_amount: 5000.0,
      commission_amount: 500.0,
      net_amount: 4500.0,
      currency: 'ILS',
      status: 'scheduled',
      notes: 'דמו: תשלום רופא לתקופה',
      created_at: new Date(),
      updated_at: new Date(),
    });
  }

  await knex('finance_commission_rules').insert({
    tenant_id: tenantId,
    name: 'דמו: עמלה סטנדרטית',
    percent: 10.0,
    fixed_amount: 0,
    is_active: true,
    created_at: new Date(),
    updated_at: new Date(),
  });

  await knex('integration_connections').insert([
    {
      tenant_id: tenantId,
      provider: 'google_calendar',
      scope: 'tenant',
      user_id: null,
      status: 'connected',
      last_sync_at: new Date(),
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      tenant_id: tenantId,
      provider: 'lab',
      scope: 'tenant',
      status: 'connected',
      last_sync_at: new Date(),
      created_at: new Date(),
      updated_at: new Date(),
    },
  ]);

  await knex('integration_events').insert([
    {
      tenant_id: tenantId,
      provider: 'google_calendar',
      event_type: 'sync',
      severity: 'info',
      status: 'ok',
      message: 'דמו: סנכרון לוח שנה הושלם',
      payload: JSON.stringify({}),
      created_at: new Date(),
    },
    {
      tenant_id: tenantId,
      provider: 'lab',
      event_type: 'results',
      severity: 'warn',
      status: 'ok',
      message: 'דמו: תוצאות ממתינות לאישור',
      payload: JSON.stringify({}),
      created_at: new Date(),
    },
  ]);

  const hasAudit = await knex.schema.hasTable('audit_logs');
  if (hasAudit && admin) {
    await knex('audit_logs').insert({
      tenant_id: tenantId,
      user_id: admin.id,
      action: 'demo_seed',
      entity_type: 'system',
      entity_id: null,
      old_values: null,
      new_values: JSON.stringify({ note: 'demo_module_screen_samples' }),
      created_at: new Date(),
    });
  }

  console.log('demo_module_screen_samples: inserted demo rows for tenant', tenantId);
}
