import { Request, Response, NextFunction } from 'express';
export declare class DoctorController {
    /**
     * Get all doctors
     * GET /api/v1/doctors
     */
    getAllDoctors: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Search doctors
     * GET /api/v1/doctors/search
     */
    searchDoctors: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get doctor by ID
     * GET /api/v1/doctors/:id
     */
    getDoctorById: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get doctor availability
     * GET /api/v1/doctors/:id/availability
     */
    getDoctorAvailability: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get doctor reviews
     * GET /api/v1/doctors/:id/reviews
     */
    getDoctorReviews: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Create doctor
     * POST /api/v1/doctors
     */
    createDoctor: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update doctor
     * PUT /api/v1/doctors/:id
     */
    updateDoctor: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update doctor schedule
     * PUT /api/v1/doctors/:id/schedule
     */
    updateSchedule: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Add time off
     * POST /api/v1/doctors/:id/time-off
     */
    addTimeOff: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Delete doctor
     * DELETE /api/v1/doctors/:id
     */
    deleteDoctor: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get doctor appointments
     * GET /api/v1/doctors/:id/appointments
     */
    getDoctorAppointments: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get doctor statistics
     * GET /api/v1/doctors/:id/statistics
     */
    getDoctorStatistics: (req: Request, res: Response, next: NextFunction) => void;
}
//# sourceMappingURL=doctor.controller.d.ts.map