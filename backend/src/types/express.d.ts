import 'jsonwebtoken';

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

// Augment JwtPayload with app-specific claims (merges with jsonwebtoken types)
declare module 'jsonwebtoken' {
  interface JwtPayload {
    id?: string;
    userId?: string;
    email?: string;
    role?: string;
    tenant_id?: string;
  }
}













