interface WhatsAppOptions {
    to: string;
    message: string;
    mediaUrl?: string;
}
/**
 * Send WhatsApp message
 */
export declare const sendWhatsApp: (options: WhatsAppOptions) => Promise<boolean>;
/**
 * Send appointment confirmation WhatsApp
 */
export declare const sendAppointmentConfirmationWhatsApp: (phoneNumber: string, data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    location: string;
}) => Promise<boolean>;
/**
 * Send appointment reminder WhatsApp
 */
export declare const sendAppointmentReminderWhatsApp: (phoneNumber: string, data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    hoursUntil: number;
}) => Promise<boolean>;
/**
 * Send appointment cancellation WhatsApp
 */
export declare const sendAppointmentCancellationWhatsApp: (phoneNumber: string, data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    reason?: string;
}) => Promise<boolean>;
/**
 * Send payment confirmation WhatsApp
 */
export declare const sendPaymentConfirmationWhatsApp: (phoneNumber: string, data: {
    patientName: string;
    amount: number;
    currency: string;
    transactionId: string;
}) => Promise<boolean>;
/**
 * Check WhatsApp service status
 */
export declare const checkWhatsAppServiceStatus: () => {
    configured: boolean;
    accountSid?: string;
    phoneNumber?: string;
};
export {};
//# sourceMappingURL=whatsapp.service.d.ts.map