import { cardcomService, CardcomChargeRequest, CardcomChargeResponse } from './cardcom.service';
import { logger } from '../config/logger';
import db from '../config/database';

/**
 * Cardcom Payment Service Integration
 * Wraps Cardcom service for appointment payment processing
 */

interface ProcessPaymentOptions {
  appointmentId: string;
  amount: number;
  currency?: string;
  patientId: string;
  tenantId: string;
  cardDetails: {
    cardNumber: string;
    cvv: string;
    expirationMonth: string;
    expirationYear: string;
    holderName?: string;
    holderEmail?: string;
    holderPhone?: string;
    holderId?: string;
  };
  description?: string;
}

interface ProcessPaymentResult {
  success: boolean;
  transactionId?: string;
  cardcomTransactionId?: string;
  approvalNumber?: string;
  token?: string;
  cardLast4Digits?: string;
  paymentRecord?: any;
  error?: string;
}

/**
 * Process appointment payment with Cardcom
 */
export const processCardcomPayment = async (
  options: ProcessPaymentOptions
): Promise<ProcessPaymentResult> => {
  try {
    const { appointmentId, amount, currency = 'ILS', patientId, tenantId, cardDetails, description } = options;

    // Format expiration date (MMYY)
    const expirationMonth = cardDetails.expirationMonth.padStart(2, '0');
    const expirationYear = cardDetails.expirationYear.slice(-2); // Last 2 digits
    const cardExpiration = `${expirationMonth}${expirationYear}`;

    // Prepare Cardcom charge request
    const chargeRequest: CardcomChargeRequest = {
      Amount: amount,
      Currency: currency,
      CardNumber: cardDetails.cardNumber.replace(/\s/g, ''),
      CVV: cardDetails.cvv,
      CardExpiration: cardExpiration,
      HolderID: cardDetails.holderId,
      HolderName: cardDetails.holderName,
      HolderEmail: cardDetails.holderEmail,
      HolderPhone: cardDetails.holderPhone,
      Description: description || `Appointment payment: ${appointmentId}`,
      TransactionReference: `APPT-${appointmentId}-${Date.now()}`,
    };

    logger.info('Processing Cardcom payment', {
      appointmentId,
      amount,
      currency,
      patientId,
    });

    // Charge card via Cardcom
    const chargeResponse: CardcomChargeResponse = await cardcomService.chargeCard(chargeRequest);

    // Check if charge was successful
    if (chargeResponse.ResponseCode !== 0) {
      logger.error('Cardcom payment failed', {
        responseCode: chargeResponse.ResponseCode,
        responseMessage: chargeResponse.ResponseMessage,
        appointmentId,
      });

      return {
        success: false,
        error: chargeResponse.ResponseMessage || 'Payment failed',
      };
    }

    // Create payment record in database
    const [paymentRecord] = await db('payments').insert({
      tenant_id: tenantId,
      appointment_id: appointmentId,
      patient_id: patientId,
      amount,
      currency,
      status: 'succeeded',
      cardcom_transaction_id: chargeResponse.TransactionId,
      cardcom_approval_number: chargeResponse.ApprovalNumber,
      cardcom_rrn: chargeResponse.RRN,
      payment_method: 'cardcom',
      card_type: chargeResponse.CardType,
      card_brand: chargeResponse.CardBrand,
      card_last4: chargeResponse.CardLast4Digits,
      cardcom_token: chargeResponse.Token, // Save token for future use
      metadata: JSON.stringify({
        cardcomResponse: chargeResponse,
      }),
      created_at: new Date(),
      updated_at: new Date(),
    }).returning('*');

    logger.info('Cardcom payment processed successfully', {
      appointmentId,
      transactionId: chargeResponse.TransactionId,
      paymentId: paymentRecord.id,
    });

    return {
      success: true,
      transactionId: paymentRecord.id,
      cardcomTransactionId: chargeResponse.TransactionId,
      approvalNumber: chargeResponse.ApprovalNumber,
      token: chargeResponse.Token,
      cardLast4Digits: chargeResponse.CardLast4Digits,
      paymentRecord,
    };
  } catch (error: any) {
    logger.error('Cardcom payment processing error:', error.message);
    return {
      success: false,
      error: error.message || 'Payment processing failed',
    };
  }
};

/**
 * Process refund with Cardcom
 */
export const processCardcomRefund = async (
  cardcomTransactionId: string,
  amount?: number,
  reason?: string
): Promise<{ success: boolean; error?: string }> => {
  try {
    const refundResponse = await cardcomService.refund({
      TransactionId: cardcomTransactionId,
      Amount: amount,
      Reason: reason || 'Refund request',
    });

    if (refundResponse.ResponseCode !== 0) {
      return {
        success: false,
        error: refundResponse.ResponseMessage || 'Refund failed',
      };
    }

    // Update payment record in database
    await db('payments')
      .where({ cardcom_transaction_id: cardcomTransactionId })
      .update({
        status: 'refunded',
        refunded_at: new Date(),
        refund_amount: amount,
        refund_reason: reason,
        updated_at: new Date(),
      });

    logger.info('Cardcom refund processed successfully', {
      transactionId: cardcomTransactionId,
      amount,
    });

    return { success: true };
  } catch (error: any) {
    logger.error('Cardcom refund processing error:', error.message);
    return {
      success: false,
      error: error.message || 'Refund processing failed',
    };
  }
};

/**
 * Get payment status from Cardcom
 */
export const getCardcomPaymentStatus = async (
  cardcomTransactionId: string
): Promise<any> => {
  try {
    const status = await cardcomService.getTransactionStatus(cardcomTransactionId);
    return status;
  } catch (error: any) {
    logger.error('Cardcom get payment status error:', error.message);
    throw error;
  }
};

/**
 * Create Low Profile payment link (redirect-based payment)
 */
export const createCardcomPaymentLink = async (params: {
  appointmentId: string;
  amount: number;
  currency?: string;
  patientId: string;
  tenantId: string;
  successUrl: string;
  errorUrl: string;
  cancelUrl?: string;
  holderName?: string;
  holderEmail?: string;
  holderId?: string;
}): Promise<{ paymentUrl: string; lowProfileCode: string } | null> => {
  try {
    const link = await cardcomService.createLowProfileLink({
      Amount: params.amount,
      Currency: params.currency || 'ILS',
      Description: `Appointment payment: ${params.appointmentId}`,
      SuccessUrl: params.successUrl,
      ErrorUrl: params.errorUrl,
      CancelUrl: params.cancelUrl,
      HolderID: params.holderId,
      HolderName: params.holderName,
      HolderEmail: params.holderEmail,
    });

    if (link) {
      // Save payment record with pending status
      await db('payments').insert({
        tenant_id: params.tenantId,
        appointment_id: params.appointmentId,
        patient_id: params.patientId,
        amount: params.amount,
        currency: params.currency || 'ILS',
        status: 'pending',
        payment_method: 'cardcom',
        cardcom_low_profile_code: link.LowProfileCode,
        created_at: new Date(),
        updated_at: new Date(),
      });

      return {
        paymentUrl: link.PaymentUrl,
        lowProfileCode: link.LowProfileCode,
      };
    }

    return null;
  } catch (error: any) {
    logger.error('Cardcom create payment link error:', error.message);
    return null;
  }
};

/**
 * Check Cardcom service status
 */
export const checkCardcomStatus = () => {
  return cardcomService.checkStatus();
};

