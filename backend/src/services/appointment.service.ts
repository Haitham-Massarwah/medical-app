import db from '../config/database';
import redis from '../config/redis';
import { logger } from '../config/logger';
import { ApiError } from '../utils/apiError';
import { addMinutes, format, isAfter, isBefore } from 'date-fns';

interface BookAppointmentParams {
  tenantId: string;
  patientId: string;
  doctorId: string;
  serviceId?: string;
  appointmentDate: Date;
  durationMinutes: number;
  notes?: string;
  location?: string;
  isTelehealth: boolean;
  bookedBy: string;
}

interface CheckAvailabilityParams {
  doctorId: string;
  appointmentDate: Date;
  durationMinutes: number;
  tenantId: string;
  excludeAppointmentId?: string;
}

interface GetAvailableSlotsParams {
  doctorId: string;
  startDate: Date;
  endDate?: Date;
  durationMinutes: number;
  tenantId: string;
}

export class AppointmentService {
  private readonly timezone = process.env.TIMEZONE || 'Asia/Jerusalem';

  /**
   * Book a new appointment
   */
  public async bookAppointment(params: BookAppointmentParams): Promise<any> {
    const {
      tenantId,
      patientId,
      doctorId,
      serviceId,
      appointmentDate,
      durationMinutes,
      notes,
      location,
      isTelehealth,
      bookedBy,
    } = params;

    return await db.transaction(async (trx) => {
      try {
        // 1. Check if doctor exists and is active
        const doctor = await trx('doctors')
          .where({ id: doctorId, tenant_id: tenantId, is_active: true })
          .first();

        if (!doctor) {
          throw new ApiError(404, 'Doctor not found or inactive');
        }

        // 2. Check if patient exists
        const patient = await trx('patients')
          .where({ id: patientId, tenant_id: tenantId })
          .first();

        if (!patient) {
          throw new ApiError(404, 'Patient not found');
        }

        // 3. Double-check availability (atomic check within transaction)
        const isAvailable = await this.checkAvailabilityInTransaction(
          trx,
          doctorId,
          appointmentDate,
          durationMinutes,
          tenantId
        );

        if (!isAvailable) {
          throw new ApiError(409, 'Time slot is no longer available');
        }

        // 4. Create appointment
        const [appointment] = await trx('appointments')
          .insert({
            tenant_id: tenantId,
            patient_id: patientId,
            doctor_id: doctorId,
            service_id: serviceId,
            appointment_date: appointmentDate,
            duration_minutes: durationMinutes,
            status: 'scheduled',
            notes,
            location,
            is_telehealth: isTelehealth,
          })
          .returning('*');

        // 5. Log audit
        await trx('audit_logs').insert({
          tenant_id: tenantId,
          user_id: bookedBy,
          action: 'CREATE',
          entity_type: 'appointment',
          entity_id: appointment.id,
          new_values: appointment,
          ip_address: null, // Would come from request
        });

        // 6. Clear cache
        await this.clearAppointmentCache(tenantId, doctorId, patientId);

        logger.info(`Appointment booked successfully: ${appointment.id}`);
        return appointment;
      } catch (error) {
        logger.error('Error in bookAppointment transaction:', error);
        throw error;
      }
    });
  }

  /**
   * Check if a time slot is available
   */
  public async checkAvailability(params: CheckAvailabilityParams): Promise<boolean> {
    const { doctorId, appointmentDate, durationMinutes, tenantId, excludeAppointmentId } = params;

    const appointmentEnd = addMinutes(appointmentDate, durationMinutes);

    // 1. Check if it's in the past
    if (isBefore(appointmentDate, new Date())) {
      return false;
    }

    // 2. Check doctor's regular availability
    const dayOfWeek = appointmentDate.getDay();
    const appointmentTime = format(appointmentDate, 'HH:mm:ss');

    const regularAvailability = await db('availability')
      .where({
        doctor_id: doctorId,
        tenant_id: tenantId,
        day_of_week: dayOfWeek,
        is_active: true,
      })
      .andWhere('start_time', '<=', appointmentTime)
      .andWhere('end_time', '>=', format(appointmentEnd, 'HH:mm:ss'))
      .first();

    if (!regularAvailability) {
      return false;
    }

    // 3. Check for exceptions (holidays, blocked dates)
    const dateOnly = format(appointmentDate, 'yyyy-MM-dd');
    const exception = await db('availability_exceptions')
      .where({
        doctor_id: doctorId,
        tenant_id: tenantId,
        date: dateOnly,
        type: 'blocked',
      })
      .first();

    if (exception) {
      // Check if appointment time falls within blocked time
      if (
        exception.start_time &&
        exception.end_time &&
        appointmentTime >= exception.start_time &&
        appointmentTime <= exception.end_time
      ) {
        return false;
      } else if (!exception.start_time && !exception.end_time) {
        // Entire day is blocked
        return false;
      }
    }

    // 4. Check for conflicting appointments
    const conflictingAppointments = await db('appointments')
      .where({ doctor_id: doctorId, tenant_id: tenantId })
      .whereIn('status', ['scheduled', 'confirmed'])
      .andWhere((builder) => {
        if (excludeAppointmentId) {
          builder.whereNot('id', excludeAppointmentId);
        }
      })
      .andWhere((builder) => {
        // Check for overlapping time slots
        builder
          .where((b) => {
            b.where('appointment_date', '<=', appointmentDate).andWhere(
              db.raw(`appointment_date + (duration_minutes || ' minutes')::interval > ?`, [appointmentDate])
            );
          })
          .orWhere((b) => {
            b.where('appointment_date', '<', appointmentEnd).andWhere('appointment_date', '>=', appointmentDate);
          });
      });

    if (conflictingAppointments.length > 0) {
      return false;
    }

    return true;
  }

  /**
   * Check availability within a transaction (for atomic booking)
   */
  private async checkAvailabilityInTransaction(
    trx: any,
    doctorId: string,
    appointmentDate: Date,
    durationMinutes: number,
    tenantId: string
  ): Promise<boolean> {
    const appointmentEnd = addMinutes(appointmentDate, durationMinutes);

    // Lock the doctor's appointments for this time slot
    const conflictingAppointments = await trx('appointments')
      .where({ doctor_id: doctorId, tenant_id: tenantId })
      .whereIn('status', ['scheduled', 'confirmed'])
      .andWhere((builder: any) => {
        builder
          .where((b: any) => {
            b.where('appointment_date', '<=', appointmentDate).andWhere(
              trx.raw(`appointment_date + (duration_minutes || ' minutes')::interval > ?`, [appointmentDate])
            );
          })
          .orWhere((b: any) => {
            b.where('appointment_date', '<', appointmentEnd).andWhere('appointment_date', '>=', appointmentDate);
          });
      })
      .forUpdate(); // Lock rows for update

    return conflictingAppointments.length === 0;
  }

  /**
   * Get available time slots for a doctor
   */
  public async getAvailableSlots(params: GetAvailableSlotsParams): Promise<Date[]> {
    const { doctorId, startDate, endDate, durationMinutes, tenantId } = params;

    const endDateOrDefault = endDate || addMinutes(startDate, 7 * 24 * 60); // Default 7 days

    // Get doctor's availability
    const availability = await db('availability')
      .where({ doctor_id: doctorId, tenant_id: tenantId, is_active: true });

    // Get existing appointments
    const appointments = await db('appointments')
      .where({ doctor_id: doctorId, tenant_id: tenantId })
      .whereIn('status', ['scheduled', 'confirmed'])
      .whereBetween('appointment_date', [startDate, endDateOrDefault]);

    // Get exceptions
    const exceptions = await db('availability_exceptions')
      .where({ doctor_id: doctorId, tenant_id: tenantId })
      .whereBetween('date', [format(startDate, 'yyyy-MM-dd'), format(endDateOrDefault, 'yyyy-MM-dd')]);

    // Generate available slots
    const availableSlots: Date[] = [];
    const currentDate = new Date(startDate);

    while (isBefore(currentDate, endDateOrDefault)) {
      const dayOfWeek = currentDate.getDay();
      const dayAvailability = availability.filter((a) => a.day_of_week === dayOfWeek);

      for (const av of dayAvailability) {
        // Parse start and end times
        const [startHour, startMinute] = av.start_time.split(':').map(Number);
        const [endHour, endMinute] = av.end_time.split(':').map(Number);

        let slotTime = new Date(currentDate);
        slotTime.setHours(startHour, startMinute, 0, 0);

        const endTime = new Date(currentDate);
        endTime.setHours(endHour, endMinute, 0, 0);

        // Generate slots within working hours
        while (isBefore(addMinutes(slotTime, durationMinutes), endTime) || slotTime.getTime() === endTime.getTime()) {
          // Check if slot is not in the past
          if (isAfter(slotTime, new Date())) {
            // Check if not blocked by exception
            const isBlocked = this.isSlotBlocked(slotTime, durationMinutes, exceptions);
            
            // Check if not conflicting with existing appointment
            const hasConflict = this.hasAppointmentConflict(slotTime, durationMinutes, appointments);

            if (!isBlocked && !hasConflict) {
              availableSlots.push(new Date(slotTime));
            }
          }

          slotTime = addMinutes(slotTime, durationMinutes);
        }
      }

      // Move to next day
      currentDate.setDate(currentDate.getDate() + 1);
      currentDate.setHours(0, 0, 0, 0);
    }

    return availableSlots;
  }

  /**
   * Check if appointment can be cancelled based on policy
   */
  public async canCancelAppointment(
    appointmentId: string,
    tenantId: string
  ): Promise<{ allowed: boolean; reason?: string; penalty?: number }> {
    const appointment = await db('appointments')
      .where({ id: appointmentId, tenant_id: tenantId })
      .first();

    if (!appointment) {
      return { allowed: false, reason: 'Appointment not found' };
    }

    if (appointment.status === 'cancelled' || appointment.status === 'completed') {
      return { allowed: false, reason: 'Appointment cannot be cancelled' };
    }

    // Get cancellation policy
    const policy = await db('cancellation_policies')
      .where({ tenant_id: tenantId, is_active: true })
      .orderBy('hours_before', 'desc')
      .first();

    if (!policy) {
      // No policy = can always cancel
      return { allowed: true };
    }

    const now = new Date();
    const appointmentDate = new Date(appointment.appointment_date);
    const hoursUntilAppointment = (appointmentDate.getTime() - now.getTime()) / (1000 * 60 * 60);

    if (hoursUntilAppointment < policy.hours_before) {
      const penalty =
        policy.penalty_percentage > 0
          ? (policy.penalty_percentage / 100) * 100 // Would need actual price
          : policy.penalty_fixed_amount;

      return {
        allowed: true,
        reason: `Cancellation within ${policy.hours_before} hours incurs a penalty`,
        penalty,
      };
    }

    return { allowed: true };
  }

  /**
   * Cancel appointment
   */
  public async cancelAppointment(params: {
    appointmentId: string;
    tenantId: string;
    userId: string;
    role: string;
    reason?: string;
  }): Promise<void> {
    const { appointmentId, tenantId, userId, reason } = params;

    await db.transaction(async (trx) => {
      await trx('appointments')
        .where({ id: appointmentId, tenant_id: tenantId })
        .update({
          status: 'cancelled',
          cancellation_reason: reason,
          cancelled_at: new Date(),
          cancelled_by: userId,
          updated_at: new Date(),
        });

      // Log audit
      await trx('audit_logs').insert({
        tenant_id: tenantId,
        user_id: userId,
        action: 'CANCEL',
        entity_type: 'appointment',
        entity_id: appointmentId,
        new_values: { status: 'cancelled', reason },
      });
    });

    // Clear cache
    const appointment = await db('appointments').where({ id: appointmentId }).first();
    if (appointment) {
      await this.clearAppointmentCache(tenantId, appointment.doctor_id, appointment.patient_id);
    }
  }

  /**
   * Reschedule appointment
   */
  public async rescheduleAppointment(params: {
    appointmentId: string;
    newAppointmentDate: Date;
    durationMinutes?: number;
    reason?: string;
    tenantId: string;
    userId: string;
  }): Promise<any> {
    const { appointmentId, newAppointmentDate, durationMinutes, reason, tenantId, userId } = params;

    return await db.transaction(async (trx) => {
      const [updatedAppointment] = await trx('appointments')
        .where({ id: appointmentId, tenant_id: tenantId })
        .update({
          appointment_date: newAppointmentDate,
          duration_minutes: durationMinutes,
          status: 'rescheduled',
          updated_at: new Date(),
        })
        .returning('*');

      // Log audit
      await trx('audit_logs').insert({
        tenant_id: tenantId,
        user_id: userId,
        action: 'RESCHEDULE',
        entity_type: 'appointment',
        entity_id: appointmentId,
        new_values: { appointment_date: newAppointmentDate, reason },
      });

      return updatedAppointment;
    });
  }

  /**
   * Confirm appointment
   */
  public async confirmAppointment(appointmentId: string, tenantId: string, userId: string): Promise<void> {
    await db.transaction(async (trx) => {
      await trx('appointments')
        .where({ id: appointmentId, tenant_id: tenantId })
        .update({
          status: 'confirmed',
          updated_at: new Date(),
        });

      // Log audit
      await trx('audit_logs').insert({
        tenant_id: tenantId,
        user_id: userId,
        action: 'CONFIRM',
        entity_type: 'appointment',
        entity_id: appointmentId,
      });
    });
  }

  /**
   * Update appointment (status, notes, etc.)
   */
  public async updateAppointment(
    appointmentId: string,
    tenantId: string,
    userId: string,
    updates: { status?: string; notes?: string }
  ): Promise<any> {
    return await db.transaction(async (trx) => {
      const updateData: any = {
        updated_at: new Date(),
      };

      if (updates.status) {
        updateData.status = updates.status;
      }
      if (updates.notes !== undefined) {
        updateData.notes = updates.notes;
      }

      const [updated] = await trx('appointments')
        .where({ id: appointmentId, tenant_id: tenantId })
        .update(updateData)
        .returning('*');

      // Log audit
      await trx('audit_logs').insert({
        tenant_id: tenantId,
        user_id: userId,
        action: 'UPDATE',
        entity_type: 'appointment',
        entity_id: appointmentId,
        new_values: updateData,
      });

      return updated;
    });
  }

  /**
   * Mark appointment as no-show
   */
  public async markNoShow(appointmentId: string, tenantId: string, userId: string): Promise<void> {
    await db.transaction(async (trx) => {
      await trx('appointments')
        .where({ id: appointmentId, tenant_id: tenantId })
        .update({
          status: 'no_show',
          updated_at: new Date(),
        });

      // Log audit
      await trx('audit_logs').insert({
        tenant_id: tenantId,
        user_id: userId,
        action: 'NO_SHOW',
        entity_type: 'appointment',
        entity_id: appointmentId,
      });
    });
  }

  /**
   * Get appointments with filters
   */
  public async getAppointments(params: any): Promise<any> {
    const { tenantId, userId, role, page, limit, status, doctorId, patientId, startDate, endDate } = params;

    let query = db('appointments').where({ tenant_id: tenantId });

    // Admin / Developer / Receptionist (SRS Rev 02): tenant-wide appointment context
    if (role === 'admin' || role === 'developer' || role === 'receptionist') {
      query = query
        .leftJoin('doctors', 'appointments.doctor_id', 'doctors.id')
        .leftJoin('users as doctor_users', 'doctors.user_id', 'doctor_users.id')
        .leftJoin('patients', 'appointments.patient_id', 'patients.id')
        .leftJoin('users as patient_users', 'patients.user_id', 'patient_users.id')
        .select(
          'appointments.*',
          db.raw(
            "TRIM(CONCAT(COALESCE(doctor_users.first_name, ''), ' ', COALESCE(doctor_users.last_name, ''))) as doctorName"
          ),
          db.raw(
            "TRIM(CONCAT(COALESCE(patient_users.first_name, ''), ' ', COALESCE(patient_users.last_name, ''))) as patientName"
          ),
          'doctors.specialty as specialty'
        );
    }

    // Apply role-based filters
    if (role === 'patient') {
      let patient = await db('patients')
        .where({ user_id: userId, tenant_id: tenantId })
        .first();
      if (!patient && userId) {
        patient = await db('patients')
          .where({ user_id: userId })
          .first();
      }
      if (!patient) {
        return { data: [], page, limit, total: 0 };
      }
      if (patient.tenant_id && patient.tenant_id !== tenantId) {
        query = db('appointments').where({ tenant_id: patient.tenant_id });
      }
      query = query.where({ patient_id: patient.id });
    } else if (role === 'doctor' || role === 'paramedical') {
      let doctor = await db('doctors')
        .where({ user_id: userId, tenant_id: tenantId })
        .first();
      if (!doctor && userId) {
        doctor = await db('doctors')
          .where({ user_id: userId })
          .first();
      }
      if (!doctor) {
        return { data: [], page, limit, total: 0 };
      }
      if (doctor.tenant_id && doctor.tenant_id !== tenantId) {
        query = db('appointments').where({ tenant_id: doctor.tenant_id });
      }
      query = query.where({ doctor_id: doctor.id });
    }

    // Apply filters
    if (status) {
      query = query.where({ status });
    }
    if (doctorId) {
      query = query.where({ doctor_id: doctorId });
    }
    if (patientId) {
      query = query.where({ patient_id: patientId });
    }
    if (startDate) {
      query = query.where('appointment_date', '>=', startDate);
    }
    if (endDate) {
      query = query.where('appointment_date', '<=', endDate);
    }

    // Get total count
    const [{ count }] = await query.clone().clearSelect().count('* as count');

    // Get paginated data
    const data = await query
      .orderBy('appointment_date', 'asc')
      .limit(limit)
      .offset((page - 1) * limit);

    return {
      data,
      page,
      limit,
      total: Number(count),
    };
  }

  /**
   * Get appointment by ID
   */
  public async getAppointmentById(id: string, tenantId: string, userId: string, role: string): Promise<any> {
    let query = db('appointments').where({ id, tenant_id: tenantId });

    // Apply role-based access
    if (role === 'patient') {
      const patient = await db('patients')
        .where({ user_id: userId, tenant_id: tenantId })
        .first();
      if (!patient) {
        return null;
      }
      query = query.where({ patient_id: patient.id });
    } else if (role === 'doctor' || role === 'paramedical') {
      const doctor = await db('doctors')
        .where({ user_id: userId, tenant_id: tenantId })
        .first();
      if (!doctor) {
        return null;
      }
      query = query.where({ doctor_id: doctor.id });
    }

    const appointment = await query.first();
    return appointment;
  }

  /**
   * Helper: Check if slot is blocked by exception
   */
  private isSlotBlocked(slotTime: Date, durationMinutes: number, exceptions: any[]): boolean {
    const dateOnly = format(slotTime, 'yyyy-MM-dd');
    const timeOnly = format(slotTime, 'HH:mm:ss');
    const slotEnd = format(addMinutes(slotTime, durationMinutes), 'HH:mm:ss');

    const exception = exceptions.find((e) => e.date === dateOnly && e.type === 'blocked');

    if (!exception) {
      return false;
    }

    if (!exception.start_time && !exception.end_time) {
      return true; // Entire day blocked
    }

    if (exception.start_time && exception.end_time) {
      return timeOnly >= exception.start_time && slotEnd <= exception.end_time;
    }

    return false;
  }

  /**
   * Helper: Check if slot conflicts with existing appointment
   */
  private hasAppointmentConflict(slotTime: Date, durationMinutes: number, appointments: any[]): boolean {
    const slotEnd = addMinutes(slotTime, durationMinutes);

    return appointments.some((apt) => {
      const aptStart = new Date(apt.appointment_date);
      const aptEnd = addMinutes(aptStart, apt.duration_minutes);

      // Check for overlap
      return (
        (slotTime >= aptStart && slotTime < aptEnd) ||
        (slotEnd > aptStart && slotEnd <= aptEnd) ||
        (slotTime <= aptStart && slotEnd >= aptEnd)
      );
    });
  }

  /**
   * Clear appointment-related cache
   */
  private async clearAppointmentCache(tenantId: string, doctorId: string, patientId: string): Promise<void> {
    try {
      await redis.del(`appointments:tenant:${tenantId}`);
      await redis.del(`appointments:doctor:${doctorId}`);
      await redis.del(`appointments:patient:${patientId}`);
    } catch (error) {
      logger.error('Error clearing appointment cache:', error);
    }
  }

  /**
   * AI no-show prediction: compute risk score for an appointment (heuristic-based).
   * Returns risk level and score 0-100. Replace with ML model in production.
   */
  public async getNoShowRisk(appointmentId: string, tenantId: string): Promise<{ risk: 'low' | 'medium' | 'high'; score: number; factors: string[] }> {
    const factors: string[] = [];
    let score = 20; // base

    const appointment = await db('appointments')
      .where({ id: appointmentId, tenant_id: tenantId })
      .first();
    if (!appointment) {
      return { risk: 'low', score: 0, factors: ['Appointment not found'] };
    }

    const appointmentDate = new Date(appointment.appointment_date);
    const hoursUntil = (appointmentDate.getTime() - Date.now()) / (1000 * 60 * 60);

    if (hoursUntil < 24) factors.push('Less than 24h until appointment');
    if (hoursUntil < 2) {
      score += 25;
      factors.push('Within 2 hours');
    } else if (hoursUntil < 24) {
      score += 10;
    }

    const patientId = appointment.patient_id;
    const pastNoShows = await db('appointments')
      .where({ patient_id: patientId, tenant_id: tenantId, status: 'no_show' })
      .count('id as count')
      .first();
    const noShowCount = Number((pastNoShows as any)?.count || 0);
    if (noShowCount > 0) {
      score += Math.min(noShowCount * 15, 35);
      factors.push(`Patient has ${noShowCount} past no-show(s)`);
    }

    const dayOfWeek = appointmentDate.getDay();
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      score += 10;
      factors.push('Weekend appointment');
    }

    score = Math.min(100, Math.max(0, score));
    const risk: 'low' | 'medium' | 'high' = score >= 60 ? 'high' : score >= 35 ? 'medium' : 'low';
    return { risk, score, factors };
  }
}
