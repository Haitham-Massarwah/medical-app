"use strict";
/**
 * Email Gate Configuration
 * Controls whether email functionality is enabled
 * Email is disabled until test accounts are created
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.EMAIL_GATE_ENABLED = exports.ALLOWED_EMAIL_ADDRESSES = void 0;
exports.canSendEmail = canSendEmail;
exports.isEmailEnabled = isEmailEnabled;
// List of allowed email addresses that can receive emails
// Email functionality is disabled until test accounts exist
exports.ALLOWED_EMAIL_ADDRESSES = [
    // Developer account (always allowed)
    'haitham.massarwah@medical-appointments.com',
    // Test accounts (add after creation)
    // 'test.doctor@medical-appointments.com',
    // 'test.customer@medical-appointments.com',
    // Old example accounts (can be removed)
    // 'doctor.example@medical-appointments.com',
    // 'patient.example@medical-appointments.com',
];
// Email gate enabled flag
// Set to true after test accounts are created
exports.EMAIL_GATE_ENABLED = exports.ALLOWED_EMAIL_ADDRESSES.length > 1; // Enabled if more than just developer
/**
 * Check if email can be sent to the given address
 */
function canSendEmail(to) {
    // If gate is disabled (no test accounts), block all emails
    if (!exports.EMAIL_GATE_ENABLED) {
        return false;
    }
    // Allow emails to developer and test accounts only
    return exports.ALLOWED_EMAIL_ADDRESSES.some(allowed => to.toLowerCase().includes(allowed.toLowerCase()));
}
/**
 * Check if email functionality is enabled
 */
function isEmailEnabled() {
    return exports.EMAIL_GATE_ENABLED;
}
//# sourceMappingURL=email.gate.js.map