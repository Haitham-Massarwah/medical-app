import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('crm_leads', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('full_name', 255).notNullable();
    table.string('email', 255);
    table.string('phone', 30);
    table.string('source', 80).defaultTo('manual');
    table.string('status', 40).notNullable().defaultTo('new');
    table.text('notes');
    table.uuid('owner_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.timestamps(true, true);
    table.index(['tenant_id', 'status']);
    table.index(['tenant_id', 'owner_user_id']);
  });

  await knex.schema.createTable('crm_followups', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('lead_id').references('id').inTable('crm_leads').onDelete('CASCADE');
    table.string('channel', 30).notNullable().defaultTo('sms'); // sms/email/whatsapp/call
    table.text('message').notNullable();
    table.timestamp('due_at');
    table.timestamp('completed_at');
    table.string('status', 30).notNullable().defaultTo('pending');
    table.uuid('created_by_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.timestamps(true, true);
    table.index(['tenant_id', 'lead_id']);
    table.index(['tenant_id', 'status']);
  });

  await knex.schema.createTable('communication_templates', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('name', 120).notNullable();
    table.string('channel', 30).notNullable().defaultTo('sms');
    table.string('subject', 255);
    table.text('body').notNullable();
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamps(true, true);
    table.index(['tenant_id', 'channel']);
    table.index(['tenant_id', 'is_active']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('communication_templates');
  await knex.schema.dropTableIfExists('crm_followups');
  await knex.schema.dropTableIfExists('crm_leads');
}

