import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('ml_model_versions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.string('model_type', 80).notNullable();
    table.string('version_code', 120).notNullable();
    table.string('status', 20).notNullable().defaultTo('draft'); // draft|active|archived|failed
    table.timestamp('trained_at');
    table.timestamp('training_started_at');
    table.timestamp('training_finished_at');
    table.integer('training_rows_count').notNullable().defaultTo(0);
    table.integer('training_positive_count').notNullable().defaultTo(0);
    table.integer('training_negative_count').notNullable().defaultTo(0);
    table.integer('validation_rows_count').notNullable().defaultTo(0);
    table.string('feature_schema_version', 40).notNullable().defaultTo('v1');
    table.jsonb('hyperparameters_json').notNullable().defaultTo('{}');
    table.jsonb('weights_json').notNullable().defaultTo('{}');
    table.decimal('bias_value', 16, 8).notNullable().defaultTo(0);
    table.jsonb('metrics_json').notNullable().defaultTo('{}');
    table.timestamp('data_range_from');
    table.timestamp('data_range_to');
    table.string('created_by_source', 40).notNullable().defaultTo('system');
    table.boolean('is_active').notNullable().defaultTo(false);
    table.text('notes');
    table.timestamps(true, true);
    table.index(['tenant_id', 'model_type', 'is_active']);
    table.index(['tenant_id', 'model_type', 'trained_at']);
    table.unique(['tenant_id', 'model_type', 'version_code']);
  });

  await knex.raw(
    `CREATE UNIQUE INDEX IF NOT EXISTS ml_model_versions_one_active_idx
     ON ml_model_versions (tenant_id, model_type)
     WHERE is_active = true`,
  );

  await knex.schema.createTable('ml_training_jobs', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.string('model_type', 80).notNullable();
    table.string('trigger_type', 30).notNullable(); // cron|manual|runtime_fallback
    table.string('status', 20).notNullable(); // queued|running|success|failed|skipped
    table.timestamp('started_at');
    table.timestamp('finished_at');
    table.text('reason');
    table.integer('input_rows_count').notNullable().defaultTo(0);
    table.uuid('output_model_version_id').references('id').inTable('ml_model_versions').onDelete('SET NULL');
    table.jsonb('metrics_json').notNullable().defaultTo('{}');
    table.text('error_message');
    table.timestamps(true, true);
    table.index(['tenant_id', 'model_type', 'started_at']);
    table.index(['status', 'started_at']);
  });

  await knex.schema.createTable('appointment_no_show_predictions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('appointment_id').notNullable().references('id').inTable('appointments').onDelete('CASCADE');
    table.uuid('patient_id').references('id').inTable('patients').onDelete('SET NULL');
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('SET NULL');
    table.uuid('model_version_id').references('id').inTable('ml_model_versions').onDelete('SET NULL');
    table.decimal('risk_score', 8, 6).notNullable().defaultTo(0);
    table.string('risk_level', 20).notNullable();
    table.jsonb('factors_json').notNullable().defaultTo('[]');
    table.timestamp('predicted_at').notNullable().defaultTo(knex.fn.now());
    table.boolean('is_current').notNullable().defaultTo(true);
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.index(['tenant_id', 'doctor_id', 'predicted_at']);
    table.index(['tenant_id', 'risk_level', 'predicted_at']);
    table.index(['tenant_id', 'appointment_id', 'is_current']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('appointment_no_show_predictions');
  await knex.schema.dropTableIfExists('ml_training_jobs');
  await knex.raw('DROP INDEX IF EXISTS ml_model_versions_one_active_idx');
  await knex.schema.dropTableIfExists('ml_model_versions');
}

