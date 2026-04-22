import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('payment_transactions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('appointment_id').references('id').inTable('appointments').onDelete('SET NULL');
    table.uuid('patient_id').references('id').inTable('users').onDelete('SET NULL');
    table.uuid('doctor_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.decimal('amount', 12, 2).notNullable();
    table.string('currency', 10).notNullable().defaultTo('ILS');
    table.string('status', 32).notNullable().defaultTo('pending'); // pending/processing/succeeded/failed/refunded/disputed/cancelled
    table.string('provider', 32).notNullable().defaultTo('pending_provider');
    table.string('provider_transaction_id', 255);
    table.string('idempotency_key', 255).notNullable();
    table.jsonb('metadata').notNullable().defaultTo('{}');
    table.timestamp('processed_at');
    table.timestamp('failed_at');
    table.text('failure_reason');
    table.timestamps(true, true);
    table.unique(['tenant_id', 'idempotency_key']);
    table.index(['tenant_id', 'status']);
    table.index(['tenant_id', 'appointment_id']);
  });

  await knex.schema.createTable('payment_attempts', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('payment_transaction_id').notNullable().references('id').inTable('payment_transactions').onDelete('CASCADE');
    table.integer('attempt_number').notNullable().defaultTo(1);
    table.string('status', 32).notNullable().defaultTo('started'); // started/succeeded/failed
    table.string('provider_status', 64);
    table.text('provider_message');
    table.jsonb('provider_payload').notNullable().defaultTo('{}');
    table.timestamp('attempted_at').notNullable().defaultTo(knex.fn.now());
    table.timestamps(true, true);
    table.unique(['payment_transaction_id', 'attempt_number']);
    table.index(['tenant_id', 'payment_transaction_id']);
  });

  await knex.schema.createTable('settlements', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('payment_transaction_id').notNullable().references('id').inTable('payment_transactions').onDelete('CASCADE');
    table.uuid('doctor_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.decimal('gross_amount', 12, 2).notNullable();
    table.decimal('fee_amount', 12, 2).notNullable().defaultTo(0);
    table.decimal('net_amount', 12, 2).notNullable();
    table.string('currency', 10).notNullable().defaultTo('ILS');
    table.string('status', 32).notNullable().defaultTo('pending'); // pending/paid/failed/reversed
    table.date('settlement_date');
    table.string('provider_settlement_id', 255);
    table.text('notes');
    table.timestamps(true, true);
    table.index(['tenant_id', 'status']);
    table.index(['tenant_id', 'doctor_user_id']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('settlements');
  await knex.schema.dropTableIfExists('payment_attempts');
  await knex.schema.dropTableIfExists('payment_transactions');
}
