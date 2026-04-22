import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import { createServer } from 'http';
import os from 'os';

// Load environment variables
// Check NODE_ENV from environment first (before dotenv loads)
const nodeEnv = process.env.NODE_ENV || 'development';
// Load env files in order (later files override earlier values).
// This lets each clinic keep secrets in .env.local across upgrades.
const envFiles =
  nodeEnv === 'production'
    ? ['.env.production', '.env', '.env.local', '.env.production.local']
    : ['.env', '.env.local'];

for (const file of envFiles) {
  const fullPath = path.join(process.cwd(), file);
  if (fs.existsSync(fullPath)) {
    dotenv.config({ path: fullPath, override: true });
  }
}

// Import configurations
import { corsOptions } from './config/cors';
import { validateEnvironment } from './config/env';
import { rateLimiter } from './middleware/rateLimiter';
import { errorHandler } from './middleware/errorHandler';
import { logger, getAppPackageVersion } from './config/logger';

validateEnvironment();

// Import routes
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';
import doctorRoutes from './routes/doctor.routes';
import patientRoutes from './routes/patient.routes';
import appointmentRoutes from './routes/appointment.routes';
import paymentRoutes from './routes/payment.routes';
import cardcomRoutes from './routes/cardcom.routes';
import notificationRoutes from './routes/notification.routes';
import tenantRoutes from './routes/tenant.routes';
import analyticsRoutes from './routes/analytics.routes';
import calendarRoutes from './routes/calendar.routes';
import testRoutes from './routes/test.routes';
import treatmentRoutes from './routes/treatment.routes';
import invitationRoutes from './routes/invitation.routes';
import adminRoutes from './routes/admin.routes';
import permissionsRoutes from './routes/permissions.routes';
import labRoutes from './routes/lab.routes';
import insuranceRoutes from './routes/insurance.routes';
import formsRoutes from './routes/forms.routes';
import crmRoutes from './routes/crm.routes';
import financeRoutes from './routes/finance.routes';
import integrationRoutes from './routes/integration.routes';
import operationsRoutes from './routes/operations.routes';
import auditRoutes from './routes/audit.routes';
import noShowAiRoutes from './routes/noShowAi.routes';
import clinicTemplatesRoutes from './routes/clinicTemplates.routes';
import telegramRoutes from './routes/telegram.routes';
import { noShowCronService } from './services/noShowCron.service';
import { appointmentSmsAutomationService } from './services/appointmentSmsAutomation.service';
import { setTelegramWebhook, isTelegramConfigured } from './services/telegram.service';

const app: Application = express();
const httpServer = createServer(app);

// Behind nginx / load balancers: correct req.ip, X-Forwarded-Proto, etc.
app.set('trust proxy', 1);

// Middleware
app.use(helmet()); // Security headers
app.use(cors(corsOptions)); // CORS configuration
app.use(compression()); // Compress responses
app.use(express.json({ limit: '10mb' })); // Parse JSON bodies
app.use(express.urlencoded({ extended: true, limit: '10mb' })); // Parse URL-encoded bodies
app.use(morgan('combined', { stream: { write: (message) => logger.info(message.trim()) } })); // HTTP logging

// Rate limiting
app.use('/api', rateLimiter);

// Health check endpoint
app.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    appVersion: getAppPackageVersion(),
  });
});

// API Routes
const API_VERSION = process.env.API_VERSION || 'v1';
app.use(`/api/${API_VERSION}/auth`, authRoutes);
app.use(`/api/${API_VERSION}/users`, userRoutes);
app.use(`/api/${API_VERSION}/doctors`, doctorRoutes);
app.use(`/api/${API_VERSION}/patients`, patientRoutes);
app.use(`/api/${API_VERSION}/appointments`, appointmentRoutes);
app.use(`/api/${API_VERSION}/payments`, paymentRoutes);
app.use(`/api/${API_VERSION}/payments/cardcom`, cardcomRoutes);
app.use(`/api/${API_VERSION}/notifications`, notificationRoutes);
app.use(`/api/${API_VERSION}/tenants`, tenantRoutes);
app.use(`/api/${API_VERSION}/analytics`, analyticsRoutes);
app.use(`/api/${API_VERSION}/calendar`, calendarRoutes);
app.use(`/api/${API_VERSION}/test`, testRoutes);
app.use(`/api/${API_VERSION}/treatments`, treatmentRoutes);
app.use(`/api/${API_VERSION}/invitations`, invitationRoutes);
app.use(`/api/${API_VERSION}/admin`, adminRoutes);
app.use(`/api/${API_VERSION}/permissions`, permissionsRoutes);
app.use(`/api/${API_VERSION}/lab`, labRoutes);
app.use(`/api/${API_VERSION}/insurance`, insuranceRoutes);
app.use(`/api/${API_VERSION}/forms`, formsRoutes);
app.use(`/api/${API_VERSION}/crm`, crmRoutes);
app.use(`/api/${API_VERSION}/finance`, financeRoutes);
app.use(`/api/${API_VERSION}/integrations`, integrationRoutes);
app.use(`/api/${API_VERSION}/operations`, operationsRoutes);
app.use(`/api/${API_VERSION}/audit`, auditRoutes);
app.use(`/api/${API_VERSION}/ai/no-show`, noShowAiRoutes);
app.use(`/api/${API_VERSION}/templates`, clinicTemplatesRoutes);
app.use(`/api/${API_VERSION}/telegram`, telegramRoutes);

// Root redirect to frontend
app.get('/', (_req, res) => {
  res.redirect('http://localhost:8081');
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.url} not found`,
    timestamp: new Date().toISOString(),
  });
});

// Error handler (must be last)
app.use(errorHandler);

// Start server only when executed directly (not when imported by tests)
const PORT = process.env.PORT || 3000;

export const startServer = () => {
  return httpServer.listen(PORT, () => {
    logger.info(`🚀 Server running on port ${PORT}`);
    logger.info(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
    logger.info(`🔗 API Base URL: http://localhost:${PORT}/api/${API_VERSION}`);
    logger.info(`❤️  Health Check: http://localhost:${PORT}/health`);
    logger.info(`🌐 CORS Enabled: Development mode is permissive`);
    logger.info(`🏥 Medical Appointment System Backend Ready!`);
    logger.info('');
    logger.info('📋 Connection Info:');
    logger.info(`   - Local: http://localhost:${PORT}`);

    // Get network IP address
    const networkInterfaces = os.networkInterfaces();
    const ipAddress =
      Object.values(networkInterfaces)
        .flat()
        .find((iface) => iface && !iface.internal && iface.family === 'IPv4')?.address || '0.0.0.0';
    logger.info(`   - Network: http://${ipAddress}:${PORT}`);
    logger.info(`   - CORS Origins: ${process.env.CORS_ORIGIN || 'All (development mode)'}`);
    noShowCronService.start();
    appointmentSmsAutomationService.start();

    // Register the Telegram webhook once at startup when TELEGRAM_WEBHOOK_URL is set.
    if (isTelegramConfigured()) {
      setTelegramWebhook().catch((e) =>
        logger.warn('Telegram webhook registration failed', { message: (e as Error)?.message }),
      );
    }
  });
};

if (!process.env.JEST_WORKER_ID) {
  startServer();
}

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  httpServer.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT signal received: closing HTTP server');
  httpServer.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
});

export default app;
