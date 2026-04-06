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
  const developerPassword = 'Haitham@0412'; // Password for developer account
  
  let developerUser = await knex('users').where({ email: developerEmail }).first();
  
  const hashedDeveloperPassword = await bcrypt.hash(developerPassword, 12);
  if (!developerUser) {
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
    await knex('users')
      .where({ id: developerUser.id })
      .update({
        password_hash: hashedDeveloperPassword,
        updated_at: new Date(),
      });
    console.log('♻️  Developer account updated:', developerEmail);
  }

  // 2. Create Admin Account
  const adminEmail = 'Admin@medical-appointments.com';
  const adminPassword = 'Haitham@0412';
  
  let adminUser = await knex('users').where({ email: adminEmail }).first();
  
  const hashedAdminPassword = await bcrypt.hash(adminPassword, 12);
  if (!adminUser) {
    const [newAdmin] = await knex('users')
      .insert({
        tenant_id: tenantId,
        email: adminEmail,
        password_hash: hashedAdminPassword,
        first_name: 'System',
        last_name: 'Admin',
        role: 'admin',
        preferred_language: 'he',
        is_email_verified: true,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');
    adminUser = newAdmin;
    console.log('✅ Admin account created:', adminEmail);
  } else {
    await knex('users')
      .where({ id: adminUser.id })
      .update({
        password_hash: hashedAdminPassword,
        updated_at: new Date(),
      });
    console.log('♻️  Admin account updated:', adminEmail);
  }

  console.log('\n📋 Admin/Developer Credentials:');
  console.log('================================');
  console.log('\n👨‍💻 Developer Account:');
  console.log(`   Email: ${developerEmail}`);
  console.log(`   Password: ${developerPassword}`);
  console.log(`   Role: developer`);
  console.log(`   Status: Active`);
  console.log('\n🛡️ Admin Account:');
  console.log(`   Email: ${adminEmail}`);
  console.log(`   Password: ${adminPassword}`);
  console.log(`   Role: admin`);
  console.log(`   Status: Active`);
  console.log('\n================================\n');
}

