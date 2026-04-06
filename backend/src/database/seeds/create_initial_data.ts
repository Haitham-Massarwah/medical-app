import { Knex } from 'knex';
import bcrypt from 'bcryptjs';

/**
 * Creates initial development data: 5 doctors and 5 patients
 * This seed file creates real data for development/testing
 */
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

  console.log('\n📊 Creating Initial Development Data...');
  console.log('================================================\n');

  // 5 Doctors with real data
  const doctors = [
    {
      email: 'doctor1@medical-appointments.com',
      password: 'Doctor@123',
      firstName: 'ד"ר יוסף',
      lastName: 'כהן',
      phone: '+972-50-1234567',
      specialty: 'רפואה משפחתית',
      licenseNumber: 'DOC-001',
      bio: 'רופא משפחה מנוסה עם מעל 20 שנות ניסיון. מתמחה ברפואה כללית ורפואה מונעת.',
      languages: ['he', 'en', 'ar'],
      education: 'תואר ראשון ברפואה מאוניברסיטת תל אביב',
      rating: 4.8,
      reviewCount: 47,
    },
    {
      email: 'doctor2@medical-appointments.com',
      password: 'Doctor@123',
      firstName: 'ד"ר שרה',
      lastName: 'לוי',
      phone: '+972-50-2345678',
      specialty: 'קרדיולוגיה',
      licenseNumber: 'DOC-002',
      bio: 'קרדיולוגית מומחית עם התמחות במחלות לב וכלי דם. ניסיון של 15 שנים.',
      languages: ['he', 'en'],
      education: 'תואר ראשון ברפואה מאוניברסיטת העברית, התמחות בקרדיולוגיה',
      rating: 4.9,
      reviewCount: 62,
    },
    {
      email: 'doctor3@medical-appointments.com',
      password: 'Doctor@123',
      firstName: 'ד"ר דוד',
      lastName: 'מזרחי',
      phone: '+972-50-3456789',
      specialty: 'רפואת ילדים',
      licenseNumber: 'DOC-003',
      bio: 'רופא ילדים מומחה עם ניסיון רב בטיפול בילדים מכל הגילאים.',
      languages: ['he', 'ar'],
      education: 'תואר ראשון ברפואה מאוניברסיטת בן גוריון, התמחות ברפואת ילדים',
      rating: 4.7,
      reviewCount: 38,
    },
    {
      email: 'doctor4@medical-appointments.com',
      password: 'Doctor@123',
      firstName: 'ד"ר רחל',
      lastName: 'אברהם',
      phone: '+972-50-4567890',
      specialty: 'גינקולוגיה',
      licenseNumber: 'DOC-004',
      bio: 'גינקולוגית מומחית עם ניסיון של 18 שנים. מתמחה בבריאות האישה.',
      languages: ['he', 'en', 'ru'],
      education: 'תואר ראשון ברפואה מאוניברסיטת תל אביב, התמחות בגינקולוגיה',
      rating: 4.8,
      reviewCount: 55,
    },
    {
      email: 'doctor5@medical-appointments.com',
      password: 'Doctor@123',
      firstName: 'ד"ר משה',
      lastName: 'בן דוד',
      phone: '+972-50-5678901',
      specialty: 'אורתופדיה',
      licenseNumber: 'DOC-005',
      bio: 'אורתופד מומחה עם התמחות בניתוחי עמוד שדרה. ניסיון של 12 שנים.',
      languages: ['he', 'en'],
      education: 'תואר ראשון ברפואה מאוניברסיטת תל אביב, התמחות באורתופדיה',
      rating: 4.6,
      reviewCount: 41,
    },
  ];

  // 5 Patients with real data
  const patients = [
    {
      email: 'patient1@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'אבי',
      lastName: 'כהן',
      phone: '+972-52-1111111',
    },
    {
      email: 'patient2@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'מיכל',
      lastName: 'לוי',
      phone: '+972-52-2222222',
    },
    {
      email: 'patient3@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'יוסי',
      lastName: 'מזרחי',
      phone: '+972-52-3333333',
    },
    {
      email: 'patient4@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'תמר',
      lastName: 'אברהם',
      phone: '+972-52-4444444',
    },
    {
      email: 'patient5@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'דני',
      lastName: 'בן דוד',
      phone: '+972-52-5555555',
    },
  ];

  // Create doctors
  for (const doctorData of doctors) {
    let user = await knex('users').where({ email: doctorData.email }).first();
    
    if (!user) {
      const hashedPassword = await bcrypt.hash(doctorData.password, 12);
      const [newUser] = await knex('users')
        .insert({
          tenant_id: tenantId,
          email: doctorData.email,
          password_hash: hashedPassword,
          first_name: doctorData.firstName,
          last_name: doctorData.lastName,
          role: 'doctor',
          preferred_language: 'he',
          is_email_verified: true,
          phone: doctorData.phone,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');
      
      user = newUser;

      await knex('doctors')
        .insert({
          user_id: newUser.id,
          tenant_id: tenantId,
          specialty: doctorData.specialty,
          license_number: doctorData.licenseNumber,
          bio: doctorData.bio,
          languages: doctorData.languages,
          education: doctorData.education,
          rating: doctorData.rating,
          review_count: doctorData.reviewCount,
          is_active: true,
          created_at: new Date(),
          updated_at: new Date(),
        });

      console.log(`✅ Doctor created: ${doctorData.email}`);
    } else {
      console.log(`ℹ️  Doctor already exists: ${doctorData.email}`);
    }
  }

  // Create patients
  for (const patientData of patients) {
    let user = await knex('users').where({ email: patientData.email }).first();
    
    if (!user) {
      const hashedPassword = await bcrypt.hash(patientData.password, 12);
      const [newUser] = await knex('users')
        .insert({
          tenant_id: tenantId,
          email: patientData.email,
          password_hash: hashedPassword,
          first_name: patientData.firstName,
          last_name: patientData.lastName,
          role: 'patient',
          preferred_language: 'he',
          is_email_verified: true,
          phone: patientData.phone,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');
      
      user = newUser;

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

      console.log(`✅ Patient created: ${patientData.email}`);
    } else {
      console.log(`ℹ️  Patient already exists: ${patientData.email}`);
    }
  }

  console.log('\n================================================');
  console.log('📋 Initial Data Created:');
  console.log('================================================');
  console.log('\n👨‍⚕️ Doctors (5):');
  doctors.forEach((doc, idx) => {
    console.log(`   ${idx + 1}. ${doc.email} / ${doc.password}`);
  });
  console.log('\n👤 Patients (5):');
  patients.forEach((pat, idx) => {
    console.log(`   ${idx + 1}. ${pat.email} / ${pat.password}`);
  });
  console.log('\n================================================\n');
}


