import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  // Create subscription_plans table
  await knex.schema.createTable('subscription_plans', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('name', 100).notNullable();
    table.text('description');
    table.decimal('price', 10, 2).notNullable();
    table.string('currency', 10).defaultTo('ILS');
    table.enum('interval', ['monthly', 'quarterly', 'yearly']).defaultTo('monthly');
    table.integer('interval_count').defaultTo(1);
    table.integer('trial_days').defaultTo(0);
    table.jsonb('features'); // List of features included in this plan
    table.integer('max_appointments_per_month').defaultTo(-1); // -1 = unlimited
    table.boolean('is_active').defaultTo(true);
    table.boolean('is_popular').defaultTo(false);
    table.integer('sort_order').defaultTo(0);
    table.string('stripe_price_id'); // Stripe Price ID
    table.string('stripe_product_id'); // Stripe Product ID
    table.timestamps(true, true);
    table.index('is_active');
  });

  // Create doctor_subscriptions table
  await knex.schema.createTable('doctor_subscriptions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.uuid('plan_id').references('id').inTable('subscription_plans').onDelete('RESTRICT');
    table.enum('status', [
      'active',
      'trialing',
      'past_due',
      'canceled',
      'unpaid',
      'incomplete',
      'incomplete_expired'
    ]).defaultTo('incomplete');
    table.string('stripe_subscription_id').unique();
    table.string('stripe_customer_id');
    table.timestamp('current_period_start');
    table.timestamp('current_period_end');
    table.timestamp('trial_start');
    table.timestamp('trial_end');
    table.timestamp('canceled_at');
    table.timestamp('ended_at');
    table.boolean('cancel_at_period_end').defaultTo(false);
    table.jsonb('metadata');
    table.timestamps(true, true);
    table.index(['doctor_id', 'status']);
    table.index(['tenant_id', 'status']);
    table.index('stripe_subscription_id');
    table.index('current_period_end');
  });

  // Create subscription_transactions table
  await knex.schema.createTable('subscription_transactions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('subscription_id').references('id').inTable('doctor_subscriptions').onDelete('CASCADE');
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.uuid('tenant_id').references('id').inTable('tenants').onDelete('CASCADE');
    table.decimal('amount', 10, 2).notNullable();
    table.string('currency', 10).defaultTo('ILS');
    table.enum('status', ['pending', 'succeeded', 'failed', 'refunded']).defaultTo('pending');
    table.enum('type', ['payment', 'refund', 'adjustment']).notNullable();
    table.string('stripe_invoice_id');
    table.string('stripe_payment_intent_id');
    table.string('stripe_charge_id');
    table.text('failure_reason');
    table.timestamp('paid_at');
    table.jsonb('invoice_data'); // Store invoice details
    table.timestamps(true, true);
    table.index(['subscription_id', 'status']);
    table.index(['doctor_id', 'created_at']);
    table.index('stripe_invoice_id');
  });

  // Add subscription-related columns to doctors table
  await knex.schema.table('doctors', (table) => {
    table.uuid('active_subscription_id').references('id').inTable('doctor_subscriptions').onDelete('SET NULL');
    table.enum('subscription_status', [
      'none',
      'active',
      'trialing',
      'past_due',
      'canceled',
      'unpaid'
    ]).defaultTo('none');
    table.timestamp('subscription_expires_at');
  });

  // Create subscription_usage table for tracking usage limits
  await knex.schema.createTable('subscription_usage', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('subscription_id').references('id').inTable('doctor_subscriptions').onDelete('CASCADE');
    table.uuid('doctor_id').references('id').inTable('doctors').onDelete('CASCADE');
    table.integer('month').notNullable(); // 1-12
    table.integer('year').notNullable(); // 2024, 2025, etc.
    table.integer('appointments_count').defaultTo(0);
    table.jsonb('metadata');
    table.timestamps(true, true);
    table.unique(['subscription_id', 'month', 'year']);
    table.index(['doctor_id', 'year', 'month']);
  });

  // Insert default subscription plans
  await knex('subscription_plans').insert([
    {
      name: 'Basic',
      description: 'Perfect for solo practitioners starting out',
      price: 99.00,
      currency: 'ILS',
      interval: 'monthly',
      interval_count: 1,
      trial_days: 14,
      max_appointments_per_month: 50,
      is_active: true,
      is_popular: false,
      sort_order: 1,
      features: JSON.stringify([
        'Up to 50 appointments per month',
        'Email notifications',
        'Basic calendar integration',
        'Patient management',
        'Mobile app access'
      ])
    },
    {
      name: 'Professional',
      description: 'For growing practices with more patients',
      price: 199.00,
      currency: 'ILS',
      interval: 'monthly',
      interval_count: 1,
      trial_days: 14,
      max_appointments_per_month: 200,
      is_active: true,
      is_popular: true,
      sort_order: 2,
      features: JSON.stringify([
        'Up to 200 appointments per month',
        'Email & SMS notifications',
        'Full calendar integration',
        'Patient management',
        'Mobile app access',
        'WhatsApp notifications',
        'Priority support',
        'Custom availability rules'
      ])
    },
    {
      name: 'Enterprise',
      description: 'For busy practices and clinics',
      price: 399.00,
      currency: 'ILS',
      interval: 'monthly',
      interval_count: 1,
      trial_days: 14,
      max_appointments_per_month: -1, // unlimited
      is_active: true,
      is_popular: false,
      sort_order: 3,
      features: JSON.stringify([
        'Unlimited appointments',
        'All notification channels',
        'Advanced calendar integration',
        'Patient management',
        'Mobile app access',
        'WhatsApp notifications',
        'Priority 24/7 support',
        'Custom availability rules',
        'Analytics dashboard',
        'Multiple staff accounts',
        'API access',
        'Custom branding'
      ])
    }
  ]);
}

export async function down(knex: Knex): Promise<void> {
  // Drop tables in reverse order
  await knex.schema.dropTableIfExists('subscription_usage');
  
  await knex.schema.table('doctors', (table) => {
    table.dropColumn('active_subscription_id');
    table.dropColumn('subscription_status');
    table.dropColumn('subscription_expires_at');
  });
  
  await knex.schema.dropTableIfExists('subscription_transactions');
  await knex.schema.dropTableIfExists('doctor_subscriptions');
  await knex.schema.dropTableIfExists('subscription_plans');
}


