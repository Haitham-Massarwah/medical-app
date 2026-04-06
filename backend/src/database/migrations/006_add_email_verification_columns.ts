import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  // Add email verification columns to users table
  await knex.schema.table('users', (table) => {
    table.string('email_verification_token', 64).nullable();
    table.timestamp('email_verification_expiry').nullable();
    table.string('password_reset_token', 64).nullable();
    table.timestamp('password_reset_expiry').nullable();
  });

  // Add index for faster lookups
  await knex.schema.table('users', (table) => {
    table.index('email_verification_token');
    table.index('password_reset_token');
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.table('users', (table) => {
    table.dropIndex('password_reset_token');
    table.dropIndex('email_verification_token');
    table.dropColumn('password_reset_expiry');
    table.dropColumn('password_reset_token');
    table.dropColumn('email_verification_expiry');
    table.dropColumn('email_verification_token');
  });
}








