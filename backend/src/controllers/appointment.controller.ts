import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { AppointmentService } from '../services/appointment.service';
import { logger } from '../config/logger';
import { ApiError } from '../utils/apiError';
import db from '../config/database';

export class AppointmentController {
  private appointmentService: AppointmentService;

  constructor() {
    this.appointmentService = new AppointmentService();
  }

  private resolveTenantId(req: Request): string {
    const tenantId =
      req.tenantId ||
      req.user?.tenantId ||
      (req.headers['x-tenant-id'] as string | undefined) ||
      '';
    if (!tenantId) {
      throw new ApiError(400, 'Tenant ID not found');
    }
    return tenantId;
  }

  private async resolvePatientIdForBooking(
    tenantId: string,
    body: any
  ): Promise<{ patientId: string; guestSnapshot?: Record<string, unknown> }> {
    const directPatientId = (body?.patientId || '').toString().trim();
    if (directPatientId) {
      return { patientId: directPatientId };
    }

    const guest = body?.guestPatient || {};
    const fullName = (guest.fullName || '').toString().trim();
    const phone = (guest.phone || '').toString().trim();
    const email = (guest.email || '').toString().trim().toLowerCase();
    const idNumber = (guest.idNumber || '').toString().trim();

    if (!fullName || !phone) {
      throw new ApiError(400, 'Either patientId or guestPatient(fullName, phone) is required');
    }

    // Reuse existing patient by tenant+email when available.
    if (email) {
      const existing = await db('patients as p')
        .join('users as u', 'p.user_id', 'u.id')
        .where('p.tenant_id', tenantId)
        .andWhereRaw('LOWER(u.email) = ?', [email])
        .select('p.id')
        .first();
      if (existing?.id) {
        return {
          patientId: String(existing.id),
          guestSnapshot: { fullName, phone, email, idNumber },
        };
      }
    }

    const userColumnsRaw = await db('information_schema.columns')
      .where({ table_name: 'users' })
      .select('column_name');
    const userColumns = new Set(userColumnsRaw.map((r: any) => String(r.column_name)));
    const hasIsActive = userColumns.has('is_active');

    const parts = fullName.split(/\s+/).filter((s: string) => s.length > 0);
    const firstName = parts.length > 0 ? parts[0] : 'Guest';
    const lastName = parts.length > 1 ? parts.slice(1).join(' ') : 'Patient';
    const generatedEmail =
      email.length > 0
          ? email
          : `guest_${Date.now()}_${phone.replace(/[^0-9]/g, '')}@guest.local`;
    const randomPasswordHash = await bcrypt.hash(crypto.randomBytes(24).toString('hex'), 10);

    let newPatientId = '';
    await db.transaction(async (trx) => {
      const [newUser] = await trx('users')
        .insert({
          tenant_id: tenantId,
          email: generatedEmail,
          password_hash: randomPasswordHash,
          first_name: firstName,
          last_name: lastName,
          phone: phone || null,
          role: 'patient',
          is_email_verified: false,
          ...(hasIsActive ? { is_active: true } : {}),
          metadata: {
            guest_booking: true,
            source: 'reception_booking',
            id_number: idNumber || null,
            original_name: fullName,
          },
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning(['id']);

      const [newPatient] = await trx('patients')
        .insert({
          user_id: newUser.id,
          tenant_id: tenantId,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning(['id']);
      newPatientId = String(newPatient.id);
    });

    return {
      patientId: newPatientId,
      guestSnapshot: { fullName, phone, email: generatedEmail, idNumber },
    };
  }

  /**
   * Get all appointments
   * @route GET /api/v1/appointments
   */
  public async getAppointments(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const tenantId = this.resolveTenantId(req);
      const userId = req.user?.userId || req.user?.id || '';
      const role = req.user?.role || '';

      const { page = 1, limit = 20, status, doctorId, patientId, startDate, endDate } = req.query;

      const result = await this.appointmentService.getAppointments({
        tenantId,
        userId,
        role,
        page: Number(page),
        limit: Number(limit),
        status: status as string,
        doctorId: doctorId as string,
        patientId: patientId as string,
        startDate: startDate as string,
        endDate: endDate as string,
      });

      res.status(200).json({
        success: true,
        data: result.data,
        pagination: {
          page: result.page,
          limit: result.limit,
          total: result.total,
          totalPages: Math.ceil(result.total / result.limit),
        },
      });
    } catch (error) {
      logger.error('Error getting appointments:', error);
      next(error);
    }
  }

  /**
   * Get no-show risk prediction for an appointment
   * @route GET /api/v1/appointments/:id/no-show-risk
   */
  public async getNoShowRisk(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const tenantId = this.resolveTenantId(req);
      const result = await this.appointmentService.getNoShowRisk(id, tenantId);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      logger.error('Error getting no-show risk:', error);
      next(error);
    }
  }

  /**
   * Get appointment by ID
   * @route GET /api/v1/appointments/:id
   */
  public async getAppointmentById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const tenantId = this.resolveTenantId(req);
      const userId = req.user?.userId || req.user?.id || '';
      const role = req.user?.role || '';

      const appointment = await this.appointmentService.getAppointmentById(id, tenantId, userId, role);

      if (!appointment) {
        throw new ApiError(404, 'Appointment not found');
      }

      res.status(200).json({
        success: true,
        data: appointment,
      });
    } catch (error) {
      logger.error('Error getting appointment:', error);
      next(error);
    }
  }

  /**
   * Book new appointment
   * @route POST /api/v1/appointments
   */
  public async bookAppointment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const tenantId = this.resolveTenantId(req);
      const userId = req.user?.userId || req.user?.id || '';

      const {
        doctorId,
        serviceId,
        appointmentDate,
        durationMinutes,
        notes,
        location,
        isTelehealth,
        patientId,
        guestPatient,
      } = req.body;

      // Validate required fields
      if (!doctorId || !appointmentDate) {
        throw new ApiError(400, 'Doctor ID and appointment date are required');
      }

      const role = (req.user?.role as string) || 'admin';
      let resolved: { patientId: string; guestSnapshot?: Record<string, unknown> };
      if (!patientId && role === 'patient') {
        const selfPatient = await db('patients')
          .where({ tenant_id: tenantId, user_id: userId })
          .select('id')
          .first();
        if (!selfPatient?.id) {
          throw new ApiError(404, 'Patient profile not found');
        }
        resolved = { patientId: String(selfPatient.id) };
      } else {
        resolved = await this.resolvePatientIdForBooking(tenantId, {
          patientId,
          guestPatient,
        });
      }

      // Availability + overbooking enforced atomically inside bookAppointment
      const { appointment, booking_meta } = await this.appointmentService.bookAppointment({
        tenantId,
        patientId: resolved.patientId || userId, // If patient books for themselves
        doctorId,
        serviceId,
        appointmentDate: new Date(appointmentDate),
        durationMinutes: durationMinutes || 30,
        notes,
        location,
        isTelehealth: isTelehealth || false,
        bookedBy: userId,
        actorRole: role,
        guestPatient: resolved.guestSnapshot,
      });

      logger.info(`Appointment booked: ${appointment.id}`);

      res.status(201).json({
        success: true,
        data: appointment,
        booking_meta,
        message: 'Appointment booked successfully',
      });
    } catch (error) {
      logger.error('Error booking appointment:', error);
      next(error);
    }
  }

  /**
   * Cancel appointment
   * @route DELETE /api/v1/appointments/:id
   */
  public async cancelAppointment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { reason } = req.body;
      const tenantId = this.resolveTenantId(req);
      const userId = req.user?.userId || req.user?.id || '';
      const role = req.user?.role || '';

      // Check cancellation policy
      const canCancel = await this.appointmentService.canCancelAppointment(id, tenantId);

      if (!canCancel.allowed) {
        throw new ApiError(400, canCancel.reason || 'Cannot cancel appointment');
      }

      await this.appointmentService.cancelAppointment({
        appointmentId: id,
        tenantId,
        userId,
        role,
        reason,
      });

      logger.info(`Appointment cancelled: ${id} by user: ${userId}`);

      res.status(200).json({
        success: true,
        message: 'Appointment cancelled successfully',
        penalty: canCancel.penalty,
      });
    } catch (error) {
      logger.error('Error cancelling appointment:', error);
      next(error);
    }
  }

  /**
   * Reschedule appointment
   * @route POST /api/v1/appointments/:id/reschedule
   */
  public async rescheduleAppointment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { newAppointmentDate, durationMinutes, reason } = req.body;
      const tenantId = this.resolveTenantId(req);
      const userId = req.user?.userId || req.user?.id || '';
      const role = req.user?.role || '';

      if (!newAppointmentDate) {
        throw new ApiError(400, 'New appointment date is required');
      }

      // Get original appointment
      const originalAppointment = await this.appointmentService.getAppointmentById(id, tenantId, userId, role);

      if (!originalAppointment) {
        throw new ApiError(404, 'Appointment not found');
      }

      // Check new slot availability
      const isAvailable = await this.appointmentService.checkAvailability({
        doctorId: originalAppointment.doctorId,
        appointmentDate: new Date(newAppointmentDate),
        durationMinutes: durationMinutes || originalAppointment.durationMinutes,
        tenantId,
        excludeAppointmentId: id,
      });

      if (!isAvailable) {
        throw new ApiError(409, 'The new time slot is not available');
      }

      // Reschedule
      const updatedAppointment = await this.appointmentService.rescheduleAppointment({
        appointmentId: id,
        newAppointmentDate: new Date(newAppointmentDate),
        durationMinutes,
        reason,
        tenantId,
        userId,
      });

      logger.info(`Appointment rescheduled: ${id}`);

      res.status(200).json({
        success: true,
        data: updatedAppointment,
        message: 'Appointment rescheduled successfully',
      });
    } catch (error) {
      logger.error('Error rescheduling appointment:', error);
      next(error);
    }
  }

  /**
   * Confirm appointment
   * @route POST /api/v1/appointments/:id/confirm
   */
  public async confirmAppointment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const tenantId = this.resolveTenantId(req);
      const userId = req.user?.userId || req.user?.id || '';

      await this.appointmentService.confirmAppointment(id, tenantId, userId);

      logger.info(`Appointment confirmed: ${id} by user: ${userId}`);

      res.status(200).json({
        success: true,
        message: 'Appointment confirmed successfully',
      });
    } catch (error) {
      logger.error('Error confirming appointment:', error);
      next(error);
    }
  }

  /**
   * Update appointment
   * @route PUT /api/v1/appointments/:id
   */
  public async updateAppointment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const tenantId = this.resolveTenantId(req);
      const userId = req.user?.userId || req.user?.id || '';
      const { status, notes } = req.body;

      const updated = await this.appointmentService.updateAppointment(id, tenantId, userId, {
        status,
        notes,
      });

      logger.info(`Appointment updated: ${id} by user: ${userId}`);

      res.status(200).json({
        success: true,
        data: updated,
        message: 'Appointment updated successfully',
      });
    } catch (error) {
      logger.error('Error updating appointment:', error);
      next(error);
    }
  }

  /**
   * Mark appointment as no-show
   * @route POST /api/v1/appointments/:id/no-show
   */
  public async markNoShow(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const tenantId = this.resolveTenantId(req);
      const userId = req.user?.userId || req.user?.id || '';

      await this.appointmentService.markNoShow(id, tenantId, userId);

      logger.info(`Appointment marked as no-show: ${id}`);

      res.status(200).json({
        success: true,
        message: 'Appointment marked as no-show',
      });
    } catch (error) {
      logger.error('Error marking no-show:', error);
      next(error);
    }
  }

  /**
   * Get available slots for a doctor
   * @route GET /api/v1/appointments/available-slots
   */
  public async getAvailableSlots(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const tenantId = this.resolveTenantId(req);
      const { doctorId, startDate, endDate, durationMinutes = 30 } = req.query;

      if (!doctorId || !startDate) {
        throw new ApiError(400, 'Doctor ID and start date are required');
      }

      const slots = await this.appointmentService.getAvailableSlots({
        doctorId: doctorId as string,
        startDate: new Date(startDate as string),
        endDate: endDate ? new Date(endDate as string) : undefined,
        durationMinutes: Number(durationMinutes),
        tenantId,
      });

      res.status(200).json({
        success: true,
        data: slots,
      });
    } catch (error) {
      logger.error('Error getting available slots:', error);
      next(error);
    }
  }
}
