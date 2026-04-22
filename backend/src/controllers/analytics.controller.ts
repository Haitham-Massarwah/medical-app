import { Request, Response, NextFunction } from 'express';
import { asyncHandler } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';

export class AnalyticsController {
  private async _hasPaymentsTable(): Promise<boolean> {
    try {
      return await db.schema.hasTable('payments');
    } catch (e) {
      // If schema introspection fails for any reason, fail safe by treating as missing.
      logger.warn('Failed to check payments table existence; defaulting to no-payments.', e as any);
      return false;
    }
  }

  /**
   * Get dashboard overview statistics
   * GET /api/v1/analytics/dashboard
   */
  getDashboardStats = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;

    // Get counts
    const [totalUsers] = await db('users')
      .where({ tenant_id: tenantId })
      .count('* as count');

    const [totalDoctors] = await db('doctors')
      .where({ tenant_id: tenantId })
      .andWhere('is_active', true)
      .count('* as count');

    const [totalPatients] = await db('patients')
      .where({ tenant_id: tenantId })
      .count('* as count');

    const [totalAppointments] = await db('appointments')
      .where({ tenant_id: tenantId })
      .count('* as count');

    const [todayAppointments] = await db('appointments')
      .where({ tenant_id: tenantId })
      // appointment_date is a timestamp; compare by DATE() to avoid mismatched types
      .andWhereRaw('DATE(appointment_date) = CURRENT_DATE')
      .count('* as count');

    const [completedAppointments] = await db('appointments')
      .where({ tenant_id: tenantId, status: 'completed' })
      .count('* as count');

    let totalRevenue = 0;
    if (await this._hasPaymentsTable()) {
      const totalRevenueResult = await db('payments')
        .where({ tenant_id: tenantId, status: 'succeeded' })
        .sum('amount as total')
        .first();
      totalRevenue = Number((totalRevenueResult as any)?.total || 0);
    }

    res.status(200).json({
      status: 'success',
      data: {
        dashboard: {
          total_users: parseInt(totalUsers.count as string),
          total_doctors: parseInt(totalDoctors.count as string),
          total_patients: parseInt(totalPatients.count as string),
          total_appointments: parseInt(totalAppointments.count as string),
          today_appointments: parseInt(todayAppointments.count as string),
          completed_appointments: parseInt(completedAppointments.count as string),
          total_revenue: totalRevenue,
        },
      },
    });
  });

  /**
   * Dashboard user activity (audit_events + light signup stats).
   * GET /api/v1/analytics/dashboard-activity
   */
  getDashboardActivity = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const hasAuditEvents = await db.schema.hasTable('audit_events');

    let recent_events: any[] = [];
    let audit_events_last_24h = 0;
    let distinct_actor_users_7d = 0;

    if (hasAuditEvents) {
      recent_events = await db('audit_events')
        .leftJoin('users', 'audit_events.actor_user_id', 'users.id')
        .where('audit_events.tenant_id', tenantId)
        .select(
          'audit_events.created_at',
          'audit_events.action',
          'audit_events.entity_type',
          'audit_events.summary',
          db.raw(
            "TRIM(CONCAT(COALESCE(users.first_name,''),' ',COALESCE(users.last_name,''))) as actor_name",
          ),
          'users.email as actor_email',
        )
        .orderBy('audit_events.created_at', 'desc')
        .limit(25);

      const c24 = await db('audit_events')
        .where({ tenant_id: tenantId })
        .andWhere('created_at', '>=', db.raw("NOW() - INTERVAL '24 hours'"))
        .count('* as c')
        .first();
      audit_events_last_24h = Number((c24 as { c?: string | number })?.c ?? 0);

      const d7 = await db('audit_events')
        .where({ tenant_id: tenantId })
        .andWhere('created_at', '>=', db.raw("NOW() - INTERVAL '7 days'"))
        .whereNotNull('actor_user_id')
        .countDistinct({ actor_user_id: 'c' })
        .first();
      distinct_actor_users_7d = Number((d7 as { c?: string | number })?.c ?? 0);
    }

    const newUsersRow = await db('users')
      .where({ tenant_id: tenantId })
      .andWhere('created_at', '>=', db.raw("NOW() - INTERVAL '7 days'"))
      .count('* as c')
      .first();
    const new_users_7d = Number((newUsersRow as { c?: string | number })?.c ?? 0);

    res.status(200).json({
      status: 'success',
      data: {
        stats: {
          audit_events_last_24h,
          distinct_actor_users_7d,
          new_users_7d,
        },
        recent_events,
      },
    });
  });

  /**
   * Admin health summary: integrations + recent audit trail.
   * GET /api/v1/analytics/admin-health
   */
  getAdminHealth = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;

    const hasIntegrationConnections = await db.schema.hasTable('integration_connections');
    const hasIntegrationEvents = await db.schema.hasTable('integration_events');
    const hasAuditLogs = await db.schema.hasTable('audit_logs');

    let connectedIntegrations = 0;
    let integrationErrors24h = 0;
    let recentIntegrationEvents: any[] = [];
    if (hasIntegrationConnections) {
      const connected = await db('integration_connections')
        .where({ tenant_id: tenantId, status: 'connected' })
        .count('* as count')
        .first();
      connectedIntegrations = Number((connected as any)?.count || 0);
    }
    if (hasIntegrationEvents) {
      const err = await db('integration_events')
        .where({ tenant_id: tenantId, severity: 'error' })
        .andWhere('created_at', '>=', db.raw("NOW() - INTERVAL '24 hours'"))
        .count('* as count')
        .first();
      integrationErrors24h = Number((err as any)?.count || 0);

      recentIntegrationEvents = await db('integration_events')
        .where({ tenant_id: tenantId })
        .orderBy('created_at', 'desc')
        .limit(20)
        .select('id', 'provider', 'event_type', 'severity', 'status', 'message', 'created_at');
    }

    let recentAudit: any[] = [];
    if (hasAuditLogs) {
      recentAudit = await db('audit_logs')
        .where({ tenant_id: tenantId })
        .orderBy('created_at', 'desc')
        .limit(20)
        .select('id', 'user_id', 'action', 'entity_type', 'entity_id', 'created_at');
    }

    res.status(200).json({
      status: 'success',
      data: {
        summary: {
          connected_integrations: connectedIntegrations,
          integration_errors_24h: integrationErrors24h,
          recent_integration_events: recentIntegrationEvents.length,
          recent_audit_entries: recentAudit.length,
        },
        integration_events: recentIntegrationEvents,
        audit_entries: recentAudit,
      },
    });
  });

  /**
   * Get appointment analytics
   * GET /api/v1/analytics/appointments
   */
  getAppointmentAnalytics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const { start_date, end_date } = req.query;

    let query = db('appointments')
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
      .select(db.raw('DATE(appointment_date) as date'))
      .count('* as count')
      .groupBy(db.raw('DATE(appointment_date)'))
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
  getRevenueAnalytics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const { start_date, end_date } = req.query;

    const empty = () => res.status(200).json({
      status: 'success',
      data: {
        totals: { total_revenue: 0, total_transactions: 0, average_transaction: 0 },
        by_date: [],
      },
    });

    if (!(await this._hasPaymentsTable())) {
      return empty();
    }

    try {
      let query = db('payments')
        .where({ tenant_id: tenantId, status: 'succeeded' });

      if (start_date) {
        query = query.andWhere('created_at', '>=', start_date);
      }
      if (end_date) {
        query = query.andWhere('created_at', '<=', end_date);
      }

      const totals = await query.clone()
        .select(
          db.raw('SUM(amount) as total_revenue'),
          db.raw('COUNT(*) as total_transactions'),
          db.raw('AVG(amount) as average_transaction')
        )
        .first();

      // By date
      const byDate = await query.clone()
        .select(db.raw('DATE(created_at) as date'))
        .sum('amount as revenue')
        .count('* as transactions')
        .groupBy(db.raw('DATE(created_at)'))
        .orderBy('date', 'desc')
        .limit(30);

      return res.status(200).json({
        status: 'success',
        data: {
          totals: totals || { total_revenue: 0, total_transactions: 0, average_transaction: 0 },
          by_date: byDate,
        },
      });
    } catch (e) {
      // Fail-safe: if the payments table exists but schema differs (missing columns), don't crash the dashboard.
      logger.warn('Revenue analytics failed; returning empty revenue analytics.', e as any);
      return empty();
    }
  });

  /**
   * Get doctor performance analytics
   * GET /api/v1/analytics/doctors
   */
  getDoctorAnalytics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;

    const doctors = await db('doctors')
      .join('users', 'doctors.user_id', 'users.id')
      .leftJoin('appointments', 'doctors.id', 'appointments.doctor_id')
      .where({ 'doctors.tenant_id': tenantId })
      .andWhere('doctors.is_active', true)
      .select(
        'doctors.id',
        'users.first_name',
        'users.last_name',
        db.raw('COUNT(appointments.id) as total_appointments'),
        db.raw("COUNT(appointments.id) FILTER (WHERE appointments.status = 'completed') as completed_appointments"),
        db.raw("COUNT(appointments.id) FILTER (WHERE appointments.status = 'cancelled') as cancelled_appointments"),
        'doctors.rating'
      )
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
  getPatientAnalytics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;

    const [newPatients] = await db('patients')
      .where({ tenant_id: tenantId })
      .andWhere('created_at', '>=', db.raw("NOW() - INTERVAL '30 days'"))
      .count('* as count');

    const [activePatients] = await db('patients')
      .where({ tenant_id: tenantId })
      .whereExists(function() {
        this.select('*')
          .from('appointments')
          .whereRaw('appointments.patient_id = patients.id')
          .andWhere('appointments.appointment_date', '>=', db.raw("NOW() - INTERVAL '90 days'"));
      })
      .count('* as count');

    const topPatients = await db('patients')
      .join('users', 'patients.user_id', 'users.id')
      .leftJoin('appointments', 'patients.id', 'appointments.patient_id')
      .where({ 'patients.tenant_id': tenantId })
      .select(
        'patients.id',
        'users.first_name',
        'users.last_name',
        db.raw('COUNT(appointments.id) as total_appointments')
      )
      .groupBy('patients.id', 'users.first_name', 'users.last_name')
      .orderBy('total_appointments', 'desc')
      .limit(10);

    res.status(200).json({
      status: 'success',
      data: {
        new_patients_30d: parseInt(newPatients.count as string),
        active_patients_90d: parseInt(activePatients.count as string),
        top_patients: topPatients,
      },
    });
  });

  /**
   * Get no-show analytics
   * GET /api/v1/analytics/no-shows
   */
  getNoShowAnalytics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;

    const [stats] = await db('appointments')
      .where({ tenant_id: tenantId })
      .select(
        db.raw("COUNT(*) FILTER (WHERE status = 'no_show') as no_shows"),
        db.raw("COUNT(*) FILTER (WHERE status = 'completed') as completed"),
        db.raw('COUNT(*) as total')
      )
      .first();

    const noShowRate = stats.total > 0 
      ? ((parseInt(stats.no_shows) / parseInt(stats.total)) * 100).toFixed(2)
      : 0;

    // By patient
    const topNoShowPatients = await db('appointments')
      .join('patients', 'appointments.patient_id', 'patients.id')
      .join('users', 'patients.user_id', 'users.id')
      .where({ 'appointments.tenant_id': tenantId, 'appointments.status': 'no_show' })
      .select(
        'patients.id',
        'users.first_name',
        'users.last_name',
        db.raw('COUNT(*) as no_show_count')
      )
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
  getSpecialtyAnalytics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;

    const specialties = await db('appointments')
      .join('doctors', 'appointments.doctor_id', 'doctors.id')
      .join('specialties', 'doctors.specialty_id', 'specialties.id')
      .where({ 'appointments.tenant_id': tenantId })
      .select(
        'specialties.name',
        db.raw('COUNT(*) as total_appointments'),
        db.raw("COUNT(*) FILTER (WHERE appointments.status = 'completed') as completed_appointments")
      )
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
  getGrowthMetrics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;

    // New users by month (last 12 months)
    const userGrowth = await db('users')
      .where({ tenant_id: tenantId })
      .select(db.raw("TO_CHAR(created_at, 'YYYY-MM') as month"))
      .count('* as count')
      .groupBy(db.raw("TO_CHAR(created_at, 'YYYY-MM')"))
      .orderBy('month', 'desc')
      .limit(12);

    // Appointments by month
    const appointmentGrowth = await db('appointments')
      .where({ tenant_id: tenantId })
      .select(db.raw("TO_CHAR(appointment_date, 'YYYY-MM') as month"))
      .count('* as count')
      .groupBy(db.raw("TO_CHAR(appointment_date, 'YYYY-MM')"))
      .orderBy('month', 'desc')
      .limit(12);

    // Revenue by month (payments table may not exist yet)
    let revenueGrowth: any[] = [];
    if (await this._hasPaymentsTable()) {
      revenueGrowth = await db('payments')
        .where({ tenant_id: tenantId, status: 'succeeded' })
        .select(db.raw("TO_CHAR(created_at, 'YYYY-MM') as month"))
        .sum('amount as revenue')
        .groupBy(db.raw("TO_CHAR(created_at, 'YYYY-MM')"))
        .orderBy('month', 'desc')
        .limit(12);
    }

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
  exportData = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const { type = 'appointments', start_date, end_date } = req.query;

    // Get data based on type
    let data: any[];
    
    switch (type) {
      case 'appointments':
        let query = db('appointments')
          .join('doctors', 'appointments.doctor_id', 'doctors.id')
          .join('users as doctor_users', 'doctors.user_id', 'doctor_users.id')
          .join('patients', 'appointments.patient_id', 'patients.id')
          .join('users as patient_users', 'patients.user_id', 'patient_users.id')
          .where({ 'appointments.tenant_id': tenantId })
          .select(
            'appointments.id',
            'appointments.appointment_date',
            'appointments.start_time',
            'appointments.end_time',
            'appointments.status',
            db.raw("CONCAT(doctor_users.first_name, ' ', doctor_users.last_name) as doctor_name"),
            db.raw("CONCAT(patient_users.first_name, ' ', patient_users.last_name) as patient_name")
          );

        if (start_date) query = query.andWhere('appointments.appointment_date', '>=', start_date);
        if (end_date) query = query.andWhere('appointments.appointment_date', '<=', end_date);

        data = await query;
        break;

      case 'revenue':
        if (!(await this._hasPaymentsTable())) {
          data = [];
          break;
        }
        data = await db('payments')
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
  getMonthlyReport = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const { month, year } = req.query;

    const currentMonth = month || new Date().getMonth() + 1;
    const currentYear = year || new Date().getFullYear();

    const startDate = `${currentYear}-${String(currentMonth).padStart(2, '0')}-01`;
    const endDate = `${currentYear}-${String(currentMonth).padStart(2, '0')}-31`;

    // Get various metrics for the month
    const [appointments] = await db('appointments')
      .where({ tenant_id: tenantId })
      .andWhereBetween('appointment_date', [startDate, endDate])
      .select(
        db.raw('COUNT(*) as total'),
        db.raw("COUNT(*) FILTER (WHERE status = 'completed') as completed"),
        db.raw("COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled"),
        db.raw("COUNT(*) FILTER (WHERE status = 'no_show') as no_shows")
      )
      .first();

    let revenue: any = { total: 0, transactions: 0 };
    if (await this._hasPaymentsTable()) {
      revenue = await db('payments')
        .where({ tenant_id: tenantId, status: 'succeeded' })
        .andWhereBetween('created_at', [startDate, endDate])
        .select(
          db.raw('SUM(amount) as total'),
          db.raw('COUNT(*) as transactions')
        )
        .first();
    }

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
   * Combined advanced analytics: revenue, appointments, doctor performance.
   * GET /api/v1/analytics/advanced?start_date=&end_date=
   */
  getAdvancedAnalytics = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const tenantId = req.tenantId!;
    const role = req.user?.role || '';
    const userId = req.user?.userId || req.user?.id;
    const start_date = req.query.start_date as string | undefined;
    const end_date = req.query.end_date as string | undefined;
    const scopedDoctorIdFromQuery = req.query.doctor_id as string | undefined;

    let scopedDoctorId: string | null = null;
    if (role === 'doctor') {
      const doctor = await db('doctors')
        .where({ tenant_id: tenantId, user_id: userId, is_active: true })
        .first('id');
      scopedDoctorId = doctor?.id ?? null;
    } else if (role === 'admin' || role === 'developer') {
      scopedDoctorId = scopedDoctorIdFromQuery || null;
    }

    let apptQ = db('appointments').where({ tenant_id: tenantId });
    if (scopedDoctorId) {
      apptQ = apptQ.andWhere('doctor_id', scopedDoctorId);
    }
    if (start_date) {
      apptQ = apptQ.andWhere('appointment_date', '>=', start_date);
    }
    if (end_date) {
      apptQ = apptQ.andWhere('appointment_date', '<=', end_date);
    }

    const appointments_by_status = await apptQ
      .clone()
      .select('status')
      .count('* as count')
      .groupBy('status');

    const appointments_by_date = await apptQ
      .clone()
      .select(db.raw('DATE(appointment_date) as date'))
      .count('* as count')
      .groupBy(db.raw('DATE(appointment_date)'))
      .orderBy('date', 'desc')
      .limit(30);

    let revenue: Record<string, unknown> = {
      totals: { total_revenue: 0, total_transactions: 0 },
      by_date: [],
    };

    if (await this._hasPaymentsTable()) {
      try {
        let payQ = db('payments as p')
          .leftJoin('appointments as a', 'p.appointment_id', 'a.id')
          .where({ 'p.tenant_id': tenantId, 'p.status': 'succeeded' });
        if (scopedDoctorId) {
          payQ = payQ.andWhere('a.doctor_id', scopedDoctorId);
        }
        if (start_date) {
          payQ = payQ.andWhere('p.created_at', '>=', start_date);
        }
        if (end_date) {
          payQ = payQ.andWhere('p.created_at', '<=', end_date);
        }
        const totals = await payQ
          .clone()
          .select(
            db.raw('COALESCE(SUM(p.amount),0) as total_revenue'),
            db.raw('COUNT(*)::int as total_transactions'),
          )
          .first();
        const byDate = await payQ
          .clone()
          .select(db.raw('DATE(p.created_at) as date'))
          .sum('p.amount as revenue')
          .count('* as transactions')
          .groupBy(db.raw('DATE(p.created_at)'))
          .orderBy('date', 'desc')
          .limit(30);
        const byDoctor = await payQ
          .clone()
          .join('doctors as d', 'a.doctor_id', 'd.id')
          .join('users as u', 'd.user_id', 'u.id')
          .select(
            'd.id as doctor_id',
            'u.first_name',
            'u.last_name',
            db.raw('COALESCE(SUM(p.amount),0) as revenue'),
            db.raw('COUNT(*)::int as transactions'),
          )
          .groupBy('d.id', 'u.first_name', 'u.last_name')
          .orderBy('revenue', 'desc');
        revenue = { totals: totals || {}, by_date: byDate, by_doctor: byDoctor };
      } catch (e) {
        logger.warn('Advanced analytics revenue block failed', e as any);
      }
    }

    const doctors = await db('doctors')
      .join('users', 'doctors.user_id', 'users.id')
      .leftJoin('appointments', 'doctors.id', 'appointments.doctor_id')
      .where({ 'doctors.tenant_id': tenantId })
      .where('doctors.is_active', true)
      .select(
        'doctors.id',
        'users.first_name',
        'users.last_name',
        db.raw('COUNT(appointments.id) as total_appointments'),
        db.raw(
          "COUNT(appointments.id) FILTER (WHERE appointments.status = 'completed') as completed_appointments",
        ),
        db.raw(
          "COUNT(appointments.id) FILTER (WHERE appointments.status = 'cancelled') as cancelled_appointments",
        ),
      )
      .groupBy('doctors.id', 'users.first_name', 'users.last_name')
      .orderBy('total_appointments', 'desc');

    // Workload distribution by weekday.
    const workload_by_weekday = await apptQ
      .clone()
      .select(db.raw("EXTRACT(DOW FROM appointment_date)::int as day_of_week"))
      .count('* as appointments')
      .groupBy(db.raw('EXTRACT(DOW FROM appointment_date)::int'))
      .orderBy('day_of_week', 'asc');

    // Cancellation analysis (rate + reasons + by day).
    const cancellationTotals = await apptQ
      .clone()
      .select(
        db.raw('COUNT(*)::int as total'),
        db.raw("COUNT(*) FILTER (WHERE status = 'cancelled')::int as cancelled"),
      )
      .first();
    const cancellation_by_reason = await apptQ
      .clone()
      .where('status', 'cancelled')
      .select(db.raw("COALESCE(NULLIF(TRIM(cancellation_reason), ''), 'unspecified') as reason"))
      .count('* as count')
      .groupBy(db.raw("COALESCE(NULLIF(TRIM(cancellation_reason), ''), 'unspecified')"))
      .orderBy('count', 'desc')
      .limit(10);
    const cancellation_by_day = await apptQ
      .clone()
      .where('status', 'cancelled')
      .select(db.raw('DATE(appointment_date) as date'))
      .count('* as count')
      .groupBy(db.raw('DATE(appointment_date)'))
      .orderBy('date', 'desc')
      .limit(30);
    const totalAppointments = Number((cancellationTotals as any)?.total || 0);
    const totalCancelled = Number((cancellationTotals as any)?.cancelled || 0);
    const cancellation_analysis = {
      total_appointments: totalAppointments,
      total_cancelled: totalCancelled,
      cancellation_rate_pct:
        totalAppointments > 0 ? Number(((totalCancelled / totalAppointments) * 100).toFixed(2)) : 0,
      by_reason: cancellation_by_reason,
      by_day: cancellation_by_day,
    };

    // Lead conversion (CRM lead -> booked appointment with same phone/email in tenant).
    let lead_conversion: Record<string, unknown> = {
      total_leads: 0,
      converted_leads: 0,
      conversion_rate_pct: 0,
    };
    const hasCrmLeads = await db.schema.hasTable('crm_leads');
    if (hasCrmLeads) {
      let leadsQ = db('crm_leads as l').where('l.tenant_id', tenantId);
      if (scopedDoctorId) {
        leadsQ = leadsQ.andWhere('l.owner_user_id', userId || '');
      }
      if (start_date) {
        leadsQ = leadsQ.andWhere('l.created_at', '>=', start_date);
      }
      if (end_date) {
        leadsQ = leadsQ.andWhere('l.created_at', '<=', end_date);
      }
      const convertedExistsSql = scopedDoctorId
        ? `
            EXISTS (
              SELECT 1
              FROM patients p
              JOIN appointments a ON a.patient_id = p.id AND a.tenant_id = l.tenant_id
              WHERE p.tenant_id = l.tenant_id
                AND (LOWER(COALESCE(p.phone,'')) = LOWER(COALESCE(l.phone,'')) OR LOWER(COALESCE(p.email,'')) = LOWER(COALESCE(l.email,'')))
                AND a.doctor_id = ?
            )
          `
        : `
            EXISTS (
              SELECT 1
              FROM patients p
              JOIN appointments a ON a.patient_id = p.id AND a.tenant_id = l.tenant_id
              WHERE p.tenant_id = l.tenant_id
                AND (LOWER(COALESCE(p.phone,'')) = LOWER(COALESCE(l.phone,'')) OR LOWER(COALESCE(p.email,'')) = LOWER(COALESCE(l.email,'')))
            )
          `;
      const leadStats = await leadsQ
        .clone()
        .select(
          db.raw('COUNT(DISTINCT l.id)::int as total_leads'),
          db.raw(
            `COUNT(DISTINCT CASE WHEN ${convertedExistsSql} THEN l.id END)::int as converted_leads`,
            scopedDoctorId ? [scopedDoctorId] : [],
          ),
        )
        .first();
      const totalLeads = Number((leadStats as any)?.total_leads || 0);
      const convertedLeads = Number((leadStats as any)?.converted_leads || 0);
      lead_conversion = {
        total_leads: totalLeads,
        converted_leads: convertedLeads,
        conversion_rate_pct: totalLeads > 0 ? Number(((convertedLeads / totalLeads) * 100).toFixed(2)) : 0,
      };
    }

    res.status(200).json({
      status: 'success',
      data: {
        scope: {
          tenant_id: tenantId,
          role,
          scoped_doctor_id: scopedDoctorId,
          start_date: start_date || null,
          end_date: end_date || null,
        },
        appointments_by_status,
        appointments_by_date,
        revenue,
        doctors,
        workload_by_weekday,
        cancellation_analysis,
        lead_conversion,
      },
    });
  });

  /**
   * Get quarterly report
   * GET /api/v1/analytics/reports/quarterly
   */
  getQuarterlyReport = asyncHandler(async (_req: Request, res: Response, next: NextFunction) => {
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
  getYearlyReport = asyncHandler(async (_req: Request, res: Response, next: NextFunction) => {
    // Similar to monthly but for year
    res.status(200).json({
      status: 'success',
      message: 'Yearly report endpoint',
    });
  });

  /**
   * Helper: Convert array of objects to CSV
   */
  private convertToCSV(data: any[]): string {
    if (data.length === 0) return '';

    const headers = Object.keys(data[0]).join(',');
    const rows = data.map(row => 
      Object.values(row).map(value => 
        typeof value === 'string' ? `"${value}"` : value
      ).join(',')
    );

    return [headers, ...rows].join('\n');
  }
}


