"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const analytics_controller_1 = require("../controllers/analytics.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validator_1 = require("../middleware/validator");
const tenantContext_1 = require("../middleware/tenantContext");
const router = (0, express_1.Router)();
const analyticsController = new analytics_controller_1.AnalyticsController();
// All routes require authentication and admin/developer role
router.use(auth_middleware_1.authenticate);
router.use(tenantContext_1.tenantContext);
router.use((0, auth_middleware_1.authorize)('admin', 'developer'));
/**
 * @route   GET /api/v1/analytics/dashboard
 * @desc    Get dashboard overview statistics
 * @access  Private/Admin
 */
router.get('/dashboard', analyticsController.getDashboardStats);
/**
 * @route   GET /api/v1/analytics/appointments
 * @desc    Get appointment analytics
 * @access  Private/Admin
 */
router.get('/appointments', validator_1.validateDateRange, analyticsController.getAppointmentAnalytics);
/**
 * @route   GET /api/v1/analytics/revenue
 * @desc    Get revenue analytics
 * @access  Private/Admin
 */
router.get('/revenue', validator_1.validateDateRange, analyticsController.getRevenueAnalytics);
/**
 * @route   GET /api/v1/analytics/doctors
 * @desc    Get doctor performance analytics
 * @access  Private/Admin
 */
router.get('/doctors', validator_1.validateDateRange, analyticsController.getDoctorAnalytics);
/**
 * @route   GET /api/v1/analytics/patients
 * @desc    Get patient analytics
 * @access  Private/Admin
 */
router.get('/patients', validator_1.validateDateRange, analyticsController.getPatientAnalytics);
/**
 * @route   GET /api/v1/analytics/no-shows
 * @desc    Get no-show analytics
 * @access  Private/Admin
 */
router.get('/no-shows', validator_1.validateDateRange, analyticsController.getNoShowAnalytics);
/**
 * @route   GET /api/v1/analytics/specialties
 * @desc    Get specialty analytics
 * @access  Private/Admin
 */
router.get('/specialties', validator_1.validateDateRange, analyticsController.getSpecialtyAnalytics);
/**
 * @route   GET /api/v1/analytics/growth
 * @desc    Get growth metrics
 * @access  Private/Admin
 */
router.get('/growth', validator_1.validateDateRange, analyticsController.getGrowthMetrics);
/**
 * @route   GET /api/v1/analytics/export
 * @desc    Export analytics data (CSV/Excel)
 * @access  Private/Admin
 */
router.get('/export', validator_1.validateDateRange, analyticsController.exportData);
/**
 * @route   GET /api/v1/analytics/reports/monthly
 * @desc    Get monthly report
 * @access  Private/Admin
 */
router.get('/reports/monthly', analyticsController.getMonthlyReport);
/**
 * @route   GET /api/v1/analytics/reports/quarterly
 * @desc    Get quarterly report
 * @access  Private/Admin
 */
router.get('/reports/quarterly', analyticsController.getQuarterlyReport);
/**
 * @route   GET /api/v1/analytics/reports/yearly
 * @desc    Get yearly report
 * @access  Private/Admin
 */
router.get('/reports/yearly', analyticsController.getYearlyReport);
exports.default = router;
//# sourceMappingURL=analytics.routes.js.map