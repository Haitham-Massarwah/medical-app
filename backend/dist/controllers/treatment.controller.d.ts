import { Request, Response } from 'express';
export declare function listTreatments(req: Request, res: Response): Promise<void>;
export declare function createTreatment(req: Request, res: Response): Promise<Response<any, Record<string, any>> | undefined>;
export declare function updateTreatment(req: Request, res: Response): Promise<void>;
export declare function deleteTreatment(req: Request, res: Response): Promise<void>;
export declare function getDoctorPaymentSettings(req: Request, res: Response): Promise<void>;
export declare function setDoctorPaymentSettings(req: Request, res: Response): Promise<void>;
//# sourceMappingURL=treatment.controller.d.ts.map