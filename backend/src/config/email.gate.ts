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
  'haitham.massarwah@gmail.com',
  'Haitham.Massarwah@gmail.com', // Doctor registration test email
  
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
  
  const normalizedTo = (to || '').toLowerCase().trim();

  // Allow emails to explicitly allowed addresses
  if (
    ALLOWED_EMAIL_ADDRESSES.some(
      allowed => normalizedTo === allowed.toLowerCase().trim()
    )
  ) {
    return true;
  }

  // Allow emails to our product domain accounts (needed for self-registration verification flows)
  // NOTE: Keep this list narrow; expand only if explicitly required.
  const allowedDomains = ['medical-appointments.com'];
  if (allowedDomains.some(domain => normalizedTo.endsWith(`@${domain}`))) {
    return true;
  }

  return false;
}

/**
 * Check if email functionality is enabled
 */
export function isEmailEnabled(): boolean {
  return EMAIL_GATE_ENABLED;
}




