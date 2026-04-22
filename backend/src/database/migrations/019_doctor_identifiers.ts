import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  const hasBusinessId = await knex.schema.hasColumn('doctors', 'business_file_id');
  const hasPrimaryType = await knex.schema.hasColumn('doctors', 'primary_identifier_type');
  const hasPrimaryValue = await knex.schema.hasColumn('doctors', 'primary_identifier_value');

  await knex.schema.alterTable('doctors', (table) => {
    if (!hasBusinessId) table.string('business_file_id', 32);
    if (!hasPrimaryType) table.string('primary_identifier_type', 32);
    if (!hasPrimaryValue) table.string('primary_identifier_value', 64);
  });
}

export async function down(knex: Knex): Promise<void> {
  const hasBusinessId = await knex.schema.hasColumn('doctors', 'business_file_id');
  const hasPrimaryType = await knex.schema.hasColumn('doctors', 'primary_identifier_type');
  const hasPrimaryValue = await knex.schema.hasColumn('doctors', 'primary_identifier_value');

  await knex.schema.alterTable('doctors', (table) => {
    if (hasBusinessId) table.dropColumn('business_file_id');
    if (hasPrimaryType) table.dropColumn('primary_identifier_type');
    if (hasPrimaryValue) table.dropColumn('primary_identifier_value');
  });
}
