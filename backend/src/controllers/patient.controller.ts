import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { asyncHandler, NotFoundError, ValidationError, AuthorizationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';
import path from 'path';
import fs from 'fs';
import { insertAuditEventSafe } from '../services/auditLog.service';

export class PatientController {
  /**
   * Get all patients
   * GET /api/v1/patients
   */
  getAllPatients = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const { page, limit, offset } = (req as any).pagination;
    const { search } = req.query;

    let query = db('patients')
      .join('users', 'patients.user_id', 'users.id')
      .where('patients.tenant_id', tenantId);

    if (search) {
      query = query.andWhere(function() {
        this.where('users.first_name', 'ilike', `%${search}%`)
          .orWhere('users.last_name', 'ilike', `%${search}%`)
          .orWhere('users.email', 'ilike', `%${search}%`);
      });
    }


    const [{ count }] = await query.clone().count('patients.id as count');

    const patients = await query
      .select(
        'patients.*',
        'users.first_name',
        'users.last_name',
        'users.email',
        'users.phone',
        db.raw(`users.metadata->>'id_number' as id_number`),
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
      .select(
        'patients.*',
        'users.first_name',
        'users.last_name',
        'users.email',
        'users.phone',
        db.raw(`users.metadata->>'id_number' as id_number`)
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
   * Get patient by Israeli ID (id_number)
   * GET /api/v1/patients/by-israeli-id/:idNumber
   */
  getPatientByIsraeliId = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { idNumber } = req.params;
    const tenantId = req.tenantId!;
    const normalizedIsraeliId = String(idNumber).replace(/\D/g, '').padStart(9, '0');

    const patient = await db('patients')
      .join('users', 'patients.user_id', 'users.id')
      .where('patients.tenant_id', tenantId)
      .andWhereRaw(`users.metadata->>'id_number' = ?`, [normalizedIsraeliId])
      .select(
        'patients.*',
        'users.first_name',
        'users.last_name',
        'users.email',
        'users.phone',
        db.raw(`users.metadata->>'id_number' as id_number`)
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
    
    // Doctors/Therapists, admins, and developers only.
    if (!['doctor', 'admin', 'developer'].includes(creatorRole)) {
      throw new AuthorizationError('Only doctors and administrators can create patient accounts');
    }

    const {
      id_number,
      email,
      password,
      first_name,
      last_name,
      phone,
      address: _address,
      city: _city,
      allergies,
      chronic_conditions,
      current_medications,
      emergency_contact_name,
      emergency_contact_phone,
      insurance_provider,
      insurance_number,
    } = req.body;

    // Check if user already exists
    if (!email) {
      throw new ValidationError('Email is required');
    }
    if (!id_number) {
      throw new ValidationError('Israeli ID is required');
    }
    const normalizedIsraeliId = String(id_number).replace(/\D/g, '').padStart(9, '0');
    const existingUser = await db('users')
      .where('email', email)
      .where('tenant_id', tenantId)
      .first();

    if (existingUser) {
      throw new ValidationError('Email already registered');
    }
    const existingByIsraeliId = await db('users')
      .where('tenant_id', tenantId)
      .whereRaw(`metadata->>'id_number' = ?`, [normalizedIsraeliId])
      .first();

    if (existingByIsraeliId) {
      throw new ValidationError('Israeli ID already registered');
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
          role: 'patient',
          tenant_id: tenantId,
          is_email_verified: false,
          metadata: {
            id_number: normalizedIsraeliId,
          },
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');

      // Create patient profile
      const [patient] = await trx('patients')
        .insert({
          user_id: user.id,
          tenant_id: tenantId,
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

    // Filter out fields that don't exist in schema
    const {
      blood_type: _blood_type,
      height: _height,
      weight: _weight,
      date_of_birth: _date_of_birth,
      gender: _gender,
      ...validFields
    } = req.body;
    
    const updateData: any = {
      ...validFields,
      updated_at: new Date(),
    };

    const [patient] = await db('patients')
      .where({ id, tenant_id: tenantId })
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
      .first();

    if (!patient) {
      throw new NotFoundError('Patient');
    }

    await db('patients')
      .where({ id })
      .delete();

    logger.info(`Patient soft deleted: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Patient deleted successfully',
    });
  });

  /**
   * Add medical record
   * POST /api/v1/patients/:id/medical-records
   */
  addMedicalRecord = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id: patientId } = req.params;
    const tenantId = req.tenantId!;
    const role = req.user?.role || '';

    const patient = await db('patients')
      .where({ id: patientId, tenant_id: tenantId })
      .first();

    if (!patient) {
      throw new NotFoundError('Patient');
    }

    let doctorId: string | null = null;
    if (['doctor', 'paramedical'].includes(role)) {
      const doctor = await db('doctors')
        .where({ user_id: req.user!.userId, tenant_id: tenantId })
        .first();
      if (!doctor) {
        throw new AuthorizationError('Doctor profile not found');
      }
      doctorId = doctor.id;
    } else if (['admin', 'developer'].includes(role)) {
      doctorId = req.body.doctor_id || null;
    } else {
      throw new AuthorizationError('Not allowed to add medical records');
    }

    const {
      title,
      description,
      appointment_id,
      record_type,
      is_draft,
      summary_format,
    } = req.body;

    const [record] = await db('medical_records')
      .insert({
        tenant_id: tenantId,
        patient_id: patientId,
        doctor_id: doctorId,
        appointment_id: appointment_id || null,
        title,
        description,
        record_type: record_type || 'session_summary',
        summary_format: summary_format || 'markdown',
        record_date: new Date(),
        is_draft: is_draft === true,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    await insertAuditEventSafe({
      tenantId,
      actorUserId: req.user?.userId,
      entityType: 'medical_record',
      entityId: record?.id,
      action: 'create',
      summary: 'Medical record created',
      metadata: {
        patient_id: patientId,
        record_type: record.record_type,
        appointment_id: record.appointment_id,
      },
    });

    res.status(201).json({
      status: 'success',
      data: {
        record,
      },
    });
  });

  /**
   * Update medical record
   * PUT /api/v1/patients/:id/medical-records/:recordId
   */
  updateMedicalRecord = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id: patientId, recordId } = req.params;
    const tenantId = req.tenantId!;
    const role = req.user?.role || '';

    const record = await db('medical_records')
      .where({ id: recordId, patient_id: patientId, tenant_id: tenantId })
      .first();

    if (!record) {
      throw new NotFoundError('Medical record');
    }

    if (['doctor', 'paramedical'].includes(role)) {
      const doctor = await db('doctors')
        .where({ user_id: req.user!.userId, tenant_id: tenantId })
        .first();
      if (!doctor || record.doctor_id !== doctor.id) {
        throw new AuthorizationError('You can only update your own records');
      }
    } else if (!['admin', 'developer'].includes(role)) {
      throw new AuthorizationError('Not allowed to update medical records');
    }

    const updateData: any = {
      updated_at: new Date(),
    };
    if (req.body.title !== undefined) updateData.title = req.body.title;
    if (req.body.description !== undefined) updateData.description = req.body.description;
    if (req.body.is_draft !== undefined) updateData.is_draft = req.body.is_draft === true;
    if (req.body.record_type !== undefined) updateData.record_type = req.body.record_type;
    if (req.body.summary_format !== undefined) updateData.summary_format = req.body.summary_format;

    const [updated] = await db('medical_records')
      .where({ id: recordId, patient_id: patientId, tenant_id: tenantId })
      .update(updateData)
      .returning('*');

    await insertAuditEventSafe({
      tenantId,
      actorUserId: req.user!.userId,
      entityType: 'medical_record',
      entityId: recordId,
      action: 'update',
      summary: 'Medical record updated',
      metadata: {
        patient_id: patientId,
        fields: Object.keys(updateData).filter((k) => k !== 'updated_at'),
      },
    });

    res.status(200).json({
      status: 'success',
      data: {
        record: updated,
      },
    });
  });

  /**
   * Get patient medical records
   * GET /api/v1/patients/:id/medical-records
   */
  getMedicalRecords = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id: patientId } = req.params;
    const tenantId = req.tenantId!;
    const role = req.user?.role || '';
    const userId = req.user?.userId || '';

    const patient = await db('patients')
      .where({ id: patientId, tenant_id: tenantId })
      .first();

    if (!patient) {
      throw new NotFoundError('Patient');
    }

    let query = db('medical_records')
      .where({ patient_id: patientId })
      .andWhere('medical_records.tenant_id', tenantId)
      .leftJoin('doctors as record_doctor', 'medical_records.doctor_id', 'record_doctor.id')
      .leftJoin('users as author', 'record_doctor.user_id', 'author.id')
      .select(
        'medical_records.*',
        'author.first_name as author_first_name',
        'author.last_name as author_last_name',
        'record_doctor.specialty as author_specialty'
      )
      .orderBy('medical_records.record_date', 'desc');

    if (role === 'patient') {
      if (patient.user_id !== userId) {
        throw new AuthorizationError('You can only access your own records');
      }
      query = query.andWhere({ is_draft: false });
    } else if (['doctor', 'paramedical'].includes(role)) {
      const doctor = await db('doctors')
        .where({ user_id: userId, tenant_id: tenantId })
        .first();
      if (!doctor) {
        throw new AuthorizationError('Doctor profile not found');
      }
      if (doctor.specialty) {
        query = query.andWhere('record_doctor.specialty', doctor.specialty);
      } else {
        query = query.andWhere('medical_records.doctor_id', doctor.id);
      }
      query = query.andWhere((builder: any) => {
        builder.where({ is_draft: false }).orWhere({ doctor_id: doctor.id });
      });
    }

    const records = await query;

    res.status(200).json({
      status: 'success',
      data: {
        records,
      },
    });
  });

  /**
   * Get current patient medical records
   * GET /api/v1/patients/me/medical-records
   */
  getMyMedicalRecords = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const userId = req.user?.userId || '';

    const patient = await db('patients')
      .where({ user_id: userId, tenant_id: tenantId })
      .first();

    if (!patient) {
      throw new NotFoundError('Patient');
    }

    const records = await db('medical_records')
      .where({ patient_id: patient.id, is_draft: false })
      .andWhere('medical_records.tenant_id', tenantId)
      .leftJoin('doctors as record_doctor', 'medical_records.doctor_id', 'record_doctor.id')
      .leftJoin('users as author', 'record_doctor.user_id', 'author.id')
      .select(
        'medical_records.*',
        'author.first_name as author_first_name',
        'author.last_name as author_last_name',
        'record_doctor.specialty as author_specialty'
      )
      .orderBy('medical_records.record_date', 'desc');

    res.status(200).json({
      status: 'success',
      data: {
        records,
      },
    });
  });

  /**
   * Upload medical record attachments
   * POST /api/v1/patients/:id/medical-records/:recordId/attachments
   */
  uploadMedicalRecordAttachments = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id: patientId, recordId } = req.params;
    const tenantId = req.tenantId!;
    const role = req.user?.role || '';
    const userId = req.user?.userId || '';

    const record = await db('medical_records')
      .where({ id: recordId, patient_id: patientId, tenant_id: tenantId })
      .first();

    if (!record) {
      throw new NotFoundError('Medical record');
    }

    if (role === 'patient') {
      const patient = await db('patients')
        .where({ id: patientId, tenant_id: tenantId })
        .first();
      if (!patient || patient.user_id !== userId) {
        throw new AuthorizationError('You can only upload to your own records');
      }
      if (record.is_draft) {
        throw new AuthorizationError('Cannot upload to draft records');
      }
    } else if (['doctor', 'paramedical'].includes(role)) {
      const doctor = await db('doctors')
        .where({ user_id: userId, tenant_id: tenantId })
        .first();
      if (!doctor || record.doctor_id !== doctor.id) {
        throw new AuthorizationError('You can only upload to your own records');
      }
    } else if (!['admin', 'developer'].includes(role)) {
      throw new AuthorizationError('Not allowed to upload attachments');
    }

    const files = (req as any).files as Express.Multer.File[];
    if (!files || files.length == 0) {
      throw new ValidationError('No files uploaded');
    }

    const attachmentUrls = files.map((file) => {
      return `/api/v1/patients/${patientId}/medical-records/${recordId}/attachments/${file.filename}`;
    });

    const existingAttachments = Array.isArray(record.attachments) ? record.attachments : [];
    const updatedAttachments = [...existingAttachments, ...attachmentUrls];

    await db('medical_records')
      .where({ id: recordId, tenant_id: tenantId })
      .update({
        attachments: updatedAttachments,
        updated_at: new Date(),
      });

    await insertAuditEventSafe({
      tenantId,
      actorUserId: req.user!.userId,
      entityType: 'medical_record',
      entityId: recordId,
      action: 'attachment_upload',
      summary: 'Medical record attachments uploaded',
      metadata: {
        patient_id: patientId,
        file_count: files.length,
      },
    });

    res.status(200).json({
      status: 'success',
      data: {
        attachments: updatedAttachments,
      },
    });
  });

  /**
   * Download medical record attachment
   * GET /api/v1/patients/:id/medical-records/:recordId/attachments/:fileName
   */
  getMedicalRecordAttachment = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id: patientId, recordId, fileName } = req.params;
    const tenantId = req.tenantId!;
    const role = req.user?.role || '';
    const userId = req.user?.userId || '';

    const record = await db('medical_records')
      .where({ id: recordId, patient_id: patientId, tenant_id: tenantId })
      .first();

    if (!record) {
      throw new NotFoundError('Medical record');
    }

    if (role === 'patient') {
      const patient = await db('patients')
        .where({ id: patientId, tenant_id: tenantId })
        .first();
      if (!patient || patient.user_id !== userId) {
        throw new AuthorizationError('You can only access your own records');
      }
      if (record.is_draft) {
        throw new AuthorizationError('Draft records are not accessible');
      }
    } else if (['doctor', 'paramedical'].includes(role)) {
      const doctor = await db('doctors')
        .where({ user_id: userId, tenant_id: tenantId })
        .first();
      if (!doctor) {
        throw new AuthorizationError('Doctor profile not found');
      }
      if (doctor.specialty) {
        const recordDoctor = await db('doctors')
          .where({ id: record.doctor_id, tenant_id: tenantId })
          .first();
        if (!recordDoctor || recordDoctor.specialty !== doctor.specialty) {
          throw new AuthorizationError('Access denied by specialty');
        }
      } else if (record.doctor_id !== doctor.id) {
        throw new AuthorizationError('Access denied');
      }
    }

    const attachments = Array.isArray(record.attachments) ? record.attachments : [];
    const expectedUrl = `/api/v1/patients/${patientId}/medical-records/${recordId}/attachments/${fileName}`;
    if (!attachments.includes(expectedUrl)) {
      throw new NotFoundError('Attachment');
    }

    const baseDir = path.resolve(process.cwd(), 'uploads', 'medical-records', recordId);
    const filePath = path.resolve(baseDir, fileName);
    if (!filePath.startsWith(baseDir)) {
      throw new AuthorizationError('Invalid file path');
    }
    if (!fs.existsSync(filePath)) {
      throw new NotFoundError('Attachment');
    }

    res.sendFile(filePath);
  });
}

export const patientController = new PatientController();
