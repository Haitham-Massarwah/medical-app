import { Request, Response, NextFunction } from 'express';
import { asyncHandler, NotFoundError, AuthenticationError, ValidationError, AuthorizationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';

export class DoctorController {
  private async assertDoctorAccess(req: Request, doctorId: string): Promise<string> {
    const tenantId = req.tenantId || req.user?.tenantId || req.user?.tenant_id;
    if (!tenantId) {
      throw new AuthenticationError('Tenant not found');
    }

    if (req.user?.role === 'doctor') {
      const ownDoctor = await db('doctors')
        .where({ user_id: req.user.userId || req.user.id, tenant_id: tenantId })
        .first('id');
      if (!ownDoctor || ownDoctor.id !== doctorId) {
        throw new AuthorizationError('Doctor can access only own schedule');
      }
    }

    return String(tenantId);
  }

  /**
   * Get all doctors
   * GET /api/v1/doctors
   */
  getAllDoctors = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { page, limit, offset } = (req as any).pagination;
    const { specialty, language, search, city: _city, area: _area } = req.query;

    let query = db('doctors')
      .join('users', 'doctors.user_id', 'users.id')
      .where('doctors.is_active', true);

    // Filter by specialty
    if (specialty) {
      query = query.andWhere('doctors.specialty', 'ilike', `%${specialty}%`);
    }

    // Filter by city/area (if city column exists in users table)
    // Note: users table doesn't have city column in schema - removing for now
    // if (city) {
    //   query = query.andWhere('users.city', 'ilike', `%${city}%`);
    // }

    // if (area) {
    //   query = query.andWhere('users.city', 'ilike', `%${area}%`);
    // }

    // Filter by language
    if (language) {
      query = query.whereRaw('? = ANY(doctors.languages)', [language]);
    }

    // Search by name
    if (search) {
      query = query.andWhere(function() {
        this.where('users.first_name', 'ilike', `%${search}%`)
          .orWhere('users.last_name', 'ilike', `%${search}%`);
      });
    }

    // Get total count
    const countResult = await query.clone().count('doctors.id as count').first();
    const totalCount = countResult ? parseInt(String((countResult as any).count)) : 0;

    // Get doctors
    const doctors = await query
      .select(
        'doctors.id',
        'doctors.user_id',
        'users.first_name',
        'users.last_name',
        'users.email',
        'users.phone',
        'doctors.specialty',
        'doctors.specialty as specialty_name',
        'doctors.license_number',
        'doctors.bio',
        'doctors.rating',
        'doctors.review_count as total_reviews',
        'doctors.languages'
      )
      .orderBy('doctors.rating', 'desc')
      .limit(limit)
      .offset(offset);

    res.status(200).json({
      status: 'success',
      data: {
        doctors,
        pagination: {
          page,
          limit,
          total: totalCount,
          pages: Math.ceil(totalCount / limit),
        },
      },
    });
  });

  /**
   * Search doctors
   * GET /api/v1/doctors/search
   */
  searchDoctors = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { page, limit, offset } = (req as any).pagination;
    const { q, specialty, min_rating, max_fee: _max_fee } = req.query;

    let query = db('doctors')
      .join('users', 'doctors.user_id', 'users.id')
      .where('doctors.is_active', true);

    // Search query
    if (q) {
      query = query.andWhere(function() {
        this.where('users.first_name', 'ilike', `%${q}%`)
          .orWhere('users.last_name', 'ilike', `%${q}%`)
          .orWhere('doctors.specialty', 'ilike', `%${q}%`)
          .orWhere('doctors.bio', 'ilike', `%${q}%`);
      });
    }

    // Filters
    if (specialty) query = query.andWhere('doctors.specialty', 'ilike', `%${specialty}%`);
    if (min_rating) query = query.andWhere('doctors.rating', '>=', min_rating);
    // Note: consultation_fee doesn't exist in schema - removed filter
    // if (max_fee) query = query.andWhere('doctors.consultation_fee', '<=', max_fee);

    const countResult = await query.clone().count('doctors.id as count').first();
    const totalCount = countResult ? parseInt(String((countResult as any).count)) : 0;

    const doctors = await query
      .select(
        'doctors.id',
        'users.first_name',
        'users.last_name',
        'doctors.specialty as specialty_name',
        'doctors.rating',
        'doctors.review_count as total_reviews'
      )
      .orderBy('doctors.rating', 'desc')
      .limit(limit)
      .offset(offset);

    res.status(200).json({
      status: 'success',
      data: {
        doctors,
        pagination: {
          page,
          limit,
          total: totalCount,
          pages: Math.ceil(totalCount / limit),
        },
      },
    });
  });

  /**
   * Get doctor by ID
   * GET /api/v1/doctors/:id
   */
  getDoctorById = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;

    const doctor = await db('doctors')
      .join('users', 'doctors.user_id', 'users.id')
      .where('doctors.id', id)
      .andWhere('doctors.is_active', true)
      .select(
        'doctors.*',
        'users.first_name',
        'users.last_name',
        'users.email',
        'users.phone',
        'users.metadata as user_metadata',
        'doctors.specialty as specialty_name'
      )
      .first();

    if (!doctor) {
      throw new NotFoundError('Doctor');
    }

    const userMeta =
      doctor.user_metadata && typeof doctor.user_metadata === 'object'
        ? (doctor.user_metadata as Record<string, unknown>)
        : {};
    const discountEndRaw = (userMeta.discount_end_at || '').toString();
    const discountPctRaw = Number(userMeta.discount_percentage || 0);
    const discountStillActive =
      discountEndRaw.length > 0 &&
      !Number.isNaN(Date.parse(discountEndRaw)) &&
      new Date(discountEndRaw).getTime() >= Date.now();
    const effectiveDiscount = discountStillActive ? Math.max(0, Math.min(100, discountPctRaw)) : 0;

    res.status(200).json({
      status: 'success',
      data: {
        doctor: {
          ...doctor,
          effective_discount_percentage: effectiveDiscount,
          billing_discount_active: effectiveDiscount > 0,
        },
      },
    });
  });

  /**
   * Get current doctor's profile
   * GET /api/v1/doctors/me
   */
  getMyDoctorProfile = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user?.userId || req.user?.id;
    const tenantId = req.tenantId || req.user?.tenantId || req.user?.tenant_id;
    if (!userId || !tenantId) {
      throw new AuthenticationError('User not authenticated');
    }

    const doctor = await db('doctors')
      .join('users', 'doctors.user_id', 'users.id')
      .where('doctors.user_id', userId)
      .andWhere('doctors.tenant_id', tenantId)
      .andWhere('doctors.is_active', true)
      .select(
        'doctors.*',
        'users.first_name',
        'users.last_name',
        'users.email',
        'users.phone',
        'doctors.specialty as specialty_name'
      )
      .first();

    if (!doctor) {
      throw new NotFoundError('Doctor');
    }

    res.status(200).json({
      status: 'success',
      data: {
        doctor,
      },
    });
  });

  /**
   * Get doctor availability
   * GET /api/v1/doctors/:id/availability
   */
  getDoctorAvailability = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { date } = req.query;

    // Verify doctor exists
    const doctor = await db('doctors')
      .where({ id })
      .andWhere('is_active', true)
      .first();

    if (!doctor) {
      throw new NotFoundError('Doctor');
    }

    const [workingHours, breaks, timeOff] = await Promise.all([
      db('availability').where({ doctor_id: id, is_active: true }),
      db('doctor_breaks')
        .where({ doctor_id: id, is_active: true })
        .select('day_of_week', 'start_time', 'end_time'),
      db('doctor_time_off')
        .where({ doctor_id: id })
        .select('start_date', 'end_date', 'reason', 'is_holiday'),
    ]);

    // Get appointments for the date (if provided)
    let bookedSlots: any[] = [];
    if (date) {
      bookedSlots = await db('appointments')
        .where({ doctor_id: id })
        .andWhere('appointment_date', date)
        .whereIn('status', ['scheduled', 'confirmed'])
        .select('start_time', 'end_time');
    }

    res.status(200).json({
      status: 'success',
      data: {
        working_hours: workingHours,
        breaks,
        time_off: timeOff,
        booked_slots: bookedSlots,
      },
    });
  });

  /**
   * Get doctor reviews
   * GET /api/v1/doctors/:id/reviews
   */
  getDoctorReviews = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { page, limit, offset } = (req as any).pagination;

    const countResult = await db('reviews')
      .where({ doctor_id: id })
      .count('* as count')
      .first();
    const totalCount = countResult ? parseInt(String((countResult as any).count)) : 0;

    const reviews = await db('reviews')
      .join('users', 'reviews.patient_id', 'users.id')
      .where('reviews.doctor_id', id)
      .select(
        'reviews.id',
        'reviews.rating',
        'reviews.comment',
        'reviews.created_at',
        'users.first_name',
        'users.last_name'
      )
      .orderBy('reviews.created_at', 'desc')
      .limit(limit)
      .offset(offset);

    res.status(200).json({
      status: 'success',
      data: {
        reviews,
        pagination: {
          page,
          limit,
          total: totalCount,
          pages: Math.ceil(totalCount / limit),
        },
      },
    });
  });

  /**
   * Create doctor
   * POST /api/v1/doctors
   */
  createDoctor = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const {
      user_id,
      specialty_id,
      business_file_id,
      license_number,
      years_of_experience: _years_of_experience,
      bio,
      education,
      languages,
      consultation_fee: _consultation_fee,
    } = req.body;
    const normalizedEducation = Array.isArray(education)
      ? education.join(', ')
      : education;
    const normalizedBusinessId = String(business_file_id || '').replace(/[^\d]/g, '');
    if (!/^\d{5,9}$/.test(normalizedBusinessId)) {
      throw new ValidationError('Business identifier must be 5-9 digits');
    }
    const normalizedLicense = String(license_number || '').trim();
    const primaryIdentifierValue = normalizedLicense || normalizedBusinessId;
    const primaryIdentifierType = normalizedLicense ? 'medical_license' : 'business_file_id';

    const [doctor] = await db('doctors')
      .insert({
        user_id,
        tenant_id: tenantId,
        specialty: req.body.specialty || specialty_id || 'General',
        license_number: normalizedLicense || null,
        business_file_id: normalizedBusinessId,
        primary_identifier_type: primaryIdentifierType,
        primary_identifier_value: primaryIdentifierValue,
        bio,
        education: normalizedEducation,
        languages,
        rating: 0,
        review_count: 0,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    logger.info(`Doctor created: ${doctor.id}`);

    res.status(201).json({
      status: 'success',
      message: 'Doctor profile created successfully',
      data: {
        doctor,
      },
    });
  });

  /**
   * Update doctor
   * PUT /api/v1/doctors/:id
   */
  updateDoctor = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const tenantId = req.tenantId!;
    const currentDoctor = await db('doctors').where({ id, tenant_id: tenantId }).first();
    if (!currentDoctor) {
      throw new NotFoundError('Doctor');
    }

    const {
      education,
      certifications: _certifications,
      business_file_id,
      license_number,
      pdf_branding,
      ...rest
    } = req.body;
    const updateData: any = {
      ...rest,
      updated_at: new Date(),
    };
    if (pdf_branding !== undefined) {
      updateData.pdf_branding =
        typeof pdf_branding === 'object' && pdf_branding !== null && !Array.isArray(pdf_branding)
          ? pdf_branding
          : {};
    }
    if (business_file_id !== undefined) {
      const normalizedBusinessId = String(business_file_id || '').replace(/[^\d]/g, '');
      if (!/^\d{5,9}$/.test(normalizedBusinessId)) {
        throw new ValidationError('Business identifier must be 5-9 digits');
      }
      updateData.business_file_id = normalizedBusinessId;
    }
    if (license_number !== undefined) {
      updateData.license_number = String(license_number || '').trim() || null;
    }
    const nextBusinessId = updateData.business_file_id;
    const nextLicense = updateData.license_number;
    if (nextBusinessId !== undefined || nextLicense !== undefined) {
      const effectiveBusinessId = nextBusinessId ?? currentDoctor.business_file_id;
      const effectiveLicense = nextLicense ?? currentDoctor.license_number;
      const primaryIdentifierValue = effectiveLicense || effectiveBusinessId;
      const primaryIdentifierType = effectiveLicense ? 'medical_license' : 'business_file_id';
      updateData.primary_identifier_type = primaryIdentifierType;
      updateData.primary_identifier_value = primaryIdentifierValue || null;
    }
    if (education !== undefined) {
      updateData.education = Array.isArray(education)
        ? education.join(', ')
        : education;
    }

    const [doctor] = await db('doctors')
      .where({ id, tenant_id: tenantId })
      .andWhere('is_active', true)
      .update(updateData)
      .returning('*');

    if (!doctor) {
      throw new NotFoundError('Doctor');
    }

    logger.info(`Doctor updated: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Doctor profile updated successfully',
      data: {
        doctor,
      },
    });
  });

  /**
   * Update doctor schedule
   * PUT /api/v1/doctors/:id/schedule
   */
  updateSchedule = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { working_hours } = req.body;
    const tenantId = await this.assertDoctorAccess(req, id);

    // Delete existing schedule
    await db('availability')
      .where({ doctor_id: id, tenant_id: tenantId })
      .delete();

    // Insert new schedule
    const scheduleData = working_hours.map((slot: any) => ({
      doctor_id: id,
      tenant_id: tenantId,
      day_of_week: slot.day_of_week,
      start_time: slot.start_time,
      end_time: slot.end_time,
      created_at: new Date(),
      updated_at: new Date(),
    }));

    await db('availability').insert(scheduleData);

    logger.info(`Doctor schedule updated: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Doctor schedule updated successfully',
    });
  });

  /**
   * Add time off
   * POST /api/v1/doctors/:id/time-off
   */
  addTimeOff = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { start_date, end_date, reason, is_holiday } = req.body;
    const tenantId = await this.assertDoctorAccess(req, id);

    const [timeOff] = await db('doctor_time_off')
      .insert({
        doctor_id: id,
        tenant_id: tenantId,
        start_date,
        end_date,
        is_holiday: is_holiday === true,
        reason,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    logger.info(`Time off added for doctor: ${id}`);

    res.status(201).json({
      status: 'success',
      message: 'Time off added successfully',
      data: {
        time_off: timeOff,
      },
    });
  });

  /**
   * Get doctor schedule settings
   * GET /api/v1/doctors/:id/schedule-settings
   */
  getScheduleSettings = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const tenantId = await this.assertDoctorAccess(req, id);

    const [workingHours, breaks, timeOff] = await Promise.all([
      db('availability')
        .where({ doctor_id: id, tenant_id: tenantId })
        .select('day_of_week', 'start_time', 'end_time')
        .orderBy('day_of_week', 'asc')
        .orderBy('start_time', 'asc'),
      db('doctor_breaks')
        .where({ doctor_id: id, tenant_id: tenantId, is_active: true })
        .select('id', 'day_of_week', 'start_time', 'end_time')
        .orderBy('day_of_week', 'asc')
        .orderBy('start_time', 'asc'),
      db('doctor_time_off')
        .where({ doctor_id: id, tenant_id: tenantId })
        .select('id', 'start_date', 'end_date', 'reason', 'is_holiday')
        .orderBy('start_date', 'asc'),
    ]);

    res.status(200).json({
      status: 'success',
      data: {
        working_hours: workingHours,
        breaks,
        time_off: timeOff,
      },
    });
  });

  /**
   * Save doctor schedule settings
   * PUT /api/v1/doctors/:id/schedule-settings
   */
  saveScheduleSettings = asyncHandler(async (req: Request, res: Response) => {
    const { id } = req.params;
    const tenantId = await this.assertDoctorAccess(req, id);
    const workingHours = Array.isArray(req.body.working_hours) ? req.body.working_hours : [];
    const breaks = Array.isArray(req.body.breaks) ? req.body.breaks : [];
    const timeOff = Array.isArray(req.body.time_off) ? req.body.time_off : [];

    await db.transaction(async (trx) => {
      await trx('availability').where({ doctor_id: id, tenant_id: tenantId }).delete();
      await trx('doctor_breaks').where({ doctor_id: id, tenant_id: tenantId }).delete();
      await trx('doctor_time_off').where({ doctor_id: id, tenant_id: tenantId }).delete();

      if (workingHours.length > 0) {
        await trx('availability').insert(
          workingHours.map((slot: any) => ({
            doctor_id: id,
            tenant_id: tenantId,
            day_of_week: Number(slot.day_of_week),
            start_time: String(slot.start_time),
            end_time: String(slot.end_time),
            is_active: true,
            created_at: new Date(),
            updated_at: new Date(),
          }))
        );
      }

      if (breaks.length > 0) {
        await trx('doctor_breaks').insert(
          breaks.map((slot: any) => ({
            doctor_id: id,
            tenant_id: tenantId,
            day_of_week: Number(slot.day_of_week),
            start_time: String(slot.start_time),
            end_time: String(slot.end_time),
            is_active: true,
            created_at: new Date(),
            updated_at: new Date(),
          }))
        );
      }

      if (timeOff.length > 0) {
        await trx('doctor_time_off').insert(
          timeOff.map((item: any) => ({
            doctor_id: id,
            tenant_id: tenantId,
            start_date: String(item.start_date),
            end_date: String(item.end_date),
            reason: item.reason ? String(item.reason) : null,
            is_holiday: item.is_holiday === true,
            created_at: new Date(),
            updated_at: new Date(),
          }))
        );
      }
    });

    res.status(200).json({
      status: 'success',
      message: 'Schedule settings saved successfully',
    });
  });

  /**
   * Delete doctor
   * DELETE /api/v1/doctors/:id
   */
  deleteDoctor = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;

    await db('doctors')
      .where({ id })
      .update({
        is_active: false,
        updated_at: new Date(),
      });

    logger.info(`Doctor deleted: ${id}`);

    res.status(200).json({
      status: 'success',
      message: 'Doctor deleted successfully',
    });
  });

  /**
   * Get doctor appointments
   * GET /api/v1/doctors/:id/appointments
   */
  getDoctorAppointments = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { page, limit, offset } = (req as any).pagination;
    const { status, date } = req.query;

    const [hasServicesTable, hasServiceIdColumn] = await Promise.all([
      db.schema.hasTable('services'),
      db.schema.hasColumn('appointments', 'service_id'),
    ]);

    let query = db('appointments')
      .where('appointments.doctor_id', id);

    if (status) query = query.andWhere({ status });
    if (date) query = query.andWhere('appointment_date', date);

    const countResult = await query.clone().count('* as count').first();
    const totalCount = countResult ? parseInt(String((countResult as any).count)) : 0;

    let appointmentsQuery = query
      .join('patients', 'appointments.patient_id', 'patients.id')
      .join('users', 'patients.user_id', 'users.id');

    if (hasServicesTable && hasServiceIdColumn) {
      appointmentsQuery = appointmentsQuery.leftJoin(
        'services',
        'appointments.service_id',
        'services.id'
      );
    }

    const appointments = await appointmentsQuery
      .select([
        'appointments.*',
        'users.first_name as patient_first_name',
        'users.last_name as patient_last_name',
        'users.phone as patient_phone',
        ...(hasServicesTable && hasServiceIdColumn
          ? ['services.name as service_name', 'services.price as service_price']
          : [db.raw('NULL as service_name'), db.raw('NULL as service_price')]),
      ])
      .orderBy('appointments.appointment_date', 'desc')
      .limit(limit)
      .offset(offset);

    res.status(200).json({
      status: 'success',
      data: {
        appointments,
        pagination: {
          page,
          limit,
          total: totalCount,
          pages: Math.ceil(totalCount / limit),
        },
      },
    });
  });

  /**
   * Get doctor statistics
   * GET /api/v1/doctors/:id/statistics
   */
  getDoctorStatistics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;

    const stats = await db('appointments')
      .where({ doctor_id: id })
      .select(
        db.raw('COUNT(*) as total_appointments'),
        db.raw("COUNT(*) FILTER (WHERE status = 'completed') as completed_appointments"),
        db.raw("COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_appointments"),
        db.raw("COUNT(*) FILTER (WHERE status = 'no_show') as no_show_appointments")
      )
      .first();

    res.status(200).json({
      status: 'success',
      data: {
        statistics: stats,
      },
    });
  });
}


