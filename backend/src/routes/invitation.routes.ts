import { Router } from 'express';
import * as controller from '../controllers/invitation.controller';

const router = Router();

router.post('/send', controller.sendInvitation);
router.get('/verify/:token', controller.verifyToken);
router.post('/accept/:token', controller.acceptInvitation);

export default router;






