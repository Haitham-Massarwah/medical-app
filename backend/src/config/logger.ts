import winston from 'winston';
import path from 'path';
import fs from 'fs';

const logLevel = process.env.LOG_LEVEL || 'info';
const logFile = process.env.LOG_FILE || 'logs/app.log';

const logsDir = path.join(process.cwd(), 'logs');
const errorLogPath = path.join(logsDir, 'error.log');
const appLogPath = path.isAbsolute(logFile) ? logFile : path.join(process.cwd(), logFile);

export function getLogFilePaths(): { logsDir: string; appLog: string; errorLog: string } {
  return {
    logsDir,
    appLog: appLogPath,
    errorLog: errorLogPath,
  };
}

let cachedPackageVersion: string | null = null;

export function getAppPackageVersion(): string {
  if (cachedPackageVersion) return cachedPackageVersion;
  try {
    const pkgPath = path.join(process.cwd(), 'package.json');
    const raw = fs.readFileSync(pkgPath, 'utf8');
    const pkg = JSON.parse(raw) as { version?: string };
    cachedPackageVersion = pkg.version || 'unknown';
  } catch {
    cachedPackageVersion = 'unknown';
  }
  return cachedPackageVersion;
}

// Define log format
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// Define console format
const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.printf(({ timestamp, level, message, ...meta }) => {
    let msg = `${timestamp} [${level}]: ${message}`;
    if (Object.keys(meta).length > 0) {
      msg += ` ${JSON.stringify(meta)}`;
    }
    return msg;
  })
);

// Create logger
export const logger = winston.createLogger({
  level: logLevel,
  format: logFormat,
  defaultMeta: { service: 'medical-appointment-api' },
  transports: [
    new winston.transports.Console({
      format: consoleFormat,
    }),
    new winston.transports.File({
      filename: errorLogPath,
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
    new winston.transports.File({
      filename: appLogPath,
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
  ],
});

export default logger;
