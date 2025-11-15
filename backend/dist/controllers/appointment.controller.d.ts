import { Request, Response, NextFunction } from 'express';
export declare class AppointmentController {
    private appointmentService;
    constructor();
    /**
     * Get all appointments
     * @route GET /api/v1/appointments
     */
    getAppointments(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Get appointment by ID
     * @route GET /api/v1/appointments/:id
     */
    getAppointmentById(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Book new appointment
     * @route POST /api/v1/appointments
     */
    bookAppointment(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Cancel appointment
     * @route DELETE /api/v1/appointments/:id
     */
    cancelAppointment(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Reschedule appointment
     * @route POST /api/v1/appointments/:id/reschedule
     */
    rescheduleAppointment(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Confirm appointment
     * @route POST /api/v1/appointments/:id/confirm
     */
    confirmAppointment(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Mark appointment as no-show
     * @route POST /api/v1/appointments/:id/no-show
     */
    markNoShow(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Get available slots for a doctor
     * @route GET /api/v1/appointments/available-slots
     */
    getAvailableSlots(req: Request, res: Response, next: NextFunction): Promise<void>;
}
//# sourceMappingURL=appointment.controller.d.ts.map