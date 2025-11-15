import { JwtPayload } from 'jsonwebtoken';

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email: string;
        role: string;
        tenant_id?: string;
      };
      tenantId?: string;
    }
  }
}

// Extend JwtPayload to include our custom properties
declare module 'jsonwebtoken' {
  export interface JwtPayload {
    id: string;
    email: string;
    role: string;
    tenant_id?: string;
  }
}













