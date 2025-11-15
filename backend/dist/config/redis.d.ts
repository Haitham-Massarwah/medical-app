import { RedisClientType } from 'redis';
declare class RedisClient {
    private client;
    private isConnected;
    private redisEnabled;
    constructor();
    private connect;
    getClient(): RedisClientType | null;
    get(key: string): Promise<string | null>;
    set(key: string, value: string, ttl?: number): Promise<boolean>;
    del(key: string): Promise<boolean>;
    exists(key: string): Promise<boolean>;
    flushDb(): Promise<boolean>;
    disconnect(): Promise<void>;
}
export declare const redis: RedisClient;
export default redis;
//# sourceMappingURL=redis.d.ts.map