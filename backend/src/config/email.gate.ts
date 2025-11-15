/**
 * Email Gate Configuration
 * Controls whether email functionality is enabled
 * Email is disabled until test accounts are created
 */

// List of allowed email addresses that can receive emails
// Email functionality is disabled until test accounts exist
export const ALLOWED_EMAIL_ADDRESSES: string[] = [
  // Developer account (always allowed)
  'haitham.massarwah@medical-appointments.com',
  'hn.medicalapoointments@gmail.com',
  
  // Test accounts (add after creation)
  // 'test.doctor@medical-appointments.com',
  // 'test.customer@medical-appointments.com',
  
  // Old example accounts (can be removed)
  // 'doctor.example@medical-appointments.com',
  // 'patient.example@medical-appointments.com',
];

// Email gate enabled flag
// Set to true after test accounts are created
export const EMAIL_GATE_ENABLED = ALLOWED_EMAIL_ADDRESSES.length > 1; // Enabled if more than just developer

/**
 * Check if email can be sent to the given address
 */
export function canSendEmail(to: string): boolean {
  // If gate is disabled (no test accounts), block all emails
  if (!EMAIL_GATE_ENABLED) {
    return false;
  }
  
  // Allow emails to developer and test accounts only
  return ALLOWED_EMAIL_ADDRESSES.some(
    allowed => to.toLowerCase().includes(allowed.toLowerCase())
  );
}

/**
 * Check if email functionality is enabled
 */
export function isEmailEnabled(): boolean {
  return EMAIL_GATE_ENABLED;
}




