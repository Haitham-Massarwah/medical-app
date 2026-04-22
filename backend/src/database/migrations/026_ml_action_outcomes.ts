import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('ml_action_outcomes', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('appointment_id').notNullable().references('id').inTable('appointments').onDelete('CASCADE');
    table
      .uuid('prediction_id')
      .references('id')
      .inTable('appointment_no_show_predictions')
      .onDelete('SET NULL')
      .nullable();
    table.string('action_type', 50).notNullable();
    table.timestamp('action_time').notNullable().defaultTo(knex.fn.now());
    table.string('message_kind', 30).nullable();
    table.string('twilio_sid', 64).nullable();
    table.string('to_phone_tail', 8).nullable();
    table.string('outcome', 50).nullable();
    table.timestamp('outcome_time').nullable();
    table.jsonb('details_json').notNullable().defaultTo('{}');
    table.timestamps(true, true);
    table.index(['tenant_id', 'appointment_id']);
    table.index(['tenant_id', 'action_time']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('ml_action_outcomes');
}
