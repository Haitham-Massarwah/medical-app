"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const email_service_1 = require("../services/email.service");
const logger_1 = require("../config/logger");
const database_1 = __importDefault(require("../config/database"));
const router = (0, express_1.Router)();
/**
 * Test email sending functionality
 */
router.post('/email', async (req, res) => {
    try {
        const { to } = req.body;
        const testEmail = to || process.env.SMTP_USER || 'test@example.com';
        await (0, email_service_1.sendEmail)({
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
    }
    catch (error) {
        logger_1.logger.error('Email test failed:', error);
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
router.get('/database', async (_req, res) => {
    try {
        await database_1.default.raw('SELECT 1');
        // Get table count
        const tables = await database_1.default.raw(`
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
    }
    catch (error) {
        logger_1.logger.error('Database test failed:', error);
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
router.get('/status', (_req, res) => {
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
exports.default = router;
//# sourceMappingURL=test.routes.js.map