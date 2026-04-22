import { Request, Response, NextFunction } from 'express';
import * as PaymentService from '../services/payment.service';
import { logger } from '../config/logger';
import { ApiError } from '../utils/apiError';
import crypto from 'crypto';
import db from '../config/database';

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
      const tenantId = req.tenantId as string;
      const userId = req.user?.id;
      
      const { appointmentId, amount, currency = 'ILS', metadata } = req.body;

      if (!tenantId) {
        throw new ApiError(400, 'Tenant ID is required');
      }
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

      await db('payment_transactions').insert({
        tenant_id: tenantId,
        appointment_id: appointmentId,
        patient_id: userId || null,
        amount: Number(amount),
        currency,
        status: 'pending',
        provider: process.env.PAYMENT_PROVIDER || 'pending_provider',
        provider_transaction_id: result?.id || null,
        idempotency_key: metadata?.idempotencyKey || `intent:${appointmentId}:${Date.now()}`,
        metadata: metadata || {},
      });

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
      const tenantId = req.tenantId as string;
      if (!tenantId) {
        throw new ApiError(400, 'Tenant ID is required');
      }

      const payment = await (this.paymentService as any).processPayment(id, tenantId);

      await db('payment_transactions')
        .where({ tenant_id: tenantId, id })
        .update({
          status: 'succeeded',
          processed_at: db.fn.now(),
          updated_at: db.fn.now(),
        });

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
      const tenantId = req.tenantId as string;
      const userId = req.user?.id;

      if (!tenantId) {
        throw new ApiError(400, 'Tenant ID is required');
      }
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

      await db('payment_transactions')
        .where({ tenant_id: tenantId, id })
        .update({
          status: 'refunded',
          updated_at: db.fn.now(),
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
      const tenantId = req.tenantId as string;
      if (!tenantId) {
        throw new ApiError(400, 'Tenant ID is required');
      }

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
      const tenantId = req.tenantId as string;
      const userId = req.user?.id;
      const role = req.user?.role;

      const { page = 1, limit = 20 } = req.query;

      if (!tenantId) {
        throw new ApiError(400, 'Tenant ID is required');
      }
      if (!userId || !role) {
        throw new ApiError(401, 'Unauthorized');
      }

      const result = await (this.paymentService as any).getPaymentHistory({
        tenantId,
        userId,
        role,
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

  /**
   * Foundation webhook endpoint for provider-agnostic integrations.
   * @route POST /api/v1/payments/webhooks/payment
   */
  public async handleProviderWebhook(req: Request, res: Response, _next: NextFunction): Promise<void> {
    try {
      const signature = String(req.headers['x-provider-signature'] || '');
      const secret = String(process.env.PAYMENT_WEBHOOK_SECRET || '');
      const payload = typeof req.body === 'string' ? req.body : JSON.stringify(req.body || {});

      if (!secret) {
        res.status(500).json({ status: 'error', code: 'PAYMENT_WEBHOOK_SECRET_MISSING', message: 'Webhook secret not configured' });
        return;
      }

      const expected = crypto.createHmac('sha256', secret).update(payload).digest('hex');
      if (!signature || signature !== expected) {
        res.status(401).json({ status: 'error', code: 'INVALID_WEBHOOK_SIGNATURE', message: 'Invalid webhook signature' });
        return;
      }

      const body = req.body || {};
      const transactionId = String(body.transactionId || body.paymentTransactionId || '');
      const status = String(body.status || '').toLowerCase();
      const providerTransactionId = String(body.providerTransactionId || body.externalRef || '');

      if (!transactionId || !status) {
        res.status(400).json({ status: 'error', code: 'INVALID_WEBHOOK_PAYLOAD', message: 'transactionId and status are required' });
        return;
      }

      const mappedStatus =
        status === 'success' || status === 'succeeded' || status === 'paid'
          ? 'succeeded'
          : status === 'failed' || status === 'error'
            ? 'failed'
            : status === 'refunded'
              ? 'refunded'
              : 'processing';

      await db('payment_transactions')
        .where({ id: transactionId })
        .update({
          status: mappedStatus,
          provider_transaction_id: providerTransactionId || null,
          processed_at: mappedStatus === 'succeeded' ? db.fn.now() : null,
          failed_at: mappedStatus === 'failed' ? db.fn.now() : null,
          failure_reason: mappedStatus === 'failed' ? String(body.reason || 'provider_failed') : null,
          updated_at: db.fn.now(),
        });

      await db('payment_attempts').insert({
        tenant_id: body.tenantId || null,
        payment_transaction_id: transactionId,
        attempt_number: Number(body.attemptNumber || 1),
        status: mappedStatus === 'failed' ? 'failed' : 'succeeded',
        provider_status: status,
        provider_message: body.reason || null,
        provider_payload: body,
      }).catch(() => undefined);

      res.status(200).json({ received: true });
    } catch (error) {
      logger.error('Payment provider webhook error:', error);
      res.status(400).json({ status: 'error', code: 'WEBHOOK_PROCESSING_ERROR', message: 'Webhook processing failed' });
    }
  }

  public async retryPayment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const tenantId = req.tenantId as string;
      if (!tenantId) {
        throw new ApiError(400, 'Tenant ID is required');
      }

      const transaction = await db('payment_transactions')
        .where({ id, tenant_id: tenantId })
        .first();
      if (!transaction) {
        throw new ApiError(404, 'Payment transaction not found');
      }

      const attemptsCountRow = await db('payment_attempts')
        .where({ payment_transaction_id: id })
        .count<{ count: string }[]>({ count: '*' })
        .first();
      const nextAttempt = Number(attemptsCountRow?.count || 0) + 1;

      await db('payment_transactions')
        .where({ id, tenant_id: tenantId })
        .update({
          status: 'processing',
          failure_reason: null,
          failed_at: null,
          updated_at: db.fn.now(),
        });

      await db('payment_attempts').insert({
        tenant_id: tenantId,
        payment_transaction_id: id,
        attempt_number: nextAttempt,
        status: 'started',
        provider_status: 'retry_started',
        provider_payload: { source: 'manual_retry' },
      });

      res.status(200).json({
        success: true,
        message: 'Payment retry queued',
        data: { paymentTransactionId: id, attemptNumber: nextAttempt, status: 'processing' },
      });
    } catch (error) {
      next(error);
    }
  }
}
