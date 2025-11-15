import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { asyncHandler, NotFoundError, ValidationError, AuthorizationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';

export class PatientController {
  /**
   * Get all patients
   * GET /api/v1/patients
   */
  getAllPatients = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const { page, limit, offset } = (req as any).pagination;
    const { search, blood_type } = req.query;

    let query = db('patients')
      .join('users', 'patients.user_id', 'users.id')
      .where('patients.tenant_id', tenantId)
      .andWhere('patients.deleted_at', null);

    if (search) {
      query = query.andWhere(function() {
        this.where('users.first_name', 'ilike', `%${search}%`)
          .orWhere('users.last_name', 'ilike', `%${search}%`)
          .orWhere('users.email', 'ilike', `%${search}%`);
      });
    }

    if (blood_type) {
      query = query.andWhere('patients.blood_type', blood_type);
    }

    const [{ count }] = await query.clone().count('patients.id as count');

    const patients = await query
      .select(
        'patients.*',
        'users.first_name',
        'users.last_name',
        'users.email',
        'users.phone',
        'users.date_of_birth',
        'users.gender'
      )
      .orderBy('patients.created_at', 'desc')
      .limit(limit)
      .offset(offset);

    res.status(200).json({
      status: 'success',
      data: {
        patients,
        pagination: {
          page,
          limit,
          total: parseInt(count as string),
          pages: Math.ceil(parseInt(count as string) / limit),
        },
      },
    });
  });

  /**
   * Get patient by ID
   * GET /api/v1/patients/:id
   */
  getPatientById = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const tenantId = req.tenantId!;

    const patient = await db('patients')
      .join('users', 'patients.user_id', 'users.id')
      .where('patients.id', id)
      .andWhere('patients.tenant_id', tenantId)
      .andWhere('patients.deleted_at', null)
      .select(
        'patients.*',
        'users.first_name',
        'users.last_name',
        'users.email',
        'users.phone',
        'users.date_of_birth',
        'users.gender',
        'users.address',
        'users.city'
      )
      .first();

    if (!patient) {
      throw new NotFoundError('Patient');
    }

    res.status(200).json({
      status: 'success',
      data: {
        patient,
      },
    });
  });

  /**
   * Create patient (by doctor/admin only)
   * POST /api/v1/patients
   */
  createPatient = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const creatorRole = req.user?.role || '';
    
    // Only doctors, admins, and developers can create patients
    if (!['doctor', 'admin', 'developer'].includes(creatorRole)) {
      throw new AuthorizationError('Only doctors and administrators can create patient accounts');
    }

    const {
      email,
      password,
      first_name,
      last_name,
      phone,
      date_of_birth,
      gender,
      address,
      city,
      blood_type,
      height,
      weight,
      allergies,
      chronic_conditions,
      current_medications,
      emergency_contact_name,
      emergency_contact_phone,
      insurance_provider,
      insurance_number,
    } = req.body;

    // Check if user already exists
    const existingUser = await db('users')
      .where({ email, tenant_id: tenantId })
      .andWhere('deleted_at', null)
      .first();

    if (existingUser) {
      throw new ValidationError('Email already registered');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password || 'TempPassword123!', 12);

    // Begin transaction
    const result = await db.transaction(async (trx) => {
      // Create user
      const [user] = await trx('users')
        .insert({
          email,
          password_hash: hashedPassword,
          first_name,
          last_name,
          phone,
          date_of_birth,
          gender,
          address,
          city,
          role: 'patient',
          tenant_id: tenantId,
          is_active: true,
          email_verified: true, // Auto-verify when created by doctor
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');

      // Create patient profile
      const [patient] = await trx('patients')
        .insert({
          user_id: user.id,
          tenant_id: tenantId,
          blood_type,
          height,
          weight,
          allergies: allergies || [],
          chronic_conditions: chronic_conditions || [],
          current_medications: current_medications || [],
          emergency_contact_name,
          emergency_contact_phone,
          insurance_provider,
          insurance_number,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');

      return { user, patient };
    });

    logger.info(`Patient created by ${creatorRole}: ${result.patient.id}`);

    res.status(201).json({
      status: 'success',
      message: 'Patient account created successfully',
      data: {
        patient: result.patient,
        user: {
          id: result.user.id,
          email: result.user.email,
          first_name: result.user.first_name,
          last_name: result.user.last_name,
        },
      },
    });
  });

  /**
   * Update patient profile
   * PUT /api/v1/patients/:id
   */
  updatePatient = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const tenantId = req.tenantId!;

    const updateData: any = {
      ...req.body,
      updated_at: new Date(),
    };

    const [patient] = await db('patients')
      .where({ id, tenant_id: tenantId })
      .andWhere('deleted_at', null)
      .update(updateData)
      .returning('*');

    if (!patient) {
      throw new NotFoundError('Patient');
    }

    logger.info(`Patient profile updated: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Patient profile updated successfully',
      data: {
        patient,
      },
    });
  });

  /**
   * Delete patient (soft delete)
   * DELETE /api/v1/patients/:id
   */
  deletePatient = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const tenantId = req.tenantId!;

    const patient = await db('patients')
      .where({ id, tenant_id: tenantId })
      .andWhere('deleted_at', null)
      .first();

    if (!patient) {
      throw new NotFoundError('Patient');
    }

    await db('patients')
      .where({ id })
      .update({ deleted_at: new Date() });

    logger.info(`Patient soft deleted: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Patient deleted successfully',
    });
  });
}

export const patientController = new PatientController();
