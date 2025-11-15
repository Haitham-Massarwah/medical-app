"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.seed = seed;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
async function seed(knex) {
    // Get or create default tenant
    let defaultTenant = await knex('tenants').where('email', 'admin@medical-appointments.com').first();
    if (!defaultTenant) {
        defaultTenant = await knex('tenants').first();
        if (!defaultTenant) {
            const [tenant] = await knex('tenants')
                .insert({
                name: 'Medical Appointments System',
                email: 'admin@medical-appointments.com',
                is_active: true,
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
        const hashedDeveloperPassword = await bcryptjs_1.default.hash(developerPassword, 12);
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
            is_active: true, // Ensure user is active
            created_at: new Date(),
            updated_at: new Date(),
        })
            .returning('*');
        developerUser = devUser;
        console.log('✅ Developer account created:', developerEmail);
    }
    else {
        console.log('ℹ️  Developer account already exists:', developerEmail);
    }
    // 2. Create Example User Account (Patient)
    const patientEmail = 'patient.example@medical-appointments.com';
    const patientPassword = 'Patient@123';
    let patientUser = await knex('users').where({ email: patientEmail }).first();
    if (!patientUser) {
        const hashedPatientPassword = await bcryptjs_1.default.hash(patientPassword, 12);
        const [patUser] = await knex('users')
            .insert({
            tenant_id: tenantId,
            email: patientEmail,
            password_hash: hashedPatientPassword,
            first_name: 'יוחנן',
            last_name: 'כהן',
            role: 'patient',
            preferred_language: 'he',
            is_email_verified: true,
            phone: '+972-50-1234567',
            created_at: new Date(),
            updated_at: new Date(),
        })
            .returning('*');
        patientUser = patUser;
        // Create patient profile
        await knex('patients')
            .insert({
            user_id: patUser.id,
            tenant_id: tenantId,
            emergency_contact_name: 'שרה כהן',
            emergency_contact_phone: '+972-50-7654321',
            allergies: ['פניצילין'],
            medications: [],
            created_at: new Date(),
            updated_at: new Date(),
        });
        console.log('✅ Patient account created:', patientEmail);
    }
    else {
        console.log('ℹ️  Patient account already exists:', patientEmail);
    }
    // 3. Create Example Doctor Account
    const doctorEmail = 'doctor.example@medical-appointments.com';
    const doctorPassword = 'Doctor@123';
    let doctorUser = await knex('users').where({ email: doctorEmail }).first();
    if (!doctorUser) {
        const hashedDoctorPassword = await bcryptjs_1.default.hash(doctorPassword, 12);
        const [docUser] = await knex('users')
            .insert({
            tenant_id: tenantId,
            email: doctorEmail,
            password_hash: hashedDoctorPassword,
            first_name: 'ד"ר משה',
            last_name: 'לוי',
            role: 'doctor',
            preferred_language: 'he',
            is_email_verified: true,
            phone: '+972-50-9876543',
            created_at: new Date(),
            updated_at: new Date(),
        })
            .returning('*');
        doctorUser = docUser;
        // Create doctor profile
        const [doctor] = await knex('doctors')
            .insert({
            user_id: docUser.id,
            tenant_id: tenantId,
            specialty: 'רפואה משפחתית',
            license_number: 'DOC-12345',
            bio: 'רופא משפחה מנוסה עם מעל 15 שנות ניסיון. מתמחה ברפואה כללית ורפואה מונעת.',
            languages: ['he', 'en', 'ar'],
            education: ['תואר ראשון ברפואה מאוניברסיטת תל אביב', 'תואר שני בניהול בריאות'],
            certifications: ['מומחה ברפואה משפחתית', 'מומחה בסוכרת'],
            rating: 4.8,
            review_count: 47,
            is_active: true,
            created_at: new Date(),
            updated_at: new Date(),
        })
            .returning('*');
        console.log('✅ Doctor account created:', doctorEmail);
    }
    else {
        console.log('ℹ️  Doctor account already exists:', doctorEmail);
    }
    console.log('\n📋 Account Credentials:');
    console.log('================================');
    console.log('\n👨‍💻 Developer Account:');
    console.log(`   Email: ${developerEmail}`);
    console.log(`   Password: ${developerPassword}`);
    console.log(`   Role: developer`);
    console.log(`   Status: Active`);
    console.log('\n👤 Patient Account:');
    console.log(`   Email: ${patientEmail}`);
    console.log(`   Password: ${patientPassword}`);
    console.log(`   Role: patient`);
    console.log(`   Status: Active`);
    console.log('\n👨‍⚕️ Doctor Account:');
    console.log(`   Email: ${doctorEmail}`);
    console.log(`   Password: ${doctorPassword}`);
    console.log(`   Role: doctor`);
    console.log(`   Specialty: רפואה משפחתית`);
    console.log(`   Status: Active`);
    console.log('\n================================\n');
}
//# sourceMappingURL=create_developer_accounts.js.map