import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  // Create system_permissions table
  await knex.schema.createTable('system_permissions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.boolean('doctor_payments_enabled').defaultTo(true);
    table.boolean('patient_payments_enabled').defaultTo(true);
    table.boolean('sms_enabled').defaultTo(true);
    table.boolean('email_notifications_enabled').defaultTo(true);
    table.timestamps(true, true);
    table.unique(['tenant_id']);
  });

  // Create activity_logs table
  await knex.schema.createTable('activity_logs', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('user_id').references('id').inTable('users').onDelete('SET NULL');
    table.string('action', 100).notNullable();
    table.string('category', 50).notNullable();
    table.string('severity', 20).defaultTo('info'); // info, warning, error, critical
    table.text('details');
    table.string('ip_address', 45);
    table.string('user_agent');
    table.timestamps(true, true);
    table.index(['tenant_id', 'created_at']);
    table.index(['user_id', 'created_at']);
    table.index('category');
    table.index('severity');
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('activity_logs');
  await knex.schema.dropTableIfExists('system_permissions');
}


