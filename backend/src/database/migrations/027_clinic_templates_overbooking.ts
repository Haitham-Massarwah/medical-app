import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('clinic_file_templates', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.string('template_type', 30).notNullable();
    table.string('name', 255).notNullable();
    table.text('description');
    table.string('storage_path', 512).notNullable();
    table.string('original_filename', 255).notNullable();
    table.string('mime_type', 120);
    table.integer('file_size').notNullable().defaultTo(0);
    table.uuid('created_by').references('id').inTable('users').onDelete('SET NULL').nullable();
    table.timestamps(true, true);
    table.index(['tenant_id', 'template_type']);
  });

  await knex.schema.createTable('doctor_template_assignments', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('doctor_id').notNullable().references('id').inTable('doctors').onDelete('CASCADE');
    table
      .uuid('template_id')
      .notNullable()
      .references('id')
      .inTable('clinic_file_templates')
      .onDelete('CASCADE');
    table.timestamps(true, true);
    table.unique(['doctor_id', 'template_id']);
    table.index(['tenant_id', 'doctor_id']);
  });

  await knex.schema.createTable('no_show_overbooking_rules', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').notNullable().references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE').nullable();
    table.decimal('risk_threshold', 6, 5).notNullable().defaultTo(0.7);
    table.integer('max_extra_slots').notNullable().defaultTo(1);
    table.boolean('is_enabled').notNullable().defaultTo(false);
    table.timestamps(true, true);
    table.index(['tenant_id', 'doctor_id']);
  });

  await knex.raw(`
    CREATE UNIQUE INDEX IF NOT EXISTS ux_overbooking_tenant_default
    ON no_show_overbooking_rules (tenant_id)
    WHERE doctor_id IS NULL
  `);
  await knex.raw(`
    CREATE UNIQUE INDEX IF NOT EXISTS ux_overbooking_doctor
    ON no_show_overbooking_rules (tenant_id, doctor_id)
    WHERE doctor_id IS NOT NULL
  `);
}

export async function down(knex: Knex): Promise<void> {
  await knex.raw('DROP INDEX IF EXISTS ux_overbooking_tenant_default');
  await knex.raw('DROP INDEX IF EXISTS ux_overbooking_doctor');
  await knex.schema.dropTableIfExists('no_show_overbooking_rules');
  await knex.schema.dropTableIfExists('doctor_template_assignments');
  await knex.schema.dropTableIfExists('clinic_file_templates');
}
