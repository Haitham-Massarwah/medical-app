import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('form_templates', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('title', 255).notNullable();
    table.string('form_type', 50).notNullable().defaultTo('intake');
    table.jsonb('schema_json').notNullable().defaultTo(knex.raw(`'{}'::jsonb`));
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamps(true, true);
    table.index(['tenant_id', 'form_type']);
    table.index(['tenant_id', 'is_active']);
  });

  await knex.schema.createTable('form_submissions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('template_id').references('id').inTable('form_templates').onDelete('SET NULL');
    table.uuid('patient_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.uuid('submitted_by_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.jsonb('answers_json').notNullable().defaultTo(knex.raw(`'{}'::jsonb`));
    table.string('consent_name', 255);
    table.text('signature_data');
    table.timestamp('signed_at');
    table.string('pdf_url', 1024);
    table.string('status', 30).notNullable().defaultTo('submitted');
    table.timestamps(true, true);
    table.index(['tenant_id', 'template_id']);
    table.index(['tenant_id', 'patient_user_id']);
    table.index(['tenant_id', 'status']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('form_submissions');
  await knex.schema.dropTableIfExists('form_templates');
}

