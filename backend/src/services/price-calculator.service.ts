/**
 * Price Calculator Service
 * Calculates SMS prices dynamically based on Twilio cost and multiplier
 */

import { logger } from '../config/logger';

// Twilio base cost per SMS (can be updated from environment or Twilio API)
const DEFAULT_TWILIO_COST_USD = parseFloat(process.env.TWILIO_SMS_COST_USD || '0.0075');
const DEFAULT_PRICE_MULTIPLIER = parseFloat(process.env.SMS_PRICE_MULTIPLIER || '1.5');

// Exchange rate USD to ILS (can be updated from API or config)
const DEFAULT_USD_TO_ILS_RATE = parseFloat(process.env.USD_TO_ILS_RATE || '3.7');

/**
 * Get current Twilio SMS cost in USD
 * In production, this could fetch from Twilio API or be updated via admin panel
 */
export const getTwilioSMSCost = (): number => {
  return DEFAULT_TWILIO_COST_USD;
};

/**
 * Get current USD to ILS exchange rate
 * In production, this could fetch from currency API
 */
export const getUSDToILSRate = (): number => {
  return DEFAULT_USD_TO_ILS_RATE;
};

/**
 * Calculate SMS price for doctor
 * Formula: (Twilio cost USD × Exchange rate) × Multiplier × (1 - Discount%)
 */
export const calculateSMSPrice = (
  twilioCostUSD: number = DEFAULT_TWILIO_COST_USD,
  multiplier: number = DEFAULT_PRICE_MULTIPLIER,
  exchangeRate: number = DEFAULT_USD_TO_ILS_RATE,
  discountPercentage: number = 0
): number => {
  const costInILS = twilioCostUSD * exchangeRate;
  const priceBeforeDiscount = costInILS * multiplier;
  
  // Apply discount if provided
  const discountMultiplier = discountPercentage > 0 ? (1 - discountPercentage / 100) : 1;
  const finalPrice = priceBeforeDiscount * discountMultiplier;
  
  // Round to 4 decimal places
  return Math.round(finalPrice * 10000) / 10000;
};

/**
 * Get SMS price for a doctor (with their specific multiplier and discount if set)
 */
export const getSMSPriceForDoctor = async (
  doctorId: string,
  db: any
): Promise<{ price: number; currency: string; twilioCost: number; multiplier: number; discountPercentage: number; hasDiscount: boolean; priceBeforeDiscount?: number }> => {
  try {
    const settings = await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .first();

    if (!settings) {
      // Use defaults
      const twilioCost = getTwilioSMSCost();
      const multiplier = DEFAULT_PRICE_MULTIPLIER;
      const price = calculateSMSPrice(twilioCost, multiplier);
      
      return {
        price,
        currency: 'ILS',
        twilioCost,
        multiplier,
        discountPercentage: 0,
        hasDiscount: false,
      };
    }

    // Use doctor's settings or defaults
    const twilioCost = parseFloat(settings.twilio_base_cost?.toString() || DEFAULT_TWILIO_COST_USD.toString());
    const multiplier = parseFloat(settings.price_multiplier?.toString() || DEFAULT_PRICE_MULTIPLIER.toString());
    const exchangeRate = getUSDToILSRate();
    const discountPercentage = settings.has_discount && settings.discount_percentage 
      ? parseFloat(settings.discount_percentage.toString()) 
      : 0;
    const hasDiscount = settings.has_discount === true && discountPercentage > 0;
    
    // Calculate price before discount
    const priceBeforeDiscount = calculateSMSPrice(twilioCost, multiplier, exchangeRate, 0);
    
    // Calculate final price with discount
    const price = calculateSMSPrice(twilioCost, multiplier, exchangeRate, discountPercentage);
    const currency = settings.currency || 'ILS';

    return {
      price,
      currency,
      twilioCost,
      multiplier,
      discountPercentage,
      hasDiscount,
      priceBeforeDiscount: hasDiscount ? priceBeforeDiscount : undefined,
    };
  } catch (error: any) {
    logger.error(`Error calculating SMS price for doctor ${doctorId}:`, error.message);
    
    // Fallback to defaults
    const twilioCost = getTwilioSMSCost();
    const multiplier = DEFAULT_PRICE_MULTIPLIER;
    const price = calculateSMSPrice(twilioCost, multiplier);
    
    return {
      price,
      currency: 'ILS',
      twilioCost,
      multiplier,
      discountPercentage: 0,
      hasDiscount: false,
    };
  }
};

/**
 * Update SMS cost per message for a doctor based on current Twilio pricing
 */
export const updateDoctorSMSCost = async (
  doctorId: string,
  db: any
): Promise<void> => {
  try {
    const priceInfo = await getSMSPriceForDoctor(doctorId, db);
    
    await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .update({
        sms_cost_per_message: priceInfo.price,
        updated_at: new Date(),
      });
    
    logger.debug(`Updated SMS cost for doctor ${doctorId}: ${priceInfo.price} ${priceInfo.currency}`);
  } catch (error: any) {
    logger.error(`Error updating SMS cost for doctor ${doctorId}:`, error.message);
  }
};

