import { Knex } from 'knex';

/**
 * Migration: Doctor SMS Service Settings
 * Allows doctors to opt-in to SMS service and pay for their own messages
 */
export async function up(knex: Knex): Promise<void> {
  // Create doctor_sms_settings table
  await knex.schema.createTable('doctor_sms_settings', (table: Knex.TableBuilder) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE').unique();
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    
    // SMS Service Settings
    table.boolean('sms_enabled').defaultTo(false).notNullable();
    table.decimal('sms_cost_per_message', 10, 4); // Calculated dynamically: Twilio price × multiplier
    table.decimal('twilio_base_cost', 10, 4).defaultTo(0.0075).notNullable(); // Twilio base cost per SMS (USD)
    table.decimal('price_multiplier', 10, 4).defaultTo(1.5).notNullable(); // Multiplier for markup (1.5 = 50% markup)
    table.decimal('discount_percentage', 5, 2).defaultTo(0).notNullable(); // Discount percentage (0-100), e.g., 10 for 10% discount
    table.boolean('has_discount').defaultTo(false).notNullable(); // Flag to enable/disable discount
    table.string('currency', 3).defaultTo('ILS').notNullable(); // Israeli Shekel
    
    // Billing Settings
    table.enum('billing_method', ['prepaid', 'postpaid', 'monthly']).defaultTo('prepaid').notNullable();
    table.decimal('prepaid_balance', 10, 2).defaultTo(0).notNullable();
    table.decimal('monthly_limit', 10, 2); // Optional monthly spending limit
    table.boolean('auto_recharge').defaultTo(false).notNullable();
    table.decimal('auto_recharge_amount', 10, 2); // Amount to recharge when balance is low
    table.decimal('low_balance_threshold', 10, 2).defaultTo(5.00); // Alert when balance below this
    
    // Notification Preferences
    table.boolean('send_appointment_reminders').defaultTo(true).notNullable();
    table.boolean('send_appointment_confirmations').defaultTo(true).notNullable();
    table.boolean('send_appointment_cancellations').defaultTo(true).notNullable();
    table.boolean('send_payment_receipts').defaultTo(true).notNullable();
    
    // Custom Message Templates (JSONB - stores templates per language and type)
    table.jsonb('custom_templates').defaultTo('{}'); // { "he": { "reminder": "...", "confirmation": "..." }, "ar": {...}, "en": {...} }
    
    // Status
    table.boolean('is_active').defaultTo(true).notNullable();
    table.timestamp('activated_at');
    table.timestamp('deactivated_at');
    
    table.timestamps(true, true);
    
    table.index(['doctor_id', 'sms_enabled']);
    table.index(['tenant_id', 'sms_enabled']);
    table.index('is_active');
  });

  // Create doctor_sms_usage table for tracking SMS sent
  await knex.schema.createTable('doctor_sms_usage', (table: Knex.TableBuilder) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('appointment_id').references('id').inTable('appointments').onDelete('SET NULL');
    
    // SMS Details
    table.string('to_phone', 20).notNullable();
    table.text('message').notNullable();
    table.enum('sms_type', ['reminder', 'confirmation', 'cancellation', 'payment', 'verification', 'general']).notNullable();
    
    // Twilio Details
    table.string('twilio_message_sid');
    table.string('twilio_status', 50);
    table.decimal('cost', 10, 4).notNullable();
    table.string('currency', 3).defaultTo('USD').notNullable();
    
    // Status
    table.boolean('sent_successfully').defaultTo(false).notNullable();
    table.text('error_message');
    
    table.timestamp('sent_at').defaultTo(knex.fn.now());
    table.timestamps(true, true);
    
    table.index(['doctor_id', 'sent_at']);
    table.index(['tenant_id', 'sent_at']);
    table.index('twilio_message_sid');
    table.index('sms_type');
  });

  // Create doctor_sms_billing table for billing records
  await knex.schema.createTable('doctor_sms_billing', (table: Knex.TableBuilder) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    
    // Billing Details
    table.enum('billing_type', ['recharge', 'usage', 'refund', 'adjustment']).notNullable();
    table.decimal('amount', 10, 2).notNullable();
    table.string('currency', 3).defaultTo('USD').notNullable();
    table.decimal('balance_before', 10, 2).notNullable();
    table.decimal('balance_after', 10, 2).notNullable();
    
    // Payment Details (if recharge)
    table.string('payment_method'); // 'stripe', 'credit_card', 'bank_transfer', etc.
    table.string('payment_reference'); // Stripe payment intent ID, transaction ID, etc.
    table.enum('payment_status', ['pending', 'completed', 'failed', 'refunded']).defaultTo('pending');
    
    // Description
    table.text('description');
    table.jsonb('metadata'); // Additional data (SMS count, period, etc.)
    
    table.timestamp('billing_date').defaultTo(knex.fn.now());
    table.timestamps(true, true);
    
    table.index(['doctor_id', 'billing_date']);
    table.index(['tenant_id', 'billing_date']);
    table.index('payment_status');
    table.index('billing_type');
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('doctor_sms_billing');
  await knex.schema.dropTableIfExists('doctor_sms_usage');
  await knex.schema.dropTableIfExists('doctor_sms_settings');
}

