"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkWhatsAppServiceStatus = exports.sendPaymentConfirmationWhatsApp = exports.sendAppointmentCancellationWhatsApp = exports.sendAppointmentReminderWhatsApp = exports.sendAppointmentConfirmationWhatsApp = exports.sendWhatsApp = void 0;
const twilio_1 = __importDefault(require("twilio"));
const logger_1 = require("../config/logger");
/**
 * WhatsApp Service using Twilio WhatsApp Business API
 * Sends WhatsApp messages for notifications
 */
let twilioClient = null;
/**
 * Initialize Twilio client for WhatsApp
 */
const initializeTwilioClient = () => {
    if (twilioClient)
        return twilioClient;
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    if (!accountSid || !authToken) {
        logger_1.logger.warn('Twilio credentials not configured. WhatsApp sending will be skipped.');
        return null;
    }
    twilioClient = (0, twilio_1.default)(accountSid, authToken);
    return twilioClient;
};
/**
 * Send WhatsApp message
 */
const sendWhatsApp = async (options) => {
    try {
        const client = initializeTwilioClient();
        if (!client) {
            logger_1.logger.warn(`WhatsApp sending skipped (not configured): ${options.to}`);
            return false;
        }
        const fromNumber = process.env.TWILIO_WHATSAPP_NUMBER;
        if (!fromNumber) {
            logger_1.logger.error('Twilio WhatsApp number not configured');
            return false;
        }
        // Format WhatsApp number (must start with whatsapp:+)
        let toNumber = options.to.trim();
        if (!toNumber.startsWith('whatsapp:')) {
            if (!toNumber.startsWith('+')) {
                // Assume Israeli number if no country code
                toNumber = `+972${toNumber.replace(/^0/, '')}`;
            }
            toNumber = `whatsapp:${toNumber}`;
        }
        const messageOptions = {
            body: options.message,
            from: fromNumber,
            to: toNumber,
        };
        // Add media if provided
        if (options.mediaUrl) {
            messageOptions.mediaUrl = [options.mediaUrl];
        }
        const message = await client.messages.create(messageOptions);
        logger_1.logger.info(`WhatsApp sent successfully to ${toNumber}: ${message.sid}`);
        return true;
    }
    catch (error) {
        logger_1.logger.error(`Failed to send WhatsApp to ${options.to}:`, error.message);
        return false;
    }
};
exports.sendWhatsApp = sendWhatsApp;
/**
 * Send appointment confirmation WhatsApp
 */
const sendAppointmentConfirmationWhatsApp = async (phoneNumber, data) => {
    const message = `*Appointment Confirmed* ✅\n\nHi ${data.patientName}!\n\n👨‍⚕️ Doctor: ${data.doctorName}\n📅 Date: ${data.date}\n🕐 Time: ${data.time}\n📍 Location: ${data.location}\n\nSee you there!`;
    return (0, exports.sendWhatsApp)({
        to: phoneNumber,
        message,
    });
};
exports.sendAppointmentConfirmationWhatsApp = sendAppointmentConfirmationWhatsApp;
/**
 * Send appointment reminder WhatsApp
 */
const sendAppointmentReminderWhatsApp = async (phoneNumber, data) => {
    const message = `*Appointment Reminder* 🔔\n\nHi ${data.patientName}!\n\nYou have an appointment in *${data.hoursUntil} hours*\n\n👨‍⚕️ Doctor: ${data.doctorName}\n🕐 Time: ${data.time}\n\nSee you soon!`;
    return (0, exports.sendWhatsApp)({
        to: phoneNumber,
        message,
    });
};
exports.sendAppointmentReminderWhatsApp = sendAppointmentReminderWhatsApp;
/**
 * Send appointment cancellation WhatsApp
 */
const sendAppointmentCancellationWhatsApp = async (phoneNumber, data) => {
    let message = `*Appointment Cancelled* ❌\n\nHi ${data.patientName},\n\nYour appointment has been cancelled.\n\n👨‍⚕️ Doctor: ${data.doctorName}\n📅 Date: ${data.date}\n🕐 Time: ${data.time}`;
    if (data.reason) {
        message += `\n\n📝 Reason: ${data.reason}`;
    }
    message += '\n\nPlease contact us to reschedule.';
    return (0, exports.sendWhatsApp)({
        to: phoneNumber,
        message,
    });
};
exports.sendAppointmentCancellationWhatsApp = sendAppointmentCancellationWhatsApp;
/**
 * Send payment confirmation WhatsApp
 */
const sendPaymentConfirmationWhatsApp = async (phoneNumber, data) => {
    const message = `*Payment Received* ✅\n\nThank you, ${data.patientName}!\n\n💰 Amount: ${data.amount} ${data.currency}\n🔖 Transaction ID: ${data.transactionId}\n\nReceipt sent to your email.`;
    return (0, exports.sendWhatsApp)({
        to: phoneNumber,
        message,
    });
};
exports.sendPaymentConfirmationWhatsApp = sendPaymentConfirmationWhatsApp;
/**
 * Check WhatsApp service status
 */
const checkWhatsAppServiceStatus = () => {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const phoneNumber = process.env.TWILIO_WHATSAPP_NUMBER;
    return {
        configured: !!(accountSid && process.env.TWILIO_AUTH_TOKEN && phoneNumber),
        accountSid: accountSid?.substring(0, 10) + '...',
        phoneNumber,
    };
};
exports.checkWhatsAppServiceStatus = checkWhatsAppServiceStatus;
//# sourceMappingURL=whatsapp.service.js.map