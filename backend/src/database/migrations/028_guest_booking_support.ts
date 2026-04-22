import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  const hasGuestName = await knex.schema.hasColumn('appointments', 'guest_name');
  const hasGuestPhone = await knex.schema.hasColumn('appointments', 'guest_phone');
  const hasGuestEmail = await knex.schema.hasColumn('appointments', 'guest_email');
  const hasGuestId = await knex.schema.hasColumn('appointments', 'guest_id_number');

  await knex.schema.alterTable('appointments', (table) => {
    if (!hasGuestName) table.string('guest_name', 255).nullable();
    if (!hasGuestPhone) table.string('guest_phone', 40).nullable();
    if (!hasGuestEmail) table.string('guest_email', 255).nullable();
    if (!hasGuestId) table.string('guest_id_number', 32).nullable();
  });

  // Allow guest bookings where no pre-registered patient row exists.
  await knex.raw('ALTER TABLE appointments ALTER COLUMN patient_id DROP NOT NULL');
}

export async function down(knex: Knex): Promise<void> {
  const hasGuestName = await knex.schema.hasColumn('appointments', 'guest_name');
  const hasGuestPhone = await knex.schema.hasColumn('appointments', 'guest_phone');
  const hasGuestEmail = await knex.schema.hasColumn('appointments', 'guest_email');
  const hasGuestId = await knex.schema.hasColumn('appointments', 'guest_id_number');

  await knex.schema.alterTable('appointments', (table) => {
    if (hasGuestName) table.dropColumn('guest_name');
    if (hasGuestPhone) table.dropColumn('guest_phone');
    if (hasGuestEmail) table.dropColumn('guest_email');
    if (hasGuestId) table.dropColumn('guest_id_number');
  });
}
