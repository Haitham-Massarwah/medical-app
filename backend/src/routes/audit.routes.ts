import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { tenantContext } from '../middleware/tenantContext';
import { auditController } from '../controllers/audit.controller';

const router = Router();

router.use(authenticate);
router.use(tenantContext);
router.use(authorize('developer', 'admin', 'doctor', 'paramedical'));

router.get('/trail/export.csv', auditController.exportAuditTrailCsv);
router.get('/trail', auditController.getAuditTrail);

export default router;
