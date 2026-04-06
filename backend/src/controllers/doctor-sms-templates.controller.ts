import { Request, Response, NextFunction } from 'express';
import { asyncHandler, NotFoundError, ValidationError, AuthorizationError } from '../middleware/errorHandler';
import db from '../config/database';
import { logger } from '../config/logger';
import { getSMSTemplate, getDoctorLanguage, SMSType } from '../services/sms-templates.service';

export class DoctorSMSTemplatesController {
  /**
   * Get doctor SMS templates
   * GET /api/v1/doctors/:doctorId/sms/templates
   */
  getTemplates = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { doctorId } = req.params;
    const tenantId = req.tenantId!;
    const userId = req.user!.userId;

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
      throw new AuthorizationError('You do not have permission to access this doctor\'s SMS templates');
    }

    // Get SMS settings
    const settings = await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .first();

    if (!settings) {
      throw new NotFoundError('SMS settings not found. Please enable SMS service first.');
    }

    // Get doctor's preferred language
    const language = await getDoctorLanguage(doctorId);

    // Get custom templates or use defaults
    const customTemplates = settings.custom_templates || {};

    // Merge custom templates with defaults
    const templates: Record<string, Record<SMSType, string>> = {
      he: {
        reminder: customTemplates.he?.reminder || getSMSTemplate('reminder', 'he', {}),
        confirmation: customTemplates.he?.confirmation || getSMSTemplate('confirmation', 'he', {}),
        cancellation: customTemplates.he?.cancellation || getSMSTemplate('cancellation', 'he', {}),
        payment: customTemplates.he?.payment || getSMSTemplate('payment', 'he', {}),
        verification: customTemplates.he?.verification || getSMSTemplate('verification', 'he', {}),
        general: customTemplates.he?.general || getSMSTemplate('general', 'he', {}),
      },
      ar: {
        reminder: customTemplates.ar?.reminder || getSMSTemplate('reminder', 'ar', {}),
        confirmation: customTemplates.ar?.confirmation || getSMSTemplate('confirmation', 'ar', {}),
        cancellation: customTemplates.ar?.cancellation || getSMSTemplate('cancellation', 'ar', {}),
        payment: customTemplates.ar?.payment || getSMSTemplate('payment', 'ar', {}),
        verification: customTemplates.ar?.verification || getSMSTemplate('verification', 'ar', {}),
        general: customTemplates.ar?.general || getSMSTemplate('general', 'ar', {}),
      },
      en: {
        reminder: customTemplates.en?.reminder || getSMSTemplate('reminder', 'en', {}),
        confirmation: customTemplates.en?.confirmation || getSMSTemplate('confirmation', 'en', {}),
        cancellation: customTemplates.en?.cancellation || getSMSTemplate('cancellation', 'en', {}),
        payment: customTemplates.en?.payment || getSMSTemplate('payment', 'en', {}),
        verification: customTemplates.en?.verification || getSMSTemplate('verification', 'en', {}),
        general: customTemplates.en?.general || getSMSTemplate('general', 'en', {}),
      },
    };

    res.status(200).json({
      success: true,
      data: {
        templates,
        currentLanguage: language,
        customTemplates: customTemplates || {},
      },
    });
  });

  /**
   * Update doctor SMS template
   * PUT /api/v1/doctors/:doctorId/sms/templates
   */
  updateTemplate = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { doctorId } = req.params;
    const tenantId = req.tenantId!;
    const userId = req.user!.userId;
    const { language, smsType, template } = req.body;

    // Validate inputs
    if (!language || !['he', 'ar', 'en'].includes(language)) {
      throw new ValidationError('Language must be: he, ar, or en');
    }

    if (!smsType || !['reminder', 'confirmation', 'cancellation', 'payment', 'verification', 'general'].includes(smsType)) {
      throw new ValidationError('SMS type must be: reminder, confirmation, cancellation, payment, verification, or general');
    }

    if (!template || typeof template !== 'string') {
      throw new ValidationError('Template must be a non-empty string');
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
    const isAdmin = user!.role === 'admin' || user!.role === 'developer';
    const isDoctorOwner = doctor.user_id === userId;

    if (!isAdmin && !isDoctorOwner) {
      throw new AuthorizationError('You do not have permission to update this doctor\'s SMS templates');
    }

    // Get SMS settings
    let settings = await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .first();

    if (!settings) {
      throw new NotFoundError('SMS settings not found. Please enable SMS service first.');
    }

    // Get existing custom templates
    const customTemplates = settings.custom_templates || {};
    
    // Initialize language object if it doesn't exist
    if (!customTemplates[language]) {
      customTemplates[language] = {};
    }

    // Update template
    customTemplates[language][smsType] = template;

    // Update database
    [settings] = await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .update({
        custom_templates: customTemplates,
        updated_at: new Date(),
      })
      .returning('*');

    logger.info(`SMS template updated for doctor ${doctorId}: ${language}/${smsType}`);

    res.status(200).json({
      success: true,
      message: 'Template updated successfully',
      data: {
        language,
        smsType,
        template,
        customTemplates: settings.custom_templates,
      },
    });
  });

  /**
   * Reset template to default
   * DELETE /api/v1/doctors/:doctorId/sms/templates/:language/:smsType
   */
  resetTemplate = asyncHandler(async (req: Request, res: Response, next: NextFunction) => {
    const { doctorId, language, smsType } = req.params;
    const tenantId = req.tenantId!;
    const userId = req.user!.userId;

    // Validate inputs
    if (!['he', 'ar', 'en'].includes(language)) {
      throw new ValidationError('Language must be: he, ar, or en');
    }

    if (!['reminder', 'confirmation', 'cancellation', 'payment', 'verification', 'general'].includes(smsType)) {
      throw new ValidationError('SMS type must be: reminder, confirmation, cancellation, payment, verification, or general');
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
    const isAdmin = user!.role === 'admin' || user!.role === 'developer';
    const isDoctorOwner = doctor.user_id === userId;

    if (!isAdmin && !isDoctorOwner) {
      throw new AuthorizationError('You do not have permission to reset this doctor\'s SMS templates');
    }

    // Get SMS settings
    let settings = await db('doctor_sms_settings')
      .where({ doctor_id: doctorId })
      .first();

    if (!settings) {
      throw new NotFoundError('SMS settings not found. Please enable SMS service first.');
    }

    // Get existing custom templates
    const customTemplates = settings.custom_templates || {};
    
    // Remove custom template (will use default)
    if (customTemplates[language] && customTemplates[language][smsType]) {
      delete customTemplates[language][smsType];
      
      // Remove language object if empty
      if (Object.keys(customTemplates[language]).length === 0) {
        delete customTemplates[language];
      }

      // Update database
      [settings] = await db('doctor_sms_settings')
        .where({ doctor_id: doctorId })
        .update({
          custom_templates: customTemplates,
          updated_at: new Date(),
        })
        .returning('*');
    }

    logger.info(`SMS template reset to default for doctor ${doctorId}: ${language}/${smsType}`);

    res.status(200).json({
      success: true,
      message: 'Template reset to default successfully',
      data: {
        language,
        smsType,
        customTemplates: settings.custom_templates,
      },
    });
  });
}


