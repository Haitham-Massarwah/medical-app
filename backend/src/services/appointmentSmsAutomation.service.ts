import { format } from 'date-fns';
import { utcToZonedTime } from 'date-fns-tz';
import db from '../config/database';
import { logger } from '../config/logger';
import {
  sendAppointmentConfirmationTemplate,
  sendAppointmentReminderTemplate,
  sendWhatsApp,
  checkWhatsAppServiceStatus,
  getPostBookingAppointmentMessageText,
  type AppointmentTemplateData,
} from './whatsapp.service';
import { sendTelegramMessage } from './telegram.service';
import { canSendEmail, isEmailEnabled } from '../config/email.gate';
import { sendAppointmentConfirmation } from './email.service';
import { createTelegramLinkUrlForUser } from './telegramLink.service';
import { buildNoShowSmsBody } from './sms.service';

const tz = process.env.TIMEZONE || 'Asia/Jerusalem';

/**
 * Automated WhatsApp: confirmation after booking + periodic reminder sweep (Twilio WhatsApp).
 */
export class AppointmentSmsAutomationService {
  private intervalHandle: NodeJS.Timeout | null = null;

  async onAppointmentBooked(appointmentId: string): Promise<void> {
    const emailWhenNoTelegram =
      String(process.env.APPOINTMENT_CONFIRMATION_EMAIL_WHEN_NO_TELEGRAM ?? 'true').toLowerCase() !==
      'false';

    const row = await db('appointments as a')
      .join('patients as p', 'a.patient_id', 'p.id')
      .join('users as u', 'p.user_id', 'u.id')
      .join('doctors as d', 'a.doctor_id', 'd.id')
      .join('users as du', 'd.user_id', 'du.id')
      .leftJoin('tenants as t', 'a.tenant_id', 't.id')
      .where('a.id', appointmentId)
      .select(
        'a.id as appointment_id',
        'a.tenant_id',
        'a.doctor_id',
        'a.appointment_date',
        'a.location',
        'u.id as patient_user_id',
        'u.phone as patient_phone',
        'u.email as patient_email',
        'u.telegram_chat_id as patient_telegram_chat_id',
        'u.first_name as patient_first',
        'du.first_name as doctor_first',
        'du.last_name as doctor_last',
        't.name as clinic_name',
        't.address as clinic_address',
      )
      .first();

    if (!row) {
      return;
    }
    const phoneRaw = row.patient_phone != null ? String(row.patient_phone).trim() : '';
    const hasTelegramLink = !!row.patient_telegram_chat_id;
    const patientEmail = row.patient_email != null ? String(row.patient_email).trim() : '';

    const pred = await db('appointment_no_show_predictions')
      .where({ appointment_id: appointmentId, is_current: true })
      .first();
    const riskLevel = String(pred?.risk_level || 'low').toLowerCase();

    const apptDate = new Date(row.appointment_date);
    const local = utcToZonedTime(apptDate, tz);
    const dateStr = format(local, 'yyyy-MM-dd');
    const timeStr = format(local, 'HH:mm');
    const doctorName = `${String(row.doctor_first || '').trim()} ${String(row.doctor_last || '').trim()}`.trim();
    const patientName = String(row.patient_first || '').trim() || 'Patient';
    const clinicName = String(row.clinic_name || '').trim();
    const clinicAddress = String(row.clinic_address || row.location || '').trim();
    const location = clinicAddress || '—';
    const recipientUserId = row.patient_user_id ? String(row.patient_user_id) : undefined;

    const tryEmailIfNoTelegram = async () => {
      if (!emailWhenNoTelegram || hasTelegramLink || !patientEmail) {
        return;
      }
      if (!isEmailEnabled() || !canSendEmail(patientEmail)) {
        logger.debug('Appointment confirmation email skipped (email gate or allowlist)', { appointmentId });
        return;
      }
      try {
        let telegramConnectUrl: string | undefined;
        if (recipientUserId) {
          const link = await createTelegramLinkUrlForUser(recipientUserId);
          if (link?.url) telegramConnectUrl = link.url;
        }
        await sendAppointmentConfirmation(patientEmail, {
          patientName,
          doctorName,
          date: dateStr,
          time: timeStr,
          location,
          ...(telegramConnectUrl ? { telegramConnectUrl } : {}),
        });
        logger.info('Appointment confirmation email sent (no Telegram link on user)', { appointmentId });
      } catch (err: unknown) {
        const message = err instanceof Error ? err.message : String(err);
        logger.warn('Appointment confirmation email failed', { appointmentId, message });
      }
    };

    const enabled = String(process.env.WHATSAPP_ON_APPOINTMENT_BOOK ?? 'true').toLowerCase() !== 'false';
    const messagingConfigured = checkWhatsAppServiceStatus().configured;
    if (!enabled || !messagingConfigured) {
      logger.debug('Post-booking SMS/WhatsApp skipped: disabled or provider not configured', { appointmentId });
      await tryEmailIfNoTelegram();
      return;
    }

    if (!phoneRaw && !hasTelegramLink) {
      logger.debug('Post-booking message skipped: no patient phone and no Telegram link; trying email', {
        appointmentId,
      });
      await tryEmailIfNoTelegram();
      return;
    }
    // Templates expect a "to" string; Telegram-only users may have no phone — placeholder is never dialed when channel is Telegram-only.
    const phone = phoneRaw || '0000000000';

    let ok = false;
    if (riskLevel === 'high') {
      const hint = `${dateStr} ${timeStr}`;
      ok = await sendWhatsApp({
        to: phone,
        recipientUserId,
        message: buildNoShowSmsBody('confirm', patientName, hint),
      });
      if (ok) logger.info('Appointment WhatsApp: high-risk confirmation request', { appointmentId });
    } else if (riskLevel === 'medium') {
      ok = await sendAppointmentReminderTemplate(
        phone,
        { patientName, doctorName, clinicName, clinicAddress, date: dateStr, time: timeStr },
        recipientUserId,
      );
      if (ok) logger.info('Appointment WhatsApp: medium-risk reminder style', { appointmentId });
    } else {
      ok = await sendAppointmentConfirmationTemplate(
        phone,
        { patientName, doctorName, clinicName, clinicAddress, date: dateStr, time: timeStr },
        recipientUserId,
      );
      if (ok) logger.info('Appointment WhatsApp: standard confirmation (low / unknown risk)', { appointmentId });
    }

    await tryEmailIfNoTelegram();
  }

  /**
   * After the patient links Telegram in the bot, send the same confirmation text as
   * post-booking would use (risk-aware), only to Telegram — does not re-send WhatsApp/SMS.
   */
  async resendLastBookingConfirmationToTelegramAfterLink(
    userId: string,
    chatId: string,
  ): Promise<void> {
    const enabled =
      String(process.env.TELEGRAM_RESEND_LAST_BOOKING_ON_LINK ?? 'true').toLowerCase() !== 'false';
    if (!enabled) {
      return;
    }

    const row = await db('appointments as a')
      .join('patients as p', 'a.patient_id', 'p.id')
      .join('users as u', 'p.user_id', 'u.id')
      .join('doctors as d', 'a.doctor_id', 'd.id')
      .join('users as du', 'd.user_id', 'du.id')
      .leftJoin('tenants as t', 'a.tenant_id', 't.id')
      .where('u.id', userId)
      .whereNotIn('a.status', ['cancelled'])
      .where('a.appointment_date', '>=', new Date())
      .orderBy('a.created_at', 'desc')
      .select(
        'a.id as appointment_id',
        'a.appointment_date',
        'a.location',
        'u.first_name as patient_first',
        'du.first_name as doctor_first',
        'du.last_name as doctor_last',
        't.name as clinic_name',
        't.address as clinic_address',
      )
      .first();

    if (!row) {
      logger.info('Telegram link: no upcoming non-cancelled appointment to resend confirmation', {
        userId,
      });
      return;
    }

    const appointmentId = String(row.appointment_id);
    const pred = await db('appointment_no_show_predictions')
      .where({ appointment_id: appointmentId, is_current: true })
      .first();
    const riskLevel = String(pred?.risk_level || 'low').toLowerCase();

    const apptDate = new Date(row.appointment_date);
    const local = utcToZonedTime(apptDate, tz);
    const dateStr = format(local, 'yyyy-MM-dd');
    const timeStr = format(local, 'HH:mm');
    const doctorName = `${String(row.doctor_first || '').trim()} ${String(row.doctor_last || '').trim()}`.trim();
    const patientName = String(row.patient_first || '').trim() || 'Patient';
    const clinicName = String(row.clinic_name || '').trim();
    const clinicAddress = String(row.clinic_address || row.location || '').trim();

    const data: AppointmentTemplateData = {
      patientName,
      doctorName,
      clinicName,
      clinicAddress,
      date: dateStr,
      time: timeStr,
    };

    const text = getPostBookingAppointmentMessageText(data, riskLevel, patientName, dateStr, timeStr);
    const body = `עדכון: אישור התור שלך (לאחר חיבור טלגרם)\n\n${text}`;

    const ok = await sendTelegramMessage(chatId, body);
    if (ok) {
      logger.info('Telegram: resent last booking confirmation after link', { userId, appointmentId });
    }
  }

  private async reminderSweepOnce(): Promise<void> {
    if (!checkWhatsAppServiceStatus().configured) return;

    const hoursBefore = Math.max(1, Number(process.env.WHATSAPP_REMINDER_HOURS_BEFORE_APPOINTMENT || 24));
    const now = new Date();
    const targetMs = hoursBefore * 60 * 60 * 1000;
    const windowStart = new Date(now.getTime() + targetMs - 30 * 60 * 1000);
    const windowEnd = new Date(now.getTime() + targetMs + 30 * 60 * 1000);

    const rows = await db('appointments as a')
      .join('patients as p', 'a.patient_id', 'p.id')
      .join('users as u', 'p.user_id', 'u.id')
      .join('doctors as d', 'a.doctor_id', 'd.id')
      .join('users as du', 'd.user_id', 'du.id')
      .leftJoin('tenants as t', 'a.tenant_id', 't.id')
      .whereIn('a.status', ['scheduled', 'confirmed'])
      .whereBetween('a.appointment_date', [windowStart, windowEnd])
      .whereNotNull('u.phone')
      .select(
        'a.id as appointment_id',
        'a.tenant_id',
        'a.doctor_id',
        'a.appointment_date',
        'a.location',
        'u.phone as patient_phone',
        'u.first_name as patient_first',
        'u.id as patient_user_id',
        'du.first_name as doctor_first',
        'du.last_name as doctor_last',
        't.name as clinic_name',
        't.address as clinic_address',
      );

    for (const row of rows as Record<string, unknown>[]) {
      const apptId = String(row.appointment_id);
      const tenantId = String(row.tenant_id);
      const userId = String(row.patient_user_id);

      const dup = await db('notifications')
        .where({
          tenant_id: tenantId,
          user_id: userId,
          type: 'whatsapp',
          status: 'sent',
        })
        .whereRaw("coalesce(data->>'kind','') = ?", ['appointment_reminder_whatsapp_sweep'])
        .whereRaw("data->>'appointment_id' = ?", [apptId])
        .first();

      if (dup) continue;

      const apptDate = new Date(row.appointment_date as string);
      const local = utcToZonedTime(apptDate, tz);
      const dateStr = format(local, 'yyyy-MM-dd');
      const timeStr = format(local, 'HH:mm');
      const patientName = String(row.patient_first || '').trim() || 'Patient';
      const doctorName = `${String(row.doctor_first || '').trim()} ${String(row.doctor_last || '').trim()}`.trim();
      const clinicName = String(row.clinic_name || '').trim();
      const clinicAddress = String(row.clinic_address || row.location || '').trim();
      const phone = String(row.patient_phone);

      const sent = await sendAppointmentReminderTemplate(
        phone,
        { patientName, doctorName, clinicName, clinicAddress, date: dateStr, time: timeStr },
        userId,
      );

      if (sent) {
        await db('notifications').insert({
          tenant_id: tenantId,
          user_id: userId,
          title: 'Appointment reminder WhatsApp',
          message: `Reminder sent for appointment ${apptId}`,
          type: 'whatsapp',
          is_read: true,
          data: { kind: 'appointment_reminder_whatsapp_sweep', appointment_id: apptId },
          status: 'sent',
          sent_at: new Date(),
          created_at: new Date(),
          updated_at: new Date(),
        });
        logger.info('Appointment reminder WhatsApp (sweep)', { appointmentId: apptId });
      }
    }
  }

  start(): void {
    const sweepMs = Number(process.env.WHATSAPP_REMINDER_SWEEP_MS ?? process.env.SMS_REMINDER_SWEEP_MS ?? 0);
    if (sweepMs <= 0) {
      logger.info('WhatsApp reminder sweep disabled (WHATSAPP_REMINDER_SWEEP_MS=0)');
      return;
    }
    if (this.intervalHandle) return;
    this.intervalHandle = setInterval(() => {
      this.reminderSweepOnce().catch((e) => logger.error('WhatsApp reminder sweep error', e as Error));
    }, Math.max(60_000, sweepMs));
    logger.info('WhatsApp reminder sweep started', { sweepMs });
  }
}

export const appointmentSmsAutomationService = new AppointmentSmsAutomationService();
