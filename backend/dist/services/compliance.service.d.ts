export declare class ComplianceService {
    private readonly algorithm;
    private readonly encryptionKey;
    /**
     * Generate encryption key
     */
    private generateKey;
    /**
     * Encrypt sensitive data
     */
    encrypt(text: string): string;
    /**
     * Decrypt sensitive data
     */
    decrypt(encryptedText: string): string;
    /**
     * Log audit event (GDPR/HIPAA compliance)
     */
    logAudit(params: {
        tenantId: string;
        userId?: string;
        action: string;
        entityType: string;
        entityId?: string;
        oldValues?: any;
        newValues?: any;
        ipAddress?: string;
        userAgent?: string;
    }): Promise<void>;
    /**
     * Get user's personal data (GDPR Right to Access)
     */
    getUserData(userId: string, tenantId: string): Promise<any>;
    /**
     * Delete user data (GDPR Right to Erasure)
     */
    deleteUserData(userId: string, tenantId: string): Promise<void>;
    /**
     * Export user data (GDPR Data Portability)
     */
    exportUserData(userId: string, tenantId: string): Promise<any>;
    /**
     * Implement data retention policy
     */
    enforceDataRetention(): Promise<void>;
    /**
     * Get audit logs for compliance reporting
     */
    getAuditLogs(params: {
        tenantId: string;
        startDate?: Date;
        endDate?: Date;
        userId?: string;
        entityType?: string;
        action?: string;
        page: number;
        limit: number;
    }): Promise<any>;
    /**
     * Anonymize sensitive data
     */
    private anonymizeSensitiveData;
    /**
     * Check consent for data processing (GDPR)
     */
    checkConsent(userId: string, tenantId: string, consentType: string): Promise<boolean>;
    /**
     * Update consent preferences
     */
    updateConsent(userId: string, tenantId: string, consents: Record<string, boolean>): Promise<void>;
}
//# sourceMappingURL=compliance.service.d.ts.map