"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const knex_1 = __importDefault(require("knex"));
const logger_1 = require("./logger");
const config = {
    client: 'postgresql',
    connection: {
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT || '5432'),
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'medical_appointments',
    },
    pool: {
        min: parseInt(process.env.DB_POOL_MIN || '2'),
        max: parseInt(process.env.DB_POOL_MAX || '10'),
    },
    migrations: {
        directory: './src/database/migrations',
        extension: 'ts',
    },
    seeds: {
        directory: './src/database/seeds',
        extension: 'ts',
    },
    debug: process.env.NODE_ENV === 'development',
};
const db = (0, knex_1.default)(config);
// Test database connection
db.raw('SELECT 1')
    .then(() => {
    logger_1.logger.info('✅ Database connected successfully');
})
    .catch((err) => {
    logger_1.logger.error('❌ Database connection failed:', err);
    process.exit(1);
});
exports.default = db;
//# sourceMappingURL=database.js.map