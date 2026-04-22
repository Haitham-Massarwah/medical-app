import { logger } from '../config/logger';

export type PublishedUpdateManifest = {
  version: string;
  minSupportedVersion?: string;
  releaseNotesUrl?: string;
  artifactUrl?: string;
  artifactSha256?: string;
  channel?: string;
  publishedAt?: string;
};

function parseSemverParts(v: string): number[] {
  const core = v.trim().split(/[-+]/)[0] || '0';
  return core.split('.').map((p) => parseInt(p, 10) || 0);
}

/** Returns negative if a < b, 0 if equal, positive if a > b */
export function compareSemver(a: string, b: string): number {
  const pa = parseSemverParts(a);
  const pb = parseSemverParts(b);
  const len = Math.max(pa.length, pb.length, 3);
  for (let i = 0; i < len; i++) {
    const da = pa[i] ?? 0;
    const db = pb[i] ?? 0;
    if (da !== db) return da - db;
  }
  return 0;
}

function isPlainObject(x: unknown): x is Record<string, unknown> {
  return typeof x === 'object' && x !== null && !Array.isArray(x);
}

export function parseUpdateManifest(body: unknown): PublishedUpdateManifest | null {
  if (!isPlainObject(body)) return null;
  const version = body.version;
  if (typeof version !== 'string' || !version.trim()) return null;
  const out: PublishedUpdateManifest = { version: version.trim() };
  if (typeof body.minSupportedVersion === 'string') out.minSupportedVersion = body.minSupportedVersion.trim();
  if (typeof body.releaseNotesUrl === 'string') out.releaseNotesUrl = body.releaseNotesUrl.trim();
  if (typeof body.artifactUrl === 'string') out.artifactUrl = body.artifactUrl.trim();
  if (typeof body.artifactSha256 === 'string') out.artifactSha256 = body.artifactSha256.trim();
  if (typeof body.channel === 'string') out.channel = body.channel.trim();
  if (typeof body.publishedAt === 'string') out.publishedAt = body.publishedAt.trim();
  return out;
}

export async function fetchUpdateManifest(
  url: string,
  timeoutMs: number,
): Promise<{ ok: true; manifest: PublishedUpdateManifest } | { ok: false; error: string }> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, {
      method: 'GET',
      signal: controller.signal,
      headers: { Accept: 'application/json' },
    });
    if (!res.ok) {
      return { ok: false, error: `Manifest HTTP ${res.status}` };
    }
    const json: unknown = await res.json();
    const manifest = parseUpdateManifest(json);
    if (!manifest) {
      return { ok: false, error: 'Invalid manifest JSON (version required)' };
    }
    return { ok: true, manifest };
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Fetch failed';
    logger.warn(`Update manifest fetch failed: ${msg}`);
    return { ok: false, error: msg };
  } finally {
    clearTimeout(timer);
  }
}

export function evaluateUpdate(
  currentVersion: string,
  manifest: PublishedUpdateManifest,
): {
  updateAvailable: boolean;
  currentBehind: boolean;
  belowMinSupported: boolean;
} {
  const cmp = compareSemver(manifest.version, currentVersion);
  const currentBehind = cmp > 0;

  let belowMinSupported = false;
  if (manifest.minSupportedVersion) {
    belowMinSupported = compareSemver(currentVersion, manifest.minSupportedVersion) < 0;
  }

  const updateAvailable = currentBehind && !belowMinSupported;
  return { updateAvailable, currentBehind, belowMinSupported };
}
