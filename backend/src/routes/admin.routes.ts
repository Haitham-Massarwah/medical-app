import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth.middleware';
import db from '../config/database';

const router = Router();

/**
 * Database Admin Interface Routes
 * Accessible only to developers/admins
 * Provides secure access to view and manage database data
 */

// Middleware: All admin routes require authentication and developer/admin role
router.use(authenticate);
router.use(authorize('developer', 'admin'));

/**
 * GET /api/v1/admin/database/stats
 * Get database statistics
 */
router.get('/database/stats', async (req, res) => {
  try {
    const stats = {
      users: await db('users').count('id as count').first(),
      doctors: await db('doctors').count('id as count').first(),
      patients: await db('patients').count('id as count').first(),
      appointments: await db('appointments').count('id as count').first(),
      tenants: await db('tenants').count('id as count').first(),
      subscriptions: await db('doctor_subscriptions').count('id as count').first(),
    };

    res.json({
      success: true,
      data: stats,
      timestamp: new Date().toISOString(),
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch database statistics',
      error: error.message,
    });
  }
});

/**
 * GET /api/v1/admin/database/users
 * Get all users with pagination
 */
router.get('/database/users', async (req, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = (page - 1) * limit;
    const role = req.query.role as string;

    let query = db('users')
      .select(
        'users.id',
        'users.email',
        'users.first_name',
        'users.last_name',
        'users.role',
        'users.is_email_verified',
        'users.created_at',
        'users.updated_at'
      )
      .orderBy('users.created_at', 'desc')
      .limit(limit)
      .offset(offset);

    if (role) {
      query = query.where('users.role', role);
    }

    const users = await query;
    const total = await db('users').count('id as count').first();

    res.json({
      success: true,
      data: users,
      pagination: {
        page,
        limit,
        total: Number(total?.count || 0),
        totalPages: Math.ceil(Number(total?.count || 0) / limit),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
      error: error.message,
    });
  }
});

/**
 * GET /api/v1/admin/database/appointments
 * Get all appointments with pagination
 */
router.get('/database/appointments', async (req, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = (page - 1) * limit;

    const appointments = await db('appointments')
      .select(
        'appointments.*',
        db.raw("TRIM(CONCAT(COALESCE(patient_users.first_name, ''), ' ', COALESCE(patient_users.last_name, ''))) as patient_name"),
        db.raw("TRIM(CONCAT(COALESCE(doctor_users.first_name, ''), ' ', COALESCE(doctor_users.last_name, ''))) as doctor_name"),
        'doctors.specialty as specialty'
      )
      .leftJoin('patients', 'appointments.patient_id', 'patients.id')
      .leftJoin('users as patient_users', 'patients.user_id', 'patient_users.id')
      .leftJoin('doctors', 'appointments.doctor_id', 'doctors.id')
      .leftJoin('users as doctor_users', 'doctors.user_id', 'doctor_users.id')
      .orderBy('appointments.appointment_date', 'desc')
      .limit(limit)
      .offset(offset);

    const total = await db('appointments').count('id as count').first();

    res.json({
      success: true,
      data: appointments,
      pagination: {
        page,
        limit,
        total: Number(total?.count || 0),
        totalPages: Math.ceil(Number(total?.count || 0) / limit),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch appointments',
      error: error.message,
    });
  }
});

/**
 * GET /api/v1/admin/database/doctors
 * Get all doctors with details
 */
router.get('/database/doctors', async (req, res) => {
  try {
    const doctors = await db('doctors')
      .select(
        'doctors.*',
        'users.email',
        'users.first_name',
        'users.last_name',
        'users.phone',
        'users.is_email_verified'
      )
      .leftJoin('users', 'doctors.user_id', 'users.id')
      .orderBy('doctors.created_at', 'desc');

    res.json({
      success: true,
      data: doctors,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch doctors',
      error: error.message,
    });
  }
});

/**
 * GET /api/v1/admin/database/patients
 * Get all patients with details
 */
router.get('/database/patients', async (req, res) => {
  try {
    const patients = await db('patients')
      .select(
        'patients.*',
        'users.email',
        'users.first_name',
        'users.last_name',
        'users.phone',
        'users.is_email_verified'
      )
      .leftJoin('users', 'patients.user_id', 'users.id')
      .orderBy('patients.created_at', 'desc');

    res.json({
      success: true,
      data: patients,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch patients',
      error: error.message,
    });
  }
});

/**
 * DELETE /api/v1/admin/database/users/:id
 * Delete a user (with safety checks)
 */
router.delete('/database/users/:id', async (req, res) => {
  try {
    const userId = parseInt(req.params.id);
    const currentUser = (req as any).user;

    // Prevent self-deletion
    if (userId === currentUser.id) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete your own account',
      });
    }

    // Check if user exists
    const user = await db('users').where('id', userId).first();
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Prevent deletion of developer accounts
    if (user.role === 'developer') {
      return res.status(403).json({
        success: false,
        message: 'Cannot delete developer accounts',
      });
    }

    // Delete user (cascade will handle related records)
    await db('users').where('id', userId).delete();

    res.json({
      success: true,
      message: 'User deleted successfully',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete user',
      error: error.message,
    });
  }
});

/**
 * GET /api/v1/admin/activity-logs
 * Get system activity logs
 */
router.get('/activity-logs', async (req, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 100;
    const offset = (page - 1) * limit;

    const logs = await db('activity_logs')
      .select('*')
      .orderBy('created_at', 'desc')
      .limit(limit)
      .offset(offset);

    const total = await db('activity_logs').count('id as count').first();

    res.json({
      success: true,
      data: logs,
      pagination: {
        page,
        limit,
        total: Number(total?.count || 0),
        totalPages: Math.ceil(Number(total?.count || 0) / limit),
      },
    });
  } catch (error: any) {
    // If activity_logs table doesn't exist, return empty array
    res.json({
      success: true,
      data: [],
      pagination: {
        page: 1,
        limit: 100,
        total: 0,
        totalPages: 0,
      },
    });
  }
});

/**
 * Permissions routes
 */
import { PermissionsController } from '../controllers/permissions.controller';
const permissionsController = new PermissionsController();

/**
 * GET /api/v1/admin/permissions
 * Get system permissions
 */
router.get('/permissions', permissionsController.getPermissions);

/**
 * PUT /api/v1/admin/permissions
 * Update system permissions
 */
router.put('/permissions', permissionsController.updatePermissions);

export default router;

