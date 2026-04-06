import { Knex } from 'knex';

/**
 * SRS Rev 02 §2.1: allow `receptionist` in users.role.
 * - If role is a PostgreSQL enum (Knex-created installs), add the new label.
 * - If role is `text` (common in evolved DBs), no DDL is required.
 */
export async function up(knex: Knex): Promise<void> {
  const r = await knex.raw(`
    SELECT data_type, udt_name
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'users'
      AND column_name = 'role'
  `);
  const row = (r as { rows: Array<{ data_type: string; udt_name: string }> }).rows[0];
  if (!row || row.data_type !== 'USER-DEFINED') {
    return;
  }
  const typeName = String(row.udt_name).replace(/[^a-z0-9_]/gi, '');
  if (!/^[a-z][a-z0-9_]*$/i.test(typeName)) {
    throw new Error(`Refusing unsafe enum type name: ${row.udt_name}`);
  }
  await knex.raw(`
    DO $do$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_enum e
        INNER JOIN pg_type t ON e.enumtypid = t.oid
        WHERE t.typname = '${typeName}' AND e.enumlabel = 'receptionist'
      ) THEN
        EXECUTE format('ALTER TYPE %I ADD VALUE %L', '${typeName}', 'receptionist');
      END IF;
    END
    $do$;
  `);
}

export async function down(): Promise<void> {
  // PostgreSQL does not support removing enum values safely; intentional no-op.
}
