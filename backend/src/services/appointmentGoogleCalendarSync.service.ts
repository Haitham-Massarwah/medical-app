import axios from 'axios';
import { addMinutes } from 'date-fns';
import { formatInTimeZone } from 'date-fns-tz';
import db from '../config/database';
import { logger } from '../config/logger';
import calendarService from './calendar.service';

const TZ = process.env.TIMEZONE || 'Asia/Jerusalem';
const ENABLED = process.env.GOOGLE_CALENDAR_AUTO_SYNC !== 'false';
/** none | all | externalOnly — Google Calendar sendUpdates query param */
const SEND_UPDATES = process.env.GOOGLE_CALENDAR_SEND_UPDATES || 'none';

type AppointmentRow = {
  id: string;
  appointment_date: Date;
  duration_minutes: number;
  status: string;
  notes: string | null;
  location: string | null;
  is_telehealth: boolean;
  google_calendar_event_id: string | null;
  doctor_user_id: string | null;
  doctor_name: string | null;
  patient_name: string | null;
};

function buildGoogleEvent(row: AppointmentRow): Record<string, unknown> {
  const start = new Date(row.appointment_date);
  const end = addMinutes(start, row.duration_minutes || 30);
  const startStr = formatInTimeZone(start, TZ, "yyyy-MM-dd'T'HH:mm:ssXXX");
  const endStr = formatInTimeZone(end, TZ, "yyyy-MM-dd'T'HH:mm:ssXXX");

  let summary = `Clinic: ${row.patient_name || 'Patient'}`.trim();
  if (row.doctor_name) {
    summary += ` — ${row.doctor_name}`;
  }
  if (row.status === 'no_show') {
    summary = `[No-show] ${summary}`;
  }

  const lines: string[] = [`Status: ${row.status}`, `Appointment ID: ${row.id}`];
  if (row.notes) {
    lines.push('', row.notes);
  }
  if (row.location) {
    lines.push('', `Location: ${row.location}`);
  }
  if (row.is_telehealth) {
    lines.push('', 'Telehealth appointment');
  }

  return {
    summary,
    description: lines.join('\n'),
    start: { dateTime: startStr, timeZone: TZ },
    end: { dateTime: endStr, timeZone: TZ },
    extendedProperties: {
      private: {
        medicalAppointmentId: row.id,
      },
    },
  };
}

async function loadAppointmentRow(appointmentId: string): Promise<AppointmentRow | undefined> {
  const row = await db('appointments')
    .leftJoin('doctors', 'appointments.doctor_id', 'doctors.id')
    .leftJoin('patients', 'appointments.patient_id', 'patients.id')
    .leftJoin('users as du', 'doctors.user_id', 'du.id')
    .leftJoin('users as pu', 'patients.user_id', 'pu.id')
    .where('appointments.id', appointmentId)
    .select(
      'appointments.id',
      'appointments.appointment_date',
      'appointments.duration_minutes',
      'appointments.status',
      'appointments.notes',
      'appointments.location',
      'appointments.is_telehealth',
      'appointments.google_calendar_event_id',
      'doctors.user_id as doctor_user_id',
      db.raw(
        "TRIM(CONCAT(COALESCE(du.first_name,''),' ',COALESCE(du.last_name,''))) as doctor_name"
      ),
      db.raw(
        "TRIM(CONCAT(COALESCE(pu.first_name,''),' ',COALESCE(pu.last_name,''))) as patient_name"
      )
    )
    .first();

  return row as AppointmentRow | undefined;
}

async function deleteRemoteEvent(accessToken: string, eventId: string): Promise<void> {
  await axios.delete(
    `https://www.googleapis.com/calendar/v3/calendars/primary/events/${encodeURIComponent(eventId)}`,
    {
      headers: { Authorization: `Bearer ${accessToken}` },
      params: { sendUpdates: SEND_UPDATES },
      validateStatus: (s) => (s >= 200 && s < 300) || s === 404 || s === 410,
    }
  );
}

/**
 * Keeps the doctor's Google Calendar in sync with this appointment.
 * Uses calendar tokens for doctors.user_id (doctor must connect Google in the app).
 */
export async function syncGoogleCalendarForAppointment(appointmentId: string): Promise<void> {
  if (!ENABLED) {
    return;
  }

  try {
    const row = await loadAppointmentRow(appointmentId);
    if (!row?.doctor_user_id) {
      return;
    }

    const accessToken = await calendarService.getValidAccessToken(row.doctor_user_id, 'google');
    if (!accessToken) {
      return;
    }

    if (row.status === 'cancelled') {
      if (row.google_calendar_event_id) {
        try {
          await deleteRemoteEvent(accessToken, row.google_calendar_event_id);
        } catch (e: any) {
          logger.warn('Google Calendar delete failed (continuing to clear id)', {
            appointmentId,
            message: e.message,
          });
        }
        await db('appointments').where({ id: appointmentId }).update({
          google_calendar_event_id: null,
          updated_at: new Date(),
        });
      }
      return;
    }

    const body = buildGoogleEvent(row);

    if (row.google_calendar_event_id) {
      try {
        await axios.patch(
          `https://www.googleapis.com/calendar/v3/calendars/primary/events/${encodeURIComponent(row.google_calendar_event_id)}`,
          body,
          {
            headers: {
              Authorization: `Bearer ${accessToken}`,
              'Content-Type': 'application/json',
            },
            params: { sendUpdates: SEND_UPDATES },
          }
        );
      } catch (e: any) {
        const status = e.response?.status;
        if (status === 404 || status === 410) {
          const created = await axios.post<{ id: string }>(
            'https://www.googleapis.com/calendar/v3/calendars/primary/events',
            body,
            {
              headers: {
                Authorization: `Bearer ${accessToken}`,
                'Content-Type': 'application/json',
              },
              params: { sendUpdates: SEND_UPDATES },
            }
          );
          await db('appointments').where({ id: appointmentId }).update({
            google_calendar_event_id: created.data.id,
            updated_at: new Date(),
          });
        } else {
          throw e;
        }
      }
    } else {
      const created = await axios.post<{ id: string }>(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events',
        body,
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          params: { sendUpdates: SEND_UPDATES },
        }
      );
      await db('appointments').where({ id: appointmentId }).update({
        google_calendar_event_id: created.data.id,
        updated_at: new Date(),
      });
    }
  } catch (error: any) {
    logger.error('Google Calendar sync failed', {
      appointmentId,
      message: error.message,
      data: error.response?.data,
    });
  }
}

export function fireGoogleCalendarSync(appointmentId: string): void {
  syncGoogleCalendarForAppointment(appointmentId).catch((err) =>
    logger.error('Google Calendar sync promise rejected', { appointmentId, err })
  );
}
