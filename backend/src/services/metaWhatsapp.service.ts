import { logger } from '../config/logger';

/**
 * Meta WhatsApp Cloud API client.
 *
 * Reference:
 *   https://developers.facebook.com/docs/whatsapp/cloud-api/reference/messages
 *
 * Required environment variables:
 *   META_WA_API_VERSION       e.g. v25.0
 *   META_WA_PHONE_NUMBER_ID   numeric phone number ID from API Setup
 *   META_WA_TOKEN             access token (system user or temporary)
 *
 * Notes:
 *   - Free-form text messages may only be sent within 24 hours of the
 *     recipient's last inbound message (Meta "customer service window").
 *   - Outside that window, only approved templates may be sent.
 *   - Recipient numbers must be in E.164 format WITHOUT the leading "+".
 */

const DEFAULT_API_VERSION = 'v25.0';

interface MetaConfig {
  apiVersion: string;
  phoneNumberId: string;
  token: string;
}

const getConfig = (): MetaConfig | null => {
  const apiVersion = process.env.META_WA_API_VERSION || DEFAULT_API_VERSION;
  const phoneNumberId = process.env.META_WA_PHONE_NUMBER_ID;
  const token = process.env.META_WA_TOKEN;

  if (!phoneNumberId || !token) {
    return null;
  }
  return { apiVersion, phoneNumberId, token };
};

/** Returns true when META_WA_PHONE_NUMBER_ID and META_WA_TOKEN are set. */
export const isMetaWhatsAppConfigured = (): boolean => getConfig() !== null;

/** Convert "+972526027636" or "0526027636" to "972526027636" (Meta E.164 without "+"). */
const normalizeRecipient = (raw: string): string => {
  let value = raw.trim();
  if (value.startsWith('whatsapp:')) value = value.slice('whatsapp:'.length);
  if (value.startsWith('+')) value = value.slice(1);
  value = value.replace(/[\s\-()]/g, '');
  if (/^0\d+$/.test(value)) {
    // Local Israeli format → assume +972
    value = `972${value.slice(1)}`;
  }
  return value;
};

interface MetaApiError {
  message: string;
  type?: string;
  code?: number | string;
  error_subcode?: number | string;
  fbtrace_id?: string;
}

interface MetaApiResponse {
  messaging_product?: string;
  contacts?: Array<{ input: string; wa_id: string }>;
  messages?: Array<{ id: string }>;
  error?: MetaApiError;
}

const callMeta = async (body: unknown): Promise<{ ok: boolean; data: MetaApiResponse }> => {
  const cfg = getConfig();
  if (!cfg) {
    logger.warn('Meta WhatsApp not configured; skipping send');
    return { ok: false, data: { error: { message: 'Meta WhatsApp not configured' } } };
  }

  const url = `https://graph.facebook.com/${cfg.apiVersion}/${cfg.phoneNumberId}/messages`;

  let response: Response;
  try {
    response = await fetch(url, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${cfg.token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });
  } catch (err: any) {
    logger.error('Meta WhatsApp network error', { message: err?.message });
    return { ok: false, data: { error: { message: err?.message ?? 'network error' } } };
  }

  let data: MetaApiResponse = {};
  try {
    data = (await response.json()) as MetaApiResponse;
  } catch {
    /* response had no JSON body */
  }

  if (!response.ok || data.error) {
    logger.error('Meta WhatsApp API error', {
      status: response.status,
      error: data.error,
    });
    return { ok: false, data };
  }

  const messageId = data.messages?.[0]?.id;
  logger.info('Meta WhatsApp message accepted', { messageId });
  return { ok: true, data };
};

/**
 * Send a free-form text message.
 * Only succeeds inside the 24-hour customer service window.
 */
export const sendMetaWhatsAppText = async (to: string, body: string): Promise<boolean> => {
  const recipient = normalizeRecipient(to);
  const result = await callMeta({
    messaging_product: 'whatsapp',
    to: recipient,
    type: 'text',
    text: { preview_url: false, body },
  });
  return result.ok;
};

export interface MetaTemplateComponent {
  type: 'header' | 'body' | 'button';
  sub_type?: 'quick_reply' | 'url';
  index?: number;
  parameters: Array<
    | { type: 'text'; text: string }
    | { type: 'currency'; currency: { fallback_value: string; code: string; amount_1000: number } }
    | { type: 'date_time'; date_time: { fallback_value: string } }
  >;
}

/** Helper: build a body component from positional text params ({{1}}..{{n}}). */
export const buildBodyTextComponent = (params: string[]): MetaTemplateComponent => ({
  type: 'body',
  parameters: params.map((text) => ({ type: 'text', text })),
});

/**
 * Send an approved template message.
 * `templateName` and `languageCode` must match a template approved in WhatsApp Manager.
 */
export const sendMetaWhatsAppTemplate = async (
  to: string,
  templateName: string,
  languageCode: string = 'en_US',
  components?: MetaTemplateComponent[],
): Promise<boolean> => {
  const recipient = normalizeRecipient(to);
  const template: Record<string, unknown> = {
    name: templateName,
    language: { code: languageCode },
  };
  if (components && components.length > 0) {
    template.components = components;
  }
  const result = await callMeta({
    messaging_product: 'whatsapp',
    to: recipient,
    type: 'template',
    template,
  });
  return result.ok;
};
