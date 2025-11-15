"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendAppointmentReminder = exports.sendAppointmentConfirmation = exports.sendEmail = void 0;
const nodemailer_1 = __importDefault(require("nodemailer"));
const logger_1 = require("../config/logger");
const email_templates_1 = require("./email.templates");
const email_gate_1 = require("../config/email.gate");
/**
 * Email service for sending transactional emails
 * Uses Nodemailer with configurable transport
 */
// Create reusable transporter
let transporter;
const initializeTransporter = () => {
    if (transporter)
        return transporter;
    const emailConfig = {
        host: process.env.SMTP_HOST || 'smtp.gmail.com',
        port: parseInt(process.env.SMTP_PORT || '587'),
        secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASSWORD,
        },
    };
    transporter = nodemailer_1.default.createTransport(emailConfig);
    return transporter;
};
/**
 * Send email using template
 */
const sendEmail = async (options) => {
    // Check email gate - block emails until test accounts are created
    if (!(0, email_gate_1.isEmailEnabled)()) {
        logger_1.logger.warn(`Email sending is disabled until test accounts are created. Attempted to send to: ${options.to}`);
        return; // Silently fail - don't throw error during testing phase
    }
    // Check if recipient is allowed
    if (!(0, email_gate_1.canSendEmail)(options.to)) {
        logger_1.logger.warn(`Email sending blocked to ${options.to}. Address not in allowed list.`);
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
        logger_1.logger.info(`Email sent successfully to ${options.to}: ${options.subject}`);
    }
    catch (error) {
        logger_1.logger.error(`Failed to send email to ${options.to}:`, error);
        throw new Error('Failed to send email');
    }
};
exports.sendEmail = sendEmail;
/**
 * Generate email HTML from template
 * In production, you'd use a proper template engine like Handlebars or Pug
 */
const generateEmailHTML = (template, data) => {
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
            const tpl = (0, email_templates_1.renderInvitationTemplate)({ name: data.name, registrationUrl: data.registrationUrl });
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
const sendAppointmentConfirmation = async (to, data) => {
    return (0, exports.sendEmail)({
        to,
        subject: 'Appointment Confirmed',
        template: 'appointment-confirmation',
        data,
    });
};
exports.sendAppointmentConfirmation = sendAppointmentConfirmation;
/**
 * Send appointment reminder email
 */
const sendAppointmentReminder = async (to, data) => {
    return (0, exports.sendEmail)({
        to,
        subject: 'Appointment Reminder',
        template: 'appointment-reminder',
        data,
    });
};
exports.sendAppointmentReminder = sendAppointmentReminder;
//# sourceMappingURL=email.service.js.map