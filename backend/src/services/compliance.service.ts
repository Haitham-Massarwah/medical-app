import crypto from 'crypto';
import db from '../config/database';
import { logger } from '../config/logger';
import { ApiError } from '../utils/apiError';

export class ComplianceService {
  private readonly algorithm = 'aes-256-gcm';
  private readonly encryptionKey = process.env.ENCRYPTION_KEY || this.generateKey();

  /**
   * Generate encryption key
   */
  private generateKey(): string {
    return crypto.randomBytes(32).toString('hex');
  }

  /**
   * Encrypt sensitive data
   */
  public encrypt(text: string): string {
    try {
      const iv = crypto.randomBytes(16);
      const cipher = crypto.createCipheriv(this.algorithm, Buffer.from(this.encryptionKey, 'hex'), iv);

      let encrypted = cipher.update(text, 'utf8', 'hex');
      encrypted += cipher.final('hex');

      const authTag = cipher.getAuthTag();

      return `${iv.toString('hex')}:${authTag.toString('hex')}:${encrypted}`;
    } catch (error) {
      logger.error('Encryption error:', error);
      throw error;
    }
  }

  /**
   * Decrypt sensitive data
   */
  public decrypt(encryptedText: string): string {
    try {
      const parts = encryptedText.split(':');
      const iv = Buffer.from(parts[0], 'hex');
      const authTag = Buffer.from(parts[1], 'hex');
      const encrypted = parts[2];

      const decipher = crypto.createDecipheriv(this.algorithm, Buffer.from(this.encryptionKey, 'hex'), iv);
      decipher.setAuthTag(authTag);

      let decrypted = decipher.update(encrypted, 'hex', 'utf8');
      decrypted += decipher.final('utf8');

      return decrypted;
    } catch (error) {
      logger.error('Decryption error:', error);
      throw error;
    }
  }

  /**
   * Log audit event (GDPR/HIPAA compliance)
   */
  public async logAudit(params: {
    tenantId: string;
    userId?: string;
    action: string;
    entityType: string;
    entityId?: string;
    oldValues?: any;
    newValues?: any;
    ipAddress?: string;
    userAgent?: string;
  }): Promise<void> {
    try {
      await db('audit_logs').insert({
        tenant_id: params.tenantId,
        user_id: params.userId,
        action: params.action,
        entity_type: params.entityType,
        entity_id: params.entityId,
        old_values: params.oldValues,
        new_values: params.newValues,
        ip_address: params.ipAddress,
        user_agent: params.userAgent,
      });

      logger.info(`Audit log created: ${params.action} on ${params.entityType}`);
    } catch (error) {
      logger.error('Error logging audit event:', error);
    }
  }

  /**
   * Get user's personal data (GDPR Right to Access)
   */
  public async getUserData(userId: string, tenantId: string): Promise<any> {
    try {
      // Get user data
      const user = await db('users')
        .where({ id: userId, tenant_id: tenantId })
        .first();

      // Get patient data if applicable
      const patient = await db('patients')
        .where({ user_id: userId, tenant_id: tenantId })
        .first();

      // Get doctor data if applicable
      const doctor = await db('doctors')
        .where({ user_id: userId, tenant_id: tenantId })
        .first();

      // Get appointments
      const appointments = await db('appointments')
        .where({ patient_id: patient?.id, tenant_id: tenantId })
        .orWhere({ doctor_id: doctor?.id, tenant_id: tenantId });

      // Get payments
      const payments = await db('payments')
        .where({ patient_id: patient?.id, tenant_id: tenantId });

      // Get medical records
      const medicalRecords = await db('medical_records')
        .where({ patient_id: patient?.id, tenant_id: tenantId });

      // Get notifications
      const notifications = await db('notifications')
        .where({ user_id: userId, tenant_id: tenantId });

      return {
        user: this.anonymizeSensitiveData(user, ['password_hash', 'two_factor_secret']),
        patient,
        doctor,
        appointments,
        payments,
        medicalRecords,
        notifications,
      };
    } catch (error) {
      logger.error('Error getting user data:', error);
      throw new ApiError(500, 'Failed to retrieve user data');
    }
  }

  /**
   * Delete user data (GDPR Right to Erasure)
   */
  public async deleteUserData(userId: string, tenantId: string): Promise<void> {
    try {
      await db.transaction(async (trx) => {
        // Anonymize instead of delete (for compliance)
        await trx('users')
          .where({ id: userId, tenant_id: tenantId })
          .update({
            email: `deleted_${userId}@anonymized.local`,
            first_name: 'Deleted',
            last_name: 'User',
            phone: null,
            profile_image_url: null,
            preferences: null,
            metadata: { deleted: true, deleted_at: new Date() },
            updated_at: new Date(),
          });

        // Anonymize patient data
        await trx('patients')
          .where({ user_id: userId, tenant_id: tenantId })
          .update({
            emergency_contact_name: null,
            emergency_contact_phone: null,
            insurance_provider: null,
            insurance_number: null,
            allergies: [],
            medications: [],
            medical_history: null,
            updated_at: new Date(),
          });

        // Log audit
        await trx('audit_logs').insert({
          tenant_id: tenantId,
          user_id: userId,
          action: 'DELETE_USER_DATA',
          entity_type: 'user',
          entity_id: userId,
        });
      });

      logger.info(`User data deleted/anonymized: ${userId}`);
    } catch (error) {
      logger.error('Error deleting user data:', error);
      throw new ApiError(500, 'Failed to delete user data');
    }
  }

  /**
   * Export user data (GDPR Data Portability)
   */
  public async exportUserData(userId: string, tenantId: string): Promise<any> {
    try {
      const data = await this.getUserData(userId, tenantId);

      // Convert to JSON format
      const exportData = {
        exportDate: new Date().toISOString(),
        userId,
        data,
      };

      logger.info(`User data exported: ${userId}`);

      return exportData;
    } catch (error) {
      logger.error('Error exporting user data:', error);
      throw new ApiError(500, 'Failed to export user data');
    }
  }

  /**
   * Implement data retention policy
   */
  public async enforceDataRetention(): Promise<void> {
    try {
      const retentionDays = parseInt(process.env.DATA_RETENTION_DAYS || '2555'); // ~7 years
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

      // Delete old audit logs
      const deletedLogs = await db('audit_logs')
        .where('created_at', '<', cutoffDate)
        .delete();

      logger.info(`Data retention: Deleted ${deletedLogs} old audit logs`);

      // Delete old notifications
      const deletedNotifications = await db('notifications')
        .where('created_at', '<', cutoffDate)
        .where({ is_read: true })
        .delete();

      logger.info(`Data retention: Deleted ${deletedNotifications} old notifications`);
    } catch (error) {
      logger.error('Error enforcing data retention:', error);
    }
  }

  /**
   * Get audit logs for compliance reporting
   */
  public async getAuditLogs(params: {
    tenantId: string;
    startDate?: Date;
    endDate?: Date;
    userId?: string;
    entityType?: string;
    action?: string;
    page: number;
    limit: number;
  }): Promise<any> {
    const { tenantId, startDate, endDate, userId, entityType, action, page, limit } = params;

    let query = db('audit_logs').where({ tenant_id: tenantId });

    if (startDate) {
      query = query.where('created_at', '>=', startDate);
    }
    if (endDate) {
      query = query.where('created_at', '<=', endDate);
    }
    if (userId) {
      query = query.where({ user_id: userId });
    }
    if (entityType) {
      query = query.where({ entity_type: entityType });
    }
    if (action) {
      query = query.where({ action });
    }

    const [{ count }] = await query.clone().count('* as count');

    const data = await query
      .orderBy('created_at', 'desc')
      .limit(limit)
      .offset((page - 1) * limit);

    return {
      data,
      page,
      limit,
      total: Number(count),
    };
  }

  /**
   * Anonymize sensitive data
   */
  private anonymizeSensitiveData(obj: any, sensitiveFields: string[]): any {
    if (!obj) return obj;

    const anonymized = { ...obj };
    sensitiveFields.forEach((field) => {
      if (anonymized[field]) {
        anonymized[field] = '[REDACTED]';
      }
    });

    return anonymized;
  }

  /**
   * Check consent for data processing (GDPR)
   */
  public async checkConsent(userId: string, tenantId: string, consentType: string): Promise<boolean> {
    try {
      const user = await db('users')
        .where({ id: userId, tenant_id: tenantId })
        .first();

      if (!user || !user.preferences) {
        return false;
      }

      return user.preferences[`consent_${consentType}`] === true;
    } catch (error) {
      logger.error('Error checking consent:', error);
      return false;
    }
  }

  /**
   * Update consent preferences
   */
  public async updateConsent(
    userId: string,
    tenantId: string,
    consents: Record<string, boolean>
  ): Promise<void> {
    try {
      const user = await db('users')
        .where({ id: userId, tenant_id: tenantId })
        .first();

      const preferences = user.preferences || {};
      Object.keys(consents).forEach((key) => {
        preferences[`consent_${key}`] = consents[key];
      });

      await db('users')
        .where({ id: userId, tenant_id: tenantId })
        .update({
          preferences,
          updated_at: new Date(),
        });

      // Log consent changes
      await this.logAudit({
        tenantId,
        userId,
        action: 'UPDATE_CONSENT',
        entityType: 'user',
        entityId: userId,
        newValues: consents,
      });

      logger.info(`Consent updated for user: ${userId}`);
    } catch (error) {
      logger.error('Error updating consent:', error);
      throw new ApiError(500, 'Failed to update consent');
    }
  }
}
