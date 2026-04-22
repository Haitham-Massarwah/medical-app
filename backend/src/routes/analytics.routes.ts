import { Router } from 'express';
import { AnalyticsController } from '../controllers/analytics.controller';
import { authenticate, authorize } from '../middleware/auth.middleware';
import { validateDateRange } from '../middleware/validator';
import { tenantContext } from '../middleware/tenantContext';

const router = Router();
const analyticsController = new AnalyticsController();

// All routes require authentication + tenant context.
router.use(authenticate);
router.use(tenantContext);

/**
 * @route   GET /api/v1/analytics/dashboard
 * @desc    Get dashboard overview statistics
 * @access  Private/Admin
 */
router.get(
  '/dashboard',
  authorize('admin', 'developer'),
  analyticsController.getDashboardStats
);

/**
 * @route   GET /api/v1/analytics/dashboard-activity
 * @desc    Recent audit activity + signup stats for admin dashboard
 * @access  Private/Admin
 */
router.get(
  '/dashboard-activity',
  authorize('admin', 'developer'),
  analyticsController.getDashboardActivity
);

/**
 * @route   GET /api/v1/analytics/advanced
 * @desc    Revenue + appointments + per-doctor performance (optional date range)
 */
router.get(
  '/advanced',
  authorize('admin', 'developer', 'doctor'),
  validateDateRange,
  analyticsController.getAdvancedAnalytics
);

/**
 * @route   GET /api/v1/analytics/admin-health
 * @desc    Admin health summary (integrations + recent audit)
 * @access  Private/Admin
 */
router.get(
  '/admin-health',
  authorize('admin', 'developer'),
  analyticsController.getAdminHealth
);

/**
 * @route   GET /api/v1/analytics/appointments
 * @desc    Get appointment analytics
 * @access  Private/Admin
 */
router.get(
  '/appointments',
  authorize('admin', 'developer'),
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
  authorize('admin', 'developer'),
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
  authorize('admin', 'developer'),
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
  authorize('admin', 'developer'),
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
  authorize('admin', 'developer'),
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
  authorize('admin', 'developer'),
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
  authorize('admin', 'developer'),
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
  authorize('admin', 'developer'),
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
  authorize('admin', 'developer'),
  analyticsController.getMonthlyReport
);

/**
 * @route   GET /api/v1/analytics/reports/quarterly
 * @desc    Get quarterly report
 * @access  Private/Admin
 */
router.get(
  '/reports/quarterly',
  authorize('admin', 'developer'),
  analyticsController.getQuarterlyReport
);

/**
 * @route   GET /api/v1/analytics/reports/yearly
 * @desc    Get yearly report
 * @access  Private/Admin
 */
router.get(
  '/reports/yearly',
  authorize('admin', 'developer'),
  analyticsController.getYearlyReport
);

export default router;



