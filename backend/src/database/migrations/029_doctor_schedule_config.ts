import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  const hasDoctorBreaks = await knex.schema.hasTable('doctor_breaks');
  if (!hasDoctorBreaks) {
    await knex.schema.createTable('doctor_breaks', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('doctor_id').notNullable().references('id').inTable('doctors').onDelete('CASCADE');
      table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
      table.integer('day_of_week').notNullable(); // 0-6
      table.time('start_time').notNullable();
      table.time('end_time').notNullable();
      table.boolean('is_active').notNullable().defaultTo(true);
      table.timestamps(true, true);
      table.index(['tenant_id', 'doctor_id', 'day_of_week']);
    });
  }

  const hasDoctorTimeOff = await knex.schema.hasTable('doctor_time_off');
  if (!hasDoctorTimeOff) {
    await knex.schema.createTable('doctor_time_off', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('doctor_id').notNullable().references('id').inTable('doctors').onDelete('CASCADE');
      table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
      table.date('start_date').notNullable();
      table.date('end_date').notNullable();
      table.boolean('is_holiday').notNullable().defaultTo(false);
      table.string('reason', 255);
      table.timestamps(true, true);
      table.index(['tenant_id', 'doctor_id', 'start_date']);
    });
  }
}

export async function down(knex: Knex): Promise<void> {
  const hasDoctorTimeOff = await knex.schema.hasTable('doctor_time_off');
  if (hasDoctorTimeOff) {
    await knex.schema.dropTable('doctor_time_off');
  }

  const hasDoctorBreaks = await knex.schema.hasTable('doctor_breaks');
  if (hasDoctorBreaks) {
    await knex.schema.dropTable('doctor_breaks');
  }
}

