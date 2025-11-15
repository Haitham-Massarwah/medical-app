"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ComplianceService = void 0;
const crypto_1 = __importDefault(require("crypto"));
const database_1 = __importDefault(require("../config/database"));
const logger_1 = require("../config/logger");
const apiError_1 = require("../utils/apiError");
class ComplianceService {
    constructor() {
        this.algorithm = 'aes-256-gcm';
        this.encryptionKey = process.env.ENCRYPTION_KEY || this.generateKey();
    }
    /**
     * Generate encryption key
     */
    generateKey() {
        return crypto_1.default.randomBytes(32).toString('hex');
    }
    /**
     * Encrypt sensitive data
     */
    encrypt(text) {
        try {
            const iv = crypto_1.default.randomBytes(16);
            const cipher = crypto_1.default.createCipheriv(this.algorithm, Buffer.from(this.encryptionKey, 'hex'), iv);
            let encrypted = cipher.update(text, 'utf8', 'hex');
            encrypted += cipher.final('hex');
            const authTag = cipher.getAuthTag();
            return `${iv.toString('hex')}:${authTag.toString('hex')}:${encrypted}`;
        }
        catch (error) {
            logger_1.logger.error('Encryption error:', error);
            throw error;
        }
    }
    /**
     * Decrypt sensitive data
     */
    decrypt(encryptedText) {
        try {
            const parts = encryptedText.split(':');
            const iv = Buffer.from(parts[0], 'hex');
            const authTag = Buffer.from(parts[1], 'hex');
            const encrypted = parts[2];
            const decipher = crypto_1.default.createDecipheriv(this.algorithm, Buffer.from(this.encryptionKey, 'hex'), iv);
            decipher.setAuthTag(authTag);
            let decrypted = decipher.update(encrypted, 'hex', 'utf8');
            decrypted += decipher.final('utf8');
            return decrypted;
        }
        catch (error) {
            logger_1.logger.error('Decryption error:', error);
            throw error;
        }
    }
    /**
     * Log audit event (GDPR/HIPAA compliance)
     */
    async logAudit(params) {
        try {
            await (0, database_1.default)('audit_logs').insert({
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
            logger_1.logger.info(`Audit log created: ${params.action} on ${params.entityType}`);
        }
        catch (error) {
            logger_1.logger.error('Error logging audit event:', error);
        }
    }
    /**
     * Get user's personal data (GDPR Right to Access)
     */
    async getUserData(userId, tenantId) {
        try {
            // Get user data
            const user = await (0, database_1.default)('users')
                .where({ id: userId, tenant_id: tenantId })
                .first();
            // Get patient data if applicable
            const patient = await (0, database_1.default)('patients')
                .where({ user_id: userId, tenant_id: tenantId })
                .first();
            // Get doctor data if applicable
            const doctor = await (0, database_1.default)('doctors')
                .where({ user_id: userId, tenant_id: tenantId })
                .first();
            // Get appointments
            const appointments = await (0, database_1.default)('appointments')
                .where({ patient_id: patient?.id, tenant_id: tenantId })
                .orWhere({ doctor_id: doctor?.id, tenant_id: tenantId });
            // Get payments
            const payments = await (0, database_1.default)('payments')
                .where({ patient_id: patient?.id, tenant_id: tenantId });
            // Get medical records
            const medicalRecords = await (0, database_1.default)('medical_records')
                .where({ patient_id: patient?.id, tenant_id: tenantId });
            // Get notifications
            const notifications = await (0, database_1.default)('notifications')
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
        }
        catch (error) {
            logger_1.logger.error('Error getting user data:', error);
            throw new apiError_1.ApiError(500, 'Failed to retrieve user data');
        }
    }
    /**
     * Delete user data (GDPR Right to Erasure)
     */
    async deleteUserData(userId, tenantId) {
        try {
            await database_1.default.transaction(async (trx) => {
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
            logger_1.logger.info(`User data deleted/anonymized: ${userId}`);
        }
        catch (error) {
            logger_1.logger.error('Error deleting user data:', error);
            throw new apiError_1.ApiError(500, 'Failed to delete user data');
        }
    }
    /**
     * Export user data (GDPR Data Portability)
     */
    async exportUserData(userId, tenantId) {
        try {
            const data = await this.getUserData(userId, tenantId);
            // Convert to JSON format
            const exportData = {
                exportDate: new Date().toISOString(),
                userId,
                data,
            };
            logger_1.logger.info(`User data exported: ${userId}`);
            return exportData;
        }
        catch (error) {
            logger_1.logger.error('Error exporting user data:', error);
            throw new apiError_1.ApiError(500, 'Failed to export user data');
        }
    }
    /**
     * Implement data retention policy
     */
    async enforceDataRetention() {
        try {
            const retentionDays = parseInt(process.env.DATA_RETENTION_DAYS || '2555'); // ~7 years
            const cutoffDate = new Date();
            cutoffDate.setDate(cutoffDate.getDate() - retentionDays);
            // Delete old audit logs
            const deletedLogs = await (0, database_1.default)('audit_logs')
                .where('created_at', '<', cutoffDate)
                .delete();
            logger_1.logger.info(`Data retention: Deleted ${deletedLogs} old audit logs`);
            // Delete old notifications
            const deletedNotifications = await (0, database_1.default)('notifications')
                .where('created_at', '<', cutoffDate)
                .where({ is_read: true })
                .delete();
            logger_1.logger.info(`Data retention: Deleted ${deletedNotifications} old notifications`);
        }
        catch (error) {
            logger_1.logger.error('Error enforcing data retention:', error);
        }
    }
    /**
     * Get audit logs for compliance reporting
     */
    async getAuditLogs(params) {
        const { tenantId, startDate, endDate, userId, entityType, action, page, limit } = params;
        let query = (0, database_1.default)('audit_logs').where({ tenant_id: tenantId });
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
    anonymizeSensitiveData(obj, sensitiveFields) {
        if (!obj)
            return obj;
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
    async checkConsent(userId, tenantId, consentType) {
        try {
            const user = await (0, database_1.default)('users')
                .where({ id: userId, tenant_id: tenantId })
                .first();
            if (!user || !user.preferences) {
                return false;
            }
            return user.preferences[`consent_${consentType}`] === true;
        }
        catch (error) {
            logger_1.logger.error('Error checking consent:', error);
            return false;
        }
    }
    /**
     * Update consent preferences
     */
    async updateConsent(userId, tenantId, consents) {
        try {
            const user = await (0, database_1.default)('users')
                .where({ id: userId, tenant_id: tenantId })
                .first();
            const preferences = user.preferences || {};
            Object.keys(consents).forEach((key) => {
                preferences[`consent_${key}`] = consents[key];
            });
            await (0, database_1.default)('users')
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
            logger_1.logger.info(`Consent updated for user: ${userId}`);
        }
        catch (error) {
            logger_1.logger.error('Error updating consent:', error);
            throw new apiError_1.ApiError(500, 'Failed to update consent');
        }
    }
}
exports.ComplianceService = ComplianceService;
//# sourceMappingURL=compliance.service.js.map