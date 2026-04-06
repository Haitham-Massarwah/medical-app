import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('calendar_tokens', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable();
    table.enu('provider', ['google', 'outlook']).notNullable();
    table.text('access_token').notNullable();
    table.text('refresh_token').nullable();
    table.timestamp('expires_at').nullable();
    table.timestamps(true, true);

    // Foreign key constraint
    table.foreign('user_id').references('id').inTable('users').onDelete('CASCADE');
    
    // Unique constraint: one token per user per provider
    table.unique(['user_id', 'provider']);
    
    // Index for faster lookups
    table.index(['user_id', 'provider']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('calendar_tokens');
}





