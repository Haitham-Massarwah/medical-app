import { Router, Request, Response } from 'express';
import { sendEmail } from '../services/email.service';
import { logger } from '../config/logger';
import db from '../config/database';

const router = Router();

/**
 * Test email sending functionality
 */
router.post('/email', async (req: Request, res: Response) => {
  try {
    const { to } = req.body;
    const testEmail = to || process.env.SMTP_USER || 'test@example.com';

    await sendEmail({
      to: testEmail,
      subject: 'Test Email from Medical Appointment System',
      template: 'test-email',
      data: {
        message: 'This is a test email to verify email configuration is working correctly.',
        timestamp: new Date().toISOString(),
        system: 'Medical Appointment System',
      },
    });

    res.status(200).json({
      success: true,
      message: 'Test email sent successfully',
      to: testEmail,
    });
  } catch (error: any) {
    logger.error('Email test failed:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send test email',
      error: error.message,
    });
  }
});

/**
 * Test database connection
 */
router.get('/database', async (_req: Request, res: Response) => {
  try {
    await db.raw('SELECT 1');
    
    // Get table count
    const tables = await db.raw(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);

    res.status(200).json({
      success: true,
      message: 'Database connection successful',
      tablesCount: tables.rows.length,
      timestamp: new Date().toISOString(),
    });
  } catch (error: any) {
    logger.error('Database test failed:', error);
    res.status(500).json({
      success: false,
      message: 'Database connection failed',
      error: error.message,
    });
  }
});

/**
 * System status test
 */
router.get('/status', (_req: Request, res: Response) => {
  res.status(200).json({
    success: true,
    system: {
      backend: 'operational',
      database: 'connected',
      email: process.env.SMTP_HOST ? 'configured' : 'not configured',
      environment: process.env.NODE_ENV || 'development',
    },
    timestamp: new Date().toISOString(),
  });
});

export default router;





