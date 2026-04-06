/**
 * Database Mock for Tests
 * Provides mock database functions to avoid requiring actual database connection
 */

export const mockDb = {
  raw: jest.fn().mockResolvedValue([{ test: true }]),
  select: jest.fn().mockReturnThis(),
  from: jest.fn().mockReturnThis(),
  where: jest.fn().mockReturnThis(),
  andWhere: jest.fn().mockReturnThis(),
  insert: jest.fn().mockResolvedValue([{ id: 'test-id', name: 'Test' }]),
  update: jest.fn().mockResolvedValue([{ id: 'test-id', name: 'Updated' }]),
  delete: jest.fn().mockResolvedValue(1),
  returning: jest.fn().mockReturnThis(),
  first: jest.fn().mockResolvedValue({ id: 'test-id', name: 'Test' }),
  destroy: jest.fn().mockResolvedValue(undefined),
  transaction: jest.fn().mockImplementation((callback) => {
    return Promise.resolve(callback(mockDb));
  }),
};

// Mock the database module
jest.mock('../src/config/database', () => ({
  __esModule: true,
  default: mockDb,
}));

export default mockDb;



