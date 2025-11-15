"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DoctorController = void 0;
const errorHandler_1 = require("../middleware/errorHandler");
const database_1 = __importDefault(require("../config/database"));
const logger_1 = require("../config/logger");
class DoctorController {
    constructor() {
        /**
         * Get all doctors
         * GET /api/v1/doctors
         */
        this.getAllDoctors = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { page, limit, offset } = req.pagination;
            const { specialty, language, search, city, area } = req.query;
            let query = (0, database_1.default)('doctors')
                .join('users', 'doctors.user_id', 'users.id')
                .where('doctors.is_active', true);
            // Filter by specialty
            if (specialty) {
                query = query.andWhere('doctors.specialty', 'ilike', `%${specialty}%`);
            }
            // Filter by city/area (if city column exists in users table)
            // Note: users table doesn't have city column in schema - removing for now
            // if (city) {
            //   query = query.andWhere('users.city', 'ilike', `%${city}%`);
            // }
            // if (area) {
            //   query = query.andWhere('users.city', 'ilike', `%${area}%`);
            // }
            // Filter by language
            if (language) {
                query = query.whereRaw('? = ANY(doctors.languages)', [language]);
            }
            // Search by name
            if (search) {
                query = query.andWhere(function () {
                    this.where('users.first_name', 'ilike', `%${search}%`)
                        .orWhere('users.last_name', 'ilike', `%${search}%`);
                });
            }
            // Get total count
            const countResult = await query.clone().count('doctors.id as count').first();
            const totalCount = countResult ? parseInt(String(countResult.count)) : 0;
            // Get doctors
            const doctors = await query
                .select('doctors.id', 'doctors.user_id', 'users.first_name', 'users.last_name', 'users.email', 'users.phone', 'doctors.specialty', 'doctors.specialty as specialty_name', 'doctors.license_number', 'doctors.bio', 'doctors.rating', 'doctors.review_count as total_reviews', 'doctors.languages')
                .orderBy('doctors.rating', 'desc')
                .limit(limit)
                .offset(offset);
            res.status(200).json({
                status: 'success',
                data: {
                    doctors,
                    pagination: {
                        page,
                        limit,
                        total: totalCount,
                        pages: Math.ceil(totalCount / limit),
                    },
                },
            });
        });
        /**
         * Search doctors
         * GET /api/v1/doctors/search
         */
        this.searchDoctors = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { page, limit, offset } = req.pagination;
            const { q, specialty, min_rating, max_fee } = req.query;
            let query = (0, database_1.default)('doctors')
                .join('users', 'doctors.user_id', 'users.id')
                .where('doctors.is_active', true);
            // Search query
            if (q) {
                query = query.andWhere(function () {
                    this.where('users.first_name', 'ilike', `%${q}%`)
                        .orWhere('users.last_name', 'ilike', `%${q}%`)
                        .orWhere('doctors.specialty', 'ilike', `%${q}%`)
                        .orWhere('doctors.bio', 'ilike', `%${q}%`);
                });
            }
            // Filters
            if (specialty)
                query = query.andWhere('doctors.specialty', 'ilike', `%${specialty}%`);
            if (min_rating)
                query = query.andWhere('doctors.rating', '>=', min_rating);
            // Note: consultation_fee doesn't exist in schema - removed filter
            // if (max_fee) query = query.andWhere('doctors.consultation_fee', '<=', max_fee);
            const countResult = await query.clone().count('doctors.id as count').first();
            const totalCount = countResult ? parseInt(String(countResult.count)) : 0;
            const doctors = await query
                .select('doctors.id', 'users.first_name', 'users.last_name', 'doctors.specialty as specialty_name', 'doctors.rating', 'doctors.review_count as total_reviews')
                .orderBy('doctors.rating', 'desc')
                .limit(limit)
                .offset(offset);
            res.status(200).json({
                status: 'success',
                data: {
                    doctors,
                    pagination: {
                        page,
                        limit,
                        total: totalCount,
                        pages: Math.ceil(totalCount / limit),
                    },
                },
            });
        });
        /**
         * Get doctor by ID
         * GET /api/v1/doctors/:id
         */
        this.getDoctorById = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const doctor = await (0, database_1.default)('doctors')
                .join('users', 'doctors.user_id', 'users.id')
                .where('doctors.id', id)
                .andWhere('doctors.is_active', true)
                .select('doctors.*', 'users.first_name', 'users.last_name', 'users.email', 'users.phone', 'doctors.specialty as specialty_name')
                .first();
            if (!doctor) {
                throw new errorHandler_1.NotFoundError('Doctor');
            }
            res.status(200).json({
                status: 'success',
                data: {
                    doctor,
                },
            });
        });
        /**
         * Get doctor availability
         * GET /api/v1/doctors/:id/availability
         */
        this.getDoctorAvailability = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const { date } = req.query;
            // Verify doctor exists
            const doctor = await (0, database_1.default)('doctors')
                .where({ id })
                .andWhere('deleted_at', null)
                .first();
            if (!doctor) {
                throw new errorHandler_1.NotFoundError('Doctor');
            }
            // Get working hours
            const workingHours = await (0, database_1.default)('doctor_working_hours')
                .where({ doctor_id: id });
            // Get appointments for the date (if provided)
            let bookedSlots = [];
            if (date) {
                bookedSlots = await (0, database_1.default)('appointments')
                    .where({ doctor_id: id })
                    .andWhere('appointment_date', date)
                    .andWhere('status', 'confirmed')
                    .select('start_time', 'end_time');
            }
            res.status(200).json({
                status: 'success',
                data: {
                    working_hours: workingHours,
                    booked_slots: bookedSlots,
                },
            });
        });
        /**
         * Get doctor reviews
         * GET /api/v1/doctors/:id/reviews
         */
        this.getDoctorReviews = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const { page, limit, offset } = req.pagination;
            const countResult = await (0, database_1.default)('reviews')
                .where({ doctor_id: id })
                .count('* as count')
                .first();
            const totalCount = countResult ? parseInt(String(countResult.count)) : 0;
            const reviews = await (0, database_1.default)('reviews')
                .join('users', 'reviews.patient_id', 'users.id')
                .where('reviews.doctor_id', id)
                .select('reviews.id', 'reviews.rating', 'reviews.comment', 'reviews.created_at', 'users.first_name', 'users.last_name')
                .orderBy('reviews.created_at', 'desc')
                .limit(limit)
                .offset(offset);
            res.status(200).json({
                status: 'success',
                data: {
                    reviews,
                    pagination: {
                        page,
                        limit,
                        total: totalCount,
                        pages: Math.ceil(totalCount / limit),
                    },
                },
            });
        });
        /**
         * Create doctor
         * POST /api/v1/doctors
         */
        this.createDoctor = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const tenantId = req.tenantId;
            const { user_id, specialty_id, license_number, years_of_experience, bio, education, certifications, languages, consultation_fee, } = req.body;
            const [doctor] = await (0, database_1.default)('doctors')
                .insert({
                user_id,
                tenant_id: tenantId,
                specialty: req.body.specialty || specialty_id || 'General',
                license_number,
                bio,
                education,
                certifications,
                languages,
                rating: 0,
                review_count: 0,
                created_at: new Date(),
                updated_at: new Date(),
            })
                .returning('*');
            logger_1.logger.info(`Doctor created: ${doctor.id}`);
            res.status(201).json({
                status: 'success',
                message: 'Doctor profile created successfully',
                data: {
                    doctor,
                },
            });
        });
        /**
         * Update doctor
         * PUT /api/v1/doctors/:id
         */
        this.updateDoctor = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const tenantId = req.tenantId;
            const updateData = {
                ...req.body,
                updated_at: new Date(),
            };
            const [doctor] = await (0, database_1.default)('doctors')
                .where({ id, tenant_id: tenantId })
                .andWhere('deleted_at', null)
                .update(updateData)
                .returning('*');
            if (!doctor) {
                throw new errorHandler_1.NotFoundError('Doctor');
            }
            logger_1.logger.info(`Doctor updated: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Doctor profile updated successfully',
                data: {
                    doctor,
                },
            });
        });
        /**
         * Update doctor schedule
         * PUT /api/v1/doctors/:id/schedule
         */
        this.updateSchedule = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const { working_hours } = req.body;
            // Delete existing schedule
            await (0, database_1.default)('doctor_working_hours')
                .where({ doctor_id: id })
                .delete();
            // Insert new schedule
            const scheduleData = working_hours.map((slot) => ({
                doctor_id: id,
                day_of_week: slot.day_of_week,
                start_time: slot.start_time,
                end_time: slot.end_time,
                created_at: new Date(),
                updated_at: new Date(),
            }));
            await (0, database_1.default)('doctor_working_hours').insert(scheduleData);
            logger_1.logger.info(`Doctor schedule updated: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Doctor schedule updated successfully',
            });
        });
        /**
         * Add time off
         * POST /api/v1/doctors/:id/time-off
         */
        this.addTimeOff = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const { start_date, end_date, reason } = req.body;
            const [timeOff] = await (0, database_1.default)('doctor_time_off')
                .insert({
                doctor_id: id,
                start_date,
                end_date,
                reason,
                created_at: new Date(),
                updated_at: new Date(),
            })
                .returning('*');
            logger_1.logger.info(`Time off added for doctor: ${id}`);
            res.status(201).json({
                status: 'success',
                message: 'Time off added successfully',
                data: {
                    time_off: timeOff,
                },
            });
        });
        /**
         * Delete doctor
         * DELETE /api/v1/doctors/:id
         */
        this.deleteDoctor = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            await (0, database_1.default)('doctors')
                .where({ id })
                .update({
                is_active: false,
                updated_at: new Date(),
            });
            logger_1.logger.info(`Doctor deleted: ${id}`);
            res.status(200).json({
                status: 'success',
                message: 'Doctor deleted successfully',
            });
        });
        /**
         * Get doctor appointments
         * GET /api/v1/doctors/:id/appointments
         */
        this.getDoctorAppointments = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const { page, limit, offset } = req.pagination;
            const { status, date } = req.query;
            let query = (0, database_1.default)('appointments')
                .where({ doctor_id: id });
            if (status)
                query = query.andWhere({ status });
            if (date)
                query = query.andWhere('appointment_date', date);
            const countResult = await query.clone().count('* as count').first();
            const totalCount = countResult ? parseInt(String(countResult.count)) : 0;
            const appointments = await query
                .join('users', 'appointments.patient_id', 'users.id')
                .select('appointments.*', 'users.first_name as patient_first_name', 'users.last_name as patient_last_name')
                .orderBy('appointments.appointment_date', 'desc')
                .limit(limit)
                .offset(offset);
            res.status(200).json({
                status: 'success',
                data: {
                    appointments,
                    pagination: {
                        page,
                        limit,
                        total: totalCount,
                        pages: Math.ceil(totalCount / limit),
                    },
                },
            });
        });
        /**
         * Get doctor statistics
         * GET /api/v1/doctors/:id/statistics
         */
        this.getDoctorStatistics = (0, errorHandler_1.asyncHandler)(async (req, res, next) => {
            const { id } = req.params;
            const stats = await (0, database_1.default)('appointments')
                .where({ doctor_id: id })
                .select(database_1.default.raw('COUNT(*) as total_appointments'), database_1.default.raw("COUNT(*) FILTER (WHERE status = 'completed') as completed_appointments"), database_1.default.raw("COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_appointments"), database_1.default.raw("COUNT(*) FILTER (WHERE status = 'no_show') as no_show_appointments"))
                .first();
            res.status(200).json({
                status: 'success',
                data: {
                    statistics: stats,
                },
            });
        });
    }
}
exports.DoctorController = DoctorController;
//# sourceMappingURL=doctor.controller.js.map