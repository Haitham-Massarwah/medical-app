import { Router } from 'express';
import * as controller from '../controllers/treatment.controller';

const router = Router();

// Doctor treatments CRUD
router.get('/', controller.listTreatments);
router.post('/', controller.createTreatment);
router.put('/:id', controller.updateTreatment);
router.delete('/:id', controller.deleteTreatment);

// Payment flags (developer override)
router.get('/settings/:doctorId', controller.getDoctorPaymentSettings);
router.post('/settings/:doctorId', controller.setDoctorPaymentSettings);

export default router;






