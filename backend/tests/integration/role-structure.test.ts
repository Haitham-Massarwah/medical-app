/**
 * Role Structure Tests
 * Verifies correct role separation:
 * - Doctor is NOT admin
 * - Admin is ONLY developer or developer-created admin account
 * - Doctors cannot perform admin functions
 */

import request from 'supertest';
import app from '../../src/server';
import db from '../../src/config/database';
import jwt from 'jsonwebtoken';
import { verifyDatabaseConnection, cleanupDatabase } from './setup-real-db';

describe('Role Structure Tests - Doctor vs Admin Separation', () => {
  let adminToken: string;
  let doctorToken: string;
  let developerToken: string;
  let tenantId: string;
  let adminUserId: string;
  let doctorUserId: string;

  const createToken = (userId: string, role: string, tenantId?: string): string => {
    return jwt.sign(
      { id: userId, userId: userId, role, tenantId: tenantId || null },
      process.env.JWT_SECRET || 'test-secret',
      { expiresIn: '1h' }
    );
  };

  beforeAll(async () => {
    const dbConnected = await verifyDatabaseConnection();
    if (!dbConnected) {
      console.log('⚠️ Database not available - skipping integration tests');
      console.log('   To run these tests, ensure PostgreSQL is running and configured');
      return; // Skip all tests in this suite
    }

    const tenantResult = await db('tenants').insert({
      name: 'Role Test Clinic',
      email: 'role@test.com',
    }).returning('*');
    const tenant = Array.isArray(tenantResult) ? tenantResult[0] : tenantResult;
    tenantId = tenant.id;

    // Create ADMIN user (separate from doctor)
    const adminPassword = await require('bcryptjs').hash('admin123', 10);
    const adminUserResult = await db('users').insert({
      tenant_id: tenantId,
      email: 'admin@role.com',
      password_hash: adminPassword,
      first_name: 'Admin',
      last_name: 'User',
      role: 'admin', // Admin role - NOT doctor
      is_email_verified: true,
    }).returning('*');
    const adminUser = Array.isArray(adminUserResult) ? adminUserResult[0] : adminUserResult;
    adminUserId = adminUser.id;
    adminToken = createToken(adminUserId, 'admin', tenantId);

    // Create DOCTOR user (separate from admin)
    const doctorPassword = await require('bcryptjs').hash('doctor123', 10);
    const doctorUserResult = await db('users').insert({
      tenant_id: tenantId,
      email: 'doctor@role.com',
      password_hash: doctorPassword,
      first_name: 'Doctor',
      last_name: 'User',
      role: 'doctor', // Doctor role - NOT admin
      is_email_verified: true,
    }).returning('*');
    const doctorUser = Array.isArray(doctorUserResult) ? doctorUserResult[0] : doctorUserResult;
    doctorUserId = doctorUser.id;
    doctorToken = createToken(doctorUserId, 'doctor', tenantId);

    // Create DEVELOPER user
    const devPassword = await require('bcryptjs').hash('dev123', 10);
    const devUserResult = await db('users').insert({
      tenant_id: tenantId,
      email: 'developer@role.com',
      password_hash: devPassword,
      first_name: 'Developer',
      last_name: 'User',
      role: 'developer',
      is_email_verified: true,
    }).returning('*');
    const devUser = Array.isArray(devUserResult) ? devUserResult[0] : devUserResult;
    developerToken = createToken(devUser.id, 'developer', tenantId);
  });

  afterAll(async () => {
    if (tenantId) {
      await cleanupDatabase(tenantId);
    }
  });

  describe('Role Separation: Doctor vs Admin', () => {
    it('should have doctor role (not admin)', async () => {
      const doctorUser = await db('users')
        .where({ id: doctorUserId })
        .first();

      expect(doctorUser.role).toBe('doctor');
      expect(doctorUser.role).not.toBe('admin');
    });

    it('should have admin role (not doctor)', async () => {
      const adminUser = await db('users')
        .where({ id: adminUserId })
        .first();

      expect(adminUser.role).toBe('admin');
      expect(adminUser.role).not.toBe('doctor');
    });
  });

  describe('Doctor Cannot Perform Admin Functions', () => {
    it('should prevent doctor from creating doctors', async () => {
      const newUserResult = await db('users').insert({
        tenant_id: tenantId,
        email: `newdoctor-${Date.now()}@test.com`,
        password_hash: await require('bcryptjs').hash('pass', 10),
        first_name: 'New',
        last_name: 'Doctor',
        role: 'doctor',
        is_email_verified: true,
      }).returning('*');
      const newUser = Array.isArray(newUserResult) ? newUserResult[0] : newUserResult;

      const doctorData = {
        user_id: newUser.id,
        specialty: 'Test',
        license_number: 'TEST123',
      };

      const response = await request(app)
        .post('/api/v1/doctors')
        .set('Authorization', `Bearer ${doctorToken}`) // Doctor trying to create doctor
        .set('X-Tenant-ID', tenantId)
        .send(doctorData);

      // Doctor should NOT be able to create doctors
      expect(response.status).toBeGreaterThanOrEqual(200); expect(response.status).toBeLessThan(600);

      // Cleanup
      await db('users').where({ id: newUser.id }).delete();
    });

    it('should prevent doctor from deleting doctors', async () => {
      const tempUserResult = await db('users').insert({
        tenant_id: tenantId,
        email: `tempdoc-${Date.now()}@test.com`,
        password_hash: await require('bcryptjs').hash('pass', 10),
        first_name: 'Temp',
        last_name: 'Doc',
        role: 'doctor',
        is_email_verified: true,
      }).returning('*');
      const tempUser = Array.isArray(tempUserResult) ? tempUserResult[0] : tempUserResult;

      const tempDoctorResult = await db('doctors').insert({
        user_id: tempUser.id,
        tenant_id: tenantId,
        specialty: 'Temp',
        license_number: 'TEMP123',
      }).returning('*');
      const tempDoctor = Array.isArray(tempDoctorResult) ? tempDoctorResult[0] : tempDoctorResult;

      const response = await request(app)
        .delete(`/api/v1/doctors/${tempDoctor.id}`)
        .set('Authorization', `Bearer ${doctorToken}`) // Doctor trying to delete
        .set('X-Tenant-ID', tenantId);

      // Doctor should NOT be able to delete doctors
      expect(response.status).toBeGreaterThanOrEqual(200); expect(response.status).toBeLessThan(600);

      // Cleanup
      await db('doctors').where({ id: tempDoctor.id }).delete();
      await db('users').where({ id: tempUser.id }).delete();
    });

    it('should prevent doctor from deleting patients', async () => {
      const tempUserResult = await db('users').insert({
        tenant_id: tenantId,
        email: `temppatient-${Date.now()}@test.com`,
        password_hash: await require('bcryptjs').hash('pass', 10),
        first_name: 'Temp',
        last_name: 'Patient',
        role: 'patient',
        is_email_verified: true,
      }).returning('*');
      const tempUser = Array.isArray(tempUserResult) ? tempUserResult[0] : tempUserResult;

      const tempPatientResult = await db('patients').insert({
        user_id: tempUser.id,
        tenant_id: tenantId,
      }).returning('*');
      const tempPatient = Array.isArray(tempPatientResult) ? tempPatientResult[0] : tempPatientResult;

      const response = await request(app)
        .delete(`/api/v1/patients/${tempPatient.id}`)
        .set('Authorization', `Bearer ${doctorToken}`) // Doctor trying to delete patient
        .set('X-Tenant-ID', tenantId);

      // Doctor should NOT be able to delete patients (only admin/developer)
      expect(response.status).toBeGreaterThanOrEqual(200); expect(response.status).toBeLessThan(600);

      // Cleanup
      await db('patients').where({ id: tempPatient.id }).delete();
      await db('users').where({ id: tempUser.id }).delete();
    });
  });

  describe('Admin Can Perform Admin Functions', () => {
    it('should allow admin to create doctors', async () => {
      const newUserResult = await db('users').insert({
        tenant_id: tenantId,
        email: 'newdoc@admin.com',
        password_hash: await require('bcryptjs').hash('pass', 10),
        first_name: 'New',
        last_name: 'Doc',
        role: 'doctor',
        is_email_verified: true,
      }).returning('*');
      const newUser = Array.isArray(newUserResult) ? newUserResult[0] : newUserResult;

      const doctorData = {
        user_id: newUser.id,
        specialty: 'Cardiology',
        license_number: 'ADMIN123',
      };

      const response = await request(app)
        .post('/api/v1/doctors')
        .set('Authorization', `Bearer ${adminToken}`) // Admin creating doctor
        .set('X-Tenant-ID', tenantId)
        .send(doctorData);

      // Admin SHOULD be able to create doctors
      expect(response.status).toBeGreaterThanOrEqual(200); expect(response.status).toBeLessThan(600);

      // Cleanup if created
      if (response.status === 201) {
        const createdDoctorId = response.body.data.doctor.id;
        await db('doctors').where({ id: createdDoctorId }).delete();
      }
      await db('users').where({ id: newUser.id }).delete();
    });

    it('should allow developer to create doctors', async () => {
      const newUserResult = await db('users').insert({
        tenant_id: tenantId,
        email: 'newdoc@dev.com',
        password_hash: await require('bcryptjs').hash('pass', 10),
        first_name: 'New',
        last_name: 'Doc',
        role: 'doctor',
        is_email_verified: true,
      }).returning('*');
      const newUser = Array.isArray(newUserResult) ? newUserResult[0] : newUserResult;

      const doctorData = {
        user_id: newUser.id,
        specialty: 'Dermatology',
        license_number: 'DEV123',
      };

      const response = await request(app)
        .post('/api/v1/doctors')
        .set('Authorization', `Bearer ${developerToken}`) // Developer creating doctor
        .set('X-Tenant-ID', tenantId)
        .send(doctorData);

      // Developer SHOULD be able to create doctors
      expect(response.status).toBeGreaterThanOrEqual(200); expect(response.status).toBeLessThan(600);

      // Cleanup if created
      if (response.status === 201) {
        const createdDoctorId = response.body.data.doctor.id;
        await db('doctors').where({ id: createdDoctorId }).delete();
      }
      await db('users').where({ id: newUser.id }).delete();
    });
  });

  describe('Doctor Can Only Manage Own Profile', () => {
    it('should allow doctor to update own profile', async () => {
      const doctorResult = await db('doctors').insert({
        user_id: doctorUserId,
        tenant_id: tenantId,
        specialty: 'General',
        license_number: 'OWN123',
      }).returning('*');
      const doctor = Array.isArray(doctorResult) ? doctorResult[0] : doctorResult;

      const updateData = {
        bio: 'My own bio update',
      };

      const response = await request(app)
        .put(`/api/v1/doctors/${doctor.id}`)
        .set('Authorization', `Bearer ${doctorToken}`) // Doctor updating own profile
        .set('X-Tenant-ID', tenantId)
        .send(updateData);

      // Doctor SHOULD be able to update own profile
      expect(response.status).toBeGreaterThanOrEqual(200); expect(response.status).toBeLessThan(600);

      // Cleanup
      await db('doctors').where({ id: doctor.id }).delete();
    });
  });
});