import { Request, Response, NextFunction } from 'express';
import { asyncHandler, NotFoundError, ValidationError, AuthorizationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';
import { getSMSPriceForDoctor, calculateSMSPrice, getTwilioSMSCost, getUSDToILSRate } from '../services/price-calculator.service';

export class DoctorSMSController {
  /**
   * Get doctor SMS settings
   * GET /api/v1/doctors/:doctorId/sms/settings
   */
  getSMSSettings = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { doctorId } = req.params;
    const tenantId = req.tenantId!;
    const userId = (req.user as any)?.id;

    // Verify doctor exists and user has access
    const doctor = await db('doctors')
      .where({ id: doctorId, tenant_id: tenantId })
      .first();

    if (!doctor) {
      throw new NotFoundError('Doctor');
    }

    // Check if user is the doctor or admin
    const user = await db('users').where({ id: userId }).first();
    const isAdmin = user!.role === 'admin' || user!.role === 'developer';
    const isDoctorOwner = doctor.user_id === userId;
    
    if (!isAdmin && !isDoctorOwner) {
      throw new AuthorizationError('You do not have permission to access this doctor\'s SMS settings');
    }

    // Get or create SMS settings
    let settings = await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .first();

    if (!settings) {
      // Calculate dynamic price: Twilio cost × multiplier
      const twilioCost = getTwilioSMSCost();
      const multiplier = parseFloat(process.env.SMS_PRICE_MULTIPLIER || '1.5');
      const exchangeRate = getUSDToILSRate();
      const calculatedPrice = calculateSMSPrice(twilioCost, multiplier, exchangeRate);
      
      // Create default settings
      [settings] = await db('doctor_sms_settings')
        .insert({
          doctor_id: doctorId,
          tenant_id: tenantId,
          sms_enabled: false,
          sms_cost_per_message: calculatedPrice, // Calculated: Twilio cost × multiplier
          twilio_base_cost: twilioCost,
          price_multiplier: multiplier,
          currency: 'ILS', // Israeli Shekel
          billing_method: 'prepaid',
          prepaid_balance: 0,
          is_active: true,
          created_at: new Date(),
          updated_at: new Date(),
        })
        .returning('*');
    }

    // Get usage statistics
    const usageStats = await db('doctor_sms_usage')
      .where({ doctor_id: doctorId })
      .select(
        db.raw('COUNT(*) as total_sent'),
        db.raw('SUM(CASE WHEN sent_successfully = true THEN 1 ELSE 0 END) as successful'),
        db.raw('SUM(cost) as total_cost'),
        db.raw('COUNT(CASE WHEN sent_at >= NOW() - INTERVAL \'30 days\' THEN 1 END) as sent_last_30_days')
      )
      .first();

    // Get current dynamic price
    const priceInfo = await getSMSPriceForDoctor(doctorId, db);

    res.status(200).json({
      success: true,
      data: {
        settings: {
          ...settings,
          current_sms_price: priceInfo.price, // Current calculated price
          twilio_base_cost: priceInfo.twilioCost,
          price_multiplier: priceInfo.multiplier,
          has_discount: priceInfo.hasDiscount,
          discount_percentage: priceInfo.discountPercentage,
          price_before_discount: priceInfo.priceBeforeDiscount,
        },
        usage: {
          totalSent: parseInt(usageStats?.total_sent || '0'),
          successful: parseInt(usageStats?.successful || '0'),
          totalCost: parseFloat(usageStats?.total_cost || '0'),
          sentLast30Days: parseInt(usageStats?.sent_last_30_days || '0'),
        },
        pricing: {
          twilioCostUSD: priceInfo.twilioCost,
          multiplier: priceInfo.multiplier,
          priceILS: priceInfo.price,
          currency: priceInfo.currency,
          hasDiscount: priceInfo.hasDiscount,
          discountPercentage: priceInfo.discountPercentage,
          priceBeforeDiscount: priceInfo.priceBeforeDiscount,
          formula: priceInfo.hasDiscount 
            ? `(${priceInfo.twilioCost} USD × ${getUSDToILSRate()} ILS/USD) × ${priceInfo.multiplier} × (1 - ${priceInfo.discountPercentage}%) = ${priceInfo.priceBeforeDiscount} × 0.${100 - priceInfo.discountPercentage} = ${priceInfo.price} ILS`
            : `(${priceInfo.twilioCost} USD × ${getUSDToILSRate()} ILS/USD) × ${priceInfo.multiplier} = ${priceInfo.price} ILS`,
        },
      },
    });
  });

  /**
   * Update doctor SMS settings
   * PUT /api/v1/doctors/:doctorId/sms/settings
   * Note: Only admin/developer can enable/disable SMS. Doctors can only update preferences.
   */
  updateSMSSettings = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { doctorId } = req.params;
    const tenantId = req.tenantId!;
    const userId = (req.user as any)?.id;

    // Verify doctor exists and user has access
    const doctor = await db('doctors')
      .where({ id: doctorId, tenant_id: tenantId })
      .first();

    if (!doctor) {
      throw new NotFoundError('Doctor');
    }

    // Check user role
    const user = await db('users').where({ id: userId }).first();
    const isAdmin = user!.role === 'admin' || user!.role === 'developer';
    const isDoctorOwner = doctor.user_id === userId;

    // Only admin/developer can enable/disable SMS
    if (req.body.sms_enabled !== undefined && !isAdmin) {
      throw new AuthorizationError('Only administrators can enable/disable SMS service');
    }

    // Doctors can only update their own preferences (not enable/disable)
    if (!isAdmin && !isDoctorOwner) {
      throw new AuthorizationError('You do not have permission to update this doctor\'s SMS settings');
    }

    const {
      sms_enabled,
      send_appointment_reminders,
      send_appointment_confirmations,
      send_appointment_cancellations,
      send_payment_receipts,
      monthly_limit,
      auto_recharge,
      auto_recharge_amount,
      low_balance_threshold,
      custom_templates,
      has_discount, // Enable/disable discount
      discount_percentage, // Discount percentage (0-100)
    } = req.body;

    // Get existing settings
    let settings = await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .first();

    const updateData: any = {
      updated_at: new Date(),
    };

    if (sms_enabled !== undefined) {
      updateData.sms_enabled = sms_enabled;
      if (sms_enabled && !settings) {
        updateData.activated_at = new Date();
      } else if (!sms_enabled && settings?.sms_enabled) {
        updateData.deactivated_at = new Date();
      }
    }

    if (send_appointment_reminders !== undefined) {
      updateData.send_appointment_reminders = send_appointment_reminders;
    }
    if (send_appointment_confirmations !== undefined) {
      updateData.send_appointment_confirmations = send_appointment_confirmations;
    }
    if (send_appointment_cancellations !== undefined) {
      updateData.send_appointment_cancellations = send_appointment_cancellations;
    }
    if (send_payment_receipts !== undefined) {
      updateData.send_payment_receipts = send_payment_receipts;
    }
    if (monthly_limit !== undefined) {
      updateData.monthly_limit = monthly_limit;
    }
    if (auto_recharge !== undefined) {
      updateData.auto_recharge = auto_recharge;
    }
    if (auto_recharge_amount !== undefined) {
      updateData.auto_recharge_amount = auto_recharge_amount;
    }
    if (low_balance_threshold !== undefined) {
      updateData.low_balance_threshold = low_balance_threshold;
    }
    if (custom_templates !== undefined) {
      // Validate custom templates structure
      if (typeof custom_templates === 'object' && custom_templates !== null) {
        updateData.custom_templates = custom_templates;
      } else {
        throw new ValidationError('custom_templates must be a valid JSON object');
      }
    }
    
    // Update discount settings (admin/developer only)
    if (isAdmin) {
      if (has_discount !== undefined) {
        updateData.has_discount = has_discount;
      }
      if (discount_percentage !== undefined) {
        if (discount_percentage < 0 || discount_percentage > 100) {
          throw new ValidationError('Discount percentage must be between 0 and 100');
        }
        updateData.discount_percentage = discount_percentage;
      }
      
      // Recalculate price if discount changed
      if (has_discount !== undefined || discount_percentage !== undefined) {
        const finalHasDiscount = has_discount !== undefined ? has_discount : (settings?.has_discount || false);
        const finalDiscount = discount_percentage !== undefined ? discount_percentage : parseFloat((settings?.discount_percentage || 0).toString());
        const twilioCost = parseFloat((settings?.twilio_base_cost || getTwilioSMSCost()).toString());
        const multiplier = parseFloat((settings?.price_multiplier || process.env.SMS_PRICE_MULTIPLIER || '1.5').toString());
        const exchangeRate = getUSDToILSRate();
        const discountToApply = finalHasDiscount ? finalDiscount : 0;
        updateData.sms_cost_per_message = calculateSMSPrice(twilioCost, multiplier, exchangeRate, discountToApply);
      }
    }
    
    // Update pricing settings (admin only) - multiplier and Twilio cost
    const reqPriceMultiplier = req.body.price_multiplier;
    const reqTwilioBaseCost = req.body.twilio_base_cost;
    
    if (isAdmin) {
      if (reqPriceMultiplier !== undefined) {
        if (reqPriceMultiplier < 1) {
          throw new ValidationError('Price multiplier must be >= 1');
        }
        updateData.price_multiplier = reqPriceMultiplier;
      }
      if (reqTwilioBaseCost !== undefined) {
        if (reqTwilioBaseCost < 0) {
          throw new ValidationError('Twilio base cost must be >= 0');
        }
        updateData.twilio_base_cost = reqTwilioBaseCost;
      }
      
      // Recalculate price if multiplier or Twilio cost changed (including discount)
      if (reqPriceMultiplier !== undefined || reqTwilioBaseCost !== undefined) {
        const finalTwilioCost = reqTwilioBaseCost !== undefined 
          ? reqTwilioBaseCost 
          : parseFloat((settings?.twilio_base_cost || getTwilioSMSCost()).toString());
        const finalMultiplier = reqPriceMultiplier !== undefined 
          ? reqPriceMultiplier 
          : parseFloat((settings?.price_multiplier || process.env.SMS_PRICE_MULTIPLIER || '1.5').toString());
        const finalHasDiscount = has_discount !== undefined ? has_discount : (settings?.has_discount || false);
        const finalDiscount = discount_percentage !== undefined 
          ? discount_percentage 
          : parseFloat((settings?.discount_percentage || 0).toString());
        const discountToApply = finalHasDiscount ? finalDiscount : 0;
        const exchangeRate = getUSDToILSRate();
        updateData.sms_cost_per_message = calculateSMSPrice(finalTwilioCost, finalMultiplier, exchangeRate, discountToApply);
      }
    }

    if (!settings) {
      // Calculate dynamic price: Twilio cost × multiplier
      const twilioCost = getTwilioSMSCost();
      const multiplier = parseFloat(process.env.SMS_PRICE_MULTIPLIER || '1.5');
      const exchangeRate = getUSDToILSRate();
      const calculatedPrice = calculateSMSPrice(twilioCost, multiplier, exchangeRate);
      
      // Create new settings
      [settings] = await db('doctor_sms_settings')
      .insert({
        doctor_id: doctorId,
        tenant_id: tenantId,
        sms_enabled: sms_enabled || false,
        sms_cost_per_message: calculatedPrice, // Calculated: Twilio cost × multiplier
        twilio_base_cost: twilioCost,
        price_multiplier: multiplier,
        currency: 'ILS',
        billing_method: 'prepaid',
        prepaid_balance: 0,
        ...updateData,
        created_at: new Date(),
      })
      .returning('*');
    } else {
      // Update existing settings
      [settings] = await db('doctor_sms_settings')
        .where({ doctor_id: doctorId })
        .update(updateData)
        .returning('*');
    }

    logger.info(`SMS settings updated for doctor ${doctorId}`);

    res.status(200).json({
      success: true,
      message: 'SMS settings updated successfully',
      data: {
        settings,
      },
    });
  });

  /**
   * Recharge doctor SMS balance
   * POST /api/v1/doctors/:doctorId/sms/recharge
   */
  rechargeBalance = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { doctorId } = req.params;
    const tenantId = req.tenantId!;
    const userId = (req.user as any)?.id;
    const { amount, payment_method, payment_reference } = req.body;

    if (!amount || amount <= 0) {
      throw new ValidationError('Amount must be greater than 0');
    }

    // Verify doctor exists and user has access
    const doctor = await db('doctors')
      .where({ id: doctorId, tenant_id: tenantId })
      .first();

    if (!doctor) {
      throw new NotFoundError('Doctor');
    }

    // Check if user is the doctor or admin
    const user = await db('users').where({ id: userId }).first();
    if (user!.role !== 'admin' && user!.role !== 'developer' && doctor.user_id !== userId) {
      throw new AuthorizationError('You do not have permission to recharge this doctor\'s SMS balance');
    }

    // Get SMS settings
    let settings = await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .first();

    if (!settings) {
      throw new NotFoundError('SMS settings not found. Please enable SMS service first.');
    }

    const balanceBefore = parseFloat(settings.prepaid_balance.toString());
    const balanceAfter = balanceBefore + amount;

    // Update balance
    [settings] = await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .update({
        prepaid_balance: balanceAfter,
        updated_at: new Date(),
      })
      .returning('*');

    // Create billing record
    const [billing] = await db('doctor_sms_billing')
      .insert({
        doctor_id: doctorId,
        tenant_id: tenantId,
        billing_type: 'recharge',
        amount,
        currency: settings.currency,
        balance_before: balanceBefore,
        balance_after: balanceAfter,
        payment_method: payment_method || 'manual',
        payment_reference: payment_reference,
        payment_status: payment_reference ? 'completed' : 'pending',
        description: `SMS balance recharge of ${amount} ${settings.currency}`,
        billing_date: new Date(),
        created_at: new Date(),
        updated_at: new Date(),
      })
      .returning('*');

    logger.info(`SMS balance recharged for doctor ${doctorId}: ${amount} ${settings.currency}`);

    res.status(200).json({
      success: true,
      message: 'Balance recharged successfully',
      data: {
        settings,
        billing,
      },
    });
  });

  /**
   * Get SMS usage history
   * GET /api/v1/doctors/:doctorId/sms/usage
   */
  getUsageHistory = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { doctorId } = req.params;
    const tenantId = req.tenantId!;
    const userId = (req.user as any)?.id;
    const { page = 1, limit = 50, startDate, endDate, smsType } = req.query;

    // Verify doctor exists and user has access
    const doctor = await db('doctors')
      .where({ id: doctorId, tenant_id: tenantId })
      .first();

    if (!doctor) {
      throw new NotFoundError('Doctor');
    }

    // Check if user is the doctor or admin
    const user = await db('users').where({ id: userId }).first();
    if (user!.role !== 'admin' && user!.role !== 'developer' && doctor.user_id !== userId) {
      throw new AuthorizationError('You do not have permission to access this doctor\'s SMS usage');
    }

    let query = db('doctor_sms_usage')
      .where({ doctor_id: doctorId })
      .orderBy('sent_at', 'desc');

    if (startDate) {
      query = query.where('sent_at', '>=', startDate);
    }
    if (endDate) {
      query = query.where('sent_at', '<=', endDate);
    }
    if (smsType) {
      query = query.where('sms_type', smsType);
    }

    const offset = (Number(page) - 1) * Number(limit);
    const totalCount = await query.clone().count('* as count').first();
    const usage = await query.limit(Number(limit)).offset(offset);

    res.status(200).json({
      success: true,
      data: {
        usage,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total: parseInt(totalCount?.count?.toString() || '0'),
        },
      },
    });
  });

  /**
   * Get SMS billing history
   * GET /api/v1/doctors/:doctorId/sms/billing
   */
  getBillingHistory = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { doctorId } = req.params;
    const tenantId = req.tenantId!;
    const userId = (req.user as any)?.id;
    const { page = 1, limit = 50 } = req.query;

    // Verify doctor exists and user has access
    const doctor = await db('doctors')
      .where({ id: doctorId, tenant_id: tenantId })
      .first();

    if (!doctor) {
      throw new NotFoundError('Doctor');
    }

    // Check if user is the doctor or admin
    const user = await db('users').where({ id: userId }).first();
    const isAdmin = user!.role === 'admin' || user!.role === 'developer';
    const isDoctorOwner = doctor.user_id === userId;
    
    if (!isAdmin && !isDoctorOwner) {
      throw new AuthorizationError('You do not have permission to access this doctor\'s SMS billing');
    }

    const offset = (Number(page) - 1) * Number(limit);
    const totalCount = await db('doctor_sms_billing')
      .where({ doctor_id: doctorId })
      .count('* as count')
      .first();

    const billing = await db('doctor_sms_billing')
      .where({ doctor_id: doctorId })
      .orderBy('billing_date', 'desc')
      .limit(Number(limit))
      .offset(offset);

    res.status(200).json({
      success: true,
      data: {
        billing,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total: parseInt(totalCount?.count?.toString() || '0'),
        },
      },
    });
  });
}

