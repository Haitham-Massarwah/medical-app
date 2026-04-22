import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { tenantContext } from '../middleware/tenantContext';
import { noShowAiController } from '../controllers/noShowAi.controller';

const router = Router();

router.use(authenticate);
router.use(tenantContext);

router.get('/upcoming', authorize('developer', 'admin', 'doctor', 'paramedical'), noShowAiController.getUpcoming);
router.get('/appointment/:id', authorize('developer', 'admin', 'doctor', 'paramedical'), noShowAiController.getAppointmentPrediction);
router.get('/model/versions', authorize('developer', 'admin'), noShowAiController.listModelVersions);
router.get('/model/metrics', authorize('developer', 'admin'), noShowAiController.getModelMetrics);
router.get('/model/training-jobs', authorize('developer', 'admin'), noShowAiController.listTrainingJobs);
router.post('/model/train', authorize('developer', 'admin'), noShowAiController.trainModel);
router.post('/model/activate', authorize('developer', 'admin'), noShowAiController.activateModel);
router.post('/model/rollback', authorize('developer', 'admin'), noShowAiController.rollbackModel);

router.get('/thresholds', authorize('developer', 'admin'), noShowAiController.getThresholds);
router.put('/thresholds', authorize('developer', 'admin'), noShowAiController.putThresholds);

router.get('/drift', authorize('developer', 'admin'), noShowAiController.listDrift);
router.post('/drift/run', authorize('developer', 'admin'), noShowAiController.runDriftCheck);

router.get('/alerts', authorize('developer', 'admin'), noShowAiController.listAlerts);
router.post('/alerts/:id/ack', authorize('developer', 'admin'), noShowAiController.acknowledgeAlert);

router.get('/monitoring/daily', authorize('developer', 'admin'), noShowAiController.getMonitoringDaily);
router.post('/monitoring/rollup', authorize('developer', 'admin'), noShowAiController.rollupMonitoring);

router.post(
  '/actions/sms',
  authorize('developer', 'admin', 'doctor', 'paramedical'),
  noShowAiController.sendNoShowSms,
);
router.get('/overbooking-rule', authorize('developer', 'admin'), noShowAiController.getOverbookingRule);
router.put('/overbooking-rule', authorize('developer', 'admin'), noShowAiController.putOverbookingRule);

export default router;

