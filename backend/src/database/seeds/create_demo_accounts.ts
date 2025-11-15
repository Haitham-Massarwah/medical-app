import { Knex } from 'knex';
import bcrypt from 'bcryptjs';
import * as fs from 'fs';
import * as path from 'path';

/**
 * Creates demo accounts ONLY in development environment
 * This seed file should NEVER be run in production
 */
export async function seed(knex: Knex): Promise<void> {
  // Check environment - only allow in development
  const nodeEnv = process.env.NODE_ENV || 'development';
  
  if (nodeEnv === 'production') {
    console.log('⚠️  Demo accounts seed skipped - Production environment detected');
    console.log('   Demo accounts are only created in development environment');
    return;
  }

  // Load demo accounts from config
  const configPath = path.join(__dirname, '../../../config/development.config.json');
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
    
    if (!user) {
      const hashedPassword = await bcrypt.hash(password, 12);
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

      // Create role-specific profiles
      if (role === 'doctor' && profileData.specialty) {
        await knex('doctors')
          .insert({
            user_id: newUser.id,
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
      } else if (role === 'patient') {
        await knex('patients')
          .insert({
            user_id: newUser.id,
            tenant_id: tenantId,
            emergency_contact_name: null,
            emergency_contact_phone: null,
            allergies: [],
            medications: [],
            created_at: new Date(),
            updated_at: new Date(),
          });
      }

      console.log(`✅ Demo ${role} account created: ${email}`);
    } else {
      console.log(`ℹ️  Demo ${role} account already exists: ${email}`);
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
  console.log('⚠️  These accounts exist ONLY in development environment');
  console.log('================================================\n');
}

