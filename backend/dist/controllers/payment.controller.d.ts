import { Request, Response, NextFunction } from 'express';
export declare class PaymentController {
    private paymentService;
    constructor();
    /**
     * Create payment intent
     * @route POST /api/v1/payments
     */
    createPayment(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Process payment
     * @route POST /api/v1/payments/:id/process
     */
    processPayment(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Refund payment
     * @route POST /api/v1/payments/:id/refund
     */
    refundPayment(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Get payment receipt
     * @route GET /api/v1/payments/:id/receipt
     */
    getReceipt(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Get payment history
     * @route GET /api/v1/payments
     */
    getPaymentHistory(req: Request, res: Response, next: NextFunction): Promise<void>;
    /**
     * Handle Stripe webhook
     * @route POST /api/v1/payments/webhook
     */
    handleWebhook(req: Request, res: Response, next: NextFunction): Promise<void>;
}
//# sourceMappingURL=payment.controller.d.ts.map