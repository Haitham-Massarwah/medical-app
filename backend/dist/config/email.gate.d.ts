/**
 * Email Gate Configuration
 * Controls whether email functionality is enabled
 * Email is disabled until test accounts are created
 */
export declare const ALLOWED_EMAIL_ADDRESSES: string[];
export declare const EMAIL_GATE_ENABLED: boolean;
/**
 * Check if email can be sent to the given address
 */
export declare function canSendEmail(to: string): boolean;
/**
 * Check if email functionality is enabled
 */
export declare function isEmailEnabled(): boolean;
//# sourceMappingURL=email.gate.d.ts.map