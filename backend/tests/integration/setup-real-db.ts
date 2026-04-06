/**
 * Real Database Setup for Integration Tests
 * This file ensures integration tests use REAL database connection
 */

import db from '../../src/config/database';

// Verify database connection
export const verifyDatabaseConnection = async (): Promise<boolean> => {
  try {
    await db.raw('SELECT 1');
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    return false;
  }
};

// Cleanup function
export const cleanupDatabase = async (tenantId: string): Promise<void> => {
  try {
    // Delete in correct order (respecting foreign keys)
    await db('appointments').where({ tenant_id: tenantId }).delete();
    await db('doctor_sms_usage').whereIn('doctor_id', 
      db('doctors').select('id').where({ tenant_id: tenantId })
    ).delete();
    await db('doctor_sms_billing').whereIn('doctor_id',
      db('doctors').select('id').where({ tenant_id: tenantId })
    ).delete();
    await db('doctor_sms_settings').whereIn('doctor_id',
      db('doctors').select('id').where({ tenant_id: tenantId })
    ).delete();
    await db('patients').where({ tenant_id: tenantId }).delete();
    await db('doctors').where({ tenant_id: tenantId }).delete();
    await db('users').where({ tenant_id: tenantId }).delete();
    await db('tenants').where({ id: tenantId }).delete();
  } catch (error) {
    console.error('Cleanup error:', error);
  }
};

export default { verifyDatabaseConnection, cleanupDatabase };



