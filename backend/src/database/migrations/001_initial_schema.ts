import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  // Create tenants table
  await knex.schema.createTable('tenants', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('name', 255).notNullable();
    table.text('description');
    table.string('logo_url');
    table.string('website');
    table.string('email').unique();
    table.string('phone', 20);
    table.text('address');
    table.string('city', 100);
    table.string('country', 100);
    table.string('timezone', 50).defaultTo('Asia/Jerusalem');
    table.string('currency', 10).defaultTo('ILS');
    table.string('language', 10).defaultTo('he');
    table.jsonb('settings');
    table.boolean('is_active').defaultTo(true);
    table.timestamps(true, true);
    table.index('email');
    table.index('is_active');
  });

  // Create users table
  await knex.schema.createTable('users', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('email', 255).notNullable();
    table.string('password_hash').notNullable();
    table.string('first_name', 100).notNullable();
    table.string('last_name', 100).notNullable();
    table.string('phone', 20);
    table.string('profile_image_url');
    table.enum('role', ['developer', 'admin', 'doctor', 'paramedical', 'patient']).notNullable();
    table.string('preferred_language', 10).defaultTo('he');
    table.boolean('is_email_verified').defaultTo(false);
    table.boolean('is_two_factor_enabled').defaultTo(false);
    table.string('two_factor_secret');
    table.jsonb('preferences');
    table.jsonb('metadata');
    table.timestamp('last_login_at');
    table.integer('login_attempts').defaultTo(0);
    table.timestamp('locked_until');
    table.timestamps(true, true);
    table.unique(['tenant_id', 'email']);
    table.index(['tenant_id', 'role']);
    table.index('email');
  });

  // Create doctors table
  await knex.schema.createTable('doctors', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE').unique();
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('specialty', 100).notNullable();
    table.string('license_number', 100);
    table.text('education');
    table.specificType('languages', 'text[]').defaultTo('{"he"}');
    table.text('bio');
    table.decimal('rating', 3, 2).defaultTo(0);
    table.integer('review_count').defaultTo(0);
    table.boolean('is_active').defaultTo(true);
    table.timestamps(true, true);
    table.index(['tenant_id', 'specialty']);
    table.index('is_active');
  });

  // Create services table
  await knex.schema.createTable('services', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('name', 255).notNullable();
    table.text('description');
    table.integer('duration_minutes').notNullable();
    table.decimal('price', 10, 2).notNullable();
    table.string('currency', 10).defaultTo('ILS');
    table.boolean('is_active').defaultTo(true);
    table.timestamps(true, true);
    table.index(['tenant_id', 'doctor_id']);
  });

  // Create availability table
  await knex.schema.createTable('availability', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.integer('day_of_week').notNullable(); // 0=Sunday, 6=Saturday
    table.time('start_time').notNullable();
    table.time('end_time').notNullable();
    table.boolean('is_active').defaultTo(true);
    table.timestamps(true, true);
    table.index(['tenant_id', 'doctor_id', 'day_of_week']);
  });

  // Create availability_exceptions table
  await knex.schema.createTable('availability_exceptions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.date('date').notNullable();
    table.time('start_time');
    table.time('end_time');
    table.enum('type', ['blocked', 'available']).notNullable();
    table.string('reason');
    table.timestamps(true, true);
    table.index(['tenant_id', 'doctor_id', 'date']);
  });

  // Create patients table
  await knex.schema.createTable('patients', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE').unique();
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('emergency_contact_name', 255);
    table.string('emergency_contact_phone', 20);
    table.specificType('allergies', 'text[]').defaultTo('{}');
    table.specificType('medications', 'text[]').defaultTo('{}');
    table.string('insurance_provider');
    table.string('insurance_number');
    table.jsonb('medical_history');
    table.timestamps(true, true);
    table.index(['tenant_id', 'user_id']);
  });

  // Create appointments table
  await knex.schema.createTable('appointments', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('patient_id').references('id').inTable('patients').onDelete('CASCADE');
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('service_id').references('id').inTable('services').onDelete('SET NULL');
    table.timestamp('appointment_date').notNullable();
    table.integer('duration_minutes').notNullable();
    table.enum('status', ['scheduled', 'confirmed', 'completed', 'cancelled', 'no_show', 'rescheduled']).defaultTo('scheduled');
    table.text('notes');
    table.string('location');
    table.boolean('is_telehealth').defaultTo(false);
    table.string('telehealth_link');
    table.string('cancellation_reason');
    table.timestamp('cancelled_at');
    table.uuid('cancelled_by');
    table.timestamps(true, true);
    table.index(['tenant_id', 'patient_id']);
    table.index(['tenant_id', 'doctor_id', 'appointment_date']);
    table.index(['status', 'appointment_date']);
  });

  // Create payments table
  await knex.schema.createTable('payments', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('appointment_id').references('id').inTable('appointments').onDelete('CASCADE');
    table.uuid('patient_id').references('id').inTable('patients').onDelete('CASCADE');
    table.decimal('amount', 10, 2).notNullable();
    table.string('currency', 10).defaultTo('ILS');
    table.enum('status', ['pending', 'completed', 'failed', 'refunded']).defaultTo('pending');
    table.enum('method', ['credit_card', 'debit_card', 'bank_transfer', 'cash']).notNullable();
    table.string('transaction_id').unique();
    table.string('payment_intent_id');
    table.text('failure_reason');
    table.decimal('refund_amount', 10, 2);
    table.timestamp('refunded_at');
    table.timestamps(true, true);
    table.index(['tenant_id', 'appointment_id']);
    table.index(['patient_id', 'status']);
  });

  // Create medical_records table
  await knex.schema.createTable('medical_records', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('patient_id').references('id').inTable('patients').onDelete('CASCADE');
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('appointment_id').references('id').inTable('appointments').onDelete('SET NULL');
    table.string('title', 255).notNullable();
    table.text('description').notNullable();
    table.date('record_date').notNullable();
    table.text('diagnosis');
    table.text('treatment');
    table.specificType('attachments', 'text[]').defaultTo('{}');
    table.timestamps(true, true);
    table.index(['tenant_id', 'patient_id']);
    table.index('record_date');
  });

  // Create notifications table
  await knex.schema.createTable('notifications', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.string('title', 255).notNullable();
    table.text('message').notNullable();
    table.enum('type', ['email', 'sms', 'whatsapp', 'push']).notNullable();
    table.boolean('is_read').defaultTo(false);
    table.jsonb('data');
    table.timestamp('read_at');
    table.timestamp('sent_at');
    table.enum('status', ['pending', 'sent', 'failed']).defaultTo('pending');
    table.timestamps(true, true);
    table.index(['tenant_id', 'user_id', 'is_read']);
    table.index(['status', 'created_at']);
  });

  // Create audit_logs table
  await knex.schema.createTable('audit_logs', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('user_id').references('id').inTable('users').onDelete('SET NULL');
    table.string('action', 100).notNullable();
    table.string('entity_type', 100).notNullable();
    table.uuid('entity_id');
    table.jsonb('old_values');
    table.jsonb('new_values');
    table.string('ip_address', 45);
    table.string('user_agent');
    table.timestamp('created_at').defaultTo(knex.fn.now());
    table.index(['tenant_id', 'user_id', 'created_at']);
    table.index(['entity_type', 'entity_id']);
  });

  // Create reviews table
  await knex.schema.createTable('reviews', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('patient_id').references('id').inTable('patients').onDelete('CASCADE');
    table.uuid('appointment_id').references('id').inTable('appointments').onDelete('CASCADE');
    table.integer('rating').notNullable(); // 1-5
    table.text('comment');
    table.timestamps(true, true);
    table.index(['tenant_id', 'doctor_id']);
    table.unique(['appointment_id', 'patient_id']);
  });

  // Create cancellation_policies table
  await knex.schema.createTable('cancellation_policies', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.string('name', 255).notNullable();
    table.text('description');
    table.integer('hours_before').notNullable();
    table.decimal('penalty_percentage', 5, 2).defaultTo(0);
    table.decimal('penalty_fixed_amount', 10, 2).defaultTo(0);
    table.boolean('is_active').defaultTo(true);
    table.timestamps(true, true);
    table.index(['tenant_id', 'is_active']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('cancellation_policies');
  await knex.schema.dropTableIfExists('reviews');
  await knex.schema.dropTableIfExists('audit_logs');
  await knex.schema.dropTableIfExists('notifications');
  await knex.schema.dropTableIfExists('medical_records');
  await knex.schema.dropTableIfExists('payments');
  await knex.schema.dropTableIfExists('appointments');
  await knex.schema.dropTableIfExists('patients');
  await knex.schema.dropTableIfExists('availability_exceptions');
  await knex.schema.dropTableIfExists('availability');
  await knex.schema.dropTableIfExists('services');
  await knex.schema.dropTableIfExists('doctors');
  await knex.schema.dropTableIfExists('users');
  await knex.schema.dropTableIfExists('tenants');
}
