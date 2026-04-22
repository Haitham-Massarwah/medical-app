import { createClient, RedisClientType } from 'redis';
import { logger } from './logger';

function shouldUseRedis(): boolean {
  const v = process.env.REDIS_ENABLED;
  if (v === 'false') {
    return false;
  }
  if (v === 'true') {
    return true;
  }
  // Unset: off in development (avoids ECONNREFUSED log spam); on in production if you run Redis
  return (process.env.NODE_ENV || 'development') === 'production';
}

class RedisClient {
  private client: RedisClientType | null = null;
  private isConnected: boolean = false;
  private redisEnabled: boolean = true;
  private errorLogged = false;

  constructor() {
    const redisEnabled = shouldUseRedis();

    if (!redisEnabled) {
      logger.info('ℹ️  Redis is disabled - running without caching');
      this.redisEnabled = false;
      return;
    }

    try {
      const allowReconnect = process.env.REDIS_RECONNECT === 'true';
      this.client = createClient({
        url: `redis://${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || 6379}`,
        password: process.env.REDIS_PASSWORD || undefined,
        database: parseInt(process.env.REDIS_DB || '0'),
        socket: {
          reconnectStrategy(retries: number) {
            if (!allowReconnect || retries > 8) {
              return false;
            }
            return Math.min(retries * 150, 3000);
          },
        },
      });

      this.client.on('error', () => {
        const wasConnected = this.isConnected;
        this.isConnected = false;
        if (wasConnected) {
          logger.warn('⚠️  Redis connection error - continuing without cache');
        } else if (!this.errorLogged) {
          this.errorLogged = true;
          logger.warn(
            '⚠️  Redis unavailable - continuing without cache (set REDIS_ENABLED=false or start Redis)'
          );
        }
      });

      this.client.on('connect', () => {
        logger.info('✅ Redis connected successfully');
        this.isConnected = true;
      });

      this.client.on('disconnect', () => {
        logger.warn('⚠️  Redis disconnected - continuing without cache');
        this.isConnected = false;
      });

      this.connect();
    } catch (error) {
      logger.warn('⚠️  Redis initialization failed - continuing without cache');
      this.redisEnabled = false;
    }
  }

  private async connect(): Promise<void> {
    if (!this.client) return;

    try {
      await this.client.connect();
    } catch {
      logger.warn('⚠️  Failed to connect to Redis - app will run without caching');
      this.redisEnabled = false;
      this.isConnected = false;
      try {
        await this.client.disconnect();
      } catch {
        /* ignore */
      }
      this.client = null;
    }
  }

  public getClient(): RedisClientType | null {
    return this.client;
  }

  public async get(key: string): Promise<string | null> {
    if (!this.isConnected || !this.client) return null;
    try {
      return await this.client.get(key);
    } catch (error) {
      return null;
    }
  }

  public async set(key: string, value: string, ttl?: number): Promise<boolean> {
    if (!this.isConnected || !this.client) return false;
    try {
      if (ttl) {
        await this.client.setEx(key, ttl, value);
      } else {
        await this.client.set(key, value);
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  public async del(key: string): Promise<boolean> {
    if (!this.isConnected || !this.client) return false;
    try {
      await this.client.del(key);
      return true;
    } catch (error) {
      return false;
    }
  }

  public async exists(key: string): Promise<boolean> {
    if (!this.isConnected || !this.client) return false;
    try {
      const result = await this.client.exists(key);
      return result === 1;
    } catch (error) {
      return false;
    }
  }

  public async flushDb(): Promise<boolean> {
    if (!this.isConnected || !this.client) return false;
    try {
      await this.client.flushDb();
      return true;
    } catch (error) {
      return false;
    }
  }

  public async disconnect(): Promise<void> {
    if (this.isConnected && this.client) {
      await this.client.quit();
      logger.info('Redis connection closed');
    }
  }
}

export const redis = new RedisClient();
export default redis;
