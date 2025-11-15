"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppointmentService = void 0;
const database_1 = __importDefault(require("../config/database"));
const redis_1 = __importDefault(require("../config/redis"));
const logger_1 = require("../config/logger");
const apiError_1 = require("../utils/apiError");
const date_fns_1 = require("date-fns");
class AppointmentService {
    constructor() {
        this.timezone = process.env.TIMEZONE || 'Asia/Jerusalem';
    }
    /**
     * Book a new appointment
     */
    async bookAppointment(params) {
        const { tenantId, patientId, doctorId, serviceId, appointmentDate, durationMinutes, notes, location, isTelehealth, bookedBy, } = params;
        return await database_1.default.transaction(async (trx) => {
            try {
                // 1. Check if doctor exists and is active
                const doctor = await trx('doctors')
                    .where({ id: doctorId, tenant_id: tenantId, is_active: true })
                    .first();
                if (!doctor) {
                    throw new apiError_1.ApiError(404, 'Doctor not found or inactive');
                }
                // 2. Check if patient exists
                const patient = await trx('patients')
                    .where({ id: patientId, tenant_id: tenantId })
                    .first();
                if (!patient) {
                    throw new apiError_1.ApiError(404, 'Patient not found');
                }
                // 3. Double-check availability (atomic check within transaction)
                const isAvailable = await this.checkAvailabilityInTransaction(trx, doctorId, appointmentDate, durationMinutes, tenantId);
                if (!isAvailable) {
                    throw new apiError_1.ApiError(409, 'Time slot is no longer available');
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
                logger_1.logger.info(`Appointment booked successfully: ${appointment.id}`);
                return appointment;
            }
            catch (error) {
                logger_1.logger.error('Error in bookAppointment transaction:', error);
                throw error;
            }
        });
    }
    /**
     * Check if a time slot is available
     */
    async checkAvailability(params) {
        const { doctorId, appointmentDate, durationMinutes, tenantId, excludeAppointmentId } = params;
        const appointmentEnd = (0, date_fns_1.addMinutes)(appointmentDate, durationMinutes);
        // 1. Check if it's in the past
        if ((0, date_fns_1.isBefore)(appointmentDate, new Date())) {
            return false;
        }
        // 2. Check doctor's regular availability
        const dayOfWeek = appointmentDate.getDay();
        const appointmentTime = (0, date_fns_1.format)(appointmentDate, 'HH:mm:ss');
        const regularAvailability = await (0, database_1.default)('availability')
            .where({
            doctor_id: doctorId,
            tenant_id: tenantId,
            day_of_week: dayOfWeek,
            is_active: true,
        })
            .andWhere('start_time', '<=', appointmentTime)
            .andWhere('end_time', '>=', (0, date_fns_1.format)(appointmentEnd, 'HH:mm:ss'))
            .first();
        if (!regularAvailability) {
            return false;
        }
        // 3. Check for exceptions (holidays, blocked dates)
        const dateOnly = (0, date_fns_1.format)(appointmentDate, 'yyyy-MM-dd');
        const exception = await (0, database_1.default)('availability_exceptions')
            .where({
            doctor_id: doctorId,
            tenant_id: tenantId,
            date: dateOnly,
            type: 'blocked',
        })
            .first();
        if (exception) {
            // Check if appointment time falls within blocked time
            if (exception.start_time &&
                exception.end_time &&
                appointmentTime >= exception.start_time &&
                appointmentTime <= exception.end_time) {
                return false;
            }
            else if (!exception.start_time && !exception.end_time) {
                // Entire day is blocked
                return false;
            }
        }
        // 4. Check for conflicting appointments
        const conflictingAppointments = await (0, database_1.default)('appointments')
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
                b.where('appointment_date', '<=', appointmentDate).andWhere(database_1.default.raw(`appointment_date + (duration_minutes || ' minutes')::interval > ?`, [appointmentDate]));
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
    async checkAvailabilityInTransaction(trx, doctorId, appointmentDate, durationMinutes, tenantId) {
        const appointmentEnd = (0, date_fns_1.addMinutes)(appointmentDate, durationMinutes);
        // Lock the doctor's appointments for this time slot
        const conflictingAppointments = await trx('appointments')
            .where({ doctor_id: doctorId, tenant_id: tenantId })
            .whereIn('status', ['scheduled', 'confirmed'])
            .andWhere((builder) => {
            builder
                .where((b) => {
                b.where('appointment_date', '<=', appointmentDate).andWhere(trx.raw(`appointment_date + (duration_minutes || ' minutes')::interval > ?`, [appointmentDate]));
            })
                .orWhere((b) => {
                b.where('appointment_date', '<', appointmentEnd).andWhere('appointment_date', '>=', appointmentDate);
            });
        })
            .forUpdate(); // Lock rows for update
        return conflictingAppointments.length === 0;
    }
    /**
     * Get available time slots for a doctor
     */
    async getAvailableSlots(params) {
        const { doctorId, startDate, endDate, durationMinutes, tenantId } = params;
        const endDateOrDefault = endDate || (0, date_fns_1.addMinutes)(startDate, 7 * 24 * 60); // Default 7 days
        // Get doctor's availability
        const availability = await (0, database_1.default)('availability')
            .where({ doctor_id: doctorId, tenant_id: tenantId, is_active: true });
        // Get existing appointments
        const appointments = await (0, database_1.default)('appointments')
            .where({ doctor_id: doctorId, tenant_id: tenantId })
            .whereIn('status', ['scheduled', 'confirmed'])
            .whereBetween('appointment_date', [startDate, endDateOrDefault]);
        // Get exceptions
        const exceptions = await (0, database_1.default)('availability_exceptions')
            .where({ doctor_id: doctorId, tenant_id: tenantId })
            .whereBetween('date', [(0, date_fns_1.format)(startDate, 'yyyy-MM-dd'), (0, date_fns_1.format)(endDateOrDefault, 'yyyy-MM-dd')]);
        // Generate available slots
        const availableSlots = [];
        let currentDate = new Date(startDate);
        while ((0, date_fns_1.isBefore)(currentDate, endDateOrDefault)) {
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
                while ((0, date_fns_1.isBefore)((0, date_fns_1.addMinutes)(slotTime, durationMinutes), endTime) || slotTime.getTime() === endTime.getTime()) {
                    // Check if slot is not in the past
                    if ((0, date_fns_1.isAfter)(slotTime, new Date())) {
                        // Check if not blocked by exception
                        const isBlocked = this.isSlotBlocked(slotTime, durationMinutes, exceptions);
                        // Check if not conflicting with existing appointment
                        const hasConflict = this.hasAppointmentConflict(slotTime, durationMinutes, appointments);
                        if (!isBlocked && !hasConflict) {
                            availableSlots.push(new Date(slotTime));
                        }
                    }
                    slotTime = (0, date_fns_1.addMinutes)(slotTime, durationMinutes);
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
    async canCancelAppointment(appointmentId, tenantId) {
        const appointment = await (0, database_1.default)('appointments')
            .where({ id: appointmentId, tenant_id: tenantId })
            .first();
        if (!appointment) {
            return { allowed: false, reason: 'Appointment not found' };
        }
        if (appointment.status === 'cancelled' || appointment.status === 'completed') {
            return { allowed: false, reason: 'Appointment cannot be cancelled' };
        }
        // Get cancellation policy
        const policy = await (0, database_1.default)('cancellation_policies')
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
            const penalty = policy.penalty_percentage > 0
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
    async cancelAppointment(params) {
        const { appointmentId, tenantId, userId, reason } = params;
        await database_1.default.transaction(async (trx) => {
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
        const appointment = await (0, database_1.default)('appointments').where({ id: appointmentId }).first();
        if (appointment) {
            await this.clearAppointmentCache(tenantId, appointment.doctor_id, appointment.patient_id);
        }
    }
    /**
     * Reschedule appointment
     */
    async rescheduleAppointment(params) {
        const { appointmentId, newAppointmentDate, durationMinutes, reason, tenantId, userId } = params;
        return await database_1.default.transaction(async (trx) => {
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
    async confirmAppointment(appointmentId, tenantId, userId) {
        await database_1.default.transaction(async (trx) => {
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
     * Mark appointment as no-show
     */
    async markNoShow(appointmentId, tenantId, userId) {
        await database_1.default.transaction(async (trx) => {
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
    async getAppointments(params) {
        const { tenantId, userId, role, page, limit, status, doctorId, patientId, startDate, endDate } = params;
        let query = (0, database_1.default)('appointments').where({ tenant_id: tenantId });
        // Apply role-based filters
        if (role === 'patient') {
            query = query.where({ patient_id: userId });
        }
        else if (role === 'doctor' || role === 'paramedical') {
            query = query.where({ doctor_id: userId });
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
        const [{ count }] = await query.clone().count('* as count');
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
    async getAppointmentById(id, tenantId, userId, role) {
        let query = (0, database_1.default)('appointments').where({ id, tenant_id: tenantId });
        // Apply role-based access
        if (role === 'patient') {
            query = query.where({ patient_id: userId });
        }
        else if (role === 'doctor' || role === 'paramedical') {
            query = query.where({ doctor_id: userId });
        }
        const appointment = await query.first();
        return appointment;
    }
    /**
     * Helper: Check if slot is blocked by exception
     */
    isSlotBlocked(slotTime, durationMinutes, exceptions) {
        const dateOnly = (0, date_fns_1.format)(slotTime, 'yyyy-MM-dd');
        const timeOnly = (0, date_fns_1.format)(slotTime, 'HH:mm:ss');
        const slotEnd = (0, date_fns_1.format)((0, date_fns_1.addMinutes)(slotTime, durationMinutes), 'HH:mm:ss');
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
    hasAppointmentConflict(slotTime, durationMinutes, appointments) {
        const slotEnd = (0, date_fns_1.addMinutes)(slotTime, durationMinutes);
        return appointments.some((apt) => {
            const aptStart = new Date(apt.appointment_date);
            const aptEnd = (0, date_fns_1.addMinutes)(aptStart, apt.duration_minutes);
            // Check for overlap
            return ((slotTime >= aptStart && slotTime < aptEnd) ||
                (slotEnd > aptStart && slotEnd <= aptEnd) ||
                (slotTime <= aptStart && slotEnd >= aptEnd));
        });
    }
    /**
     * Clear appointment-related cache
     */
    async clearAppointmentCache(tenantId, doctorId, patientId) {
        try {
            await redis_1.default.del(`appointments:tenant:${tenantId}`);
            await redis_1.default.del(`appointments:doctor:${doctorId}`);
            await redis_1.default.del(`appointments:patient:${patientId}`);
        }
        catch (error) {
            logger_1.logger.error('Error clearing appointment cache:', error);
        }
    }
}
exports.AppointmentService = AppointmentService;
//# sourceMappingURL=appointment.service.js.map