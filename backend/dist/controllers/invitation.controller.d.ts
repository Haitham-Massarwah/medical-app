import { Request, Response } from 'express';
export declare function sendInvitation(req: Request, res: Response): Promise<Response<any, Record<string, any>> | undefined>;
export declare function verifyToken(req: Request, res: Response): Promise<Response<any, Record<string, any>> | undefined>;
export declare function acceptInvitation(req: Request, res: Response): Promise<Response<any, Record<string, any>> | undefined>;
//# sourceMappingURL=invitation.controller.d.ts.map