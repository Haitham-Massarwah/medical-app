import { Knex } from 'knex';
import bcrypt from 'bcryptjs';

export async function seed(knex: Knex): Promise<void> {
  // Get or create default tenant
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

  // 1. Create Developer Account (Haitham)
  const developerEmail = 'haitham.massarwah@medical-appointments.com';
  const developerPassword = 'Developer@2024'; // Password for developer account
  
  let developerUser = await knex('users').where({ email: developerEmail }).first();
  
  if (!developerUser) {
    const hashedDeveloperPassword = await bcrypt.hash(developerPassword, 12);
    const [devUser] = await knex('users')
      .insert({
        tenant_id: tenantId,
        email: developerEmail,
        password_hash: hashedDeveloperPassword,
        first_name: 'Haitham',
        last_name: 'Massarwah',
        role: 'developer',
        preferred_language: 'he',
        is_email_verified: true,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    developerUser = devUser;
    console.log('✅ Developer account created:', developerEmail);
  } else {
    console.log('ℹ️  Developer account already exists:', developerEmail);
  }

  console.log('\n📋 Developer Account Credentials:');
  console.log('================================');
  console.log('\n👨‍💻 Developer Account:');
  console.log(`   Email: ${developerEmail}`);
  console.log(`   Password: ${developerPassword}`);
  console.log(`   Role: developer`);
  console.log(`   Status: Active`);
  console.log('\n================================');
  console.log('⚠️  Note: Only developer account created.');
  console.log('   All other accounts must be created through the application.');
  console.log('================================\n');
}

