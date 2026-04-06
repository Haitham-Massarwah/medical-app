import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('finance_deposits', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('appointment_id').references('id').inTable('appointments').onDelete('SET NULL');
    table.uuid('patient_id').references('id').inTable('users').onDelete('SET NULL');
    table.decimal('amount', 12, 2).notNullable();
    table.string('currency', 10).notNullable().defaultTo('ILS');
    table.string('status', 30).notNullable().defaultTo('pending'); // pending/paid/refunded/failed
    table.string('method', 30).defaultTo('card');
    table.string('external_ref', 255);
    table.text('notes');
    table.timestamps(true, true);
    table.index(['tenant_id', 'status']);
    table.index(['tenant_id', 'appointment_id']);
  });

  await knex.schema.createTable('finance_refunds', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('payment_id');
    table.uuid('deposit_id');
    table.decimal('amount', 12, 2).notNullable();
    table.string('currency', 10).notNullable().defaultTo('ILS');
    table.string('status', 30).notNullable().defaultTo('requested'); // requested/approved/processed/rejected
    table.text('reason').notNullable();
    table.uuid('requested_by_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.uuid('approved_by_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.timestamp('processed_at');
    table.timestamps(true, true);
    table.index(['tenant_id', 'status']);
    table.index(['tenant_id', 'payment_id']);
    table.index(['tenant_id', 'deposit_id']);
  });

  await knex.schema.createTable('finance_payouts', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('provider_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.decimal('gross_amount', 12, 2).notNullable();
    table.decimal('commission_amount', 12, 2).notNullable().defaultTo(0);
    table.decimal('net_amount', 12, 2).notNullable();
    table.string('currency', 10).notNullable().defaultTo('ILS');
    table.string('status', 30).notNullable().defaultTo('scheduled'); // scheduled/paid/failed/held
    table.date('period_start');
    table.date('period_end');
    table.string('external_ref', 255);
    table.text('notes');
    table.timestamp('paid_at');
    table.timestamps(true, true);
    table.index(['tenant_id', 'provider_user_id']);
    table.index(['tenant_id', 'status']);
  });

  await knex.schema.createTable('finance_commission_rules', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('name', 120).notNullable();
    table.decimal('percent', 5, 2).notNullable().defaultTo(0); // 0..100
    table.decimal('fixed_amount', 12, 2).notNullable().defaultTo(0);
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamps(true, true);
    table.index(['tenant_id', 'is_active']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('finance_commission_rules');
  await knex.schema.dropTableIfExists('finance_payouts');
  await knex.schema.dropTableIfExists('finance_refunds');
  await knex.schema.dropTableIfExists('finance_deposits');
}

