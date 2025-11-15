import { Router } from 'express';
import { AnalyticsController } from '../controllers/analytics.controller';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { validateDateRange } from '../middleware/validator';
import { tenantContext } from '../middleware/tenantContext';

const router = Router();
const analyticsController = new AnalyticsController();

// All routes require authentication and admin/developer role
router.use(authenticate);
router.use(tenantContext);
router.use(authorize('admin', 'developer'));

/**
 * @route   GET /api/v1/analytics/dashboard
 * @desc    Get dashboard overview statistics
 * @access  Private/Admin
 */
router.get(
  '/dashboard',
  analyticsController.getDashboardStats
);

/**
 * @route   GET /api/v1/analytics/appointments
 * @desc    Get appointment analytics
 * @access  Private/Admin
 */
router.get(
  '/appointments',
  validateDateRange,
  analyticsController.getAppointmentAnalytics
);

/**
 * @route   GET /api/v1/analytics/revenue
 * @desc    Get revenue analytics
 * @access  Private/Admin
 */
router.get(
  '/revenue',
  validateDateRange,
  analyticsController.getRevenueAnalytics
);

/**
 * @route   GET /api/v1/analytics/doctors
 * @desc    Get doctor performance analytics
 * @access  Private/Admin
 */
router.get(
  '/doctors',
  validateDateRange,
  analyticsController.getDoctorAnalytics
);

/**
 * @route   GET /api/v1/analytics/patients
 * @desc    Get patient analytics
 * @access  Private/Admin
 */
router.get(
  '/patients',
  validateDateRange,
  analyticsController.getPatientAnalytics
);

/**
 * @route   GET /api/v1/analytics/no-shows
 * @desc    Get no-show analytics
 * @access  Private/Admin
 */
router.get(
  '/no-shows',
  validateDateRange,
  analyticsController.getNoShowAnalytics
);

/**
 * @route   GET /api/v1/analytics/specialties
 * @desc    Get specialty analytics
 * @access  Private/Admin
 */
router.get(
  '/specialties',
  validateDateRange,
  analyticsController.getSpecialtyAnalytics
);

/**
 * @route   GET /api/v1/analytics/growth
 * @desc    Get growth metrics
 * @access  Private/Admin
 */
router.get(
  '/growth',
  validateDateRange,
  analyticsController.getGrowthMetrics
);

/**
 * @route   GET /api/v1/analytics/export
 * @desc    Export analytics data (CSV/Excel)
 * @access  Private/Admin
 */
router.get(
  '/export',
  validateDateRange,
  analyticsController.exportData
);

/**
 * @route   GET /api/v1/analytics/reports/monthly
 * @desc    Get monthly report
 * @access  Private/Admin
 */
router.get(
  '/reports/monthly',
  analyticsController.getMonthlyReport
);

/**
 * @route   GET /api/v1/analytics/reports/quarterly
 * @desc    Get quarterly report
 * @access  Private/Admin
 */
router.get(
  '/reports/quarterly',
  analyticsController.getQuarterlyReport
);

/**
 * @route   GET /api/v1/analytics/reports/yearly
 * @desc    Get yearly report
 * @access  Private/Admin
 */
router.get(
  '/reports/yearly',
  analyticsController.getYearlyReport
);

export default router;



