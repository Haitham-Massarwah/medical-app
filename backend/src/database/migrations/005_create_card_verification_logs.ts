import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('card_verification_logs', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE').nullable();
    table.string('card_last4', 4).notNullable();
    table.string('bin', 8).notNullable();
    table.string('verification_step', 50).notNullable();
    table.boolean('is_valid').notNullable();
    table.text('message').nullable();
    table.jsonb('bin_lookup').nullable();
    table.jsonb('authorization_result').nullable();
    table.integer('fraud_score').nullable();
    table.timestamp('created_at').defaultTo(knex.fn.now());
    
    // Indexes
    table.index('user_id');
    table.index('created_at');
    table.index('is_valid');
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('card_verification_logs');
}








