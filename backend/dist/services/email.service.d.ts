interface EmailOptions {
    to: string;
    subject: string;
    template: string;
    data: any;
}
/**
 * Send email using template
 */
export declare const sendEmail: (options: EmailOptions) => Promise<void>;
/**
 * Send appointment confirmation email
 */
export declare const sendAppointmentConfirmation: (to: string, data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    location: string;
}) => Promise<void>;
/**
 * Send appointment reminder email
 */
export declare const sendAppointmentReminder: (to: string, data: {
    patientName: string;
    doctorName: string;
    date: string;
    time: string;
    location: string;
}) => Promise<void>;
export {};
//# sourceMappingURL=email.service.d.ts.map