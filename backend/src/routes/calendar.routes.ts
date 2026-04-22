import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import calendarService from '../services/calendar.service';

const router = Router();

// Callback routes must be PUBLIC (no authentication)
// They come BEFORE the authenticate middleware

/**
 * @route   GET /api/v1/calendar/google/callback
 * @desc    Handle Google Calendar OAuth callback
 * @access  Public
 */
router.get('/google/callback', async (req, res) => {
  try {
    const { code, state } = req.query;
    
    if (!code || !state) {
      return res.status(400).send(`
        <html>
          <head><title>Error</title></head>
          <body style="font-family: Arial; text-align: center; padding: 50px;">
            <h1 style="color: red;">✗ Authorization Failed</h1>
            <p>Missing authorization code or state.</p>
          </body>
        </html>
      `);
    }

    const userId = (state as string) || '';
    if (!userId) {
      return res.status(400).send(`
        <html>
          <head><title>Error</title></head>
          <body style="font-family: Arial; text-align: center; padding: 50px;">
            <h1 style="color: red;">✗ Authorization Failed</h1>
            <p>Invalid user ID in state parameter.</p>
          </body>
        </html>
      `);
    }
    
    const redirectUri = process.env.GOOGLE_REDIRECT_URI || 'https://api.medical-appointments.com/api/v1/calendar/google/callback';

    // Exchange code for tokens
    const tokens = await calendarService.exchangeGoogleCode(code as string, redirectUri);
    
    // Save tokens to database
    await calendarService.saveTokens(userId, 'google', tokens);

    res.send(`
      <html>
        <head><title>Google Calendar Connected</title></head>
        <body style="font-family: Arial; text-align: center; padding: 50px;">
          <h1 style="color: green;">✓ Google Calendar Connected!</h1>
          <p>Your Google Calendar has been successfully connected.</p>
          <p>You can close this window now.</p>
          <script>
            setTimeout(() => window.close(), 3000);
          </script>
        </body>
      </html>
    `);
  } catch (error: any) {
    console.error('Google Calendar callback error:', error);
    res.status(500).send(`
      <html>
        <head><title>Error</title></head>
        <body style="font-family: Arial; text-align: center; padding: 50px;">
          <h1 style="color: red;">✗ Connection Failed</h1>
          <p>Failed to connect Google Calendar: ${error.message}</p>
        </body>
      </html>
    `);
  }
});

/**
 * @route   GET /api/v1/calendar/outlook/callback
 * @desc    Handle Outlook Calendar OAuth callback
 * @access  Public
 */
router.get('/outlook/callback', async (req, res) => {
  try {
    const { code, state } = req.query;
    
    if (!code || !state) {
      return res.status(400).send(`
        <html>
          <head><title>Error</title></head>
          <body style="font-family: Arial; text-align: center; padding: 50px;">
            <h1 style="color: red;">✗ Authorization Failed</h1>
            <p>Missing authorization code or state.</p>
          </body>
        </html>
      `);
    }

    const userId = (state as string) || '';
    if (!userId) {
      return res.status(400).send(`
        <html>
          <head><title>Error</title></head>
          <body style="font-family: Arial; text-align: center; padding: 50px;">
            <h1 style="color: red;">✗ Authorization Failed</h1>
            <p>Invalid user ID in state parameter.</p>
          </body>
        </html>
      `);
    }
    
    const redirectUri = process.env.OUTLOOK_REDIRECT_URI || 'https://api.medical-appointments.com/api/v1/calendar/outlook/callback';

    // Exchange code for tokens
    const tokens = await calendarService.exchangeOutlookCode(code as string, redirectUri);
    
    // Save tokens to database
    await calendarService.saveTokens(userId, 'outlook', tokens);

    res.send(`
      <html>
        <head><title>Outlook Calendar Connected</title></head>
        <body style="font-family: Arial; text-align: center; padding: 50px;">
          <h1 style="color: green;">✓ Outlook Calendar Connected!</h1>
          <p>Your Outlook Calendar has been successfully connected.</p>
          <p>You can close this window now.</p>
          <script>
            setTimeout(() => window.close(), 3000);
          </script>
        </body>
      </html>
    `);
  } catch (error: any) {
    console.error('Outlook Calendar callback error:', error);
    res.status(500).send(`
      <html>
        <head><title>Error</title></head>
        <body style="font-family: Arial; text-align: center; padding: 50px;">
          <h1 style="color: red;">✗ Connection Failed</h1>
          <p>Failed to connect Outlook Calendar: ${error.message}</p>
        </body>
      </html>
    `);
  }
});

// All other routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/calendar/google/auth-url
 * @desc    Get Google Calendar OAuth URL
 * @access  Private
 */
router.get('/google/auth-url', (req, res) => {
  try {
    if (!process.env.GOOGLE_CLIENT_ID) {
      return res.status(400).json({
        success: false,
        error: 'Google client ID is not configured',
      });
    }
    const googleRedirect =
      process.env.GOOGLE_REDIRECT_URI || 'http://localhost:3000/api/v1/calendar/google/callback';
    // Always prefer the authenticated user email; do not force a system mailbox.
    const loggedInEmail =
      typeof req.user?.email === 'string' && req.user.email.trim().length > 0
        ? req.user.email.trim()
        : '';
    const googleHint = loggedInEmail
      ? `&login_hint=${encodeURIComponent(loggedInEmail)}`
      : '';
    const authUrl = `https://accounts.google.com/o/oauth2/v2/auth?` +
      `client_id=${process.env.GOOGLE_CLIENT_ID || 'YOUR_GOOGLE_CLIENT_ID'}` +
      `&redirect_uri=${encodeURIComponent(googleRedirect)}` +
      `&response_type=code` +
      `&scope=https://www.googleapis.com/auth/calendar` +
      `&access_type=offline` +
      `&state=${req.user?.userId || req.user?.id || ''}` +
      `&prompt=select_account` +
      googleHint;

    res.json({
      success: true,
      data: {
        authUrl,
        message: 'Redirect user to this URL for Google Calendar authorization',
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to generate Google auth URL'
    });
  }
});

/**
 * @route   GET /api/v1/calendar/outlook/auth-url
 * @desc    Get Outlook Calendar OAuth URL
 * @access  Private
 */
router.get('/outlook/auth-url', (req, res) => {
  try {
    // TODO: Implement actual Microsoft OAuth flow
    // For now, return a placeholder
    const outlookRedirect =
      process.env.OUTLOOK_REDIRECT_URI ||
      'http://localhost:3000/api/v1/calendar/outlook/callback';
    const outlookHint = process.env.OUTLOOK_LOGIN_HINT
      ? `&login_hint=${encodeURIComponent(process.env.OUTLOOK_LOGIN_HINT)}`
      : '';
    const authUrl = `https://login.microsoftonline.com/common/oauth2/v2.0/authorize?` +
      `client_id=${process.env.OUTLOOK_CLIENT_ID || 'YOUR_OUTLOOK_CLIENT_ID'}` +
      `&response_type=code` +
      `&redirect_uri=${encodeURIComponent(outlookRedirect)}` +
      `&scope=${encodeURIComponent('https://graph.microsoft.com/Calendars.ReadWrite')}` +
      `&state=${req.user?.id}` +
      outlookHint;

    res.json({
      success: true,
      data: {
        authUrl,
        message: 'Redirect user to this URL for Outlook Calendar authorization'
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to generate Outlook auth URL'
    });
  }
});

/**
 * @route   POST /api/v1/calendar/disconnect
 * @desc    Disconnect calendar integration
 * @access  Private
 */
router.post('/disconnect', async (req, res) => {
  try {
    const { provider } = req.body;
    const userId = req.user?.userId || req.user?.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized'
      });
    }

    if (!provider || !['google', 'outlook'].includes(provider)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid provider. Must be "google" or "outlook"'
      });
    }

    await calendarService.disconnectCalendar(userId, provider);

    res.json({
      success: true,
      message: `${provider} calendar disconnected successfully`
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: `Failed to disconnect calendar: ${error.message}`
    });
  }
});

/**
 * @route   GET /api/v1/calendar/status
 * @desc    Get calendar connection status
 * @access  Private
 */
router.get('/status', async (req, res) => {
  try {
    const userId = req.user?.userId || req.user?.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized'
      });
    }

    const status = await calendarService.getConnectionStatus(userId);

    res.json({
      success: true,
      data: status
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: `Failed to get calendar status: ${error.message}`
    });
  }
});

export default router;









