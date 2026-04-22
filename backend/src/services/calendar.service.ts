import axios from 'axios';
import db from '../config/database';

export interface CalendarTokens {
  id?: number;
  // NOTE: user IDs in this system are UUID strings (users.id)
  user_id: string;
  provider: 'google' | 'outlook';
  access_token: string;
  refresh_token?: string;
  expires_at?: Date;
  created_at?: Date;
  updated_at?: Date;
}

function formBody(params: Record<string, string | undefined>): string {
  const u = new URLSearchParams();
  for (const [k, v] of Object.entries(params)) {
    if (v !== undefined && v !== '') {
      u.set(k, v);
    }
  }
  return u.toString();
}

class CalendarService {
  /**
   * Exchange Google OAuth code for tokens
   */
  async exchangeGoogleCode(code: string, redirectUri: string): Promise<CalendarTokens> {
    try {
      const body = formBody({
        code,
        client_id: process.env.GOOGLE_CLIENT_ID,
        client_secret: process.env.GOOGLE_CLIENT_SECRET,
        redirect_uri: redirectUri,
        grant_type: 'authorization_code',
      });
      const response = await axios.post('https://oauth2.googleapis.com/token', body, {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      });

      const { access_token, refresh_token, expires_in } = response.data;

      return {
        access_token,
        refresh_token,
        expires_at: expires_in ? new Date(Date.now() + expires_in * 1000) : undefined,
      } as CalendarTokens;
    } catch (error: any) {
      const detail = error.response?.data
        ? ` ${JSON.stringify(error.response.data)}`
        : '';
      throw new Error(`Failed to exchange Google code: ${error.message}${detail}`);
    }
  }

  /**
   * Exchange Outlook OAuth code for tokens
   */
  async exchangeOutlookCode(code: string, redirectUri: string): Promise<CalendarTokens> {
    try {
      const body = formBody({
        code,
        client_id: process.env.OUTLOOK_CLIENT_ID,
        client_secret: process.env.OUTLOOK_CLIENT_SECRET,
        redirect_uri: redirectUri,
        grant_type: 'authorization_code',
        scope: 'https://graph.microsoft.com/Calendars.ReadWrite',
      });
      const response = await axios.post(
        'https://login.microsoftonline.com/common/oauth2/v2.0/token',
        body,
        { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
      );

      const { access_token, refresh_token, expires_in } = response.data;

      return {
        access_token,
        refresh_token,
        expires_at: expires_in ? new Date(Date.now() + expires_in * 1000) : undefined,
      } as CalendarTokens;
    } catch (error: any) {
      const detail = error.response?.data
        ? ` ${JSON.stringify(error.response.data)}`
        : '';
      throw new Error(`Failed to exchange Outlook code: ${error.message}${detail}`);
    }
  }

  /**
   * Save calendar tokens to database
   */
  async saveTokens(userId: string, provider: 'google' | 'outlook', tokens: CalendarTokens): Promise<void> {
    try {
      // Check if tokens already exist
      const existing = await db('calendar_tokens')
        .where({ user_id: userId, provider })
        .first();

      if (existing) {
        // Update existing tokens
        await db('calendar_tokens')
          .where({ user_id: userId, provider })
          .update({
            access_token: tokens.access_token,
            refresh_token: tokens.refresh_token,
            expires_at: tokens.expires_at,
            updated_at: new Date(),
          });
      } else {
        // Insert new tokens
        await db('calendar_tokens').insert({
          user_id: userId,
          provider,
          access_token: tokens.access_token,
          refresh_token: tokens.refresh_token,
          expires_at: tokens.expires_at,
          created_at: new Date(),
          updated_at: new Date(),
        });
      }
    } catch (error: any) {
      throw new Error(`Failed to save calendar tokens: ${error.message}`);
    }
  }

  /**
   * Get calendar tokens for a user
   */
  async getTokens(userId: string, provider: 'google' | 'outlook'): Promise<CalendarTokens | null> {
    try {
      const tokens = await db('calendar_tokens')
        .where({ user_id: userId, provider })
        .first();

      return tokens || null;
    } catch (error: any) {
      throw new Error(`Failed to get calendar tokens: ${error.message}`);
    }
  }

  /**
   * Refresh Google access token
   */
  async refreshGoogleToken(refreshToken: string): Promise<{ access_token: string; expires_at: Date }> {
    try {
      const body = formBody({
        refresh_token: refreshToken,
        client_id: process.env.GOOGLE_CLIENT_ID,
        client_secret: process.env.GOOGLE_CLIENT_SECRET,
        grant_type: 'refresh_token',
      });
      const response = await axios.post('https://oauth2.googleapis.com/token', body, {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      });

      const { access_token, expires_in } = response.data;

      return {
        access_token,
        expires_at: new Date(Date.now() + expires_in * 1000),
      };
    } catch (error: any) {
      const detail = error.response?.data
        ? ` ${JSON.stringify(error.response.data)}`
        : '';
      throw new Error(`Failed to refresh Google token: ${error.message}${detail}`);
    }
  }

  /**
   * Refresh Outlook access token
   */
  async refreshOutlookToken(refreshToken: string): Promise<{ access_token: string; expires_at: Date }> {
    try {
      const body = formBody({
        refresh_token: refreshToken,
        client_id: process.env.OUTLOOK_CLIENT_ID,
        client_secret: process.env.OUTLOOK_CLIENT_SECRET,
        grant_type: 'refresh_token',
        scope: 'https://graph.microsoft.com/Calendars.ReadWrite',
      });
      const response = await axios.post(
        'https://login.microsoftonline.com/common/oauth2/v2.0/token',
        body,
        { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
      );

      const { access_token, expires_in } = response.data;

      return {
        access_token,
        expires_at: new Date(Date.now() + expires_in * 1000),
      };
    } catch (error: any) {
      const detail = error.response?.data
        ? ` ${JSON.stringify(error.response.data)}`
        : '';
      throw new Error(`Failed to refresh Outlook token: ${error.message}${detail}`);
    }
  }

  /**
   * Get valid access token (refresh if needed)
   */
  async getValidAccessToken(userId: string, provider: 'google' | 'outlook'): Promise<string | null> {
    try {
      const tokens = await this.getTokens(userId, provider);
      if (!tokens) return null;

      // Check if token is expired
      if (tokens.expires_at && new Date() >= new Date(tokens.expires_at)) {
        if (!tokens.refresh_token) return null;

        // Refresh token
        const refreshed = provider === 'google'
          ? await this.refreshGoogleToken(tokens.refresh_token)
          : await this.refreshOutlookToken(tokens.refresh_token);

        // Update in database
        await db('calendar_tokens')
          .where({ user_id: userId, provider })
          .update({
            access_token: refreshed.access_token,
            expires_at: refreshed.expires_at,
            updated_at: new Date(),
          });

        return refreshed.access_token;
      }

      return tokens.access_token;
    } catch (error: any) {
      throw new Error(`Failed to get valid access token: ${error.message}`);
    }
  }

  /**
   * Delete calendar tokens
   */
  async disconnectCalendar(userId: string, provider: 'google' | 'outlook'): Promise<void> {
    try {
      await db('calendar_tokens')
        .where({ user_id: userId, provider })
        .delete();
    } catch (error: any) {
      throw new Error(`Failed to disconnect calendar: ${error.message}`);
    }
  }

  /**
   * Get calendar connection status
   */
  async getConnectionStatus(userId: string): Promise<{ google: boolean; outlook: boolean }> {
    try {
      const tokens = await db('calendar_tokens')
        .where({ user_id: userId })
        .select('provider');

      return {
        google: tokens.some(t => t.provider === 'google'),
        outlook: tokens.some(t => t.provider === 'outlook'),
      };
    } catch (error: any) {
      throw new Error(`Failed to get connection status: ${error.message}`);
    }
  }
}

export default new CalendarService();





