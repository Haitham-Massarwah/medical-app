import { Request, Response, NextFunction } from 'express';
import {
  processCardcomPayment,
  processCardcomRefund,
  getCardcomPaymentStatus,
  createCardcomPaymentLink,
  checkCardcomStatus,
} from '../services/cardcom-payment.service';
import { logger } from '../config/logger';
import { ApiError } from '../utils/apiError';

export class CardcomController {
  /**
   * Process payment with Cardcom
   * @route POST /api/v1/payments/cardcom/charge
   */
  public async charge(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const tenantId = req.headers['x-tenant-id'] as string;
      const userId = req.user?.id;

      const {
        appointmentId,
        amount,
        currency = 'ILS',
        cardNumber,
        cvv,
        expirationMonth,
        expirationYear,
        holderName,
        holderEmail,
        holderPhone,
        holderId,
        description,
      } = req.body;

      // Validate required fields
      if (!appointmentId || !amount || !cardNumber || !cvv || !expirationMonth || !expirationYear) {
        throw new ApiError(400, 'Missing required payment fields');
      }

      // Validate card number (basic check)
      const cleanCardNumber = cardNumber.replace(/\s/g, '');
      if (cleanCardNumber.length < 13 || cleanCardNumber.length > 19) {
        throw new ApiError(400, 'Invalid card number');
      }

      // Process payment
      const result = await processCardcomPayment({
        appointmentId,
        amount: Number(amount),
        currency,
        patientId: userId!,
        tenantId,
        cardDetails: {
          cardNumber: cleanCardNumber,
          cvv,
          expirationMonth: String(expirationMonth),
          expirationYear: String(expirationYear),
          holderName,
          holderEmail,
          holderPhone,
          holderId,
        },
        description,
      });

      if (!result.success) {
        throw new ApiError(400, result.error || 'Payment failed');
      }

      res.status(200).json({
        success: true,
        data: {
          transactionId: result.transactionId,
          cardcomTransactionId: result.cardcomTransactionId,
          approvalNumber: result.approvalNumber,
          cardLast4Digits: result.cardLast4Digits,
          paymentRecord: result.paymentRecord,
        },
        message: 'Payment processed successfully',
      });
    } catch (error) {
      logger.error('Cardcom charge error:', error);
      next(error);
    }
  }

  /**
   * Create payment link (Low Profile)
   * @route POST /api/v1/payments/cardcom/link
   */
  public async createLink(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const tenantId = req.headers['x-tenant-id'] as string;
      const userId = req.user?.id;

      const {
        appointmentId,
        amount,
        currency = 'ILS',
        successUrl,
        errorUrl,
        cancelUrl,
        holderName,
        holderEmail,
        holderId,
      } = req.body;

      if (!appointmentId || !amount || !successUrl || !errorUrl) {
        throw new ApiError(400, 'Missing required fields');
      }

      const link = await createCardcomPaymentLink({
        appointmentId,
        amount: Number(amount),
        currency,
        patientId: userId!,
        tenantId,
        successUrl,
        errorUrl,
        cancelUrl,
        holderName,
        holderEmail,
        holderId,
      });

      if (!link) {
        throw new ApiError(500, 'Failed to create payment link');
      }

      res.status(200).json({
        success: true,
        data: link,
        message: 'Payment link created successfully',
      });
    } catch (error) {
      logger.error('Cardcom create link error:', error);
      next(error);
    }
  }

  /**
   * Process refund
   * @route POST /api/v1/payments/cardcom/refund
   */
  public async refund(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { cardcomTransactionId, amount, reason } = req.body;

      if (!cardcomTransactionId) {
        throw new ApiError(400, 'Cardcom transaction ID is required');
      }

      const result = await processCardcomRefund(
        cardcomTransactionId,
        amount ? Number(amount) : undefined,
        reason
      );

      if (!result.success) {
        throw new ApiError(400, result.error || 'Refund failed');
      }

      res.status(200).json({
        success: true,
        message: 'Refund processed successfully',
      });
    } catch (error) {
      logger.error('Cardcom refund error:', error);
      next(error);
    }
  }

  /**
   * Get transaction status
   * @route GET /api/v1/payments/cardcom/status/:transactionId
   */
  public async getStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { transactionId } = req.params;

      const status = await getCardcomPaymentStatus(transactionId);

      res.status(200).json({
        success: true,
        data: status,
      });
    } catch (error) {
      logger.error('Cardcom get status error:', error);
      next(error);
    }
  }

  /**
   * Check Cardcom service status
   * @route GET /api/v1/payments/cardcom/status
   */
  public async checkStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const status = checkCardcomStatus();

      res.status(200).json({
        success: true,
        data: status,
      });
    } catch (error) {
      logger.error('Cardcom check status error:', error);
      next(error);
    }
  }

  /**
   * Test payment endpoint
   * @route POST /api/v1/payments/cardcom/test
   */
  public async testPayment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      // Test with provided test card
      const testCard = {
        cardNumber: '4580000000000000',
        cvv: '123',
        expirationMonth: '12',
        expirationYear: '2030',
        holderName: 'Test User',
      };

      const result = await processCardcomPayment({
        appointmentId: 'TEST-' + Date.now(),
        amount: 1.00, // 1 ILS test payment
        currency: 'ILS',
        patientId: req.user?.id || 'test-patient',
        tenantId: req.headers['x-tenant-id'] as string || 'test-tenant',
        cardDetails: {
          ...testCard,
          holderEmail: 'test@example.com',
        },
        description: 'Cardcom Test Payment',
      });

      res.status(200).json({
        success: result.success,
        data: result,
        message: result.success ? 'Test payment successful' : 'Test payment failed',
      });
    } catch (error) {
      logger.error('Cardcom test payment error:', error);
      next(error);
    }
  }
}

