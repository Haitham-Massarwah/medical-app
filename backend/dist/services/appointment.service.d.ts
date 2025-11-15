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
export declare class AppointmentService {
    private readonly timezone;
    /**
     * Book a new appointment
     */
    bookAppointment(params: BookAppointmentParams): Promise<any>;
    /**
     * Check if a time slot is available
     */
    checkAvailability(params: CheckAvailabilityParams): Promise<boolean>;
    /**
     * Check availability within a transaction (for atomic booking)
     */
    private checkAvailabilityInTransaction;
    /**
     * Get available time slots for a doctor
     */
    getAvailableSlots(params: GetAvailableSlotsParams): Promise<Date[]>;
    /**
     * Check if appointment can be cancelled based on policy
     */
    canCancelAppointment(appointmentId: string, tenantId: string): Promise<{
        allowed: boolean;
        reason?: string;
        penalty?: number;
    }>;
    /**
     * Cancel appointment
     */
    cancelAppointment(params: {
        appointmentId: string;
        tenantId: string;
        userId: string;
        role: string;
        reason?: string;
    }): Promise<void>;
    /**
     * Reschedule appointment
     */
    rescheduleAppointment(params: {
        appointmentId: string;
        newAppointmentDate: Date;
        durationMinutes?: number;
        reason?: string;
        tenantId: string;
        userId: string;
    }): Promise<any>;
    /**
     * Confirm appointment
     */
    confirmAppointment(appointmentId: string, tenantId: string, userId: string): Promise<void>;
    /**
     * Mark appointment as no-show
     */
    markNoShow(appointmentId: string, tenantId: string, userId: string): Promise<void>;
    /**
     * Get appointments with filters
     */
    getAppointments(params: any): Promise<any>;
    /**
     * Get appointment by ID
     */
    getAppointmentById(id: string, tenantId: string, userId: string, role: string): Promise<any>;
    /**
     * Helper: Check if slot is blocked by exception
     */
    private isSlotBlocked;
    /**
     * Helper: Check if slot conflicts with existing appointment
     */
    private hasAppointmentConflict;
    /**
     * Clear appointment-related cache
     */
    private clearAppointmentCache;
}
export {};
//# sourceMappingURL=appointment.service.d.ts.map