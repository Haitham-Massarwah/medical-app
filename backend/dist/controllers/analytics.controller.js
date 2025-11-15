"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AnalyticsController = void 0;
const errorHandler_1 = require("../middleware/errorHandler");
const database_1 = __importDefault(require("../config/database"));
class AnalyticsController {
    constructor() {
        /**
         * Get dashboard overview statistics
         * GET /api/v1/analytics/dashboard
         */
        this.getDashboardStats = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            // Get counts
            const [totalUsers] = await (0, database_1.default)('users')
                .where({ tenant_id: tenantId })
                .andWhere('deleted_at', null)
                .count('* as count');
            const [totalDoctors] = await (0, database_1.default)('doctors')
                .where({ tenant_id: tenantId })
                .andWhere('deleted_at', null)
                .count('* as count');
            const [totalPatients] = await (0, database_1.default)('patients')
                .where({ tenant_id: tenantId })
                .andWhere('deleted_at', null)
                .count('* as count');
            const [totalAppointments] = await (0, database_1.default)('appointments')
                .where({ tenant_id: tenantId })
                .count('* as count');
            const [todayAppointments] = await (0, database_1.default)('appointments')
                .where({ tenant_id: tenantId })
                .andWhere('appointment_date', new Date().toISOString().split('T')[0])
                .count('* as count');
            const [completedAppointments] = await (0, database_1.default)('appointments')
                .where({ tenant_id: tenantId, status: 'completed' })
                .count('* as count');
            const totalRevenueResult = await (0, database_1.default)('payments')
                .where({ tenant_id: tenantId, status: 'succeeded' })
                .sum('amount as total')
                .first();
            const totalRevenue = totalRevenueResult;
            res.status(200).json({
                status: 'success',
                data: {
                    dashboard: {
                        total_users: parseInt(totalUsers.count),
                        total_doctors: parseInt(totalDoctors.count),
                        total_patients: parseInt(totalPatients.count),
                        total_appointments: parseInt(totalAppointments.count),
                        today_appointments: parseInt(todayAppointments.count),
                        completed_appointments: parseInt(completedAppointments.count),
                        total_revenue: totalRevenue?.total || 0,
                    },
                },
            });
        });
        /**
         * Get appointment analytics
         * GET /api/v1/analytics/appointments
         */
        this.getAppointmentAnalytics = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const { start_date, end_date } = req.query;
            let query = (0, database_1.default)('appointments')
                .where({ tenant_id: tenantId });
            if (start_date) {
                query = query.andWhere('appointment_date', '>=', start_date);
            }
            if (end_date) {
                query = query.andWhere('appointment_date', '<=', end_date);
            }
            // By status
            const byStatus = await query.clone()
                .select('status')
                .count('* as count')
                .groupBy('status');
            // By date (last 30 days)
            const byDate = await query.clone()
                .select(database_1.default.raw('DATE(appointment_date) as date'))
                .count('* as count')
                .groupBy(database_1.default.raw('DATE(appointment_date)'))
                .orderBy('date', 'desc')
                .limit(30);
            res.status(200).json({
                status: 'success',
                data: {
                    by_status: byStatus,
                    by_date: byDate,
                },
            });
        });
        /**
         * Get revenue analytics
         * GET /api/v1/analytics/revenue
         */
        this.getRevenueAnalytics = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const { start_date, end_date } = req.query;
            let query = (0, database_1.default)('payments')
                .where({ tenant_id: tenantId, status: 'succeeded' });
            if (start_date) {
                query = query.andWhere('created_at', '>=', start_date);
            }
            if (end_date) {
                query = query.andWhere('created_at', '<=', end_date);
            }
            const [totals] = await query.clone()
                .select(database_1.default.raw('SUM(amount) as total_revenue'), database_1.default.raw('COUNT(*) as total_transactions'), database_1.default.raw('AVG(amount) as average_transaction'))
                .first();
            // By date
            const byDate = await query.clone()
                .select(database_1.default.raw('DATE(created_at) as date'))
                .sum('amount as revenue')
                .count('* as transactions')
                .groupBy(database_1.default.raw('DATE(created_at)'))
                .orderBy('date', 'desc')
                .limit(30);
            res.status(200).json({
                status: 'success',
                data: {
                    totals,
                    by_date: byDate,
                },
            });
        });
        /**
         * Get doctor performance analytics
         * GET /api/v1/analytics/doctors
         */
        this.getDoctorAnalytics = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const doctors = await (0, database_1.default)('doctors')
                .join('users', 'doctors.user_id', 'users.id')
                .leftJoin('appointments', 'doctors.id', 'appointments.doctor_id')
                .where({ 'doctors.tenant_id': tenantId })
                .andWhere('doctors.deleted_at', null)
                .select('doctors.id', 'users.first_name', 'users.last_name', database_1.default.raw('COUNT(appointments.id) as total_appointments'), database_1.default.raw("COUNT(appointments.id) FILTER (WHERE appointments.status = 'completed') as completed_appointments"), database_1.default.raw("COUNT(appointments.id) FILTER (WHERE appointments.status = 'cancelled') as cancelled_appointments"), 'doctors.rating')
                .groupBy('doctors.id', 'users.first_name', 'users.last_name', 'doctors.rating')
                .orderBy('total_appointments', 'desc');
            res.status(200).json({
                status: 'success',
                data: {
                    doctors,
                },
            });
        });
        /**
         * Get patient analytics
         * GET /api/v1/analytics/patients
         */
        this.getPatientAnalytics = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const [newPatients] = await (0, database_1.default)('patients')
                .where({ tenant_id: tenantId })
                .andWhere('created_at', '>=', database_1.default.raw("NOW() - INTERVAL '30 days'"))
                .count('* as count');
            const [activePatients] = await (0, database_1.default)('patients')
                .where({ tenant_id: tenantId })
                .whereExists(function () {
                this.select('*')
                    .from('appointments')
                    .whereRaw('appointments.patient_id = patients.id')
                    .andWhere('appointments.appointment_date', '>=', database_1.default.raw("NOW() - INTERVAL '90 days'"));
            })
                .count('* as count');
            const topPatients = await (0, database_1.default)('patients')
                .join('users', 'patients.user_id', 'users.id')
                .leftJoin('appointments', 'patients.id', 'appointments.patient_id')
                .where({ 'patients.tenant_id': tenantId })
                .select('patients.id', 'users.first_name', 'users.last_name', database_1.default.raw('COUNT(appointments.id) as total_appointments'))
                .groupBy('patients.id', 'users.first_name', 'users.last_name')
                .orderBy('total_appointments', 'desc')
                .limit(10);
            res.status(200).json({
                status: 'success',
                data: {
                    new_patients_30d: parseInt(newPatients.count),
                    active_patients_90d: parseInt(activePatients.count),
                    top_patients: topPatients,
                },
            });
        });
        /**
         * Get no-show analytics
         * GET /api/v1/analytics/no-shows
         */
        this.getNoShowAnalytics = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const [stats] = await (0, database_1.default)('appointments')
                .where({ tenant_id: tenantId })
                .select(database_1.default.raw("COUNT(*) FILTER (WHERE status = 'no_show') as no_shows"), database_1.default.raw("COUNT(*) FILTER (WHERE status = 'completed') as completed"), database_1.default.raw('COUNT(*) as total'))
                .first();
            const noShowRate = stats.total > 0
                ? ((parseInt(stats.no_shows) / parseInt(stats.total)) * 100).toFixed(2)
                : 0;
            // By patient
            const topNoShowPatients = await (0, database_1.default)('appointments')
                .join('patients', 'appointments.patient_id', 'patients.id')
                .join('users', 'patients.user_id', 'users.id')
                .where({ 'appointments.tenant_id': tenantId, 'appointments.status': 'no_show' })
                .select('patients.id', 'users.first_name', 'users.last_name', database_1.default.raw('COUNT(*) as no_show_count'))
                .groupBy('patients.id', 'users.first_name', 'users.last_name')
                .orderBy('no_show_count', 'desc')
                .limit(10);
            res.status(200).json({
                status: 'success',
                data: {
                    no_show_rate: noShowRate,
                    total_no_shows: parseInt(stats.no_shows),
                    total_completed: parseInt(stats.completed),
                    total_appointments: parseInt(stats.total),
                    top_no_show_patients: topNoShowPatients,
                },
            });
        });
        /**
         * Get specialty analytics
         * GET /api/v1/analytics/specialties
         */
        this.getSpecialtyAnalytics = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const specialties = await (0, database_1.default)('appointments')
                .join('doctors', 'appointments.doctor_id', 'doctors.id')
                .join('specialties', 'doctors.specialty_id', 'specialties.id')
                .where({ 'appointments.tenant_id': tenantId })
                .select('specialties.name', database_1.default.raw('COUNT(*) as total_appointments'), database_1.default.raw("COUNT(*) FILTER (WHERE appointments.status = 'completed') as completed_appointments"))
                .groupBy('specialties.name')
                .orderBy('total_appointments', 'desc');
            res.status(200).json({
                status: 'success',
                data: {
                    specialties,
                },
            });
        });
        /**
         * Get growth metrics
         * GET /api/v1/analytics/growth
         */
        this.getGrowthMetrics = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            // New users by month (last 12 months)
            const userGrowth = await (0, database_1.default)('users')
                .where({ tenant_id: tenantId })
                .andWhere('deleted_at', null)
                .select(database_1.default.raw("TO_CHAR(created_at, 'YYYY-MM') as month"))
                .count('* as count')
                .groupBy(database_1.default.raw("TO_CHAR(created_at, 'YYYY-MM')"))
                .orderBy('month', 'desc')
                .limit(12);
            // Appointments by month
            const appointmentGrowth = await (0, database_1.default)('appointments')
                .where({ tenant_id: tenantId })
                .select(database_1.default.raw("TO_CHAR(appointment_date, 'YYYY-MM') as month"))
                .count('* as count')
                .groupBy(database_1.default.raw("TO_CHAR(appointment_date, 'YYYY-MM')"))
                .orderBy('month', 'desc')
                .limit(12);
            // Revenue by month
            const revenueGrowth = await (0, database_1.default)('payments')
                .where({ tenant_id: tenantId, status: 'succeeded' })
                .select(database_1.default.raw("TO_CHAR(created_at, 'YYYY-MM') as month"))
                .sum('amount as revenue')
                .groupBy(database_1.default.raw("TO_CHAR(created_at, 'YYYY-MM')"))
                .orderBy('month', 'desc')
                .limit(12);
            res.status(200).json({
                status: 'success',
                data: {
                    user_growth: userGrowth,
                    appointment_growth: appointmentGrowth,
                    revenue_growth: revenueGrowth,
                },
            });
        });
        /**
         * Export analytics data (CSV format)
         * GET /api/v1/analytics/export
         */
        this.exportData = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const { type = 'appointments', start_date, end_date } = req.query;
            // Get data based on type
            let data;
            switch (type) {
                case 'appointments':
                    let query = (0, database_1.default)('appointments')
                        .join('doctors', 'appointments.doctor_id', 'doctors.id')
                        .join('users as doctor_users', 'doctors.user_id', 'doctor_users.id')
                        .join('patients', 'appointments.patient_id', 'patients.id')
                        .join('users as patient_users', 'patients.user_id', 'patient_users.id')
                        .where({ 'appointments.tenant_id': tenantId })
                        .select('appointments.id', 'appointments.appointment_date', 'appointments.start_time', 'appointments.end_time', 'appointments.status', database_1.default.raw("CONCAT(doctor_users.first_name, ' ', doctor_users.last_name) as doctor_name"), database_1.default.raw("CONCAT(patient_users.first_name, ' ', patient_users.last_name) as patient_name"));
                    if (start_date)
                        query = query.andWhere('appointments.appointment_date', '>=', start_date);
                    if (end_date)
                        query = query.andWhere('appointments.appointment_date', '<=', end_date);
                    data = await query;
                    break;
                case 'revenue':
                    data = await (0, database_1.default)('payments')
                        .where({ tenant_id: tenantId, status: 'succeeded' })
                        .select('id', 'amount', 'currency', 'created_at', 'payment_method');
                    break;
                default:
                    data = [];
            }
            // Convert to CSV
            const csvData = this.convertToCSV(data);
            res.setHeader('Content-Type', 'text/csv');
            res.setHeader('Content-Disposition', `attachment; filename="${type}_export_${new Date().toISOString().split('T')[0]}.csv"`);
            res.status(200).send(csvData);
        });
        /**
         * Get monthly report
         * GET /api/v1/analytics/reports/monthly
         */
        this.getMonthlyReport = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const { month, year } = req.query;
            const currentMonth = month || new Date().getMonth() + 1;
            const currentYear = year || new Date().getFullYear();
            const startDate = `${currentYear}-${String(currentMonth).padStart(2, '0')}-01`;
            const endDate = `${currentYear}-${String(currentMonth).padStart(2, '0')}-31`;
            // Get various metrics for the month
            const [appointments] = await (0, database_1.default)('appointments')
                .where({ tenant_id: tenantId })
                .andWhereBetween('appointment_date', [startDate, endDate])
                .select(database_1.default.raw('COUNT(*) as total'), database_1.default.raw("COUNT(*) FILTER (WHERE status = 'completed') as completed"), database_1.default.raw("COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled"), database_1.default.raw("COUNT(*) FILTER (WHERE status = 'no_show') as no_shows"))
                .first();
            const [revenue] = await (0, database_1.default)('payments')
                .where({ tenant_id: tenantId, status: 'succeeded' })
                .andWhereBetween('created_at', [startDate, endDate])
                .select(database_1.default.raw('SUM(amount) as total'), database_1.default.raw('COUNT(*) as transactions'))
                .first();
            res.status(200).json({
                status: 'success',
                data: {
                    month: currentMonth,
                    year: currentYear,
                    appointments,
                    revenue,
                },
            });
        });
        /**
         * Get quarterly report
         * GET /api/v1/analytics/reports/quarterly
         */
        this.getQuarterlyReport = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            // Similar to monthly but for quarter
            res.status(200).json({
                status: 'success',
                message: 'Quarterly report endpoint',
            });
        });
        /**
         * Get yearly report
         * GET /api/v1/analytics/reports/yearly
         */
        this.getYearlyReport = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            // Similar to monthly but for year
            res.status(200).json({
                status: 'success',
                message: 'Yearly report endpoint',
            });
        });
    }
    /**
     * Helper: Convert array of objects to CSV
     */
    convertToCSV(data) {
        if (data.length === 0)
            return '';
        const headers = Object.keys(data[0]).join(',');
        const rows = data.map(row => Object.values(row).map(value => typeof value === 'string' ? `"${value}"` : value).join(','));
        return [headers, ...rows].join('\n');
    }
}
exports.AnalyticsController = AnalyticsController;
//# sourceMappingURL=analytics.controller.js.map