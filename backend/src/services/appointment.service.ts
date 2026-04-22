import db from '../config/database';
import redis from '../config/redis';
import { logger } from '../config/logger';
import { ApiError } from '../utils/apiError';
import { add, addMinutes, format, isAfter, isBefore } from 'date-fns';
import { formatInTimeZone, zonedTimeToUtc } from 'date-fns-tz';
import { fireGoogleCalendarSync } from './appointmentGoogleCalendarSync.service';
import { noShowOverbookingService } from './noShowOverbooking.service';
import { appointmentSmsAutomationService } from './appointmentSmsAutomation.service';
import { noShowPredictionService } from './noShowPrediction.service';

export type BookAppointmentMeta = {
  overbooked: boolean;
  overbooking?: {
    reason: string;
    risk_score: number;
    risk_threshold: number | null;
    max_extra_slots: number | null;
    current_extra_in_slot: number;
    overlapping_appointments: number;
    rule_enabled: boolean;
  };
};

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
  /** JWT role of booker (for AI service / prediction scope). */
  actorRole?: string;
  /** Optional snapshot for non-registered bookings. */
  guestPatient?: {
    fullName?: string;
    phone?: string;
    email?: string;
    idNumber?: string;
  };
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

  /** DB day_of_week: 0=Sun..6=Sat; from ISO weekday in this timezone (1=Mon..7=Sun). */
  private dayOfWeekInTimezone(d: Date): number {
    const i = parseInt(formatInTimeZone(d, this.timezone, 'i'), 10);
    if (Number.isNaN(i)) return 0;
    return i === 7 ? 0 : i;
  }

  private ymdInTimezone(d: Date): string {
    return formatInTimeZone(d, this.timezone, 'yyyy-MM-dd');
  }

  private timeHmssInTimezone(d: Date): string {
    return formatInTimeZone(d, this.timezone, 'HH:mm:ss');
  }

  private minutesFromMidnightInTimezone(d: Date): number {
    const h = parseInt(formatInTimeZone(d, this.timezone, 'H'), 10);
    const m = parseInt(formatInTimeZone(d, this.timezone, 'm'), 10);
    return h * 60 + m;
  }

  private addOneCalendarYmd(ymd: string): string {
    const t = zonedTimeToUtc(`${ymd}T12:00:00.000`, this.timezone);
    const t2 = add(t, { days: 1 });
    return formatInTimeZone(t2, this.timezone, 'yyyy-MM-dd');
  }

  /**
   * Book a new appointment
   */
  public async bookAppointment(
    params: BookAppointmentParams,
  ): Promise<{ appointment: Record<string, unknown>; booking_meta: BookAppointmentMeta }> {
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
      actorRole,
      guestPatient,
    } = params;

    let bookingMetaOverbooked = false;
    let bookingMetaDetail: BookAppointmentMeta['overbooking'] | undefined;

    const appointment = (await db.transaction(async (trx) => {
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

        // 3. Double-check availability (atomic + overbooking rules)
        const slot = await this.checkAvailabilityInTransaction(
          trx,
          doctorId,
          appointmentDate,
          durationMinutes,
          tenantId,
        );

        bookingMetaOverbooked = slot.overbooked;
        if (slot.overbooked && slot.overbooking_detail) {
          bookingMetaDetail = slot.overbooking_detail;
        }

        // 4. Create appointment
        const apptColumnsRaw = await trx('information_schema.columns')
          .where({ table_name: 'appointments' })
          .select('column_name');
        const apptColumns = new Set(apptColumnsRaw.map((r: any) => String(r.column_name)));

        const guestPayload: Record<string, unknown> = {};
        if (guestPatient && apptColumns.has('guest_name')) {
          guestPayload.guest_name = guestPatient.fullName || null;
        }
        if (guestPatient && apptColumns.has('guest_phone')) {
          guestPayload.guest_phone = guestPatient.phone || null;
        }
        if (guestPatient && apptColumns.has('guest_email')) {
          guestPayload.guest_email = guestPatient.email || null;
        }
        if (guestPatient && apptColumns.has('guest_id_number')) {
          guestPayload.guest_id_number = guestPatient.idNumber || null;
        }

        const [created] = await trx('appointments')
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
            ...guestPayload,
          })
          .returning('*');

        // 5. Log audit
        await trx('audit_logs').insert({
          tenant_id: tenantId,
          user_id: bookedBy,
          action: 'CREATE',
          entity_type: 'appointment',
          entity_id: created.id,
          new_values: created,
          ip_address: null, // Would come from request
        });

        // 6. Clear cache
        await this.clearAppointmentCache(tenantId, doctorId, patientId);

        logger.info(`Appointment booked successfully: ${created.id}`);
        return created;
      } catch (error) {
        logger.error('Error in bookAppointment transaction:', error);
        throw error;
      }
    })) as Record<string, unknown>;

    const predictionScope = {
      tenantId,
      role: actorRole || 'admin',
      scopedDoctorId: null as string | null,
      actorUserId: bookedBy,
    };

    try {
      await noShowPredictionService.predictAppointmentNoShow(predictionScope, String(appointment.id));
    } catch (e) {
      logger.warn('Auto no-show prediction after booking failed', {
        appointmentId: appointment.id,
        error: e instanceof Error ? e.message : String(e),
      });
    }

    fireGoogleCalendarSync(appointment.id as string);
    try {
      await appointmentSmsAutomationService.onAppointmentBooked(String(appointment.id));
    } catch (e) {
      logger.warn('Post-book SMS automation failed', { error: (e as Error)?.message });
    }

    const booking_meta: BookAppointmentMeta = {
      overbooked: bookingMetaOverbooked,
      ...(bookingMetaDetail ? { overbooking: bookingMetaDetail } : {}),
    };

    return { appointment, booking_meta };
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

    // 2. Check doctor's regular availability (wall-clock in clinic timezone, e.g. Asia/Jerusalem)
    const dayOfWeek = this.dayOfWeekInTimezone(appointmentDate);
    const appointmentTime = this.timeHmssInTimezone(appointmentDate);

    const regularAvailability = await db('availability')
      .where({
        doctor_id: doctorId,
        tenant_id: tenantId,
        day_of_week: dayOfWeek,
        is_active: true,
      })
      .andWhere('start_time', '<=', appointmentTime)
      .andWhere('end_time', '>=', this.timeHmssInTimezone(appointmentEnd))
      .first();

    if (!regularAvailability) {
      return false;
    }

    // 3. Check for exceptions (holidays, blocked dates)
    const dateOnly = this.ymdInTimezone(appointmentDate);
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

    const timeOffRows = await db('doctor_time_off')
      .where({ doctor_id: doctorId, tenant_id: tenantId })
      .select('start_date', 'end_date');
    if (this.isDateInDoctorTimeOff(dateOnly, timeOffRows)) {
      return false;
    }
    const breakRows = await db('doctor_breaks')
      .where({ doctor_id: doctorId, tenant_id: tenantId, is_active: true })
      .select('day_of_week', 'start_time', 'end_time');
    if (this.breaksOverlapSlot(appointmentDate, appointmentEnd, breakRows)) {
      return false;
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
      const ids = conflictingAppointments.map((c: { id: string }) => c.id);
      const preds = await db('appointment_no_show_predictions')
        .where({ tenant_id: tenantId, is_current: true })
        .whereIn('appointment_id', ids)
        .select('risk_score');
      let maxRisk = 0;
      for (const p of preds) {
        maxRisk = Math.max(maxRisk, Number((p as { risk_score?: unknown }).risk_score || 0));
      }
      const extraInSlot = conflictingAppointments.length - 1;
      const ev = await noShowOverbookingService.evaluate(tenantId, doctorId, maxRisk, extraInSlot);
      if (!ev.allowed) {
        return false;
      }
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
    tenantId: string,
  ): Promise<{
    overbooked: boolean;
    overbooking_detail?: BookAppointmentMeta['overbooking'];
  }> {
    const appointmentEnd = addMinutes(appointmentDate, durationMinutes);
    const dateOnly = this.ymdInTimezone(appointmentDate);

    const dayOfWeek = this.dayOfWeekInTimezone(appointmentDate);
    const appointmentTime = this.timeHmssInTimezone(appointmentDate);
    const regularAvailability = await trx('availability')
      .where({
        doctor_id: doctorId,
        tenant_id: tenantId,
        day_of_week: dayOfWeek,
        is_active: true,
      })
      .andWhere('start_time', '<=', appointmentTime)
      .andWhere('end_time', '>=', this.timeHmssInTimezone(appointmentEnd))
      .first();
    if (!regularAvailability) {
      throw new ApiError(409, 'Time slot is not available');
    }

    const exception = await trx('availability_exceptions')
      .where({
        doctor_id: doctorId,
        tenant_id: tenantId,
        date: dateOnly,
        type: 'blocked',
      })
      .first();
    if (exception) {
      if (
        exception.start_time &&
        exception.end_time &&
        appointmentTime >= exception.start_time &&
        appointmentTime <= exception.end_time
      ) {
        throw new ApiError(409, 'Time slot is not available');
      }
      if (!exception.start_time && !exception.end_time) {
        throw new ApiError(409, 'Time slot is not available');
      }
    }

    const timeOffRows = await trx('doctor_time_off')
      .where({ doctor_id: doctorId, tenant_id: tenantId })
      .select('start_date', 'end_date');
    if (this.isDateInDoctorTimeOff(dateOnly, timeOffRows)) {
      throw new ApiError(409, 'Time slot is not available');
    }
    const breakRows = await trx('doctor_breaks')
      .where({ doctor_id: doctorId, tenant_id: tenantId, is_active: true })
      .select('day_of_week', 'start_time', 'end_time');
    if (this.breaksOverlapSlot(appointmentDate, appointmentEnd, breakRows)) {
      throw new ApiError(409, 'Time slot is not available');
    }

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

    if (conflictingAppointments.length === 0) {
      return { overbooked: false };
    }

    const ids = conflictingAppointments.map((c: { id: string }) => c.id);
    const preds = await trx('appointment_no_show_predictions')
      .where({ tenant_id: tenantId, is_current: true })
      .whereIn('appointment_id', ids)
      .select('risk_score');
    let maxRisk = 0;
    for (const p of preds) {
      maxRisk = Math.max(maxRisk, Number((p as { risk_score?: unknown }).risk_score || 0));
    }
    const extraInSlot = conflictingAppointments.length - 1;
    const detailed = await noShowOverbookingService.evaluateDetailed(
      tenantId,
      doctorId,
      maxRisk,
      extraInSlot,
    );

    const detailPayload: BookAppointmentMeta['overbooking'] = {
      reason: detailed.reason,
      risk_score: detailed.risk_score,
      risk_threshold: detailed.risk_threshold,
      max_extra_slots: detailed.max_extra_slots,
      current_extra_in_slot: detailed.current_extra_in_slot,
      overlapping_appointments: conflictingAppointments.length,
      rule_enabled: detailed.rule_enabled,
    };

    if (detailed.allowed) {
      logger.info('Slot overbooking approved (transaction)', {
        tenantId,
        doctorId,
        maxRisk,
        extraInSlot,
        reason: detailed.reason,
      });
      return { overbooked: true, overbooking_detail: detailPayload };
    }

    throw new ApiError(409, 'Time slot is no longer available', {
      overbooking: detailPayload,
    });
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
    const startYmd = formatInTimeZone(startDate, this.timezone, 'yyyy-MM-dd');
    const endYmd = formatInTimeZone(endDateOrDefault, this.timezone, 'yyyy-MM-dd');

    const exceptions = await db('availability_exceptions')
      .where({ doctor_id: doctorId, tenant_id: tenantId })
      .whereBetween('date', [startYmd, endYmd]);

    const [doctorBreaks, doctorTimeOff] = await Promise.all([
      db('doctor_breaks')
        .where({ doctor_id: doctorId, tenant_id: tenantId, is_active: true })
        .select('day_of_week', 'start_time', 'end_time'),
      db('doctor_time_off').where({ doctor_id: doctorId, tenant_id: tenantId }).select('start_date', 'end_date'),
    ]);

    const availableSlots: Date[] = [];
    const pad2 = (n: number) => n.toString().padStart(2, '0');
    let ymd = startYmd;
    while (ymd <= endYmd) {
      if (this.isDateInDoctorTimeOff(ymd, doctorTimeOff)) {
        ymd = this.addOneCalendarYmd(ymd);
        continue;
      }
      const noon = zonedTimeToUtc(`${ymd}T12:00:00.000`, this.timezone);
      const dayOfWeek = this.dayOfWeekInTimezone(noon);
      const dayAvailability = availability.filter((a) => a.day_of_week === dayOfWeek);

      for (const av of dayAvailability) {
        const [startHour, startMinute] = av.start_time.split(':').map(Number);
        const [endHour, endMinute] = av.end_time.split(':').map(Number);

        let slotTime = zonedTimeToUtc(
          `${ymd} ${pad2(startHour)}:${pad2(startMinute)}:00`,
          this.timezone,
        );
        const endTime = zonedTimeToUtc(
          `${ymd} ${pad2(endHour)}:${pad2(endMinute)}:00`,
          this.timezone,
        );

        while (
          isBefore(addMinutes(slotTime, durationMinutes), endTime) ||
          slotTime.getTime() === endTime.getTime()
        ) {
          if (isAfter(slotTime, new Date())) {
            const isBlocked = this.isSlotBlocked(slotTime, durationMinutes, exceptions);
            const hasConflict = this.hasAppointmentConflict(slotTime, durationMinutes, appointments);
            const slotEnd = addMinutes(slotTime, durationMinutes);
            const inBreak = this.breaksOverlapSlot(slotTime, slotEnd, doctorBreaks);

            if (!isBlocked && !hasConflict && !inBreak) {
              availableSlots.push(new Date(slotTime));
            }
          }

          slotTime = addMinutes(slotTime, durationMinutes);
        }
      }

      ymd = this.addOneCalendarYmd(ymd);
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

    fireGoogleCalendarSync(appointmentId);
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

    fireGoogleCalendarSync(appointmentId);
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

    fireGoogleCalendarSync(appointmentId);
  }

  /**
   * Get appointments with filters
   */
  public async getAppointments(params: any): Promise<any> {
    const { tenantId, userId, role, page, limit, status, doctorId, patientId, startDate, endDate } = params;

    let query = db('appointments').where({ tenant_id: tenantId });

    // Admin / Developer / Doctor / Paramedical: include patient and doctor display fields (IDs alone are not useful in UI).
    if (role === 'admin' || role === 'developer' || role === 'doctor' || role === 'paramedical') {
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
            "COALESCE(NULLIF(TRIM(CONCAT(COALESCE(patient_users.first_name, ''), ' ', COALESCE(patient_users.last_name, ''))), ''), appointments.guest_name, 'מטופל') as patientName"
          ),
          db.raw(
            "NULLIF(TRIM(COALESCE(patient_users.phone, appointments.guest_phone, '')), '') as patientPhone"
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
   * Re-run post-booking WhatsApp/Telegram/email flow for an appointment (doctor/staff only).
   */
  public async resendBookingNotification(
    appointmentId: string,
    tenantId: string,
    userId: string,
    role: string,
  ): Promise<void> {
    if (!['doctor', 'paramedical', 'admin', 'developer'].includes(role)) {
      throw new ApiError(403, 'Not allowed to resend patient notification');
    }
    const appointment = await this.getAppointmentById(appointmentId, tenantId, userId, role);
    if (!appointment) {
      throw new ApiError(404, 'Appointment not found');
    }
    await appointmentSmsAutomationService.onAppointmentBooked(appointmentId);
  }

  private toYmd(value: unknown): string {
    if (value == null) return '';
    if (value instanceof Date) return format(value, 'yyyy-MM-dd');
    const s = String(value);
    if (s.length >= 10) {
      if (s.includes('T')) {
        return format(new Date(s), 'yyyy-MM-dd');
      }
      return s.slice(0, 10);
    }
    return '';
  }

  private isDateInDoctorTimeOff(ymd: string, rows: any[]): boolean {
    return rows.some((r) => {
      const a = this.toYmd(r.start_date);
      const b = this.toYmd(r.end_date);
      return a <= ymd && ymd <= b;
    });
  }

  private timePartsToMinutes(t: unknown): number {
    const s = String(t ?? '');
    const m = s.match(/^(\d{1,2}):(\d{2})/);
    if (!m) return -1;
    return parseInt(m[1], 10) * 60 + parseInt(m[2], 10);
  }

  /** True if [slotStart, slotEnd) overlaps any doctor break on that weekday. */
  private breaksOverlapSlot(slotStart: Date, slotEnd: Date, breaks: any[]): boolean {
    const dow = this.dayOfWeekInTimezone(slotStart);
    const sm = this.minutesFromMidnightInTimezone(slotStart);
    const em = this.minutesFromMidnightInTimezone(slotEnd);
    for (const br of breaks) {
      if (Number(br.day_of_week) !== dow) continue;
      const bs = this.timePartsToMinutes(br.start_time);
      const be = this.timePartsToMinutes(br.end_time);
      if (bs < 0 || be < 0) continue;
      if (sm < be && em > bs) return true;
    }
    return false;
  }

  /**
   * Helper: Check if slot is blocked by exception
   */
  private isSlotBlocked(slotTime: Date, durationMinutes: number, exceptions: any[]): boolean {
    const dateOnly = this.ymdInTimezone(slotTime);
    const timeOnly = this.timeHmssInTimezone(slotTime);
    const slotEnd = this.timeHmssInTimezone(addMinutes(slotTime, durationMinutes));

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
   * Data-driven no-show prediction.
   * Trains a lightweight logistic model on tenant historical appointments.
   */
  public async getNoShowRisk(appointmentId: string, tenantId: string): Promise<{ risk: 'low' | 'medium' | 'high'; score: number; factors: string[] }> {
    const appointment = await db('appointments')
      .where({ id: appointmentId, tenant_id: tenantId })
      .first();
    if (!appointment) {
      return { risk: 'low', score: 0, factors: ['Appointment not found'] };
    }

    const rows = await db('appointments')
      .where({ tenant_id: tenantId })
      .whereIn('status', ['completed', 'no_show', 'cancelled'])
      .whereNotNull('appointment_date')
      .orderBy('appointment_date', 'desc')
      .limit(3000)
      .select('patient_id', 'status', 'appointment_date', 'created_at', 'duration_minutes');

    const byPatient = new Map<string, { total: number; noShows: number }>();
    for (const r of rows) {
      const pid = (r as any).patient_id ? String((r as any).patient_id) : '';
      if (!pid) continue;
      const cur = byPatient.get(pid) || { total: 0, noShows: 0 };
      cur.total += 1;
      if ((r as any).status === 'no_show') cur.noShows += 1;
      byPatient.set(pid, cur);
    }

    const featuresFrom = (r: any): number[] => {
      const appt = new Date(r.appointment_date);
      const created = r.created_at ? new Date(r.created_at) : new Date(appt.getTime() - 24 * 3600 * 1000);
      const leadHours = Math.max(0, (appt.getTime() - created.getTime()) / 3600000);
      const hour = appt.getHours();
      const dow = appt.getDay();
      const duration = Number(r.duration_minutes || 0);
      const pid = r.patient_id ? String(r.patient_id) : '';
      const hist = byPatient.get(pid) || { total: 0, noShows: 0 };
      const patientNoShowRate = hist.total > 0 ? hist.noShows / hist.total : 0;
      const patientApptCount = hist.total;
      return [
        1, // bias
        Math.min(leadHours, 24 * 14) / (24 * 14), // 0..1 (up to 14 days)
        hour / 23,
        dow / 6,
        Math.min(duration, 180) / 180,
        patientNoShowRate,
        Math.min(patientApptCount, 30) / 30,
      ];
    };

    const train = rows.filter((r: any) => r.status === 'no_show' || r.status === 'completed');
    // Fallback to neutral output when insufficient data.
    if (train.length < 25) {
      return {
        risk: 'medium',
        score: 50,
        factors: ['Insufficient historical data for model training'],
      };
    }

    const x = train.map((r: any) => featuresFrom(r));
    const y = train.map((r: any) => (r.status === 'no_show' ? 1 : 0));
    const dim = x[0].length;
    const w = new Array<number>(dim).fill(0);
    const lr = 0.2;
    const epochs = 180;
    const sigmoid = (z: number) => 1 / (1 + Math.exp(-Math.max(-20, Math.min(20, z))));

    for (let epoch = 0; epoch < epochs; epoch += 1) {
      const grad = new Array<number>(dim).fill(0);
      for (let i = 0; i < x.length; i += 1) {
        let z = 0;
        for (let j = 0; j < dim; j += 1) z += w[j] * x[i][j];
        const p = sigmoid(z);
        const err = p - y[i];
        for (let j = 0; j < dim; j += 1) grad[j] += err * x[i][j];
      }
      for (let j = 0; j < dim; j += 1) {
        w[j] -= (lr / x.length) * grad[j];
      }
    }

    const targetFeatures = featuresFrom(appointment as any);
    let z = 0;
    for (let j = 0; j < dim; j += 1) z += w[j] * targetFeatures[j];
    const probability = sigmoid(z);
    const score = Math.max(0, Math.min(100, Math.round(probability * 100)));
    const risk: 'low' | 'medium' | 'high' = score >= 65 ? 'high' : score >= 35 ? 'medium' : 'low';

    const factors: string[] = [];
    const leadHoursRaw = targetFeatures[1] * (24 * 14);
    if (leadHoursRaw < 24) factors.push('Low lead-time before appointment');
    if (targetFeatures[5] > 0.25) factors.push('Patient historical no-show rate is high');
    if (targetFeatures[6] < 0.15) factors.push('Limited historical attendance data for patient');
    factors.push(`Model trained on ${train.length} historical appointments`);

    return { risk, score, factors };
  }
}
