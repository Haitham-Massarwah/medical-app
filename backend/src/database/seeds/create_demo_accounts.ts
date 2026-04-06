import { Knex } from 'knex';
import bcrypt from 'bcryptjs';
import * as fs from 'fs';
import * as path from 'path';

/**
 * Creates demo accounts from configuration
 * Use with caution when running against real data
 */
export async function seed(knex: Knex): Promise<void> {
  // Load demo accounts from environment config
  const nodeEnv = process.env.NODE_ENV || 'development';
  const configFile =
    nodeEnv === 'production' ? 'production.config.json' : 'development.config.json';
  const configPath = path.join(__dirname, '../../../config', configFile);
  let config: any;
  
  try {
    const configContent = fs.readFileSync(configPath, 'utf-8');
    config = JSON.parse(configContent);
  } catch (error) {
    console.error('❌ Failed to load development config:', error);
    return;
  }

  if (!config.demoAccounts?.enabled) {
    console.log('ℹ️  Demo accounts are disabled in configuration');
    return;
  }

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

  console.log('\n🎭 Creating Demo Accounts (Development Only)...');
  console.log('================================================\n');

  // Create demo accounts from config
  for (const accountConfig of config.demoAccounts.accounts) {
    const { email, password, role, firstName, lastName, ...profileData } = accountConfig;
    
    let user = await knex('users').where({ email }).first();
    const hashedPassword = await bcrypt.hash(password, 12);

    if (!user) {
      const [newUser] = await knex('users')
        .insert({
          tenant_id: tenantId,
          email,
          password_hash: hashedPassword,
          first_name: firstName,
          last_name: lastName,
          role,
          preferred_language: 'he',
          is_email_verified: true,
          phone: profileData.phone || null,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');
      
      user = newUser;
      console.log(`✅ Demo ${role} account created: ${email}`);
    } else {
      await knex('users')
        .where({ id: user.id })
        .update({
          password_hash: hashedPassword,
          first_name: firstName,
          last_name: lastName,
          role,
          phone: profileData.phone || user.phone,
          updated_at: new Date(),
        });
      console.log(`♻️  Demo ${role} account updated: ${email}`);
    }

    // Ensure role-specific profiles exist
    if (role === 'doctor' && profileData.specialty) {
      const doctor = await knex('doctors').where({ user_id: user.id }).first();
      if (!doctor) {
        await knex('doctors')
          .insert({
            user_id: user.id,
            tenant_id: tenantId,
            specialty: profileData.specialty,
            license_number: profileData.licenseNumber || `DEMO-${role.toUpperCase()}-${Date.now()}`,
            bio: `חשבון דמו למטרות פיתוח - ${profileData.specialty}`,
            languages: ['he', 'en'],
            education: [],
            rating: 0,
            review_count: 0,
            created_at: new Date(),
            updated_at: new Date(),
          });
      }
    } else if (role === 'patient') {
      const patient = await knex('patients').where({ user_id: user.id }).first();
      if (!patient) {
        await knex('patients')
          .insert({
            user_id: user.id,
            tenant_id: tenantId,
            emergency_contact_name: null,
            emergency_contact_phone: null,
            allergies: [],
            medications: [],
            created_at: new Date(),
            updated_at: new Date(),
          });
      }
    }
  }

  console.log('\n================================================');
  console.log('📋 Demo Account Credentials:');
  console.log('================================================');
  
  for (const accountConfig of config.demoAccounts.accounts) {
    console.log(`\n${accountConfig.role === 'doctor' ? '👨‍⚕️' : '👤'} ${accountConfig.role.toUpperCase()}:`);
    console.log(`   Email: ${accountConfig.email}`);
    console.log(`   Password: ${accountConfig.password}`);
  }
  
  console.log('\n================================================');
  console.log('⚠️  Demo accounts created/updated from configuration');
  console.log('================================================\n');
}

