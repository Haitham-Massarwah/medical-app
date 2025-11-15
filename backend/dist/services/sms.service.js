"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkSMSServiceStatus = exports.sendPaymentReceiptSMS = exports.sendVerificationCodeSMS = exports.sendAppointmentCancellationSMS = exports.sendAppointmentReminderSMS = exports.sendAppointmentConfirmationSMS = exports.sendSMS = void 0;
const twilio_1 = __importDefault(require("twilio"));
const logger_1 = require("../config/logger");
/**
 * SMS Service using Twilio
 * Sends SMS messages for notifications and reminders
 */
let twilioClient = null;
/**
 * Initialize Twilio client
 */
const initializeTwilioClient = () => {
    if (twilioClient)
        return twilioClient;
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    if (!accountSid || !authToken) {
        logger_1.logger.warn('Twilio credentials not configured. SMS sending will be skipped.');
        return null;
    }
    twilioClient = (0, twilio_1.default)(accountSid, authToken);
    return twilioClient;
};
/**
 * Send SMS message
 */
const sendSMS = async (options) => {
    try {
        const client = initializeTwilioClient();
        if (!client) {
            logger_1.logger.warn(`SMS sending skipped (not configured): ${options.to}`);
            return false;
        }
        const fromNumber = options.from || process.env.TWILIO_PHONE_NUMBER;
        if (!fromNumber) {
            logger_1.logger.error('Twilio phone number not configured');
            return false;
        }
        // Format phone number (ensure it starts with +)
        let toNumber = options.to.trim();
        if (!toNumber.startsWith('+')) {
            // Assume Israeli number if no country code
            toNumber = `+972${toNumber.replace(/^0/, '')}`;
        }
        const message = await client.messages.create({
            body: options.message,
            from: fromNumber,
            to: toNumber,
        });
        logger_1.logger.info(`SMS sent successfully to ${toNumber}: ${message.sid}`);
        return true;
    }
    catch (error) {
        logger_1.logger.error(`Failed to send SMS to ${options.to}:`, error.message);
        return false;
    }
};
exports.sendSMS = sendSMS;
/**
 * Send appointment confirmation SMS
 */
const sendAppointmentConfirmationSMS = async (phoneNumber, data) => {
    const message = `Hi ${data.patientName},\n\nYour appointment is confirmed!\n\nDoctor: ${data.doctorName}\nDate: ${data.date}\nTime: ${data.time}\nLocation: ${data.location}\n\nSee you there!`;
    return (0, exports.sendSMS)({
        to: phoneNumber,
        message,
    });
};
exports.sendAppointmentConfirmationSMS = sendAppointmentConfirmationSMS;
/**
 * Send appointment reminder SMS
 */
const sendAppointmentReminderSMS = async (phoneNumber, data) => {
    const message = `Reminder: You have an appointment in ${data.hoursUntil} hours!\n\nDoctor: ${data.doctorName}\nTime: ${data.time}\n\nSee you soon!`;
    return (0, exports.sendSMS)({
        to: phoneNumber,
        message,
    });
};
exports.sendAppointmentReminderSMS = sendAppointmentReminderSMS;
/**
 * Send appointment cancellation SMS
 */
const sendAppointmentCancellationSMS = async (phoneNumber, data) => {
    let message = `Hi ${data.patientName},\n\nYour appointment has been cancelled.\n\nDoctor: ${data.doctorName}\nDate: ${data.date}\nTime: ${data.time}`;
    if (data.reason) {
        message += `\n\nReason: ${data.reason}`;
    }
    message += '\n\nPlease contact us to reschedule.';
    return (0, exports.sendSMS)({
        to: phoneNumber,
        message,
    });
};
exports.sendAppointmentCancellationSMS = sendAppointmentCancellationSMS;
/**
 * Send verification code SMS
 */
const sendVerificationCodeSMS = async (phoneNumber, code) => {
    const message = `Your verification code is: ${code}\n\nThis code expires in 10 minutes.`;
    return (0, exports.sendSMS)({
        to: phoneNumber,
        message,
    });
};
exports.sendVerificationCodeSMS = sendVerificationCodeSMS;
/**
 * Send payment receipt SMS
 */
const sendPaymentReceiptSMS = async (phoneNumber, data) => {
    const message = `Payment received!\n\nAmount: ${data.amount} ${data.currency}\nTransaction ID: ${data.transactionId}\n\nThank you!`;
    return (0, exports.sendSMS)({
        to: phoneNumber,
        message,
    });
};
exports.sendPaymentReceiptSMS = sendPaymentReceiptSMS;
/**
 * Check SMS service status
 */
const checkSMSServiceStatus = () => {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const phoneNumber = process.env.TWILIO_PHONE_NUMBER;
    return {
        configured: !!(accountSid && process.env.TWILIO_AUTH_TOKEN),
        accountSid: accountSid?.substring(0, 10) + '...',
        phoneNumber,
    };
};
exports.checkSMSServiceStatus = checkSMSServiceStatus;
//# sourceMappingURL=sms.service.js.map