interface SMSOptions {
    to: string;
    message: string;
    from?: string;
}
/**
 * Send SMS message
 */
export declare const sendSMS: (options: SMSOptions) => Promise<boolean>;
/**
 * Send appointment confirmation SMS
 */
export declare const sendAppointmentConfirmationSMS: (phoneNumber: string, data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    location: string;
}) => Promise<boolean>;
/**
 * Send appointment reminder SMS
 */
export declare const sendAppointmentReminderSMS: (phoneNumber: string, data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    hoursUntil: number;
}) => Promise<boolean>;
/**
 * Send appointment cancellation SMS
 */
export declare const sendAppointmentCancellationSMS: (phoneNumber: string, data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    reason?: string;
}) => Promise<boolean>;
/**
 * Send verification code SMS
 */
export declare const sendVerificationCodeSMS: (phoneNumber: string, code: string) => Promise<boolean>;
/**
 * Send payment receipt SMS
 */
export declare const sendPaymentReceiptSMS: (phoneNumber: string, data: {
    patientName: string;
    amount: number;
    currency: string;
    transactionId: string;
}) => Promise<boolean>;
/**
 * Check SMS service status
 */
export declare const checkSMSServiceStatus: () => {
    configured: boolean;
    accountSid?: string;
    phoneNumber?: string;
};
export {};
//# sourceMappingURL=sms.service.d.ts.map