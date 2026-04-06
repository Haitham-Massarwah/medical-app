import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.table('medical_records', (table) => {
    table.boolean('is_draft').notNullable().defaultTo(false);
    table.string('record_type', 50);
    table.string('summary_format', 20).defaultTo('markdown');
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.table('medical_records', (table) => {
    table.dropColumn('summary_format');
    table.dropColumn('record_type');
    table.dropColumn('is_draft');
  });
}
