import request from 'supertest';
import app from '../src/server';
import db from '../src/config/database';

describe('Appointment API Tests', () => {
  let authToken: string;
  let testTenantId: string;
  let testDoctorId: string;
  let testPatientId: string;
  let testAppointmentId: string;

  beforeAll(async () => {
    // Setup test data
    const [tenant] = await db('tenants').insert({
      name: 'Test Clinic',
      email: 'test@clinic.com',
    }).returning('*');
    testTenantId = tenant.id;

    // Create test user and get auth token
    // TODO: Implement auth test helper
  });

  afterAll(async () => {
    // Cleanup test data
    await db('appointments').where({ tenant_id: testTenantId }).delete();
    await db('patients').where({ tenant_id: testTenantId }).delete();
    await db('doctors').where({ tenant_id: testTenantId }).delete();
    await db('users').where({ tenant_id: testTenantId }).delete();
    await db('tenants').where({ id: testTenantId }).delete();
    
    await db.destroy();
  });

  describe('POST /api/v1/appointments', () => {
    it('should book a new appointment', async () => {
      const appointmentData = {
        doctorId: testDoctorId,
        appointmentDate: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Tomorrow
        durationMinutes: 30,
        notes: 'Test appointment',
        isTelehealth: false,
      };

      const response = await request(app)
        .post('/api/v1/appointments')
        .set('Authorization', `Bearer ${authToken}`)
        .set('X-Tenant-ID', testTenantId)
        .send(appointmentData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data.doctor_id).toBe(testDoctorId);

      testAppointmentId = response.body.data.id;
    });

    it('should not book conflicting appointment', async () => {
      const appointmentData = {
        doctorId: testDoctorId,
        appointmentDate: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Same time
        durationMinutes: 30,
      };

      const response = await request(app)
        .post('/api/v1/appointments')
        .set('Authorization', `Bearer ${authToken}`)
        .set('X-Tenant-ID', testTenantId)
        .send(appointmentData)
        .expect(409);

      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/v1/appointments', () => {
    it('should get all appointments', async () => {
      const response = await request(app)
        .get('/api/v1/appointments')
        .set('Authorization', `Bearer ${authToken}`)
        .set('X-Tenant-ID', testTenantId)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });

  describe('DELETE /api/v1/appointments/:id', () => {
    it('should cancel appointment', async () => {
      const response = await request(app)
        .delete(`/api/v1/appointments/${testAppointmentId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .set('X-Tenant-ID', testTenantId)
        .send({ reason: 'Test cancellation' })
        .expect(200);

      expect(response.body.success).toBe(true);
    });
  });
});
