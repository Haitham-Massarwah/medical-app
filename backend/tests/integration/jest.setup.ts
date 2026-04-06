/**
 * Integration tests — real Knex/Postgres (no jest.mock on database).
 */

import dotenv from 'dotenv';

dotenv.config({ path: '.env.test' });
dotenv.config();

process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret-key-change-in-production';
process.env.DB_NAME = process.env.DB_NAME || 'medical_app_test_db';
process.env.SKIP_SERVER_START = 'true';
process.env.SKIP_DB_CONNECTION_CHECK = 'true';

jest.setTimeout(120000);



