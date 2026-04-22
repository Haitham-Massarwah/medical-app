import { Knex } from 'knex';

/**
 * Telegram Bot linking for appointment notifications.
 *
 *   users.telegram_chat_id          Long integer as text; Telegram chat ID of
 *                                   the user. NULL until the user taps the
 *                                   /start deep-link on the bot.
 *   users.telegram_username         Optional @handle captured during /start
 *                                   (display only; never used for routing).
 *   users.telegram_linked_at        UTC timestamp of successful binding.
 *
 *   telegram_link_tokens            One-time opaque tokens passed in the
 *                                   deep-link t.me/<bot>?start=<token> to let
 *                                   the bot bind a user to a chat without
 *                                   credentials. Short-lived.
 */
export async function up(knex: Knex): Promise<void> {
  const hasChatId     = await knex.schema.hasColumn('users', 'telegram_chat_id');
  const hasUsername   = await knex.schema.hasColumn('users', 'telegram_username');
  const hasLinkedAt   = await knex.schema.hasColumn('users', 'telegram_linked_at');

  await knex.schema.alterTable('users', (table) => {
    if (!hasChatId)   table.string('telegram_chat_id', 64).nullable().index('users_telegram_chat_id_idx');
    if (!hasUsername) table.string('telegram_username', 64).nullable();
    if (!hasLinkedAt) table.timestamp('telegram_linked_at', { useTz: true }).nullable();
  });

  const hasTokens = await knex.schema.hasTable('telegram_link_tokens');
  if (!hasTokens) {
    await knex.schema.createTable('telegram_link_tokens', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      table.string('token', 64).notNullable().unique();
      table.timestamp('expires_at', { useTz: true }).notNullable();
      table.timestamp('consumed_at', { useTz: true }).nullable();
      table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
      table.index(['user_id'], 'telegram_link_tokens_user_id_idx');
    });
  }
}

export async function down(knex: Knex): Promise<void> {
  const hasTokens = await knex.schema.hasTable('telegram_link_tokens');
  if (hasTokens) await knex.schema.dropTable('telegram_link_tokens');

  const hasChatId     = await knex.schema.hasColumn('users', 'telegram_chat_id');
  const hasUsername   = await knex.schema.hasColumn('users', 'telegram_username');
  const hasLinkedAt   = await knex.schema.hasColumn('users', 'telegram_linked_at');

  await knex.schema.alterTable('users', (table) => {
    if (hasChatId)   table.dropColumn('telegram_chat_id');
    if (hasUsername) table.dropColumn('telegram_username');
    if (hasLinkedAt) table.dropColumn('telegram_linked_at');
  });
}
