import { Request, Response, NextFunction } from 'express';
import db from '../config/database';
import { logger } from '../config/logger';

/** Match JWT payload: login sets `id`; some paths only expose `userId`. */
function resolveActorUserId(req: Request): string | undefined {
  const u = req.user;
  if (!u) return undefined;
  return u.id ?? u.userId ?? undefined;
}

/**
 * Middleware to check if doctor has an active subscription
 * This should be applied to routes that require a valid subscription
 */
export async function requireActiveSubscription(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const userId = resolveActorUserId(req);
    const userRole = req.user?.role;

    // Only check for doctors and paramedical staff
    if (!userId || !['doctor', 'paramedical'].includes(userRole || '')) {
      next();
      return;
    }

    // Get doctor record
    const doctor = await db('doctors')
      .where('user_id', userId)
      .first();

    if (!doctor) {
      res.status(403).json({
        success: false,
        message: 'Doctor profile not found',
        code: 'NO_DOCTOR_PROFILE',
      });
      return;
    }

    // Check subscription status
    const subscriptionStatus = doctor.subscription_status;

    // Allow access during trial and active subscription
    const allowedStatuses = ['active', 'trialing'];
    if (!allowedStatuses.includes(subscriptionStatus)) {
      res.status(403).json({
        success: false,
        message: 'Active subscription required',
        code: 'SUBSCRIPTION_REQUIRED',
        data: {
          status: subscriptionStatus,
          expires_at: doctor.subscription_expires_at,
        },
      });
      return;
    }

    // Check if subscription has expired
    if (doctor.subscription_expires_at && new Date(doctor.subscription_expires_at) < new Date()) {
      res.status(403).json({
        success: false,
        message: 'Subscription has expired',
        code: 'SUBSCRIPTION_EXPIRED',
        data: {
          expires_at: doctor.subscription_expires_at,
        },
      });
      return;
    }

    // Add subscription info to request
    req.doctor = doctor;
    next();
  } catch (error) {
    logger.error('Error checking subscription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify subscription',
    });
  }
}

/**
 * Middleware to check if doctor can book appointment based on usage limits
 */
export async function checkAppointmentLimit(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const userId = resolveActorUserId(req);
    const userRole = req.user?.role;

    // Only check for doctors and paramedical staff
    if (!userId || !['doctor', 'paramedical'].includes(userRole || '')) {
      next();
      return;
    }

    const doctor = await db('doctors')
      .where('user_id', userId)
      .first();

    if (!doctor) {
      next();
      return;
    }

    // Get active subscription
    const subscription = await db('doctor_subscriptions')
      .where('doctor_id', doctor.id)
      .whereIn('status', ['active', 'trialing'])
      .orderBy('created_at', 'desc')
      .first();

    if (!subscription) {
      res.status(403).json({
        success: false,
        message: 'Active subscription required',
        code: 'SUBSCRIPTION_REQUIRED',
      });
      return;
    }

    // Get plan to check limits
    const plan = await db('subscription_plans')
      .where('id', subscription.plan_id)
      .first();

    if (!plan) {
      next();
      return;
    }

    // If unlimited, allow
    if (plan.max_appointments_per_month === -1) {
      next();
      return;
    }

    // Check current month usage
    const now = new Date();
    const month = now.getMonth() + 1;
    const year = now.getFullYear();

    const usage = await db('subscription_usage')
      .where('subscription_id', subscription.id)
      .where('month', month)
      .where('year', year)
      .first();

    const currentCount = usage?.appointments_count || 0;

    if (currentCount >= plan.max_appointments_per_month) {
      res.status(403).json({
        success: false,
        message: 'Monthly appointment limit reached',
        code: 'APPOINTMENT_LIMIT_REACHED',
        data: {
          current_usage: currentCount,
          limit: plan.max_appointments_per_month,
          plan_name: plan.name,
        },
      });
      return;
    }

    next();
  } catch (error) {
    logger.error('Error checking appointment limit:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify appointment limit',
    });
  }
}

/**
 * Middleware to allow graceful degradation (warning but allow access)
 * Useful for non-critical features during subscription issues
 */
export async function warnIfNoSubscription(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const userId = resolveActorUserId(req);
    const userRole = req.user?.role;

    if (!userId || !['doctor', 'paramedical'].includes(userRole || '')) {
      next();
      return;
    }

    const doctor = await db('doctors')
      .where('user_id', userId)
      .first();

    if (doctor && doctor.subscription_status !== 'active' && doctor.subscription_status !== 'trialing') {
      // Add warning to response headers
      res.set('X-Subscription-Warning', 'Subscription is not active');
      res.set('X-Subscription-Status', doctor.subscription_status);
    }

    next();
  } catch (error) {
    logger.error('Error checking subscription warning:', error);
    next(); // Continue anyway for non-critical checks
  }
}

// Extend Express Request type to include doctor
declare global {
  namespace Express {
    interface Request {
      doctor?: any;
    }
  }
}


