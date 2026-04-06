import nodemailer from 'nodemailer';
import { logger } from '../config/logger';
import { renderInvitationTemplate } from './email.templates';
import { canSendEmail, isEmailEnabled } from '../config/email.gate';

interface EmailOptions {
  to: string;
  subject: string;
  template: string;
  data: any;
}

/**
 * Email service for sending transactional emails
 * Uses Nodemailer with configurable transport
 */

// Create reusable transporter
let transporter: nodemailer.Transporter;

const initializeTransporter = () => {
  if (transporter) return transporter;

  const emailConfig = {
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASSWORD,
    },
  };

  transporter = nodemailer.createTransport(emailConfig);

  return transporter;
};

/**
 * Send email using template
 */
export const sendEmail = async (options: EmailOptions): Promise<void> => {
  // Check email gate - block emails until test accounts are created
  if (!isEmailEnabled()) {
    logger.warn(`Email sending is disabled until test accounts are created. Attempted to send to: ${options.to}`);
    return; // Silently fail - don't throw error during testing phase
  }
  
  // Check if recipient is allowed
  if (!canSendEmail(options.to)) {
    logger.warn(`Email sending blocked to ${options.to}. Address not in allowed list.`);
    return; // Silently fail - don't send to unauthorized addresses
  }
  
  try {
    const transport = initializeTransporter();

    // Generate email HTML based on template
    const html = generateEmailHTML(options.template, options.data);

    const mailOptions = {
      from: `${process.env.EMAIL_FROM_NAME || 'Medical Appointment System'} <${process.env.EMAIL_FROM || process.env.SMTP_USER}>`,
      to: options.to,
      subject: options.subject,
      html,
    };

    await transport.sendMail(mailOptions);

    logger.info(`Email sent successfully to ${options.to}: ${options.subject}`);
  } catch (error) {
    logger.error(`Failed to send email to ${options.to}:`, error);
    throw new Error('Failed to send email');
  }
};

/**
 * Generate email HTML from template
 * In production, you'd use a proper template engine like Handlebars or Pug
 */
const generateEmailHTML = (template: string, data: any): string => {
  const baseStyle = `
    <style>
      body {
        font-family: Arial, sans-serif;
        line-height: 1.6;
        color: #333;
        max-width: 600px;
        margin: 0 auto;
        padding: 20px;
      }
      .header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 30px;
        text-align: center;
        border-radius: 8px 8px 0 0;
      }
      .content {
        background: #f9f9f9;
        padding: 30px;
        border-radius: 0 0 8px 8px;
      }
      .button {
        display: inline-block;
        padding: 12px 30px;
        background: #667eea;
        color: white;
        text-decoration: none;
        border-radius: 5px;
        margin: 20px 0;
      }
      .footer {
        text-align: center;
        padding: 20px;
        color: #666;
        font-size: 12px;
      }
    </style>
  `;

  switch (template) {
    case 'invitation': {
      const tpl = renderInvitationTemplate({ name: data.name, registrationUrl: data.registrationUrl });
      return `
        <!DOCTYPE html>
        <html>
        <head>${baseStyle}</head>
        <body>
          <div class="header">
            <h1>🏥 Medical Appointments</h1>
          </div>
          <div class="content">
            ${tpl.html}
          </div>
        </body>
        </html>
      `;
    }
    case 'email-verification':
      return `
        <!DOCTYPE html>
        <html>
        <head>${baseStyle}</head>
        <body>
          <div class="header">
            <h1>🏥 Medical Appointment System</h1>
          </div>
          <div class="content">
            <h2>Welcome, ${data.name}!</h2>
            <p>Thank you for registering. Please verify your email address to activate your account.</p>
            <a href="${data.verificationUrl}" class="button">Verify Email</a>
            <p>Or copy this link: ${data.verificationUrl}</p>
            <p><small>This link expires in 24 hours.</small></p>
          </div>
          <div class="footer">
            <p>If you didn't create this account, please ignore this email.</p>
          </div>
        </body>
        </html>
      `;

    case 'password-reset':
      return `
        <!DOCTYPE html>
        <html>
        <head>${baseStyle}</head>
        <body>
          <div class="header">
            <h1>🏥 Medical Appointment System</h1>
          </div>
          <div class="content">
            <h2>Password Reset Request</h2>
            <p>Hi ${data.name},</p>
            <p>We received a request to reset your password. Click the button below to create a new password:</p>
            <a href="${data.resetUrl}" class="button">Reset Password</a>
            <p>Or copy this link: ${data.resetUrl}</p>
            <p><small>This link expires in 1 hour.</small></p>
          </div>
          <div class="footer">
            <p>If you didn't request this, please ignore this email.</p>
          </div>
        </body>
        </html>
      `;

    case 'appointment-confirmation':
      return `
        <!DOCTYPE html>
        <html>
        <head>${baseStyle}</head>
        <body>
          <div class="header">
            <h1>🏥 Appointment Confirmed</h1>
          </div>
          <div class="content">
            <h2>Hi ${data.patientName},</h2>
            <p>Your appointment has been confirmed!</p>
            <div style="background: white; padding: 20px; border-radius: 5px; margin: 20px 0;">
              <p><strong>Doctor:</strong> ${data.doctorName}</p>
              <p><strong>Date:</strong> ${data.date}</p>
              <p><strong>Time:</strong> ${data.time}</p>
              <p><strong>Location:</strong> ${data.location}</p>
            </div>
            <p>Please arrive 10 minutes early.</p>
          </div>
          <div class="footer">
            <p>Need to reschedule? Contact us or use the app.</p>
          </div>
        </body>
        </html>
      `;

    case 'appointment-reminder':
      return `
        <!DOCTYPE html>
        <html>
        <head>${baseStyle}</head>
        <body>
          <div class="header">
            <h1>🔔 Appointment Reminder</h1>
          </div>
          <div class="content">
            <h2>Hi ${data.patientName},</h2>
            <p>This is a reminder about your upcoming appointment:</p>
            <div style="background: white; padding: 20px; border-radius: 5px; margin: 20px 0;">
              <p><strong>Doctor:</strong> ${data.doctorName}</p>
              <p><strong>Date:</strong> ${data.date}</p>
              <p><strong>Time:</strong> ${data.time}</p>
              <p><strong>Location:</strong> ${data.location}</p>
            </div>
            <p>See you soon!</p>
          </div>
          <div class="footer">
            <p>Need to cancel or reschedule? Contact us ASAP.</p>
          </div>
        </body>
        </html>
      `;

    case 'admin-approval-required':
      return `
        <!DOCTYPE html>
        <html>
        <head>${baseStyle}</head>
        <body>
          <div class="header">
            <h1>🔔 New Registration Requires Approval</h1>
          </div>
          <div class="content">
            <h2>Hi ${data.adminName},</h2>
            <p>A new ${data.userRole} has verified their email and is waiting for your approval:</p>
            <div style="background: white; padding: 20px; border-radius: 5px; margin: 20px 0;">
              <p><strong>Name:</strong> ${data.userName}</p>
              <p><strong>Email:</strong> ${data.userEmail}</p>
              <p><strong>Role:</strong> ${data.userRole}</p>
              <p><strong>User ID:</strong> ${data.userId}</p>
            </div>
            <p>Please log in to the admin dashboard to review and approve this registration.</p>
            <a href="${process.env.FRONTEND_URL || 'http://localhost:8081'}/admin" class="button">Review Registration</a>
          </div>
          <div class="footer">
            <p>This is an automated notification from the Medical Appointment System.</p>
          </div>
        </body>
        </html>
      `;

    case 'account-approved':
      return `
        <!DOCTYPE html>
        <html>
        <head>${baseStyle}</head>
        <body>
          <div class="header">
            <h1>🏥 Medical Appointment System</h1>
          </div>
          <div class="content">
            <h2>Hi ${data.name || 'User'},</h2>
            <p>Your account has been approved by an administrator.</p>
            <p>You can now log in and start using the system.</p>
            <a href="${process.env.FRONTEND_URL || 'http://localhost:8081'}" class="button">Open App</a>
          </div>
          <div class="footer">
            <p>This is an automated message from the Medical Appointment System.</p>
          </div>
        </body>
        </html>
      `;

    default:
      return `
        <!DOCTYPE html>
        <html>
        <head>${baseStyle}</head>
        <body>
          <div class="header">
            <h1>🏥 Medical Appointment System</h1>
          </div>
          <div class="content">
            <p>${JSON.stringify(data)}</p>
          </div>
        </body>
        </html>
      `;
  }
};

/**
 * Send appointment confirmation email
 */
export const sendAppointmentConfirmation = async (
  to: string,
  data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    location: string;
  }
) => {
  return sendEmail({
    to,
    subject: 'Appointment Confirmed',
    template: 'appointment-confirmation',
    data,
  });
};

/**
 * Send appointment reminder email
 */
export const sendAppointmentReminder = async (
  to: string,
  data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    location: string;
  }
) => {
  return sendEmail({
    to,
    subject: 'Appointment Reminder',
    template: 'appointment-reminder',
    data,
  });
};


