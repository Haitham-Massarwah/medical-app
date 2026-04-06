/**
 * Database Helper for Integration Tests
 * Fixes Knex returning() syntax issues
 */

import db from '../../src/config/database';

/**
 * Insert and return first result
 * Handles both array and single object returns from Knex
 */
export const insertAndReturn = async <T>(
  table: string,
  data: any
): Promise<T> => {
  const result = await db(table).insert(data).returning('*');
  return Array.isArray(result) ? result[0] : result;
};

/**
 * Insert multiple and return all results
 */
export const insertMultipleAndReturn = async <T>(
  table: string,
  data: any[]
): Promise<T[]> => {
  const result = await db(table).insert(data).returning('*');
  return Array.isArray(result) ? result : [result];
};

export default { insertAndReturn, insertMultipleAndReturn };



