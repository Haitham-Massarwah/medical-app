import { Request, Response, NextFunction } from 'express';
export declare class AnalyticsController {
    /**
     * Get dashboard overview statistics
     * GET /api/v1/analytics/dashboard
     */
    getDashboardStats: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get appointment analytics
     * GET /api/v1/analytics/appointments
     */
    getAppointmentAnalytics: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get revenue analytics
     * GET /api/v1/analytics/revenue
     */
    getRevenueAnalytics: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get doctor performance analytics
     * GET /api/v1/analytics/doctors
     */
    getDoctorAnalytics: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get patient analytics
     * GET /api/v1/analytics/patients
     */
    getPatientAnalytics: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get no-show analytics
     * GET /api/v1/analytics/no-shows
     */
    getNoShowAnalytics: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get specialty analytics
     * GET /api/v1/analytics/specialties
     */
    getSpecialtyAnalytics: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get growth metrics
     * GET /api/v1/analytics/growth
     */
    getGrowthMetrics: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Export analytics data (CSV format)
     * GET /api/v1/analytics/export
     */
    exportData: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get monthly report
     * GET /api/v1/analytics/reports/monthly
     */
    getMonthlyReport: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get quarterly report
     * GET /api/v1/analytics/reports/quarterly
     */
    getQuarterlyReport: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Get yearly report
     * GET /api/v1/analytics/reports/yearly
     */
    getYearlyReport: (req: Request, res: Response, next: NextFunction) => void;
    /**
     * Helper: Convert array of objects to CSV
     */
    private convertToCSV;
}
//# sourceMappingURL=analytics.controller.d.ts.map