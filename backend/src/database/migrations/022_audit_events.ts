import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('audit_events', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table
      .uuid('tenant_id')
      .notNullable()
      .references('id')
      .inTable('tenants')
      .onDelete('CASCADE');
    table.uuid('actor_user_id').nullable().references('id').inTable('users').onDelete('SET NULL');
    table.string('entity_type', 120).notNullable();
    table.uuid('entity_id').nullable();
    table.string('action', 120).notNullable();
    table.text('summary').nullable();
    table.jsonb('metadata').notNullable().defaultTo('{}');
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    table.index(['tenant_id', 'created_at']);
    table.index(['entity_type', 'entity_id']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('audit_events');
}
