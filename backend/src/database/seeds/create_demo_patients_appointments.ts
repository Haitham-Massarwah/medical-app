import { Knex } from 'knex';
import bcrypt from 'bcryptjs';

/**
 * Creates demo patients, appointments, and messages for the demo doctor account
 * This seed adds realistic data to doctor.example@medical-appointments.com
 */
export async function seed(knex: Knex): Promise<void> {
  // Get demo doctor
  const demoDoctor = await knex('users')
    .where('email', 'doctor.example@medical-appointments.com')
    .first();

  if (!demoDoctor) {
    console.log('⚠️  Demo doctor not found. Run create_demo_accounts seed first.');
    return;
  }

  const doctorId = await knex('doctors')
    .where('user_id', demoDoctor.id)
    .select('id')
    .first();

  if (!doctorId) {
    console.log('⚠️  Demo doctor profile not found.');
    return;
  }

  const tenantId = demoDoctor.tenant_id;

  console.log('\n👥 Creating Demo Patients, Appointments, and Messages...');
  console.log('================================================\n');

  // Create demo patients
  const demoPatients = [
    {
      email: 'patient1.demo@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'יוסי',
      lastName: 'כהן',
      phone: '+972-50-1234567',
    },
    {
      email: 'patient2.demo@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'שרה',
      lastName: 'לוי',
      phone: '+972-50-2345678',
    },
    {
      email: 'patient3.demo@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'דוד',
      lastName: 'ישראלי',
      phone: '+972-50-3456789',
    },
    {
      email: 'patient4.demo@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'רחל',
      lastName: 'אברהם',
      phone: '+972-50-4567890',
    },
    {
      email: 'patient5.demo@medical-appointments.com',
      password: 'Patient@123',
      firstName: 'משה',
      lastName: 'כהן',
      phone: '+972-50-5678901',
    },
  ];

  const createdPatients: any[] = [];

  for (const patientData of demoPatients) {
    let user = await knex('users').where('email', patientData.email).first();
    const hashedPassword = await bcrypt.hash(patientData.password, 12);

    if (!user) {
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
    }

    let patient = await knex('patients').where('user_id', user.id).first();
    if (!patient) {
      const [newPatient] = await knex('patients')
        .insert({
          user_id: user.id,
          tenant_id: tenantId,
          emergency_contact_name: null,
          emergency_contact_phone: null,
          allergies: [],
          medications: [],
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');
      patient = newPatient;
    }

    createdPatients.push({ user, patient });
    console.log(`✅ Created/Updated patient: ${patientData.firstName} ${patientData.lastName}`);
  }

  // Create appointments for the demo doctor
  const now = new Date();
  
  // Helper function to create appointment date with time
  const createAppointmentDate = (daysOffset: number, time: string): Date => {
    const date = new Date(now);
    date.setDate(date.getDate() + daysOffset);
    const [hours, minutes] = time.split(':').map(Number);
    date.setHours(hours, minutes, 0, 0);
    return date;
  };

  const appointments = [
    {
      tenant_id: tenantId,
      doctor_id: doctorId.id,
      patient_id: createdPatients[0].patient.id,
      appointment_date: createAppointmentDate(2, '10:00'), // 2 days from now at 10:00
      duration_minutes: 30,
      status: 'scheduled',
      notes: 'ביקור שגרתי',
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      tenant_id: tenantId,
      doctor_id: doctorId.id,
      patient_id: createdPatients[1].patient.id,
      appointment_date: createAppointmentDate(3, '14:00'), // 3 days from now at 14:00
      duration_minutes: 45,
      status: 'scheduled',
      notes: 'מעקב אחר טיפול',
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      tenant_id: tenantId,
      doctor_id: doctorId.id,
      patient_id: createdPatients[2].patient.id,
      appointment_date: createAppointmentDate(5, '11:30'), // 5 days from now at 11:30
      duration_minutes: 30,
      status: 'scheduled',
      notes: 'ביקור ראשון',
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      tenant_id: tenantId,
      doctor_id: doctorId.id,
      patient_id: createdPatients[0].patient.id,
      appointment_date: createAppointmentDate(-7, '09:00'), // 7 days ago at 09:00
      duration_minutes: 30,
      status: 'completed',
      notes: 'ביקור הושלם בהצלחה',
      created_at: new Date(now.getTime() - 8 * 24 * 60 * 60 * 1000),
      updated_at: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
    },
    {
      tenant_id: tenantId,
      doctor_id: doctorId.id,
      patient_id: createdPatients[3].patient.id,
      appointment_date: createAppointmentDate(-3, '15:00'), // 3 days ago at 15:00
      duration_minutes: 45,
      status: 'completed',
      notes: 'מעקב תקין',
      created_at: new Date(now.getTime() - 4 * 24 * 60 * 60 * 1000),
      updated_at: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000),
    },
  ];

  for (const appointment of appointments) {
    const existing = await knex('appointments')
      .where({
        doctor_id: appointment.doctor_id,
        patient_id: appointment.patient_id,
        appointment_date: appointment.appointment_date,
      })
      .first();

    if (!existing) {
      await knex('appointments').insert(appointment);
      console.log(`✅ Created appointment for patient ${appointment.patient_id}`);
    }
  }

  // Create messages/notifications for the demo doctor
  // Note: type field is for delivery method (email, sms, whatsapp, push)
  // Category is stored in data jsonb field
  const messages = [
    {
      user_id: demoDoctor.id,
      tenant_id: tenantId,
      type: 'push', // Delivery method
      title: 'תזכורת תור',
      message: 'יש לך תור מחר בשעה 10:00 עם יוסי כהן',
      is_read: false,
      status: 'sent',
      data: { category: 'appointment_reminder' },
      created_at: new Date(),
      updated_at: new Date(),
    },
    {
      user_id: demoDoctor.id,
      tenant_id: tenantId,
      type: 'push',
      title: 'אישור תור',
      message: 'שרה לוי אישרה את התור ב-14:00',
      is_read: false,
      status: 'sent',
      data: { category: 'appointment_confirmation' },
      created_at: new Date(now.getTime() - 1 * 60 * 60 * 1000), // 1 hour ago
      updated_at: new Date(now.getTime() - 1 * 60 * 60 * 1000),
    },
    {
      user_id: demoDoctor.id,
      tenant_id: tenantId,
      type: 'email',
      title: 'עדכון מערכת',
      message: 'המערכת עודכנה בהצלחה. כל התכונות זמינות כעת.',
      is_read: true,
      status: 'sent',
      data: { category: 'system' },
      created_at: new Date(now.getTime() - 24 * 60 * 60 * 1000), // 1 day ago
      updated_at: new Date(now.getTime() - 24 * 60 * 60 * 1000),
    },
    {
      user_id: demoDoctor.id,
      tenant_id: tenantId,
      type: 'push',
      title: 'תשלום התקבל',
      message: 'תשלום של ₪150 התקבל עבור תור של דוד ישראלי',
      is_read: false,
      status: 'sent',
      data: { category: 'payment' },
      created_at: new Date(now.getTime() - 2 * 60 * 60 * 1000), // 2 hours ago
      updated_at: new Date(now.getTime() - 2 * 60 * 60 * 1000),
    },
    {
      user_id: demoDoctor.id,
      tenant_id: tenantId,
      type: 'push',
      title: 'ביטול תור',
      message: 'משה כהן ביטל את התור שהיה מתוכנן למחר',
      is_read: false,
      status: 'sent',
      data: { category: 'appointment_cancellation' },
      created_at: new Date(now.getTime() - 3 * 60 * 60 * 1000), // 3 hours ago
      updated_at: new Date(now.getTime() - 3 * 60 * 60 * 1000),
    },
  ];

  for (const message of messages) {
    const existing = await knex('notifications')
      .where({
        user_id: message.user_id,
        title: message.title,
        message: message.message,
      })
      .first();

    if (!existing) {
      await knex('notifications').insert(message);
      console.log(`✅ Created notification: ${message.title}`);
    }
  }

  console.log('\n================================================');
  console.log('✅ Demo data created successfully!');
  console.log('================================================\n');
}
