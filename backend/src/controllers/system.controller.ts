import { Request, Response, NextFunction } from 'express';
import fs from 'fs';
import path from 'path';
import db from '../config/database';
import { asyncHandler } from '../middleware/errorHandler';
import { getAppPackageVersion, getLogFilePaths } from '../config/logger';
import {
  evaluateUpdate,
  fetchUpdateManifest,
} from '../services/update-manifest.service';

type MigrationRow = { name: string; batch: number };

export class SystemController {
  /**
   * Local-install diagnostics: version, DB migration state, log file locations.
   * GET /api/v1/admin/system/diagnostics
   */
  getDiagnostics = asyncHandler(async (_req: Request, res: Response, _next: NextFunction) => {
    let databaseOk = false;
    let migrationRows: MigrationRow[] = [];
    let migrationError: string | undefined;

    try {
      await db.raw('SELECT 1');
      databaseOk = true;
    } catch (e: unknown) {
      migrationError = e instanceof Error ? e.message : 'Database connection failed';
    }

    if (databaseOk) {
      try {
        migrationRows = await db('knex_migrations')
          .select('name', 'batch')
          .orderBy('id', 'desc')
          .limit(30);
      } catch (e: unknown) {
        migrationError = e instanceof Error ? e.message : 'Could not read knex_migrations';
      }
    }

    const logPaths = getLogFilePaths();
    const logFiles: { path: string; bytes: number | null; exists: boolean }[] = [];

    for (const p of [logPaths.appLog, logPaths.errorLog]) {
      try {
        const st = fs.statSync(p);
        logFiles.push({ path: p, bytes: st.size, exists: true });
      } catch {
        logFiles.push({ path: p, bytes: null, exists: false });
      }
    }

    res.status(200).json({
      success: true,
      data: {
        deployment: 'local-per-install',
        appVersion: getAppPackageVersion(),
        nodeVersion: process.version,
        environment: process.env.NODE_ENV || 'development',
        database: {
          ok: databaseOk,
          host: process.env.DB_HOST || 'localhost',
          name: process.env.DB_NAME || '(default)',
        },
        migrations: {
          latest: migrationRows[0] || null,
          recent: migrationRows,
          error: migrationError,
        },
        logs: {
          directory: logPaths.logsDir,
          files: logFiles,
          level: process.env.LOG_LEVEL || 'info',
        },
        upgrade: {
          steps: [
            'git pull (or copy new release files)',
            'npm ci',
            'npm run build',
            'npm run migrate',
            'restart backend (npm start or PM2)',
          ],
          npmScript: 'npm run upgrade:local',
          manifestConfigured: Boolean(
            (process.env.UPDATE_MANIFEST_URL || '').trim(),
          ),
        },
      },
      timestamp: new Date().toISOString(),
    });
  });

  /**
   * Compare local package version to central manifest (you host JSON at UPDATE_MANIFEST_URL).
   * GET /api/v1/admin/system/update-check
   */
  getUpdateCheck = asyncHandler(async (_req: Request, res: Response, _next: NextFunction) => {
    const manifestUrl = (process.env.UPDATE_MANIFEST_URL || '').trim();
    const timeoutMs = parseInt(process.env.UPDATE_MANIFEST_TIMEOUT_MS || '10000', 10) || 10000;
    const currentVersion = getAppPackageVersion();

    if (!manifestUrl) {
      res.status(200).json({
        success: true,
        data: {
          configured: false,
          currentVersion,
          message:
            'Set UPDATE_MANIFEST_URL to an HTTPS JSON manifest to enable central update notifications.',
        },
        timestamp: new Date().toISOString(),
      });
      return;
    }

    const fetched = await fetchUpdateManifest(manifestUrl, timeoutMs);
    if (!fetched.ok) {
      res.status(200).json({
        success: true,
        data: {
          configured: true,
          currentVersion,
          manifestError: fetched.error,
          updateAvailable: false,
        },
        timestamp: new Date().toISOString(),
      });
      return;
    }

    const { manifest } = fetched;
    const evalResult = evaluateUpdate(currentVersion, manifest);

    res.status(200).json({
      success: true,
      data: {
        configured: true,
        currentVersion,
        publishedVersion: manifest.version,
        channel: manifest.channel || 'stable',
        updateAvailable: evalResult.updateAvailable,
        currentBehindPublished: evalResult.currentBehind,
        belowMinSupported: evalResult.belowMinSupported,
        minSupportedVersion: manifest.minSupportedVersion || null,
        releaseNotesUrl: manifest.releaseNotesUrl || null,
        artifactUrl: manifest.artifactUrl || null,
        artifactSha256: manifest.artifactSha256 || null,
        publishedAt: manifest.publishedAt || null,
        applyHint:
          'On this machine, stop the API then run: .\\scripts\\clinic-pull-upgrade.ps1 (Windows) or ./scripts/clinic-pull-upgrade.sh (Linux/macOS), or npm run upgrade:local after updating source.',
      },
      timestamp: new Date().toISOString(),
    });
  });

  /**
   * Optional: last N lines of main app log (local support). Gated by env.
   * GET /api/v1/admin/system/logs/tail?lines=200
   */
  getLogTail = asyncHandler(async (req: Request, res: Response, _next: NextFunction) => {
    if (String(process.env.ADMIN_ALLOW_LOG_TAIL || '').toLowerCase() !== 'true') {
      res.status(403).json({
        success: false,
        message:
          'Log tail is disabled. Set ADMIN_ALLOW_LOG_TAIL=true on this machine to enable (local support only).',
      });
      return;
    }

    const lines = Math.min(
      500,
      Math.max(1, parseInt(String(req.query.lines || '150'), 10) || 150),
    );
    const { appLog } = getLogFilePaths();

    if (!fs.existsSync(appLog)) {
      res.status(404).json({ success: false, message: 'Log file not found', path: appLog });
      return;
    }

    const content = fs.readFileSync(appLog, 'utf8');
    const allLines = content.split(/\r?\n/);
    const tail = allLines.slice(-lines).join('\n');

    res.status(200).json({
      success: true,
      data: {
        path: appLog,
        lines,
        content: tail,
      },
      timestamp: new Date().toISOString(),
    });
  });
}

export const systemController = new SystemController();
