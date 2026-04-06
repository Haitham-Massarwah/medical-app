/**
 * SMS Templates Service
 * Provides SMS message templates in multiple languages
 */

export type Language = 'he' | 'ar' | 'en';
export type SMSType = 'reminder' | 'confirmation' | 'cancellation' | 'payment' | 'verification' | 'general';

interface SMSData {
  patientName?: string;
  doctorName?: string;
  date?: string;
  time?: string;
  location?: string;
  hoursUntil?: number;
  reason?: string;
  amount?: number;
  currency?: string;
  transactionId?: string;
  code?: string;
  message?: string; // For general/custom messages
}

/**
 * Get SMS template based on language and type
 * If custom template exists for doctor, use it; otherwise use default
 */
export const getSMSTemplate = (
  type: SMSType,
  language: Language = 'he',
  data: SMSData = {},
  customTemplates?: Record<string, Record<string, string>> | null
): string => {
  // Check if custom template exists
  if (customTemplates && customTemplates[language] && customTemplates[language][type]) {
    let template = customTemplates[language][type];
    
    // Replace placeholders with actual data
    template = template.replace(/\{\{patientName\}\}/g, data.patientName || '');
    template = template.replace(/\{\{doctorName\}\}/g, data.doctorName || '');
    template = template.replace(/\{\{date\}\}/g, data.date || '');
    template = template.replace(/\{\{time\}\}/g, data.time || '');
    template = template.replace(/\{\{location\}\}/g, data.location || '');
    template = template.replace(/\{\{hoursUntil\}\}/g, String(data.hoursUntil || ''));
    template = template.replace(/\{\{reason\}\}/g, data.reason || '');
    template = template.replace(/\{\{amount\}\}/g, String(data.amount || 0));
    template = template.replace(/\{\{currency\}\}/g, data.currency || 'ILS');
    template = template.replace(/\{\{transactionId\}\}/g, data.transactionId || '');
    template = template.replace(/\{\{code\}\}/g, data.code || '');
    
    return template;
  }

  // Use default templates
  const templates: Record<Language, Record<SMSType, (data: SMSData) => string>> = {
    he: {
      reminder: (data) => `שלום ${data.patientName || 'חולה'},

תזכורת: יש לך תור בעוד ${data.hoursUntil || 'כמה'} שעות!

רופא: ${data.doctorName || ''}
תאריך: ${data.date || ''}
שעה: ${data.time || ''}

נראה אותך בקרוב!`,

      confirmation: (data) => `שלום ${data.patientName || 'חולה'},

התור שלך אושר!

רופא: ${data.doctorName || ''}
תאריך: ${data.date || ''}
שעה: ${data.time || ''}
מיקום: ${data.location || ''}

נראה אותך שם!`,

      cancellation: (data) => `שלום ${data.patientName || 'חולה'},

התור שלך בוטל.

רופא: ${data.doctorName || ''}
תאריך: ${data.date || ''}
שעה: ${data.time || ''}${data.reason ? `\n\nסיבה: ${data.reason}` : ''}

אנא צור איתנו קשר לקביעת תור חדש.`,

      payment: (data) => `תשלום התקבל!

סכום: ${data.amount || 0} ${data.currency || 'ILS'}
מספר עסקה: ${data.transactionId || ''}

תודה!`,

      verification: (data) => `קוד האימות שלך הוא: ${data.code || ''}

קוד זה פג תוקף תוך 10 דקות.`,

      general: (data) => data.message || '',
    },
    ar: {
      reminder: (data) => `مرحباً ${data.patientName || 'مريض'},

تذكير: لديك موعد خلال ${data.hoursUntil || 'بضع'} ساعات!

الطبيب: ${data.doctorName || ''}
التاريخ: ${data.date || ''}
الوقت: ${data.time || ''}

نراك قريباً!`,

      confirmation: (data) => `مرحباً ${data.patientName || 'مريض'},

تم تأكيد موعدك!

الطبيب: ${data.doctorName || ''}
التاريخ: ${data.date || ''}
الوقت: ${data.time || ''}
الموقع: ${data.location || ''}

نراك هناك!`,

      cancellation: (data) => `مرحباً ${data.patientName || 'مريض'},

تم إلغاء موعدك.

الطبيب: ${data.doctorName || ''}
التاريخ: ${data.date || ''}
الوقت: ${data.time || ''}${data.reason ? `\n\nالسبب: ${data.reason}` : ''}

يرجى الاتصال بنا لإعادة تحديد موعد.`,

      payment: (data) => `تم استلام الدفع!

المبلغ: ${data.amount || 0} ${data.currency || 'ILS'}
رقم المعاملة: ${data.transactionId || ''}

شكراً!`,

      verification: (data) => `رمز التحقق الخاص بك هو: ${data.code || ''}

ينتهي صلاحية هذا الرمز خلال 10 دقائق.`,

      general: (data) => data.message || '',
    },
    en: {
      reminder: (data) => `Hi ${data.patientName || 'Patient'},

Reminder: You have an appointment in ${data.hoursUntil || 'a few'} hours!

Doctor: ${data.doctorName || ''}
Date: ${data.date || ''}
Time: ${data.time || ''}

See you soon!`,

      confirmation: (data) => `Hi ${data.patientName || 'Patient'},

Your appointment is confirmed!

Doctor: ${data.doctorName || ''}
Date: ${data.date || ''}
Time: ${data.time || ''}
Location: ${data.location || ''}

See you there!`,

      cancellation: (data) => `Hi ${data.patientName || 'Patient'},

Your appointment has been cancelled.

Doctor: ${data.doctorName || ''}
Date: ${data.date || ''}
Time: ${data.time || ''}${data.reason ? `\n\nReason: ${data.reason}` : ''}

Please contact us to reschedule.`,

      payment: (data) => `Payment received!

Amount: ${data.amount || 0} ${data.currency || 'ILS'}
Transaction ID: ${data.transactionId || ''}

Thank you!`,

      verification: (data) => `Your verification code is: ${data.code || ''}

This code expires in 10 minutes.`,

      general: (data) => data.message || '',
    },
  };

  const template = templates[language]?.[type];
  if (!template) {
    // Fallback to Hebrew if language not found
    return templates.he[type](data);
  }

  return template(data);
};

/**
 * Get doctor's preferred language from database
 */
export const getDoctorLanguage = async (doctorId: string): Promise<Language> => {
  const db = require('../config/database').default;
  
  const doctor = await db('doctors')
    .join('users', 'doctors.user_id', 'users.id')
    .where('doctors.id', doctorId)
    .select('users.preferred_language')
    .first();

  if (!doctor) {
    return 'he'; // Default to Hebrew
  }

  const lang = doctor.preferred_language?.toLowerCase();
  
  // Map language codes
  if (lang === 'he' || lang === 'hebrew' || lang === 'עברית') {
    return 'he';
  }
  if (lang === 'ar' || lang === 'arabic' || lang === 'عربي') {
    return 'ar';
  }
  if (lang === 'en' || lang === 'english') {
    return 'en';
  }

  return 'he'; // Default fallback
};

