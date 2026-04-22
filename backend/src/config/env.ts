import { logger } from './logger';

type EnvSpec = {
  key: string;
  requiredInProduction?: boolean;
};

const envSpecs: EnvSpec[] = [
  { key: 'NODE_ENV' },
  { key: 'PORT' },
  { key: 'API_VERSION' },
  { key: 'JWT_SECRET', requiredInProduction: true },
  { key: 'JWT_REFRESH_SECRET', requiredInProduction: true },
  { key: 'DB_URL', requiredInProduction: false },
  { key: 'DB_HOST', requiredInProduction: false },
  { key: 'DB_PORT', requiredInProduction: false },
  { key: 'DB_NAME', requiredInProduction: false },
  { key: 'DB_USER', requiredInProduction: false },
  { key: 'DB_PASSWORD', requiredInProduction: false },
];

const hasValue = (value: string | undefined): boolean =>
  typeof value === 'string' && value.trim().length > 0;

const getMissingRequired = (): string[] => {
  const isProduction = (process.env.NODE_ENV || 'development') === 'production';
  const missing: string[] = [];

  for (const spec of envSpecs) {
    const isRequired = isProduction ? spec.requiredInProduction === true : false;
    if (isRequired && !hasValue(process.env[spec.key])) {
      missing.push(spec.key);
    }
  }

  // DB connection requirement in production:
  // either DB_URL or full split credentials.
  if (isProduction) {
    const hasDbUrl = hasValue(process.env.DB_URL);
    const hasSplitDb =
      hasValue(process.env.DB_HOST) &&
      hasValue(process.env.DB_PORT) &&
      hasValue(process.env.DB_NAME) &&
      hasValue(process.env.DB_USER) &&
      hasValue(process.env.DB_PASSWORD);

    if (!hasDbUrl && !hasSplitDb) {
      missing.push('DB_URL (or DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASSWORD)');
    }
  }

  return missing;
};

export const validateEnvironment = (): void => {
  const missing = getMissingRequired();
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }

  if ((process.env.NODE_ENV || 'development') !== 'production') {
    logger.info('Environment validation completed (development mode)');
  }
};

