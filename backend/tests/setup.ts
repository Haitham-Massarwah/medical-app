import dotenv from 'dotenv';

dotenv.config({ path: '.env.test' });
dotenv.config();

process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret-key-change-in-production';
process.env.DB_NAME = process.env.DB_NAME || 'medical_app_test_db';
process.env.SKIP_DB_CONNECTION_CHECK = 'true';
process.env.SKIP_SERVER_START = 'true';
process.env.PORT = '0';

jest.setTimeout(60000);

const resolvedRow = [{ id: 'test-id' }];

/** Knex-style chain: insert/update then .returning(...) */
const chainAfterWrite = () => ({
  returning: jest.fn().mockResolvedValue(resolvedRow),
  onConflict: jest.fn().mockReturnThis(),
});

const createQueryBuilder = () => ({
  select: jest.fn().mockReturnThis(),
  from: jest.fn().mockReturnThis(),
  where: jest.fn().mockReturnThis(),
  andWhere: jest.fn().mockReturnThis(),
  orWhere: jest.fn().mockReturnThis(),
  leftJoin: jest.fn().mockReturnThis(),
  innerJoin: jest.fn().mockReturnThis(),
  orderBy: jest.fn().mockReturnThis(),
  limit: jest.fn().mockReturnThis(),
  offset: jest.fn().mockReturnThis(),
  insert: jest.fn().mockImplementation(() => chainAfterWrite()),
  update: jest.fn().mockImplementation(() => chainAfterWrite()),
  delete: jest.fn().mockResolvedValue(1),
  returning: jest.fn().mockResolvedValue(resolvedRow),
  first: jest.fn().mockResolvedValue({ id: 'test-id', name: 'Test' }),
  count: jest.fn().mockResolvedValue(0),
  clone: jest.fn().mockReturnThis(),
  increment: jest.fn().mockReturnThis(),
  decrement: jest.fn().mockReturnThis(),
});

const mockDb = jest.fn(() => createQueryBuilder()) as any;
mockDb.raw = jest.fn().mockResolvedValue([{ '?column?': 1 }]);
mockDb.transaction = jest.fn((callback: (trx: typeof mockDb) => unknown) =>
  Promise.resolve(callback(mockDb)),
);
mockDb.destroy = jest.fn().mockResolvedValue(undefined);

jest.mock('../src/config/database', () => ({
  __esModule: true,
  default: mockDb,
}));

afterAll(async () => {
  await new Promise((r) => setTimeout(r, 100));
  if (global.gc) {
    global.gc();
  }
});
