import { Request, Response } from 'express';
import db from '../config/database';

// Schema helper: ensures tables exist (lightweight guard)
async function ensureSchema() {
  const hasTreatments = await db.schema.hasTable('doctor_treatments');
  if (!hasTreatments) {
    await db.schema.createTable('doctor_treatments', (table) => {
      table.increments('id').primary();
      table.integer('doctor_id').notNullable().index();
      table.string('name').notNullable();
      table.text('description');
      table.decimal('price', 10, 2).nullable();
      table.integer('duration_minutes').notNullable().defaultTo(30);
      table.boolean('allow_multiple_patients').notNullable().defaultTo(false);
      table.integer('max_patients_per_slot').notNullable().defaultTo(1);
      table.timestamp('created_at').defaultTo(db.fn.now());
      table.timestamp('updated_at').defaultTo(db.fn.now());
    });
  }

  const hasSettings = await db.schema.hasTable('doctor_settings');
  if (!hasSettings) {
    await db.schema.createTable('doctor_settings', (table) => {
      table.increments('id').primary();
      table.integer('doctor_id').notNullable().unique();
      table.boolean('payments_enabled').notNullable().defaultTo(false);
      table.boolean('forced_by_developer').notNullable().defaultTo(false);
      table.timestamp('updated_at').defaultTo(db.fn.now());
    });
  }
}

export async function listTreatments(req: Request, res: Response) {
  await ensureSchema();
  const { doctorId } = req.query;
  try {
    const q = db('doctor_treatments').select('*');
    if (doctorId) q.where('doctor_id', doctorId as any);
    const rows = await q.orderBy('id', 'desc');
    res.status(200).json({ success: true, data: rows });
  } catch (e: any) {
    res.status(500).json({ success: false, message: e.message });
  }
}

export async function createTreatment(req: Request, res: Response) {
  await ensureSchema();
  const { doctor_id, name, description, price, duration_minutes, allow_multiple_patients, max_patients_per_slot } = req.body;
  if (!doctor_id || !name) return res.status(400).json({ success: false, message: 'doctor_id and name are required' });
  try {
    const [row] = await db('doctor_treatments')
      .insert({ doctor_id, name, description, price, duration_minutes: duration_minutes ?? 30, allow_multiple_patients: !!allow_multiple_patients, max_patients_per_slot: max_patients_per_slot ?? 1 })
      .returning('*');
    res.status(201).json({ success: true, data: row });
  } catch (e: any) {
    res.status(500).json({ success: false, message: e.message });
  }
}

export async function updateTreatment(req: Request, res: Response) {
  await ensureSchema();
  const { id } = req.params;
  const payload = req.body || {};
  try {
    payload.updated_at = db.fn.now();
    const [row] = await db('doctor_treatments').where({ id }).update(payload).returning('*');
    res.status(200).json({ success: true, data: row });
  } catch (e: any) {
    res.status(500).json({ success: false, message: e.message });
  }
}

export async function deleteTreatment(req: Request, res: Response) {
  await ensureSchema();
  const { id } = req.params;
  try {
    await db('doctor_treatments').where({ id }).del();
    res.status(200).json({ success: true });
  } catch (e: any) {
    res.status(500).json({ success: false, message: e.message });
  }
}

export async function getDoctorPaymentSettings(req: Request, res: Response) {
  await ensureSchema();
  const { doctorId } = req.params;
  try {
    let row = await db('doctor_settings').where({ doctor_id: doctorId }).first();
    if (!row) {
      const [created] = await db('doctor_settings').insert({ doctor_id: doctorId }).returning('*');
      row = created;
    }
    res.status(200).json({ success: true, data: row });
  } catch (e: any) {
    res.status(500).json({ success: false, message: e.message });
  }
}

export async function setDoctorPaymentSettings(req: Request, res: Response) {
  await ensureSchema();
  const { doctorId } = req.params;
  const { payments_enabled, forced_by_developer } = req.body || {};
  try {
    const [row] = await db('doctor_settings')
      .insert({ doctor_id: doctorId, payments_enabled: !!payments_enabled, forced_by_developer: !!forced_by_developer })
      .onConflict('doctor_id')
      .merge({ payments_enabled: !!payments_enabled, forced_by_developer: !!forced_by_developer, updated_at: db.fn.now() })
      .returning('*');
    res.status(200).json({ success: true, data: row });
  } catch (e: any) {
    res.status(500).json({ success: false, message: e.message });
  }
}






