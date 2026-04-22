import knex, { Knex } from 'knex';
import { logger } from './logger';

const isTrue = (value: string | undefined): boolean =>
  String(value || '')
    .trim()
    .toLowerCase() === 'true';

const sslEnabled = isTrue(process.env.DB_SSL);
const rejectUnauthorized = isTrue(process.env.DB_SSL_REJECT_UNAUTHORIZED);

const baseConnection = process.env.DB_URL
  ? process.env.DB_URL
  : {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432'),
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD ? String(process.env.DB_PASSWORD).trim() : '',
      database: process.env.DB_NAME || 'medical_appointments',
    };

const config: Knex.Config = {
  client: 'postgresql',
  connection:
    typeof baseConnection === 'string'
      ? baseConnection
      : {
          ...baseConnection,
          ssl: sslEnabled
            ? {
                rejectUnauthorized,
              }
            : false,
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

const db = knex(config);

// Test database connection (only in non-test environment)
if (process.env.NODE_ENV !== 'test' && !process.env.SKIP_DB_CONNECTION_CHECK) {
  db.raw('SELECT 1')
    .then(() => {
      logger.info('✅ Database connected successfully');
    })
    .catch((err) => {
      logger.error('❌ Database connection failed:', err);
      // Don't exit in development, allow app to start
      if (process.env.NODE_ENV === 'production') {
        process.exit(1);
      }
    });
}

export default db;
