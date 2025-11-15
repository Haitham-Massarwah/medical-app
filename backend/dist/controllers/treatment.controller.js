"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.listTreatments = listTreatments;
exports.createTreatment = createTreatment;
exports.updateTreatment = updateTreatment;
exports.deleteTreatment = deleteTreatment;
exports.getDoctorPaymentSettings = getDoctorPaymentSettings;
exports.setDoctorPaymentSettings = setDoctorPaymentSettings;
const database_1 = __importDefault(require("../config/database"));
// Schema helper: ensures tables exist (lightweight guard)
async function ensureSchema() {
    const hasTreatments = await database_1.default.schema.hasTable('doctor_treatments');
    if (!hasTreatments) {
        await database_1.default.schema.createTable('doctor_treatments', (table) => {
            table.increments('id').primary();
            table.integer('doctor_id').notNullable().index();
            table.string('name').notNullable();
            table.text('description');
            table.decimal('price', 10, 2).nullable();
            table.integer('duration_minutes').notNullable().defaultTo(30);
            table.boolean('allow_multiple_patients').notNullable().defaultTo(false);
            table.integer('max_patients_per_slot').notNullable().defaultTo(1);
            table.timestamp('created_at').defaultTo(database_1.default.fn.now());
            table.timestamp('updated_at').defaultTo(database_1.default.fn.now());
        });
    }
    const hasSettings = await database_1.default.schema.hasTable('doctor_settings');
    if (!hasSettings) {
        await database_1.default.schema.createTable('doctor_settings', (table) => {
            table.increments('id').primary();
            table.integer('doctor_id').notNullable().unique();
            table.boolean('payments_enabled').notNullable().defaultTo(false);
            table.boolean('forced_by_developer').notNullable().defaultTo(false);
            table.timestamp('updated_at').defaultTo(database_1.default.fn.now());
        });
    }
}
async function listTreatments(req, res) {
    await ensureSchema();
    const { doctorId } = req.query;
    try {
        const q = (0, database_1.default)('doctor_treatments').select('*');
        if (doctorId)
            q.where('doctor_id', doctorId);
        const rows = await q.orderBy('id', 'desc');
        res.status(200).json({ success: true, data: rows });
    }
    catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
}
async function createTreatment(req, res) {
    await ensureSchema();
    const { doctor_id, name, description, price, duration_minutes, allow_multiple_patients, max_patients_per_slot } = req.body;
    if (!doctor_id || !name)
        return res.status(400).json({ success: false, message: 'doctor_id and name are required' });
    try {
        const [row] = await (0, database_1.default)('doctor_treatments')
            .insert({ doctor_id, name, description, price, duration_minutes: duration_minutes ?? 30, allow_multiple_patients: !!allow_multiple_patients, max_patients_per_slot: max_patients_per_slot ?? 1 })
            .returning('*');
        res.status(201).json({ success: true, data: row });
    }
    catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
}
async function updateTreatment(req, res) {
    await ensureSchema();
    const { id } = req.params;
    const payload = req.body || {};
    try {
        payload.updated_at = database_1.default.fn.now();
        const [row] = await (0, database_1.default)('doctor_treatments').where({ id }).update(payload).returning('*');
        res.status(200).json({ success: true, data: row });
    }
    catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
}
async function deleteTreatment(req, res) {
    await ensureSchema();
    const { id } = req.params;
    try {
        await (0, database_1.default)('doctor_treatments').where({ id }).del();
        res.status(200).json({ success: true });
    }
    catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
}
async function getDoctorPaymentSettings(req, res) {
    await ensureSchema();
    const { doctorId } = req.params;
    try {
        let row = await (0, database_1.default)('doctor_settings').where({ doctor_id: doctorId }).first();
        if (!row) {
            const [created] = await (0, database_1.default)('doctor_settings').insert({ doctor_id: doctorId }).returning('*');
            row = created;
        }
        res.status(200).json({ success: true, data: row });
    }
    catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
}
async function setDoctorPaymentSettings(req, res) {
    await ensureSchema();
    const { doctorId } = req.params;
    const { payments_enabled, forced_by_developer } = req.body || {};
    try {
        const [row] = await (0, database_1.default)('doctor_settings')
            .insert({ doctor_id: doctorId, payments_enabled: !!payments_enabled, forced_by_developer: !!forced_by_developer })
            .onConflict('doctor_id')
            .merge({ payments_enabled: !!payments_enabled, forced_by_developer: !!forced_by_developer, updated_at: database_1.default.fn.now() })
            .returning('*');
        res.status(200).json({ success: true, data: row });
    }
    catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
}
//# sourceMappingURL=treatment.controller.js.map