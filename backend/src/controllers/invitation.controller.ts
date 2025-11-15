import { Request, Response } from 'express';
import crypto from 'crypto';
import db from '../config/database';
import { sendEmail } from '../services/email.service';

async function ensureSchema() {
  const hasInvites = await db.schema.hasTable('invitations');
  if (!hasInvites) {
    await db.schema.createTable('invitations', (table) => {
      table.increments('id').primary();
      table.integer('doctor_id').notNullable();
      table.string('email').notNullable();
      table.string('name').notNullable();
      table.string('token').notNullable().unique();
      table.timestamp('expires_at').notNullable();
      table.timestamp('used_at');
      table.timestamp('created_at').defaultTo(db.fn.now());
    });
  }
}

export async function sendInvitation(req: Request, res: Response) {
  await ensureSchema();
  const { doctor_id, email, name } = req.body || {};
  if (!doctor_id || !email || !name) return res.status(400).json({ success: false, message: 'doctor_id, email, name are required' });

  try {
    const token = crypto.randomBytes(24).toString('hex');
    const expires_at = new Date(Date.now() + 1000 * 60 * 60 * 24 * 7); // 7 days

    await db('invitations').insert({ doctor_id, email, name, token, expires_at });

    const baseUrl = process.env.APP_PUBLIC_URL || 'http://localhost:3000';
    const registrationUrl = `${baseUrl}/register?token=${token}`;

    await sendEmail({
      to: email,
      subject: 'הזמנה להירשם למערכת התורים',
      template: 'invitation',
      data: { name, registrationUrl },
    });

    res.status(200).json({ success: true, message: 'Invitation sent', token });
  } catch (e: any) {
    res.status(500).json({ success: false, message: e.message });
  }
}

export async function verifyToken(req: Request, res: Response) {
  await ensureSchema();
  const { token } = req.params;
  try {
    const invite = await db('invitations').where({ token }).first();
    if (!invite) return res.status(404).json({ success: false, message: 'Invalid token' });
    if (invite.used_at) return res.status(400).json({ success: false, message: 'Token already used' });
    if (new Date(invite.expires_at) < new Date()) return res.status(400).json({ success: false, message: 'Token expired' });
    res.status(200).json({ success: true, data: { email: invite.email, name: invite.name, doctor_id: invite.doctor_id } });
  } catch (e: any) {
    res.status(500).json({ success: false, message: e.message });
  }
}

export async function acceptInvitation(req: Request, res: Response) {
  await ensureSchema();
  const { token } = req.params;
  const { password, phone } = req.body || {};
  try {
    const invite = await db('invitations').where({ token }).first();
    if (!invite) return res.status(404).json({ success: false, message: 'Invalid token' });
    if (invite.used_at) return res.status(400).json({ success: false, message: 'Token already used' });
    if (new Date(invite.expires_at) < new Date()) return res.status(400).json({ success: false, message: 'Token expired' });

    // Create user with role patient if not exists
    let user = await db('users').where({ email: invite.email }).first();
    if (!user) {
      const [created] = await db('users')
        .insert({
          email: invite.email,
          name: invite.name,
          role: 'patient',
          phone: phone || null,
          password_hash: '', // password flow can be implemented later
          last_login_at: null,
          created_at: db.fn.now(),
        })
        .returning('*');
      user = created;
    }

    // Mark invite as used
    await db('invitations').where({ token }).update({ used_at: db.fn.now() });

    res.status(200).json({ success: true, data: { user_id: user.id, doctor_id: invite.doctor_id } });
  } catch (e: any) {
    res.status(500).json({ success: false, message: e.message });
  }
}






