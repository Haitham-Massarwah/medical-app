import { Request, Response, NextFunction } from 'express';
import { validationResult } from 'express-validator';
import { ValidationError } from '../utils/apiError';

// Generic validation middleware for express-validator
export const validateRequest = (req: Request, _res: Response, next: NextFunction) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map((error: any) => error.msg).join(', ');
    return next(new ValidationError(errorMessages));
  }
  next();
};

// Appointment validation
export const validateAppointmentCreate = (req: Request, _res: Response, next: NextFunction) => {
  const { patient_id, doctor_id, appointment_date, start_time, end_time } = req.body;

  if (!patient_id || !doctor_id || !appointment_date || !start_time || !end_time) {
    return next(new ValidationError('Missing required fields for appointment creation'));
  }

  next();
};

export const validateAppointmentUpdate = (req: Request, _res: Response, next: NextFunction) => {
  const { status, appointment_date, start_time, end_time } = req.body;

  if (!status && !appointment_date && !start_time && !end_time) {
    return next(new ValidationError('At least one field must be provided for update'));
  }

  if (status && !['scheduled', 'confirmed', 'cancelled', 'completed', 'no-show'].includes(status)) {
    return next(new ValidationError('Invalid status value'));
  }

  next();
};

// Payment validation
export const validatePaymentCreate = (req: Request, _res: Response, next: NextFunction) => {
  const { appointment_id, amount, payment_method } = req.body;

  if (!appointment_id || !amount || !payment_method) {
    return next(new ValidationError('Missing required fields for payment creation'));
  }

  if (amount <= 0) {
    return next(new ValidationError('Amount must be greater than 0'));
  }

  if (!['credit_card', 'debit_card', 'cash', 'insurance'].includes(payment_method)) {
    return next(new ValidationError('Invalid payment method'));
  }

  next();
};

export const validateRefundCreate = (req: Request, _res: Response, next: NextFunction) => {
  const { payment_id, amount, reason } = req.body;

  if (!payment_id || !amount || !reason) {
    return next(new ValidationError('Missing required fields for refund'));
  }

  if (amount <= 0) {
    return next(new ValidationError('Refund amount must be greater than 0'));
  }

  next();
};

