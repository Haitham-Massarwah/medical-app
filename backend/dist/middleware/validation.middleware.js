"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateRefundCreate = exports.validatePaymentCreate = exports.validateAppointmentUpdate = exports.validateAppointmentCreate = exports.validateRequest = void 0;
const express_validator_1 = require("express-validator");
const apiError_1 = require("../utils/apiError");
// Generic validation middleware for express-validator
const validateRequest = (req, _res, next) => {
    const errors = (0, express_validator_1.validationResult)(req);
    if (!errors.isEmpty()) {
        const errorMessages = errors.array().map((error) => error.msg).join(', ');
        return next(new apiError_1.ValidationError(errorMessages));
    }
    next();
};
exports.validateRequest = validateRequest;
// Appointment validation
const validateAppointmentCreate = (req, _res, next) => {
    const { patient_id, doctor_id, appointment_date, start_time, end_time } = req.body;
    if (!patient_id || !doctor_id || !appointment_date || !start_time || !end_time) {
        return next(new apiError_1.ValidationError('Missing required fields for appointment creation'));
    }
    next();
};
exports.validateAppointmentCreate = validateAppointmentCreate;
const validateAppointmentUpdate = (req, _res, next) => {
    const { status, appointment_date, start_time, end_time } = req.body;
    if (!status && !appointment_date && !start_time && !end_time) {
        return next(new apiError_1.ValidationError('At least one field must be provided for update'));
    }
    if (status && !['scheduled', 'confirmed', 'cancelled', 'completed', 'no-show'].includes(status)) {
        return next(new apiError_1.ValidationError('Invalid status value'));
    }
    next();
};
exports.validateAppointmentUpdate = validateAppointmentUpdate;
// Payment validation
const validatePaymentCreate = (req, _res, next) => {
    const { appointment_id, amount, payment_method } = req.body;
    if (!appointment_id || !amount || !payment_method) {
        return next(new apiError_1.ValidationError('Missing required fields for payment creation'));
    }
    if (amount <= 0) {
        return next(new apiError_1.ValidationError('Amount must be greater than 0'));
    }
    if (!['credit_card', 'debit_card', 'cash', 'insurance'].includes(payment_method)) {
        return next(new apiError_1.ValidationError('Invalid payment method'));
    }
    next();
};
exports.validatePaymentCreate = validatePaymentCreate;
const validateRefundCreate = (req, _res, next) => {
    const { payment_id, amount, reason } = req.body;
    if (!payment_id || !amount || !reason) {
        return next(new apiError_1.ValidationError('Missing required fields for refund'));
    }
    if (amount <= 0) {
        return next(new apiError_1.ValidationError('Refund amount must be greater than 0'));
    }
    next();
};
exports.validateRefundCreate = validateRefundCreate;
//# sourceMappingURL=validation.middleware.js.map