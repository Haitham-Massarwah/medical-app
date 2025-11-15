import Stripe from 'stripe';
interface CreatePaymentIntentOptions {
    amount: number;
    currency?: string;
    description?: string;
    metadata?: Record<string, string>;
    customerId?: string;
}
/**
 * Create payment intent
 */
export declare const createPaymentIntent: (options: CreatePaymentIntentOptions) => Promise<Stripe.PaymentIntent | null>;
/**
 * Confirm payment
 */
export declare const confirmPayment: (paymentIntentId: string) => Promise<Stripe.PaymentIntent | null>;
/**
 * Get payment status
 */
export declare const getPaymentStatus: (paymentIntentId: string) => Promise<Stripe.PaymentIntent | null>;
/**
 * Create refund
 */
export declare const createRefund: (paymentIntentId: string, amount?: number, reason?: string) => Promise<Stripe.Refund | null>;
/**
 * Create customer
 */
export declare const createCustomer: (email: string, name: string, metadata?: Record<string, string>) => Promise<Stripe.Customer | null>;
/**
 * Process appointment payment
 */
export declare const processAppointmentPayment: (appointmentId: string, amount: number, patientId: string, tenantId: string) => Promise<{
    paymentIntent: Stripe.PaymentIntent;
    paymentRecord: any;
} | null>;
/**
 * Process deposit payment
 */
export declare const processDepositPayment: (appointmentId: string, depositAmount: number, patientId: string, tenantId: string) => Promise<{
    paymentIntent: Stripe.PaymentIntent;
    paymentRecord: any;
} | null>;
/**
 * Handle webhook event
 */
export declare const handleWebhookEvent: (event: Stripe.Event) => Promise<void>;
/**
 * Check payment service status
 */
export declare const checkPaymentServiceStatus: () => {
    configured: boolean;
    currency?: string;
};
/**
 * Construct webhook event from raw body
 */
export declare const constructWebhookEvent: (payload: string | Buffer, signature: string) => Stripe.Event | null;
export declare const PaymentService: {
    createPaymentIntent: (options: CreatePaymentIntentOptions) => Promise<Stripe.PaymentIntent | null>;
    confirmPayment: (paymentIntentId: string) => Promise<Stripe.PaymentIntent | null>;
    getPaymentStatus: (paymentIntentId: string) => Promise<Stripe.PaymentIntent | null>;
    createRefund: (paymentIntentId: string, amount?: number, reason?: string) => Promise<Stripe.Refund | null>;
    createCustomer: (email: string, name: string, metadata?: Record<string, string>) => Promise<Stripe.Customer | null>;
    processAppointmentPayment: (appointmentId: string, amount: number, patientId: string, tenantId: string) => Promise<{
        paymentIntent: Stripe.PaymentIntent;
        paymentRecord: any;
    } | null>;
    processDepositPayment: (appointmentId: string, depositAmount: number, patientId: string, tenantId: string) => Promise<{
        paymentIntent: Stripe.PaymentIntent;
        paymentRecord: any;
    } | null>;
    handleWebhookEvent: (event: Stripe.Event) => Promise<void>;
    checkPaymentServiceStatus: () => {
        configured: boolean;
        currency?: string;
    };
    constructWebhookEvent: (payload: string | Buffer, signature: string) => Stripe.Event | null;
};
export {};
//# sourceMappingURL=payment.service.d.ts.map