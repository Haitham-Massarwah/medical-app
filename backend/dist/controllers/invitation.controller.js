"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendInvitation = sendInvitation;
exports.verifyToken = verifyToken;
exports.acceptInvitation = acceptInvitation;
const crypto_1 = __importDefault(require("crypto"));
const database_1 = __importDefault(require("../config/database"));
const email_service_1 = require("../services/email.service");
async function ensureSchema() {
    const hasInvites = await database_1.default.schema.hasTable('invitations');
    if (!hasInvites) {
        await database_1.default.schema.createTable('invitations', (table) => {
            table.increments('id').primary();
            table.integer('doctor_id').notNullable();
            table.string('email').notNullable();
            table.string('name').notNullable();
            table.string('token').notNullable().unique();
            table.timestamp('expires_at').notNullable();
            table.timestamp('used_at');
            table.timestamp('created_at').defaultTo(database_1.default.fn.now());
        });
    }
}
async function sendInvitation(req, res) {
    await ensureSchema();
    const { doctor_id, email, name } = req.body || {};
    if (!doctor_id || !email || !name)
        return res.status(400).json({ success: false, message: 'doctor_id, email, name are required' });
    try {
        const token = crypto_1.default.randomBytes(24).toString('hex');
        const expires_at = new Date(Date.now() + 1000 * 60 * 60 * 24 * 7); // 7 days
        await (0, database_1.default)('invitations').insert({ doctor_id, email, name, token, expires_at });
        const baseUrl = process.env.APP_PUBLIC_URL || 'http://localhost:3000';
        const registrationUrl = `${baseUrl}/register?token=${token}`;
        await (0, email_service_1.sendEmail)({
            to: email,
            subject: 'הזמנה להירשם למערכת התורים',
            template: 'invitation',
            data: { name, registrationUrl },
        });
        res.status(200).json({ success: true, message: 'Invitation sent', token });
    }
    catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
}
async function verifyToken(req, res) {
    await ensureSchema();
    const { token } = req.params;
    try {
        const invite = await (0, database_1.default)('invitations').where({ token }).first();
        if (!invite)
            return res.status(404).json({ success: false, message: 'Invalid token' });
        if (invite.used_at)
            return res.status(400).json({ success: false, message: 'Token already used' });
        if (new Date(invite.expires_at) < new Date())
            return res.status(400).json({ success: false, message: 'Token expired' });
        res.status(200).json({ success: true, data: { email: invite.email, name: invite.name, doctor_id: invite.doctor_id } });
    }
    catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
}
async function acceptInvitation(req, res) {
    await ensureSchema();
    const { token } = req.params;
    const { password, phone } = req.body || {};
    try {
        const invite = await (0, database_1.default)('invitations').where({ token }).first();
        if (!invite)
            return res.status(404).json({ success: false, message: 'Invalid token' });
        if (invite.used_at)
            return res.status(400).json({ success: false, message: 'Token already used' });
        if (new Date(invite.expires_at) < new Date())
            return res.status(400).json({ success: false, message: 'Token expired' });
        // Create user with role patient if not exists
        let user = await (0, database_1.default)('users').where({ email: invite.email }).first();
        if (!user) {
            const [created] = await (0, database_1.default)('users')
                .insert({
                email: invite.email,
                name: invite.name,
                role: 'patient',
                phone: phone || null,
                password_hash: '', // password flow can be implemented later
                last_login_at: null,
                created_at: database_1.default.fn.now(),
            })
                .returning('*');
            user = created;
        }
        // Mark invite as used
        await (0, database_1.default)('invitations').where({ token }).update({ used_at: database_1.default.fn.now() });
        res.status(200).json({ success: true, data: { user_id: user.id, doctor_id: invite.doctor_id } });
    }
    catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
}
//# sourceMappingURL=invitation.controller.js.map