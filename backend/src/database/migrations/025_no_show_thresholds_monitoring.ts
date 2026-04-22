import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('ml_model_threshold_configs', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('doctor_user_id').references('id').inTable('users').onDelete('CASCADE').nullable();
    table.string('model_key', 100).notNullable().defaultTo('no_show_prediction');
    table.uuid('model_version_id').references('id').inTable('ml_model_versions').onDelete('SET NULL').nullable();
    table.decimal('medium_threshold', 6, 5).notNullable();
    table.decimal('high_threshold', 6, 5).notNullable();
    table.boolean('auto_sms_medium_enabled').notNullable().defaultTo(false);
    table.boolean('auto_sms_high_enabled').notNullable().defaultTo(true);
    table.boolean('smart_overbooking_enabled').notNullable().defaultTo(false);
    table.uuid('created_by').references('id').inTable('users').onDelete('SET NULL').nullable();
    table.uuid('updated_by').references('id').inTable('users').onDelete('SET NULL').nullable();
    table.timestamps(true, true);
    table.index(['tenant_id', 'model_key']);
  });

  await knex.raw(`
    ALTER TABLE ml_model_threshold_configs
    ADD CONSTRAINT chk_ml_threshold_medium CHECK (medium_threshold >= 0 AND medium_threshold <= 1),
    ADD CONSTRAINT chk_ml_threshold_high CHECK (high_threshold >= 0 AND high_threshold <= 1),
    ADD CONSTRAINT chk_ml_threshold_order CHECK (medium_threshold < high_threshold)
  `);

  await knex.raw(`
    CREATE UNIQUE INDEX IF NOT EXISTS ux_ml_threshold_tenant_default
    ON ml_model_threshold_configs (tenant_id, model_key)
    WHERE doctor_user_id IS NULL
  `);
  await knex.raw(`
    CREATE UNIQUE INDEX IF NOT EXISTS ux_ml_threshold_doctor_override
    ON ml_model_threshold_configs (tenant_id, model_key, doctor_user_id)
    WHERE doctor_user_id IS NOT NULL
  `);

  await knex.schema.createTable('ml_drift_snapshots', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.string('model_key', 100).notNullable().defaultTo('no_show_prediction');
    table.uuid('model_version_id').references('id').inTable('ml_model_versions').onDelete('SET NULL').nullable();
    table.string('snapshot_type', 50).notNullable();
    table.timestamp('detection_window_start').notNullable();
    table.timestamp('detection_window_end').notNullable();
    table.timestamp('baseline_window_start').nullable();
    table.timestamp('baseline_window_end').nullable();
    table.string('status', 30).notNullable();
    table.decimal('drift_score', 10, 6).nullable();
    table.decimal('threshold_value', 10, 6).nullable();
    table.string('metric_name', 100).nullable();
    table.decimal('metric_value', 12, 6).nullable();
    table.decimal('baseline_metric_value', 12, 6).nullable();
    table.string('affected_feature', 255).nullable();
    table.jsonb('details_json').notNullable().defaultTo('{}');
    table.jsonb('recommendation_json').notNullable().defaultTo('{}');
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.index(['tenant_id', 'model_key', 'created_at']);
    table.index(['tenant_id', 'status', 'created_at']);
    table.index(['tenant_id', 'affected_feature', 'created_at']);
  });

  await knex.schema.createTable('ml_feature_distribution_baselines', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.string('model_key', 100).notNullable().defaultTo('no_show_prediction');
    table.uuid('model_version_id').notNullable().references('id').inTable('ml_model_versions').onDelete('CASCADE');
    table.string('feature_name', 255).notNullable();
    table.string('feature_type', 30).notNullable().defaultTo('numeric');
    table.jsonb('baseline_json').notNullable();
    table.integer('sample_size').notNullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.unique(['model_version_id', 'feature_name']);
    table.index(['tenant_id', 'model_key', 'model_version_id']);
  });

  await knex.schema.createTable('ml_prediction_monitoring_daily', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.string('model_key', 100).notNullable().defaultTo('no_show_prediction');
    table.uuid('model_version_id').references('id').inTable('ml_model_versions').onDelete('SET NULL').nullable();
    table.date('stat_date').notNullable();
    table.integer('predictions_count').notNullable().defaultTo(0);
    table.integer('actuals_available_count').notNullable().defaultTo(0);
    table.decimal('avg_score', 10, 6).nullable();
    table.decimal('pct_high_risk', 10, 6).nullable();
    table.decimal('pct_medium_risk', 10, 6).nullable();
    table.decimal('pct_low_risk', 10, 6).nullable();
    table.decimal('observed_positive_rate', 10, 6).nullable();
    table.decimal('auc', 10, 6).nullable();
    table.decimal('precision_at_high', 10, 6).nullable();
    table.decimal('recall_at_high', 10, 6).nullable();
    table.decimal('accuracy', 10, 6).nullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.unique(['tenant_id', 'model_key', 'stat_date']);
    table.index(['tenant_id', 'stat_date']);
  });

  await knex.schema.createTable('ml_alert_events', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.string('model_key', 100).notNullable().defaultTo('no_show_prediction');
    table.uuid('model_version_id').references('id').inTable('ml_model_versions').onDelete('SET NULL').nullable();
    table.string('alert_type', 50).notNullable();
    table.string('severity', 20).notNullable();
    table.string('title', 255).notNullable();
    table.text('message').notNullable();
    table.string('source_ref_type', 50).nullable();
    table.uuid('source_ref_id').nullable();
    table.boolean('is_acknowledged').notNullable().defaultTo(false);
    table.uuid('acknowledged_by').references('id').inTable('users').onDelete('SET NULL').nullable();
    table.timestamp('acknowledged_at').nullable();
    table.jsonb('details_json').notNullable().defaultTo('{}');
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.index(['tenant_id', 'created_at']);
    table.index(['tenant_id', 'is_acknowledged', 'severity', 'created_at']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.raw(
    'ALTER TABLE ml_model_threshold_configs DROP CONSTRAINT IF EXISTS chk_ml_threshold_medium',
  );
  await knex.raw(
    'ALTER TABLE ml_model_threshold_configs DROP CONSTRAINT IF EXISTS chk_ml_threshold_high',
  );
  await knex.raw(
    'ALTER TABLE ml_model_threshold_configs DROP CONSTRAINT IF EXISTS chk_ml_threshold_order',
  );
  await knex.raw('DROP INDEX IF EXISTS ux_ml_threshold_tenant_default');
  await knex.raw('DROP INDEX IF EXISTS ux_ml_threshold_doctor_override');
  await knex.schema.dropTableIfExists('ml_alert_events');
  await knex.schema.dropTableIfExists('ml_prediction_monitoring_daily');
  await knex.schema.dropTableIfExists('ml_feature_distribution_baselines');
  await knex.schema.dropTableIfExists('ml_drift_snapshots');
  await knex.schema.dropTableIfExists('ml_model_threshold_configs');
}
