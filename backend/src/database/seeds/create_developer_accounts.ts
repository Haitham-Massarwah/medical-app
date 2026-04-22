import { Knex } from 'knex';
import bcrypt from 'bcryptjs';

/**
 * Developer + admin accounts for local/testing.
 * Emails are stored lowercase so login (which lowercases) always matches one canonical row.
 * Updates every user row whose email matches case-insensitively (fixes duplicate-casing issues).
 */
export async function seed(knex: Knex): Promise<void> {
  let defaultTenant = await knex('tenants').where('email', 'admin@medical-appointments.com').first();

  if (!defaultTenant) {
    defaultTenant = await knex('tenants').first();

    if (!defaultTenant) {
      const [tenant] = await knex('tenants')
        .insert({
          name: 'Medical Appointments System',
          email: 'admin@medical-appointments.com',
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');
      defaultTenant = tenant;
    }
  }

  const tenantId = defaultTenant.id;

  const developerEmail = 'haitham.massarwah@medical-appointments.com';
  const adminEmail = 'admin@medical-appointments.com';
  const sharedPassword = 'Haitham@0412';

  const hashDev = await bcrypt.hash(sharedPassword, 12);
  const hashAdmin = await bcrypt.hash(sharedPassword, 12);

  async function ensureStaffUser(
    canonicalEmail: string,
    passwordHash: string,
    role: 'developer' | 'admin',
    firstName: string,
    lastName: string
  ): Promise<void> {
    const rows = await knex('users').whereRaw('LOWER(email) = ?', [canonicalEmail]);

    if (rows.length === 0) {
      await knex('users').insert({
        tenant_id: tenantId,
        email: canonicalEmail,
        password_hash: passwordHash,
        first_name: firstName,
        last_name: lastName,
        role,
        preferred_language: 'he',
        is_email_verified: true,
        created_at: new Date(),
        updated_at: new Date(),
      });
      console.log(`✅ ${role} account created: ${canonicalEmail}`);
      return;
    }

    const updated = await knex('users')
      .whereRaw('LOWER(email) = ?', [canonicalEmail])
      .update({
        email: canonicalEmail,
        password_hash: passwordHash,
        role,
        first_name: firstName,
        last_name: lastName,
        is_email_verified: true,
        updated_at: new Date(),
      });

    if (rows.length > 1) {
      console.warn(
        `⚠️  Merged ${rows.length} user rows for ${canonicalEmail} (case-duplicate fix). Updated ${updated} row(s).`
      );
    } else {
      console.log(`♻️  ${role} account updated: ${canonicalEmail}`);
    }
  }

  await ensureStaffUser(developerEmail, hashDev, 'developer', 'Haitham', 'Massarwah');
  await ensureStaffUser(adminEmail, hashAdmin, 'admin', 'System', 'Admin');

  console.log('\n📋 Admin/Developer Credentials (login with lowercase email):');
  console.log('================================');
  console.log(`   Developer: ${developerEmail} / ${sharedPassword}`);
  console.log(`   Admin:     ${adminEmail} / ${sharedPassword}`);
  console.log('================================\n');
}
