"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const compression_1 = __importDefault(require("compression"));
const morgan_1 = __importDefault(require("morgan"));
const dotenv_1 = __importDefault(require("dotenv"));
const http_1 = require("http");
const os_1 = __importDefault(require("os"));
// Load environment variables
dotenv_1.default.config();
// Import configurations
const cors_2 = require("./config/cors");
const rateLimiter_1 = require("./middleware/rateLimiter");
const errorHandler_1 = require("./middleware/errorHandler");
const logger_1 = require("./config/logger");
// Import routes
const auth_routes_1 = __importDefault(require("./routes/auth.routes"));
const user_routes_1 = __importDefault(require("./routes/user.routes"));
const doctor_routes_1 = __importDefault(require("./routes/doctor.routes"));
const patient_routes_1 = __importDefault(require("./routes/patient.routes"));
const appointment_routes_1 = __importDefault(require("./routes/appointment.routes"));
const payment_routes_1 = __importDefault(require("./routes/payment.routes"));
const notification_routes_1 = __importDefault(require("./routes/notification.routes"));
const tenant_routes_1 = __importDefault(require("./routes/tenant.routes"));
const analytics_routes_1 = __importDefault(require("./routes/analytics.routes"));
const calendar_routes_1 = __importDefault(require("./routes/calendar.routes"));
const test_routes_1 = __importDefault(require("./routes/test.routes"));
const treatment_routes_1 = __importDefault(require("./routes/treatment.routes"));
const invitation_routes_1 = __importDefault(require("./routes/invitation.routes"));
const app = (0, express_1.default)();
const httpServer = (0, http_1.createServer)(app);
// Middleware
app.use((0, helmet_1.default)()); // Security headers
app.use((0, cors_1.default)(cors_2.corsOptions)); // CORS configuration
app.use((0, compression_1.default)()); // Compress responses
app.use(express_1.default.json({ limit: '10mb' })); // Parse JSON bodies
app.use(express_1.default.urlencoded({ extended: true, limit: '10mb' })); // Parse URL-encoded bodies
app.use((0, morgan_1.default)('combined', { stream: { write: (message) => logger_1.logger.info(message.trim()) } })); // HTTP logging
// Rate limiting
app.use('/api', rateLimiter_1.rateLimiter);
// Health check endpoint
app.get('/health', (_req, res) => {
    res.status(200).json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV || 'development',
    });
});
// API Routes
const API_VERSION = process.env.API_VERSION || 'v1';
app.use(`/api/${API_VERSION}/auth`, auth_routes_1.default);
app.use(`/api/${API_VERSION}/users`, user_routes_1.default);
app.use(`/api/${API_VERSION}/doctors`, doctor_routes_1.default);
app.use(`/api/${API_VERSION}/patients`, patient_routes_1.default);
app.use(`/api/${API_VERSION}/appointments`, appointment_routes_1.default);
app.use(`/api/${API_VERSION}/payments`, payment_routes_1.default);
app.use(`/api/${API_VERSION}/notifications`, notification_routes_1.default);
app.use(`/api/${API_VERSION}/tenants`, tenant_routes_1.default);
app.use(`/api/${API_VERSION}/analytics`, analytics_routes_1.default);
app.use(`/api/${API_VERSION}/calendar`, calendar_routes_1.default);
app.use(`/api/${API_VERSION}/test`, test_routes_1.default);
app.use(`/api/${API_VERSION}/treatments`, treatment_routes_1.default);
app.use(`/api/${API_VERSION}/invitations`, invitation_routes_1.default);
// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        message: `Route ${req.method} ${req.url} not found`,
        timestamp: new Date().toISOString(),
    });
});
// Error handler (must be last)
app.use(errorHandler_1.errorHandler);
// Start server
const PORT = process.env.PORT || 3000;
httpServer.listen(PORT, () => {
    logger_1.logger.info(`🚀 Server running on port ${PORT}`);
    logger_1.logger.info(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
    logger_1.logger.info(`🔗 API Base URL: http://localhost:${PORT}/api/${API_VERSION}`);
    logger_1.logger.info(`❤️  Health Check: http://localhost:${PORT}/health`);
    logger_1.logger.info(`🌐 CORS Enabled: Development mode is permissive`);
    logger_1.logger.info(`🏥 Medical Appointment System Backend Ready!`);
    logger_1.logger.info('');
    logger_1.logger.info('📋 Connection Info:');
    logger_1.logger.info(`   - Local: http://localhost:${PORT}`);
    // Get network IP address
    const networkInterfaces = os_1.default.networkInterfaces();
    const ipAddress = Object.values(networkInterfaces)
        .flat()
        .find(iface => iface && !iface.internal && iface.family === 'IPv4')?.address || '0.0.0.0';
    logger_1.logger.info(`   - Network: http://${ipAddress}:${PORT}`);
    logger_1.logger.info(`   - CORS Origins: ${process.env.CORS_ORIGIN || 'All (development mode)'}`);
});
// Graceful shutdown
process.on('SIGTERM', () => {
    logger_1.logger.info('SIGTERM signal received: closing HTTP server');
    httpServer.close(() => {
        logger_1.logger.info('HTTP server closed');
        process.exit(0);
    });
});
process.on('SIGINT', () => {
    logger_1.logger.info('SIGINT signal received: closing HTTP server');
    httpServer.close(() => {
        logger_1.logger.info('HTTP server closed');
        process.exit(0);
    });
});
exports.default = app;
//# sourceMappingURL=server.js.map