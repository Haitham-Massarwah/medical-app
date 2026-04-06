import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { tenantContext } from '../middleware/tenantContext';
import { PermissionsController } from '../controllers/permissions.controller';

const router = Router();
const permissionsController = new PermissionsController();

// Read-only system permissions for authenticated users
router.get('/', authenticate, tenantContext, permissionsController.getPermissions);

export default router;
