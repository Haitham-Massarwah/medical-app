"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.patientController = exports.PatientController = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const errorHandler_1 = require("../middleware/errorHandler");
const database_1 = __importDefault(require("../config/database"));
const logger_1 = require("../config/logger");
class PatientController {
    constructor() {
        /**
         * Get all patients
         * GET /api/v1/patients
         */
        this.getAllPatients = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const { page, limit, offset } = req.pagination;
            const { search, blood_type } = req.query;
            let query = (0, database_1.default)('patients')
                .join('users', 'patients.user_id', 'users.id')
                .where('patients.tenant_id', tenantId)
                .andWhere('patients.deleted_at', null);
            if (search) {
                query = query.andWhere(function () {
                    this.where('users.first_name', 'ilike', `%${search}%`)
                        .orWhere('users.last_name', 'ilike', `%${search}%`)
                        .orWhere('users.email', 'ilike', `%${search}%`);
                });
            }
            if (blood_type) {
                query = query.andWhere('patients.blood_type', blood_type);
            }
            const [{ count }] = await query.clone().count('patients.id as count');
            const patients = await query
                .select('patients.*', 'users.first_name', 'users.last_name', 'users.email', 'users.phone', 'users.date_of_birth', 'users.gender')
                .orderBy('patients.created_at', 'desc')
                .limit(limit)
                .offset(offset);
            res.status(200).json({
                status: 'success',
                data: {
                    patients,
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
         * Get patient by ID
         * GET /api/v1/patients/:id
         */
        this.getPatientById = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const tenantId = req.tenantId;
            const patient = await (0, database_1.default)('patients')
                .join('users', 'patients.user_id', 'users.id')
                .where('patients.id', id)
                .andWhere('patients.tenant_id', tenantId)
                .andWhere('patients.deleted_at', null)
                .select('patients.*', 'users.first_name', 'users.last_name', 'users.email', 'users.phone', 'users.date_of_birth', 'users.gender', 'users.address', 'users.city')
                .first();
            if (!patient) {
                throw new errorHandler_1.NotFoundError('Patient');
            }
            res.status(200).json({
                status: 'success',
                data: {
                    patient,
                },
            });
        });
        /**
         * Create patient (by doctor/admin only)
         * POST /api/v1/patients
         */
        this.createPatient = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const creatorRole = req.user?.role || '';
            // Only doctors, admins, and developers can create patients
            if (!['doctor', 'admin', 'developer'].includes(creatorRole)) {
                throw new errorHandler_1.AuthorizationError('Only doctors and administrators can create patient accounts');
            }
            const { email, password, first_name, last_name, phone, date_of_birth, gender, address, city, blood_type, height, weight, allergies, chronic_conditions, current_medications, emergency_contact_name, emergency_contact_phone, insurance_provider, insurance_number, } = req.body;
            // Check if user already exists
            const existingUser = await (0, database_1.default)('users')
                .where({ email, tenant_id: tenantId })
                .andWhere('deleted_at', null)
                .first();
            if (existingUser) {
                throw new errorHandler_1.ValidationError('Email already registered');
            }
            // Hash password
            const hashedPassword = await bcryptjs_1.default.hash(password || 'TempPassword123!', 12);
            // Begin transaction
            const result = await database_1.default.transaction(async (trx) => {
                // Create user
                const [user] = await trx('users')
                    .insert({
                    email,
                    password_hash: hashedPassword,
                    first_name,
                    last_name,
                    phone,
                    date_of_birth,
                    gender,
                    address,
                    city,
                    role: 'patient',
                    tenant_id: tenantId,
                    is_active: true,
                    email_verified: true, // Auto-verify when created by doctor
                    created_at: new Date(),
                    updated_at: new Date(),
                })
                    .returning('*');
                // Create patient profile
                const [patient] = await trx('patients')
                    .insert({
                    user_id: user.id,
                    tenant_id: tenantId,
                    blood_type,
                    height,
                    weight,
                    allergies: allergies || [],
                    chronic_conditions: chronic_conditions || [],
                    current_medications: current_medications || [],
                    emergency_contact_name,
                    emergency_contact_phone,
                    insurance_provider,
                    insurance_number,
                    created_at: new Date(),
                    updated_at: new Date(),
                })
                    .returning('*');
                return { user, patient };
            });
            logger_1.logger.info(`Patient created by ${creatorRole}: ${result.patient.id}`);
            res.status(201).json({
                status: 'success',
                message: 'Patient account created successfully',
                data: {
                    patient: result.patient,
                    user: {
                        id: result.user.id,
                        email: result.user.email,
                        first_name: result.user.first_name,
                        last_name: result.user.last_name,
                    },
                },
            });
        });
        /**
         * Update patient profile
         * PUT /api/v1/patients/:id
         */
        this.updatePatient = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const tenantId = req.tenantId;
            const updateData = {
                ...req.body,
                updated_at: new Date(),
            };
            const [patient] = await (0, database_1.default)('patients')
                .where({ id, tenant_id: tenantId })
                .andWhere('deleted_at', null)
                .update(updateData)
                .returning('*');
            if (!patient) {
                throw new errorHandler_1.NotFoundError('Patient');
            }
            logger_1.logger.info(`Patient profile updated: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Patient profile updated successfully',
                data: {
                    patient,
                },
            });
        });
        /**
         * Delete patient (soft delete)
         * DELETE /api/v1/patients/:id
         */
        this.deletePatient = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const tenantId = req.tenantId;
            const patient = await (0, database_1.default)('patients')
                .where({ id, tenant_id: tenantId })
                .andWhere('deleted_at', null)
                .first();
            if (!patient) {
                throw new errorHandler_1.NotFoundError('Patient');
            }
            await (0, database_1.default)('patients')
                .where({ id })
                .update({ deleted_at: new Date() });
            logger_1.logger.info(`Patient soft deleted: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Patient deleted successfully',
            });
        });
    }
}
exports.PatientController = PatientController;
exports.patientController = new PatientController();
//# sourceMappingURL=patient.controller.js.map