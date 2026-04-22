import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { tenantContext } from '../middleware/tenantContext';
import { clinicTemplatesController } from '../controllers/clinicTemplates.controller';

const router = Router();

const storage = multer.diskStorage({
  destination: (req, _file, cb) => {
    const tenantId = (req as Express.Request & { tenantId?: string }).tenantId || 'unknown';
    const uploadPath = path.resolve(process.cwd(), 'uploads', 'clinic-templates', tenantId);
    fs.mkdirSync(uploadPath, { recursive: true });
    cb(null, uploadPath);
  },
  filename: (_req, file, cb) => {
    const timestamp = Date.now();
    const safe = file.originalname.replace(/[^a-zA-Z0-9.\-_]/g, '_');
    cb(null, `${timestamp}-${safe}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 30 * 1024 * 1024 },
});

router.use(authenticate);
router.use(tenantContext);

router.get('/', authorize('developer', 'admin'), clinicTemplatesController.list);
router.get('/assignments', authorize('developer', 'admin'), clinicTemplatesController.listAssignments);
router.post('/assignments', authorize('developer', 'admin'), clinicTemplatesController.assign);
router.delete('/assignments/:id', authorize('developer', 'admin'), clinicTemplatesController.unassign);
router.get('/:id/file', authorize('developer', 'admin'), clinicTemplatesController.download);
router.post(
  '/upload',
  authorize('developer', 'admin'),
  upload.single('file'),
  clinicTemplatesController.upload,
);
router.delete('/:id', authorize('developer', 'admin'), clinicTemplatesController.remove);

export default router;
