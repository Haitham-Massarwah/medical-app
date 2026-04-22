import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  const hasPerm = await knex.schema.hasColumn('user_account_permissions', 'can_view_audit');
  if (!hasPerm) {
    await knex.schema.alterTable('user_account_permissions', (table) => {
      table.boolean('can_view_audit').notNullable().defaultTo(true);
    });
  }

  const hasBranding = await knex.schema.hasColumn('doctors', 'pdf_branding');
  if (!hasBranding) {
    await knex.schema.alterTable('doctors', (table) => {
      table.jsonb('pdf_branding').notNullable().defaultTo('{}');
    });
  }
}

export async function down(knex: Knex): Promise<void> {
  const hasPerm = await knex.schema.hasColumn('user_account_permissions', 'can_view_audit');
  if (hasPerm) {
    await knex.schema.alterTable('user_account_permissions', (table) => {
      table.dropColumn('can_view_audit');
    });
  }
  const hasBranding = await knex.schema.hasColumn('doctors', 'pdf_branding');
  if (hasBranding) {
    await knex.schema.alterTable('doctors', (table) => {
      table.dropColumn('pdf_branding');
    });
  }
}
