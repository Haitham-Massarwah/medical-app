import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('receipt_templates', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('owner_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.string('template_scope', 30).notNullable().defaultTo('clinic'); // global, clinic, personal
    table.string('template_name', 255).notNullable();
    table.text('description');
    table.string('content_format', 30).notNullable().defaultTo('html'); // html, json, markdown
    table.text('template_content').notNullable();
    table.boolean('is_default').notNullable().defaultTo(false);
    table.boolean('is_active').notNullable().defaultTo(true);
    table.uuid('created_by').references('id').inTable('users').onDelete('SET NULL');
    table.uuid('updated_by').references('id').inTable('users').onDelete('SET NULL');
    table.timestamps(true, true);
    table.index(['tenant_id', 'template_scope']);
    table.index(['tenant_id', 'is_active']);
  });

  await knex.schema.createTable('report_templates', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('owner_user_id').references('id').inTable('users').onDelete('SET NULL');
    table.string('template_scope', 30).notNullable().defaultTo('clinic'); // clinic, personal
    table.string('template_name', 255).notNullable();
    table.text('description');
    table.string('content_format', 30).notNullable().defaultTo('html');
    table.text('template_content').notNullable();
    table.boolean('is_default').notNullable().defaultTo(false);
    table.boolean('is_active').notNullable().defaultTo(true);
    table.uuid('created_by').references('id').inTable('users').onDelete('SET NULL');
    table.uuid('updated_by').references('id').inTable('users').onDelete('SET NULL');
    table.timestamps(true, true);
    table.index(['tenant_id', 'template_scope']);
    table.index(['tenant_id', 'is_active']);
  });

  await knex.schema.createTable('employees', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('user_id').references('id').inTable('users').onDelete('SET NULL');
    table.string('employee_code', 100);
    table.string('job_title', 100);
    table.string('employment_type', 50); // full_time, part_time, contractor
    table.date('start_date');
    table.date('end_date');
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamps(true, true);
    table.unique(['tenant_id', 'user_id']);
    table.index(['tenant_id', 'is_active']);
  });

  await knex.schema.createTable('employee_work_hours', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('employee_id').notNullable().references('id').inTable('employees').onDelete('CASCADE');
    table.date('work_date').notNullable();
    table.timestamp('check_in_time');
    table.timestamp('check_out_time');
    table.integer('break_minutes').notNullable().defaultTo(0);
    table.integer('total_minutes');
    table.text('notes');
    table.uuid('recorded_by').references('id').inTable('users').onDelete('SET NULL');
    table.timestamps(true, true);
    table.unique(['tenant_id', 'employee_id', 'work_date']);
    table.index(['tenant_id', 'work_date']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('employee_work_hours');
  await knex.schema.dropTableIfExists('employees');
  await knex.schema.dropTableIfExists('report_templates');
  await knex.schema.dropTableIfExists('receipt_templates');
}

