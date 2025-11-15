"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TenantController = void 0;
const errorHandler_1 = require("../middleware/errorHandler");
const database_1 = __importDefault(require("../config/database"));
const logger_1 = require("../config/logger");
class TenantController {
    constructor() {
        /**
         * Get all tenants (Developer only)
         * GET /api/v1/tenants
         */
        this.getAllTenants = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { page, limit, offset } = req.pagination;
            const { search, is_active } = req.query;
            let query = (0, database_1.default)('tenants').where('deleted_at', null);
            // Search by name or subdomain
            if (search) {
                query = query.andWhere(function () {
                    this.where('name', 'ilike', `%${search}%`)
                        .orWhere('subdomain', 'ilike', `%${search}%`);
                });
            }
            // Filter by status
            if (is_active !== undefined) {
                query = query.andWhere({ is_active: is_active === 'true' });
            }
            const [{ count }] = await query.clone().count('* as count');
            const tenants = await query
                .orderBy('created_at', 'desc')
                .limit(limit)
                .offset(offset);
            res.status(200).json({
                status: 'success',
                data: {
                    tenants,
                    pagination: {
                        page,
                        limit,
                        total: parseInt(count),
                        pages: Math.ceil(parseInt(count) / limit),
                    },
                },
            });
        });
        /**
         * Get current tenant
         * GET /api/v1/tenants/current
         */
        this.getCurrentTenant = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const tenant = await (0, database_1.default)('tenants')
                .where({ id: tenantId })
                .andWhere('deleted_at', null)
                .first();
            if (!tenant) {
                throw new errorHandler_1.NotFoundError('Tenant');
            }
            res.status(200).json({
                status: 'success',
                data: {
                    tenant,
                },
            });
        });
        /**
         * Get tenant by ID
         * GET /api/v1/tenants/:id
         */
        this.getTenantById = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const tenant = await (0, database_1.default)('tenants')
                .where({ id })
                .andWhere('deleted_at', null)
                .first();
            if (!tenant) {
                throw new errorHandler_1.NotFoundError('Tenant');
            }
            res.status(200).json({
                status: 'success',
                data: {
                    tenant,
                },
            });
        });
        /**
         * Create tenant
         * POST /api/v1/tenants
         */
        this.createTenant = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { name, subdomain, contact_email, contact_phone, address, city, country, timezone = 'UTC', plan = 'starter', } = req.body;
            // Check if subdomain is already taken
            const existing = await (0, database_1.default)('tenants')
                .where({ subdomain })
                .andWhere('deleted_at', null)
                .first();
            if (existing) {
                throw new errorHandler_1.ValidationError('Subdomain is already taken');
            }
            const [tenant] = await (0, database_1.default)('tenants')
                .insert({
                name,
                subdomain,
                contact_email,
                contact_phone,
                address,
                city,
                country,
                timezone,
                plan,
                is_active: true,
                created_at: new Date(),
                updated_at: new Date(),
            })
                .returning('*');
            logger_1.logger.info(`Tenant created: ${tenant.id} (${name})`);
            res.status(201).json({
                status: 'success',
                message: 'Tenant created successfully',
                data: {
                    tenant,
                },
            });
        });
        /**
         * Update tenant
         * PUT /api/v1/tenants/:id
         */
        this.updateTenant = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const updateData = {
                ...req.body,
                updated_at: new Date(),
            };
            const [tenant] = await (0, database_1.default)('tenants')
                .where({ id })
                .andWhere('deleted_at', null)
                .update(updateData)
                .returning('*');
            if (!tenant) {
                throw new errorHandler_1.NotFoundError('Tenant');
            }
            logger_1.logger.info(`Tenant updated: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Tenant updated successfully',
                data: {
                    tenant,
                },
            });
        });
        /**
         * Update tenant settings
         * PUT /api/v1/tenants/:id/settings
         */
        this.updateSettings = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const settings = {
                booking_advance_days: req.body.booking_advance_days,
                booking_buffer_minutes: req.body.booking_buffer_minutes,
                cancellation_hours: req.body.cancellation_hours,
                default_appointment_duration: req.body.default_appointment_duration,
                working_hours_start: req.body.working_hours_start,
                working_hours_end: req.body.working_hours_end,
                enable_online_payments: req.body.enable_online_payments,
                enable_sms_reminders: req.body.enable_sms_reminders,
                enable_email_reminders: req.body.enable_email_reminders,
                enable_whatsapp_reminders: req.body.enable_whatsapp_reminders,
            };
            const [tenant] = await (0, database_1.default)('tenants')
                .where({ id })
                .andWhere('deleted_at', null)
                .update({
                settings: JSON.stringify(settings),
                updated_at: new Date(),
            })
                .returning('*');
            if (!tenant) {
                throw new errorHandler_1.NotFoundError('Tenant');
            }
            logger_1.logger.info(`Tenant settings updated: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Tenant settings updated successfully',
                data: {
                    tenant,
                },
            });
        });
        /**
         * Update tenant branding
         * PUT /api/v1/tenants/:id/branding
         */
        this.updateBranding = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const { logo_url, primary_color, secondary_color, favicon_url } = req.body;
            const branding = {
                logo_url,
                primary_color,
                secondary_color,
                favicon_url,
            };
            const [tenant] = await (0, database_1.default)('tenants')
                .where({ id })
                .andWhere('deleted_at', null)
                .update({
                branding: JSON.stringify(branding),
                updated_at: new Date(),
            })
                .returning('*');
            if (!tenant) {
                throw new errorHandler_1.NotFoundError('Tenant');
            }
            logger_1.logger.info(`Tenant branding updated: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Tenant branding updated successfully',
                data: {
                    tenant,
                },
            });
        });
        /**
         * Update tenant plan
         * PUT /api/v1/tenants/:id/plan
         */
        this.updatePlan = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const { plan, billing_cycle = 'monthly' } = req.body;
            const [tenant] = await (0, database_1.default)('tenants')
                .where({ id })
                .andWhere('deleted_at', null)
                .update({
                plan,
                billing_cycle,
                updated_at: new Date(),
            })
                .returning('*');
            if (!tenant) {
                throw new errorHandler_1.NotFoundError('Tenant');
            }
            logger_1.logger.info(`Tenant plan updated: ${id} -> ${plan}`);
            res.status(200).json({
                status: 'success',
                message: 'Tenant plan updated successfully',
                data: {
                    tenant,
                },
            });
        });
        /**
         * Update tenant status
         * PUT /api/v1/tenants/:id/status
         */
        this.updateStatus = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const { is_active, reason } = req.body;
            const [tenant] = await (0, database_1.default)('tenants')
                .where({ id })
                .andWhere('deleted_at', null)
                .update({
                is_active,
                updated_at: new Date(),
            })
                .returning('*');
            if (!tenant) {
                throw new errorHandler_1.NotFoundError('Tenant');
            }
            logger_1.logger.info(`Tenant status updated: ${id} -> ${is_active ? 'active' : 'inactive'}`);
            res.status(200).json({
                status: 'success',
                message: `Tenant ${is_active ? 'activated' : 'suspended'} successfully`,
                data: {
                    tenant,
                },
            });
        });
        /**
         * Delete tenant (soft delete)
         * DELETE /api/v1/tenants/:id
         */
        this.deleteTenant = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            await (0, database_1.default)('tenants')
                .where({ id })
                .update({
                deleted_at: new Date(),
                updated_at: new Date(),
            });
            logger_1.logger.info(`Tenant deleted: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Tenant deleted successfully',
            });
        });
        /**
         * Get tenant statistics
         * GET /api/v1/tenants/:id/statistics
         */
        this.getTenantStatistics = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            // Get various statistics
            const [userCount] = await (0, database_1.default)('users')
                .where({ tenant_id: id })
                .andWhere('deleted_at', null)
                .count('* as count');
            const [doctorCount] = await (0, database_1.default)('doctors')
                .where({ tenant_id: id })
                .andWhere('deleted_at', null)
                .count('* as count');
            const [patientCount] = await (0, database_1.default)('patients')
                .where({ tenant_id: id })
                .andWhere('deleted_at', null)
                .count('* as count');
            const appointmentCountResult = await (0, database_1.default)('appointments')
                .where({ tenant_id: id })
                .count('* as count');
            const appointmentCount = appointmentCountResult[0];
            const revenueResult = await (0, database_1.default)('payments')
                .where({ tenant_id: id })
                .andWhere('status', 'succeeded')
                .sum('amount as total_revenue')
                .first();
            const revenueData = revenueResult;
            res.status(200).json({
                status: 'success',
                data: {
                    statistics: {
                        total_users: parseInt(userCount.count),
                        total_doctors: parseInt(doctorCount.count),
                        total_patients: parseInt(patientCount.count),
                        total_appointments: parseInt(appointmentCount.count),
                        total_revenue: revenueData?.total_revenue || 0,
                    },
                },
            });
        });
    }
}
exports.TenantController = TenantController;
//# sourceMappingURL=tenant.controller.js.map