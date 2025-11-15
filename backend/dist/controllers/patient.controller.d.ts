import { Request, Response, NextFunction } from 'express';
export declare class PatientController {
    /**
     * Get all patients
     * GET /api/v1/patients
     */
    getAllPatients: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get patient by ID
     * GET /api/v1/patients/:id
     */
    getPatientById: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Create patient (by doctor/admin only)
     * POST /api/v1/patients
     */
    createPatient: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Update patient profile
     * PUT /api/v1/patients/:id
     */
    updatePatient: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Delete patient (soft delete)
     * DELETE /api/v1/patients/:id
     */
    deletePatient: (req: Request, res: Response, next: NextFunction) => void;
}
export declare const patientController: PatientController;
//# sourceMappingURL=patient.controller.d.ts.map