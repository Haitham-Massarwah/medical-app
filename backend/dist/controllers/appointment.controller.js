"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppointmentController = void 0;
const appointment_service_1 = require("../services/appointment.service");
const logger_1 = require("../config/logger");
const apiError_1 = require("../utils/apiError");
class AppointmentController {
    constructor() {
        this.appointmentService = new appointment_service_1.AppointmentService();
    }
    /**
     * Get all appointments
     * @route GET /api/v1/appointments
     */
    async getAppointments(req, res, next) {
        try {
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id || '';
            const role = req.user?.role || '';
            const { page = 1, limit = 20, status, doctorId, patientId, startDate, endDate } = req.query;
            const result = await this.appointmentService.getAppointments({
                tenantId,
                userId,
                role,
                page: Number(page),
                limit: Number(limit),
                status: status,
                doctorId: doctorId,
                patientId: patientId,
                startDate: startDate,
                endDate: endDate,
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
        }
        catch (error) {
            logger_1.logger.error('Error getting appointments:', error);
            next(error);
        }
    }
    /**
     * Get appointment by ID
     * @route GET /api/v1/appointments/:id
     */
    async getAppointmentById(req, res, next) {
        try {
            const { id } = req.params;
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id || '';
            const role = req.user?.role || '';
            const appointment = await this.appointmentService.getAppointmentById(id, tenantId, userId, role);
            if (!appointment) {
                throw new apiError_1.ApiError(404, 'Appointment not found');
            }
            res.status(200).json({
                success: true,
                data: appointment,
            });
        }
        catch (error) {
            logger_1.logger.error('Error getting appointment:', error);
            next(error);
        }
    }
    /**
     * Book new appointment
     * @route POST /api/v1/appointments
     */
    async bookAppointment(req, res, next) {
        try {
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id || '';
            const role = req.user?.role || '';
            const { doctorId, serviceId, appointmentDate, durationMinutes, notes, location, isTelehealth, patientId, } = req.body;
            // Validate required fields
            if (!doctorId || !appointmentDate) {
                throw new apiError_1.ApiError(400, 'Doctor ID and appointment date are required');
            }
            // Check availability
            const isAvailable = await this.appointmentService.checkAvailability({
                doctorId,
                appointmentDate: new Date(appointmentDate),
                durationMinutes: durationMinutes || 30,
                tenantId,
            });
            if (!isAvailable) {
                throw new apiError_1.ApiError(409, 'The selected time slot is not available');
            }
            // Book appointment
            const appointment = await this.appointmentService.bookAppointment({
                tenantId,
                patientId: patientId || userId, // If patient books for themselves
                doctorId,
                serviceId,
                appointmentDate: new Date(appointmentDate),
                durationMinutes: durationMinutes || 30,
                notes,
                location,
                isTelehealth: isTelehealth || false,
                bookedBy: userId,
            });
            logger_1.logger.info(`Appointment booked: ${appointment.id}`);
            res.status(201).json({
                success: true,
                data: appointment,
                message: 'Appointment booked successfully',
            });
        }
        catch (error) {
            logger_1.logger.error('Error booking appointment:', error);
            next(error);
        }
    }
    /**
     * Cancel appointment
     * @route DELETE /api/v1/appointments/:id
     */
    async cancelAppointment(req, res, next) {
        try {
            const { id } = req.params;
            const { reason } = req.body;
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id || '';
            const role = req.user?.role || '';
            // Check cancellation policy
            const canCancel = await this.appointmentService.canCancelAppointment(id, tenantId);
            if (!canCancel.allowed) {
                throw new apiError_1.ApiError(400, canCancel.reason || 'Cannot cancel appointment');
            }
            await this.appointmentService.cancelAppointment({
                appointmentId: id,
                tenantId,
                userId,
                role,
                reason,
            });
            logger_1.logger.info(`Appointment cancelled: ${id} by user: ${userId}`);
            res.status(200).json({
                success: true,
                message: 'Appointment cancelled successfully',
                penalty: canCancel.penalty,
            });
        }
        catch (error) {
            logger_1.logger.error('Error cancelling appointment:', error);
            next(error);
        }
    }
    /**
     * Reschedule appointment
     * @route POST /api/v1/appointments/:id/reschedule
     */
    async rescheduleAppointment(req, res, next) {
        try {
            const { id } = req.params;
            const { newAppointmentDate, durationMinutes, reason } = req.body;
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id || '';
            const role = req.user?.role || '';
            if (!newAppointmentDate) {
                throw new apiError_1.ApiError(400, 'New appointment date is required');
            }
            // Get original appointment
            const originalAppointment = await this.appointmentService.getAppointmentById(id, tenantId, userId, role);
            if (!originalAppointment) {
                throw new apiError_1.ApiError(404, 'Appointment not found');
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
                throw new apiError_1.ApiError(409, 'The new time slot is not available');
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
            logger_1.logger.info(`Appointment rescheduled: ${id}`);
            res.status(200).json({
                success: true,
                data: updatedAppointment,
                message: 'Appointment rescheduled successfully',
            });
        }
        catch (error) {
            logger_1.logger.error('Error rescheduling appointment:', error);
            next(error);
        }
    }
    /**
     * Confirm appointment
     * @route POST /api/v1/appointments/:id/confirm
     */
    async confirmAppointment(req, res, next) {
        try {
            const { id } = req.params;
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id || '';
            await this.appointmentService.confirmAppointment(id, tenantId, userId);
            logger_1.logger.info(`Appointment confirmed: ${id} by user: ${userId}`);
            res.status(200).json({
                success: true,
                message: 'Appointment confirmed successfully',
            });
        }
        catch (error) {
            logger_1.logger.error('Error confirming appointment:', error);
            next(error);
        }
    }
    /**
     * Mark appointment as no-show
     * @route POST /api/v1/appointments/:id/no-show
     */
    async markNoShow(req, res, next) {
        try {
            const { id } = req.params;
            const tenantId = req.headers['x-tenant-id'];
            const userId = req.user?.id || '';
            await this.appointmentService.markNoShow(id, tenantId, userId);
            logger_1.logger.info(`Appointment marked as no-show: ${id}`);
            res.status(200).json({
                success: true,
                message: 'Appointment marked as no-show',
            });
        }
        catch (error) {
            logger_1.logger.error('Error marking no-show:', error);
            next(error);
        }
    }
    /**
     * Get available slots for a doctor
     * @route GET /api/v1/appointments/available-slots
     */
    async getAvailableSlots(req, res, next) {
        try {
            const tenantId = req.headers['x-tenant-id'];
            const { doctorId, startDate, endDate, durationMinutes = 30 } = req.query;
            if (!doctorId || !startDate) {
                throw new apiError_1.ApiError(400, 'Doctor ID and start date are required');
            }
            const slots = await this.appointmentService.getAvailableSlots({
                doctorId: doctorId,
                startDate: new Date(startDate),
                endDate: endDate ? new Date(endDate) : undefined,
                durationMinutes: Number(durationMinutes),
                tenantId,
            });
            res.status(200).json({
                success: true,
                data: slots,
            });
        }
        catch (error) {
            logger_1.logger.error('Error getting available slots:', error);
            next(error);
        }
    }
}
exports.AppointmentController = AppointmentController;
//# sourceMappingURL=appointment.controller.js.map