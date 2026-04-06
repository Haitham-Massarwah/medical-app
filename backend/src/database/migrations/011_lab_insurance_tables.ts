import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('lab_results', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('patient_id').references('id').inTable('patients').onDelete('CASCADE');
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('SET NULL');
    table.string('lab_name', 255);
    table.string('test_name', 255).notNullable();
    table.string('result_value', 500);
    table.string('unit', 50);
    table.string('reference_range', 255);
    table.enum('status', ['pending', 'completed', 'cancelled']).defaultTo('pending');
    table.timestamp('ordered_at').defaultTo(knex.fn.now());
    table.timestamp('result_at');
    table.text('notes');
    table.timestamps(true, true);
    table.index(['tenant_id', 'patient_id']);
  });

  await knex.schema.createTable('patient_insurance', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('patient_id').references('id').inTable('patients').onDelete('CASCADE');
    table.string('provider', 255).notNullable();
    table.string('policy_number', 100);
    table.string('member_id', 100);
    table.date('effective_from');
    table.date('effective_to');
    table.jsonb('eligibility_response');
    table.timestamps(true, true);
    table.index(['tenant_id', 'patient_id']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('patient_insurance');
  await knex.schema.dropTableIfExists('lab_results');
}
