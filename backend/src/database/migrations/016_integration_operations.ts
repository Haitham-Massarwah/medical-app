import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('integration_connections', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('provider', 50).notNullable(); // google_calendar/outlook/twilio/cardcom/lab/insurance
    table.string('scope', 30).notNullable().defaultTo('tenant'); // tenant/user
    table.uuid('user_id').references('id').inTable('users').onDelete('SET NULL');
    table.string('status', 30).notNullable().defaultTo('disconnected'); // connected/disconnected/error
    table.timestamp('last_sync_at');
    table.string('last_error_code', 80);
    table.text('last_error_message');
    table.timestamps(true, true);
    table.index(['tenant_id', 'provider']);
    table.index(['tenant_id', 'status']);
  });

  await knex.schema.createTable('integration_events', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('provider', 50).notNullable();
    table.string('event_type', 80).notNullable();
    table.string('severity', 20).notNullable().defaultTo('info'); // info/warn/error
    table.string('status', 30).notNullable().defaultTo('ok'); // ok/failed/retried
    table.text('message').notNullable();
    table.jsonb('payload').defaultTo(knex.raw(`'{}'::jsonb`));
    table.timestamp('created_at').defaultTo(knex.fn.now());
    table.index(['tenant_id', 'provider']);
    table.index(['tenant_id', 'severity']);
    table.index(['tenant_id', 'created_at']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('integration_events');
  await knex.schema.dropTableIfExists('integration_connections');
}

