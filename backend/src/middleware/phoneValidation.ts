import { body } from 'express-validator';

function loosePhoneChain(field: string) {
  return body(field)
    .optional({ values: 'falsy' })
    .trim()
    .custom((value) => {
      const digits = String(value).replace(/\D/g, '');
      if (digits.length >= 9 && digits.length <= 15) return true;
      throw new Error('Phone number format is invalid');
    });
}

/**
 * Israeli mobiles (e.g. 05XXXXXXXX) often fail validator.isMobilePhone('any').
 * Accept 9–15 digits after stripping non-digits.
 */
export const bodyOptionalLoosePhone = () => loosePhoneChain('phone');

export const bodyOptionalLooseEmergencyPhone = () => loosePhoneChain('emergency_contact_phone');

export const bodyOptionalLooseContactPhone = () => loosePhoneChain('contact_phone');
