import axios, { AxiosInstance } from 'axios';
import { logger } from '../config/logger';

/**
 * Cardcom Payment Service
 * Israeli payment gateway integration
 * Documentation: https://secure.cardcom.solutions/swagger/index.html?url=/swagger/v11/swagger.json
 */

interface CardcomConfig {
  username: string;
  password: string;
  terminalNumber: string;
  apiKey?: string;
  baseUrl: string;
  isTestMode: boolean;
}

interface CardcomChargeRequest {
  Amount: number; // Amount in agorot (1 ILS = 100 agorot)
  Currency: string; // ILS, USD, EUR
  CardNumber: string;
  CVV: string;
  CardExpiration: string; // Format: MMYY
  HolderID?: string;
  HolderName?: string;
  HolderEmail?: string;
  HolderPhone?: string;
  Description?: string;
  TransactionReference?: string;
  Token?: string; // For tokenized payments
}

interface CardcomChargeResponse {
  ResponseCode: number;
  ResponseMessage: string;
  TransactionId?: string;
  LowProfileCode?: string;
  Token?: string;
  ApprovalNumber?: string;
  RRN?: string;
  CardType?: string;
  CardBrand?: string;
  CardExpiration?: string;
  CardLast4Digits?: string;
}

interface CardcomRefundRequest {
  TransactionId: string;
  Amount?: number; // If not provided, full refund
  Reason?: string;
}

export class CardcomService {
  private config: CardcomConfig;
  private axiosInstance: AxiosInstance;

  constructor() {
    // Load configuration from environment variables
    this.config = {
      username: process.env.CARDCOM_USERNAME || 'CardTest1994',
      password: process.env.CARDCOM_PASSWORD || 'Terminaltest2026',
      terminalNumber: process.env.CARDCOM_TERMINAL_NUMBER || '',
      apiKey: process.env.CARDCOM_API_KEY || '',
      baseUrl: process.env.CARDCOM_BASE_URL || 'https://secure.cardcom.solutions',
      isTestMode: process.env.NODE_ENV !== 'production',
    };

    // Initialize axios instance
    this.axiosInstance = axios.create({
      baseURL: this.config.baseUrl,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    });

    logger.info('Cardcom service initialized', {
      username: this.config.username,
      isTestMode: this.config.isTestMode,
    });
  }

  /**
   * Authenticate with Cardcom API
   */
  private async authenticate(): Promise<string | null> {
    try {
      const response = await this.axiosInstance.post('/api/v11/Token', {
        Username: this.config.username,
        Password: this.config.password,
        TerminalNumber: this.config.terminalNumber,
      });

      if (response.data && response.data.ResponseCode === 0) {
        return response.data.Token;
      }

      logger.error('Cardcom authentication failed', {
        responseCode: response.data?.ResponseCode,
        responseMessage: response.data?.ResponseMessage,
      });

      return null;
    } catch (error: any) {
      logger.error('Cardcom authentication error:', error.message);
      return null;
    }
  }

  /**
   * Charge a credit card
   */
  async chargeCard(request: CardcomChargeRequest): Promise<CardcomChargeResponse> {
    try {
      // Authenticate first
      const token = await this.authenticate();
      if (!token) {
        throw new Error('Failed to authenticate with Cardcom');
      }

      // Prepare charge request
      const chargeData = {
        Token: token,
        TerminalNumber: this.config.terminalNumber,
        Amount: Math.round(request.Amount * 100), // Convert to agorot
        Currency: request.Currency || 'ILS',
        CardNumber: request.CardNumber.replace(/\s/g, ''), // Remove spaces
        CVV: request.CVV,
        CardExpiration: request.CardExpiration,
        HolderID: request.HolderID,
        HolderName: request.HolderName,
        HolderEmail: request.HolderEmail,
        HolderPhone: request.HolderPhone,
        Description: request.Description || 'Medical Appointment Payment',
        TransactionReference: request.TransactionReference,
        TokenToSave: request.Token ? false : true, // Save token for future use
      };

      logger.info('Processing Cardcom charge', {
        amount: chargeData.Amount,
        currency: chargeData.Currency,
        cardLast4: request.CardNumber.slice(-4),
      });

      // Make charge request
      const response = await this.axiosInstance.post('/api/v11/Charge', chargeData);

      const result: CardcomChargeResponse = {
        ResponseCode: response.data.ResponseCode || -1,
        ResponseMessage: response.data.ResponseMessage || 'Unknown error',
        TransactionId: response.data.TransactionId,
        LowProfileCode: response.data.LowProfileCode,
        Token: response.data.Token,
        ApprovalNumber: response.data.ApprovalNumber,
        RRN: response.data.RRN,
        CardType: response.data.CardType,
        CardBrand: response.data.CardBrand,
        CardExpiration: response.data.CardExpiration,
        CardLast4Digits: response.data.CardLast4Digits,
      };

      if (result.ResponseCode === 0) {
        logger.info('Cardcom charge successful', {
          transactionId: result.TransactionId,
          approvalNumber: result.ApprovalNumber,
        });
      } else {
        logger.warn('Cardcom charge failed', {
          responseCode: result.ResponseCode,
          responseMessage: result.ResponseMessage,
        });
      }

      return result;
    } catch (error: any) {
      logger.error('Cardcom charge error:', error.message);
      throw new Error(`Cardcom charge failed: ${error.message}`);
    }
  }

  /**
   * Process refund
   */
  async refund(request: CardcomRefundRequest): Promise<CardcomChargeResponse> {
    try {
      const token = await this.authenticate();
      if (!token) {
        throw new Error('Failed to authenticate with Cardcom');
      }

      const refundData = {
        Token: token,
        TerminalNumber: this.config.terminalNumber,
        TransactionId: request.TransactionId,
        Amount: request.Amount ? Math.round(request.Amount * 100) : undefined,
        Reason: request.Reason || 'Refund request',
      };

      logger.info('Processing Cardcom refund', {
        transactionId: request.TransactionId,
        amount: request.Amount,
      });

      const response = await this.axiosInstance.post('/api/v11/Refund', refundData);

      const result: CardcomChargeResponse = {
        ResponseCode: response.data.ResponseCode || -1,
        ResponseMessage: response.data.ResponseMessage || 'Unknown error',
        TransactionId: response.data.TransactionId,
      };

      if (result.ResponseCode === 0) {
        logger.info('Cardcom refund successful', {
          transactionId: result.TransactionId,
        });
      } else {
        logger.warn('Cardcom refund failed', {
          responseCode: result.ResponseCode,
          responseMessage: result.ResponseMessage,
        });
      }

      return result;
    } catch (error: any) {
      logger.error('Cardcom refund error:', error.message);
      throw new Error(`Cardcom refund failed: ${error.message}`);
    }
  }

  /**
   * Get transaction status
   */
  async getTransactionStatus(transactionId: string): Promise<any> {
    try {
      const token = await this.authenticate();
      if (!token) {
        throw new Error('Failed to authenticate with Cardcom');
      }

      const response = await this.axiosInstance.post('/api/v11/GetTransactionStatus', {
        Token: token,
        TerminalNumber: this.config.terminalNumber,
        TransactionId: transactionId,
      });

      return response.data;
    } catch (error: any) {
      logger.error('Cardcom get transaction status error:', error.message);
      throw new Error(`Failed to get transaction status: ${error.message}`);
    }
  }

  /**
   * Create Low Profile payment link (for redirect-based payments)
   */
  async createLowProfileLink(params: {
    Amount: number;
    Currency?: string;
    Description?: string;
    SuccessUrl: string;
    ErrorUrl: string;
    CancelUrl?: string;
    HolderID?: string;
    HolderName?: string;
    HolderEmail?: string;
  }): Promise<{ LowProfileCode: string; PaymentUrl: string } | null> {
    try {
      const token = await this.authenticate();
      if (!token) {
        throw new Error('Failed to authenticate with Cardcom');
      }

      const response = await this.axiosInstance.post('/api/v11/CreateLowProfile', {
        Token: token,
        TerminalNumber: this.config.terminalNumber,
        Amount: Math.round(params.Amount * 100),
        Currency: params.Currency || 'ILS',
        Description: params.Description || 'Medical Appointment Payment',
        SuccessUrl: params.SuccessUrl,
        ErrorUrl: params.ErrorUrl,
        CancelUrl: params.CancelUrl,
        HolderID: params.HolderID,
        HolderName: params.HolderName,
        HolderEmail: params.HolderEmail,
      });

      if (response.data.ResponseCode === 0) {
        return {
          LowProfileCode: response.data.LowProfileCode,
          PaymentUrl: `${this.config.baseUrl}/LowProfile.aspx?code=${response.data.LowProfileCode}`,
        };
      }

      return null;
    } catch (error: any) {
      logger.error('Cardcom create low profile error:', error.message);
      return null;
    }
  }

  /**
   * Check service status
   */
  checkStatus(): { configured: boolean; testMode: boolean } {
    return {
      configured: !!(this.config.username && this.config.password && this.config.terminalNumber),
      testMode: this.config.isTestMode,
    };
  }
}

// Export singleton instance
export const cardcomService = new CardcomService();

// Export types
export type { CardcomChargeRequest, CardcomChargeResponse, CardcomRefundRequest };

