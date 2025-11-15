"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.redis = void 0;
const redis_1 = require("redis");
const logger_1 = require("./logger");
class RedisClient {
    constructor() {
        this.client = null;
        this.isConnected = false;
        this.redisEnabled = true;
        // Check if Redis should be enabled
        const redisEnabled = process.env.REDIS_ENABLED !== 'false';
        if (!redisEnabled) {
            logger_1.logger.info('ℹ️  Redis is disabled - running without caching');
            this.redisEnabled = false;
            return;
        }
        try {
            this.client = (0, redis_1.createClient)({
                url: `redis://${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || 6379}`,
                password: process.env.REDIS_PASSWORD || undefined,
                database: parseInt(process.env.REDIS_DB || '0'),
            });
            this.client.on('error', (err) => {
                if (this.isConnected) {
                    logger_1.logger.warn('⚠️  Redis connection error - continuing without cache');
                }
                this.isConnected = false;
            });
            this.client.on('connect', () => {
                logger_1.logger.info('✅ Redis connected successfully');
                this.isConnected = true;
            });
            this.client.on('disconnect', () => {
                logger_1.logger.warn('⚠️  Redis disconnected - continuing without cache');
                this.isConnected = false;
            });
            this.connect();
        }
        catch (error) {
            logger_1.logger.warn('⚠️  Redis initialization failed - continuing without cache');
            this.redisEnabled = false;
        }
    }
    async connect() {
        if (!this.client)
            return;
        try {
            await this.client.connect();
        }
        catch (error) {
            logger_1.logger.warn('⚠️  Failed to connect to Redis - app will run without caching');
            this.redisEnabled = false;
        }
    }
    getClient() {
        return this.client;
    }
    async get(key) {
        if (!this.isConnected || !this.client)
            return null;
        try {
            return await this.client.get(key);
        }
        catch (error) {
            return null;
        }
    }
    async set(key, value, ttl) {
        if (!this.isConnected || !this.client)
            return false;
        try {
            if (ttl) {
                await this.client.setEx(key, ttl, value);
            }
            else {
                await this.client.set(key, value);
            }
            return true;
        }
        catch (error) {
            return false;
        }
    }
    async del(key) {
        if (!this.isConnected || !this.client)
            return false;
        try {
            await this.client.del(key);
            return true;
        }
        catch (error) {
            return false;
        }
    }
    async exists(key) {
        if (!this.isConnected || !this.client)
            return false;
        try {
            const result = await this.client.exists(key);
            return result === 1;
        }
        catch (error) {
            return false;
        }
    }
    async flushDb() {
        if (!this.isConnected || !this.client)
            return false;
        try {
            await this.client.flushDb();
            return true;
        }
        catch (error) {
            return false;
        }
    }
    async disconnect() {
        if (this.isConnected && this.client) {
            await this.client.quit();
            logger_1.logger.info('Redis connection closed');
        }
    }
}
exports.redis = new RedisClient();
exports.default = exports.redis;
//# sourceMappingURL=redis.js.map