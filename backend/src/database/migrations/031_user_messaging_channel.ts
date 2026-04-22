import { Knex } from 'knex';

/**
 * Per-user choice of notification/messaging channel.
 *
 * Values:
 *   'default'  — fall back to the server-wide WHATSAPP_PROVIDER
 *   'whatsapp' — send via the configured WhatsApp provider (Meta/Twilio/mock)
 *   'telegram' — send via the linked Telegram chat (requires telegram_chat_id)
 *   'both'     — send via WhatsApp AND Telegram where each is available
 *   'none'     — do not send messages to this user
 *
 * NULL is treated as 'default' for backward compatibility.
 */
export async function up(knex: Knex): Promise<void> {
  const has = await knex.schema.hasColumn('users', 'preferred_messaging_channel');
  if (!has) {
    await knex.schema.alterTable('users', (table) => {
      table.string('preferred_messaging_channel', 16).nullable();
    });
    // Add a runtime CHECK constraint only if the dialect supports it.
    // Knex (Postgres) supports raw constraint creation.
    try {
      await knex.raw(`
        ALTER TABLE users
        ADD CONSTRAINT users_preferred_messaging_channel_chk
        CHECK (preferred_messaging_channel IS NULL OR preferred_messaging_channel IN
              ('default','whatsapp','telegram','both','none'))
      `);
    } catch {
      // Non-fatal: some environments don't support ALTER TABLE ADD CONSTRAINT.
    }
  }
}

export async function down(knex: Knex): Promise<void> {
  try {
    await knex.raw(
      'ALTER TABLE users DROP CONSTRAINT IF EXISTS users_preferred_messaging_channel_chk',
    );
  } catch { /* ignore */ }

  const has = await knex.schema.hasColumn('users', 'preferred_messaging_channel');
  if (has) {
    await knex.schema.alterTable('users', (table) => {
      table.dropColumn('preferred_messaging_channel');
    });
  }
}
