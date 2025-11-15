import { Request, Response, NextFunction } from 'express';
import { PaymentService } from '../services/payment.service';
import { logger } from '../config/logger';
import { ApiError } from '../utils/apiError';

export class PaymentController {
  private paymentService = PaymentService;

  constructor() {
    // PaymentService is already initialized
  }

  /**
   * Create payment intent
   * @route POST /api/v1/payments
   */
  public async createPayment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const tenantId = req.headers['x-tenant-id'] as string;
      const userId = req.user?.id;
      
      const { appointmentId, amount, currency = 'ILS', metadata } = req.body;

      if (!appointmentId || !amount) {
        throw new ApiError(400, 'Appointment ID and amount are required');
      }

      const result = await this.paymentService.createPaymentIntent({
        amount: Number(amount),
        currency,
        metadata: {
          ...metadata,
          appointmentId,
          tenantId,
          patientId: userId,
        },
      } as any);

      res.status(201).json({
        success: true,
        data: result,
        message: 'Payment intent created successfully',
      });
    } catch (error) {
      logger.error('Error creating payment:', error);
      next(error);
    }
  }

  /**
   * Process payment
   * @route POST /api/v1/payments/:id/process
   */
  public async processPayment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const tenantId = req.headers['x-tenant-id'] as string;

      const payment = await (this.paymentService as any).processPayment(id, tenantId);

      res.status(200).json({
        success: true,
        data: payment,
        message: 'Payment processed successfully',
      });
    } catch (error) {
      logger.error('Error processing payment:', error);
      next(error);
    }
  }

  /**
   * Refund payment
   * @route POST /api/v1/payments/:id/refund
   */
  public async refundPayment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const { amount, reason } = req.body;
      const tenantId = req.headers['x-tenant-id'] as string;
      const userId = req.user?.id;

      if (!reason) {
        throw new ApiError(400, 'Refund reason is required');
      }

      const payment = await (this.paymentService as any).refundPayment({
        paymentId: id,
        amount: amount ? Number(amount) : undefined,
        reason,
        tenantId,
        userId: userId!,
      });

      res.status(200).json({
        success: true,
        data: payment,
        message: 'Payment refunded successfully',
      });
    } catch (error) {
      logger.error('Error refunding payment:', error);
      next(error);
    }
  }

  /**
   * Get payment receipt
   * @route GET /api/v1/payments/:id/receipt
   */
  public async getReceipt(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const tenantId = req.headers['x-tenant-id'] as string;

      const receipt = await (this.paymentService as any).generateReceipt(id, tenantId);

      res.status(200).json({
        success: true,
        data: receipt,
      });
    } catch (error) {
      logger.error('Error getting receipt:', error);
      next(error);
    }
  }

  /**
   * Get payment history
   * @route GET /api/v1/payments
   */
  public async getPaymentHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const tenantId = req.headers['x-tenant-id'] as string;
      const userId = req.user?.id;
      const role = req.user?.role;

      const { page = 1, limit = 20 } = req.query;

      const result = await (this.paymentService as any).getPaymentHistory({
        tenantId,
        userId: userId!,
        role: role!,
        page: Number(page),
        limit: Number(limit),
      });

      res.status(200).json({
        success: true,
        data: result.data,
        pagination: {
          page: result.page,
          limit: result.limit,
          total: result.total,
          totalPages: Math.ceil(result.total / result.limit),
        },
      });
    } catch (error) {
      logger.error('Error getting payment history:', error);
      next(error);
    }
  }

  /**
   * Handle Stripe webhook
   * @route POST /api/v1/payments/webhook
   */
  public async handleWebhook(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const sig = req.headers['stripe-signature'] as string;
      const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

      if (!webhookSecret) {
        throw new ApiError(500, 'Webhook secret not configured');
      }

      // Verify webhook signature
      const stripe = new (require('stripe'))(process.env.STRIPE_SECRET_KEY);
      const event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);

      const tenantId = event.data.object.metadata?.tenantId;

      await (this.paymentService as any).handleWebhook(event, tenantId);

      res.status(200).json({ received: true });
    } catch (error) {
      logger.error('Webhook error:', error);
      res.status(400).json({ error: 'Webhook error' });
    }
  }
}
