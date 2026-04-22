import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  const exists = await knex.schema.hasTable('user_account_permissions');
  if (exists) return;

  await knex.schema.createTable('user_account_permissions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.boolean('can_manage_users').notNullable().defaultTo(false);
    table.boolean('can_manage_doctors').notNullable().defaultTo(false);
    table.boolean('can_view_payments').notNullable().defaultTo(false);
    table.boolean('can_manage_payments').notNullable().defaultTo(false);
    table.boolean('can_manage_permissions').notNullable().defaultTo(false);
    table.timestamps(true, true);
    table.unique(['tenant_id', 'user_id']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('user_account_permissions');
}
