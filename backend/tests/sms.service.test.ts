import { checkSMSServiceStatus } from '../src/services/sms.service';
import { calculateSMSPrice } from '../src/services/price-calculator.service';

describe('SMS Service Tests', () => {
  // No database needed for these tests - they test pure functions

  describe('calculateSMSPrice', () => {
    it('should calculate price correctly without discount', () => {
      const price = calculateSMSPrice(0.0075, 1.5, 3.7, 0);
      
      expect(price).toBeCloseTo(0.041625, 4); // (0.0075 * 3.7) * 1.5
    });

    it('should calculate price correctly with 10% discount', () => {
      const price = calculateSMSPrice(0.0075, 1.5, 3.7, 10);
      
      expect(price).toBeCloseTo(0.0374625, 4); // (0.0075 * 3.7) * 1.5 * 0.9
    });

    it('should handle zero Twilio cost', () => {
      const price = calculateSMSPrice(0, 1.5, 3.7, 0);
      
      expect(price).toBe(0);
    });
  });

  describe('checkSMSServiceStatus', () => {
    it('should return service status', () => {
      const status = checkSMSServiceStatus();
      
      expect(status).toHaveProperty('configured');
      expect(typeof status.configured).toBe('boolean');
      if (status.configured) {
        expect(status).toHaveProperty('accountSid');
        expect(status).toHaveProperty('phoneNumber');
      }
    });
  });
});

