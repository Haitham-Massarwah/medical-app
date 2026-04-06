import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import '../utils/app_constants.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations != null) {
      return localizations;
    }
    // Fallback to English if not found
    return AppLocalizations(const Locale('en', 'US'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = AppConstants.supportedLocales;

  // Helper method to safely get localized values with fallback to English
  String _getLocalizedValue(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key; // Fallback to key if not found
  }

  // Common
  String get appTitle => _getLocalizedValue('appTitle');
  String get loading => _getLocalizedValue('loading');
  String get error => _getLocalizedValue('error');
  String get success => _getLocalizedValue('success');
  String get cancel => _getLocalizedValue('cancel');
  String get confirm => _getLocalizedValue('confirm');
  String get save => _getLocalizedValue('save');
  String get delete => _getLocalizedValue('delete');
  String get edit => _getLocalizedValue('edit');
  String get add => _getLocalizedValue('add');
  String get search => _getLocalizedValue('search');
  String get filter => _getLocalizedValue('filter');
  String get sort => _getLocalizedValue('sort');
  String get refresh => _getLocalizedValue('refresh');
  String get retry => _getLocalizedValue('retry');
  String get back => _getLocalizedValue('back');
  String get next => _getLocalizedValue('next');
  String get previous => _getLocalizedValue('previous');
  String get close => _getLocalizedValue('close');
  String get optional => _getLocalizedValue('optional');
  String get useCurrentLocation => _getLocalizedValue('useCurrentLocation');
  String get openInGoogleMaps => _getLocalizedValue('openInGoogleMaps');
  String get openInWaze => _getLocalizedValue('openInWaze');
  String get enterLocationManually => _getLocalizedValue('enterLocationManually');
  String get done => _getLocalizedValue('done');
  String get yes => _getLocalizedValue('yes');
  String get no => _getLocalizedValue('no');
  String get ok => _getLocalizedValue('ok');

  // Authentication
  String get login => _getLocalizedValue('login');
  String get logout => _getLocalizedValue('logout');
  String get register => _getLocalizedValue('register');
  String get email => _getLocalizedValue('email');
  String get password => _getLocalizedValue('password');
  String get confirmPassword => _getLocalizedValue('confirmPassword');
  String get forgotPassword => _getLocalizedValue('forgotPassword');
  String get resetPassword => _getLocalizedValue('resetPassword');
  String get resetPasswordSubtitle => _getLocalizedValue('resetPasswordSubtitle');
  String get changePassword => _getLocalizedValue('changePassword');
  String get currentPassword => _getLocalizedValue('currentPassword');
  String get newPassword => _getLocalizedValue('newPassword');
  String get verifyEmail => _getLocalizedValue('verifyEmail');
  String get resendVerification => _getLocalizedValue('resendVerification');
  String get twoFactorAuth => _getLocalizedValue('twoFactorAuth');
  String get enableTwoFactor => _getLocalizedValue('enableTwoFactor');
  String get disableTwoFactor => _getLocalizedValue('disableTwoFactor');
  String get verificationCode => _getLocalizedValue('verificationCode');
  String get loginToYourAccount => _getLocalizedValue('loginToYourAccount');
  String get dontHaveAccount => _getLocalizedValue('dontHaveAccount');
  String get medicalAppointmentSystem => _getLocalizedValue('medicalAppointmentSystem');
  String get systemTagline => _getLocalizedValue('systemTagline');
  String get registerToSystem => _getLocalizedValue('registerToSystem');
  String get iWantToRegisterAs => _getLocalizedValue('iWantToRegisterAs');
  String get agreeToTerms => _getLocalizedValue('agreeToTerms');
  String get termsAndPrivacy => _getLocalizedValue('termsAndPrivacy');
  String get agreeToTermsPatient => _getLocalizedValue('agreeToTermsPatient');
  String get agreeToTermsDoctor => _getLocalizedValue('agreeToTermsDoctor');
  String get alreadyHaveAccount => _getLocalizedValue('alreadyHaveAccount');
  String get loginHere => _getLocalizedValue('loginHere');
  String get licenseNumber => _getLocalizedValue('licenseNumber');
  String get specialty => _getLocalizedValue('specialty');
  String get specialtyRequired => _getLocalizedValue('specialtyRequired');
  String get clinicAddress => _getLocalizedValue('clinicAddress');
  String get street => _getLocalizedValue('street');
  // Note: city and country are already declared in User Profile section (line 345-346)
  String get paymentInformation => _getLocalizedValue('paymentInformation');
  String get visaCardNumber => _getLocalizedValue('visaCardNumber');
  String get cardHolderName => _getLocalizedValue('cardHolderName');
  String get expiryDate => _getLocalizedValue('expiryDate');
  String get cvv => _getLocalizedValue('cvv');
  String get idNumber => _getLocalizedValue('idNumber');
  String get verificationNotice => _getLocalizedValue('verificationNotice');
  String get adminApprovalRequired => _getLocalizedValue('adminApprovalRequired');
  String get doctorApprovalNotice => _getLocalizedValue('doctorApprovalNotice');
  String get doctorOrTherapist => _getLocalizedValue('doctorOrTherapist');
  String get paymentInfoDescription => _getLocalizedValue('paymentInfoDescription');
  String get selectLocation => _getLocalizedValue('selectLocation');
  String get selectSpecialties => _getLocalizedValue('selectSpecialties');
  
  // Specialty names
  String get specialtyOsteopath => _getLocalizedValue('specialtyOsteopath');
  String get specialtyPhysiotherapist => _getLocalizedValue('specialtyPhysiotherapist');
  String get specialtyDentist => _getLocalizedValue('specialtyDentist');
  String get specialtyDentalHygienist => _getLocalizedValue('specialtyDentalHygienist');
  String get specialtyMassageTherapist => _getLocalizedValue('specialtyMassageTherapist');
  String get specialtyAcupuncturist => _getLocalizedValue('specialtyAcupuncturist');
  String get specialtyPsychologist => _getLocalizedValue('specialtyPsychologist');
  String get specialtyNutritionist => _getLocalizedValue('specialtyNutritionist');
  String get specialtyGeneralPractitioner => _getLocalizedValue('specialtyGeneralPractitioner');
  String get specialtySpecialist => _getLocalizedValue('specialtySpecialist');
  
  Map<String, String> getSpecialtyName(String key) {
    final specialties = {
      // Medical Specialties
      'general_practitioner': {
        'he': 'רופא כללי',
        'ar': 'طبيب عام',
        'en': 'General Practitioner',
      },
      'cardiologist': {
        'he': 'קרדיולוג',
        'ar': 'طبيب قلب',
        'en': 'Cardiologist',
      },
      'neurologist': {
        'he': 'נוירולוג',
        'ar': 'طبيب أعصاب',
        'en': 'Neurologist',
      },
      'orthopedist': {
        'he': 'אורתופד',
        'ar': 'طبيب عظام',
        'en': 'Orthopedist',
      },
      'dermatologist': {
        'he': 'דרמטולוג',
        'ar': 'طبيب جلدية',
        'en': 'Dermatologist',
      },
      'gynecologist': {
        'he': 'גינקולוג',
        'ar': 'طبيب نساء وتوليد',
        'en': 'Gynecologist',
      },
      'pediatrician': {
        'he': 'רופא ילדים',
        'ar': 'طبيب أطفال',
        'en': 'Pediatrician',
      },
      'psychiatrist': {
        'he': 'פסיכיאטר',
        'ar': 'طبيب نفسي',
        'en': 'Psychiatrist',
      },
      'ophthalmologist': {
        'he': 'רופא עיניים',
        'ar': 'طبيب عيون',
        'en': 'Ophthalmologist',
      },
      'otolaryngologist': {
        'he': 'רופא א.א.ג',
        'ar': 'طبيب أنف وأذن وحنجرة',
        'en': 'Otolaryngologist',
      },
      'urologist': {
        'he': 'אורולוג',
        'ar': 'طبيب مسالك بولية',
        'en': 'Urologist',
      },
      'gastroenterologist': {
        'he': 'גסטרואנטרולוג',
        'ar': 'طبيب جهاز هضمي',
        'en': 'Gastroenterologist',
      },
      'endocrinologist': {
        'he': 'אנדוקרינולוג',
        'ar': 'طبيب غدد صماء',
        'en': 'Endocrinologist',
      },
      'pulmonologist': {
        'he': 'רופא ריאות',
        'ar': 'طبيب رئة',
        'en': 'Pulmonologist',
      },
      'rheumatologist': {
        'he': 'ראומטולוג',
        'ar': 'طبيب روماتيزم',
        'en': 'Rheumatologist',
      },
      'oncologist': {
        'he': 'אונקולוג',
        'ar': 'طبيب أورام',
        'en': 'Oncologist',
      },
      'anesthesiologist': {
        'he': 'רופא מרדים',
        'ar': 'طبيب تخدير',
        'en': 'Anesthesiologist',
      },
      'surgeon': {
        'he': 'מנתח',
        'ar': 'جراح',
        'en': 'Surgeon',
      },
      'internal_medicine': {
        'he': 'רפואה פנימית',
        'ar': 'طب باطني',
        'en': 'Internal Medicine',
      },
      'emergency_medicine': {
        'he': 'רפואה דחופה',
        'ar': 'طب الطوارئ',
        'en': 'Emergency Medicine',
      },
      // Paramedical Specialties
      'osteopath': {
        'he': 'אוסטאופת',
        'ar': 'معالج تقويم العظام',
        'en': 'Osteopath',
      },
      'physiotherapist': {
        'he': 'פיזיותרפיסט',
        'ar': 'أخصائي علاج طبيعي',
        'en': 'Physiotherapist',
      },
      'dentist': {
        'he': 'רופא שיניים',
        'ar': 'طبيب أسنان',
        'en': 'Dentist',
      },
      'dental_hygienist': {
        'he': 'שיננית',
        'ar': 'أخصائي صحة الأسنان',
        'en': 'Dental Hygienist',
      },
      'massage_therapist': {
        'he': 'מעסה',
        'ar': 'معالج تدليك',
        'en': 'Massage Therapist',
      },
      'acupuncturist': {
        'he': 'מטפל בדיקור',
        'ar': 'أخصائي الوخز بالإبر',
        'en': 'Acupuncturist',
      },
      'psychologist': {
        'he': 'פסיכולוג',
        'ar': 'طبيب نفسي',
        'en': 'Psychologist',
      },
      'nutritionist': {
        'he': 'דיאטנית',
        'ar': 'أخصائي تغذية',
        'en': 'Nutritionist',
      },
      'speech_therapist': {
        'he': 'קלינאי תקשורת',
        'ar': 'أخصائي نطق',
        'en': 'Speech Therapist',
      },
      'occupational_therapist': {
        'he': 'מרפא בעיסוק',
        'ar': 'أخصائي علاج وظيفي',
        'en': 'Occupational Therapist',
      },
      'chiropractor': {
        'he': 'כירופרקט',
        'ar': 'معالج تقويم العمود الفقري',
        'en': 'Chiropractor',
      },
      'naturopath': {
        'he': 'נטורופת',
        'ar': 'معالج طبيعي',
        'en': 'Naturopath',
      },
      'homeopath': {
        'he': 'הומאופת',
        'ar': 'معالج بالطب المثلي',
        'en': 'Homeopath',
      },
      'podiatrist': {
        'he': 'פודיאטר',
        'ar': 'طبيب أقدام',
        'en': 'Podiatrist',
      },
      'optometrist': {
        'he': 'אופטומטריסט',
        'ar': 'أخصائي فحص النظر',
        'en': 'Optometrist',
      },
      'audiologist': {
        'he': 'קלינאי שמיעה',
        'ar': 'أخصائي سمع',
        'en': 'Audiologist',
      },
      'radiologist_technician': {
        'he': 'טכנאי רנטגן',
        'ar': 'فني أشعة',
        'en': 'Radiologist Technician',
      },
      'medical_laboratory_technician': {
        'he': 'טכנאי מעבדה רפואית',
        'ar': 'فني مختبر طبي',
        'en': 'Medical Laboratory Technician',
      },
      'pharmacy_technician': {
        'he': 'טכנאי רוקחות',
        'ar': 'فني صيدلة',
        'en': 'Pharmacy Technician',
      },
    };
    return {
      'he': specialties[key]?['he'] ?? key,
      'ar': specialties[key]?['ar'] ?? key,
      'en': specialties[key]?['en'] ?? key,
    };
  }

  // User Profile
  String get profile => _getLocalizedValue('profile');
  String get firstName => _getLocalizedValue('firstName');
  String get lastName => _getLocalizedValue('lastName');
  String get fullName => _getLocalizedValue('fullName');
  String get phone => _getLocalizedValue('phone');
  String get mobileOnly => _getLocalizedValue('mobileOnly');
  String get mobilePhoneHint => _getLocalizedValue('mobilePhoneHint');
  String get username => _getLocalizedValue('username');
  String get address => _getLocalizedValue('address');
  String get city => _getLocalizedValue('city');
  String get country => _getLocalizedValue('country');
  String get language => _getLocalizedValue('language');
  String get theme => _getLocalizedValue('theme');
  String get notifications => _getLocalizedValue('notifications');
  String get privacy => _getLocalizedValue('privacy');
  String get settings => _getLocalizedValue('settings');

  // Medical Specialties
  String get osteopath => _getLocalizedValue('osteopath');
  String get physiotherapist => _getLocalizedValue('physiotherapist');
  String get dentist => _getLocalizedValue('dentist');
  String get dentalHygienist => _getLocalizedValue('dentalHygienist');
  String get massageTherapist => _getLocalizedValue('massageTherapist');
  String get acupuncturist => _getLocalizedValue('acupuncturist');
  String get psychologist => _getLocalizedValue('psychologist');
  String get nutritionist => _getLocalizedValue('nutritionist');
  String get generalPractitioner => _getLocalizedValue('generalPractitioner');
  String get specialist => _getLocalizedValue('specialist');

  // Appointments
  String get appointments => _getLocalizedValue('appointments');
  String get appointment => _getLocalizedValue('appointment');
  String get bookAppointment => _getLocalizedValue('bookAppointment');
  String get cancelAppointment => _getLocalizedValue('cancelAppointment');
  String get rescheduleAppointment => _getLocalizedValue('rescheduleAppointment');
  String get confirmAppointment => _getLocalizedValue('confirmAppointment');
  String get appointmentDate => _getLocalizedValue('appointmentDate');
  String get appointmentTime => _getLocalizedValue('appointmentTime');
  String get appointmentDuration => _getLocalizedValue('appointmentDuration');
  String get appointmentStatus => _getLocalizedValue('appointmentStatus');
  String get scheduled => _getLocalizedValue('scheduled');
  String get confirmed => _getLocalizedValue('confirmed');
  String get completed => _getLocalizedValue('completed');
  String get cancelled => _getLocalizedValue('cancelled');
  String get noShow => _getLocalizedValue('noShow');
  String get rescheduled => _getLocalizedValue('rescheduled');

  // Doctors
  String get doctors => _getLocalizedValue('doctors');
  String get doctor => _getLocalizedValue('doctor');
  String get paramedical => _getLocalizedValue('paramedical');
  String get availability => _getLocalizedValue('availability');
  String get workingHours => _getLocalizedValue('workingHours');
  String get experience => _getLocalizedValue('experience');
  String get education => _getLocalizedValue('education');
  String get certifications => _getLocalizedValue('certifications');
  String get languages => _getLocalizedValue('languages');
  String get reviews => _getLocalizedValue('reviews');
  String get rating => _getLocalizedValue('rating');
  String get location => _getLocalizedValue('location');
  String get telehealth => _getLocalizedValue('telehealth');
  String get inPerson => _getLocalizedValue('inPerson');

  // Patients
  String get patients => _getLocalizedValue('patients');
  String get patient => _getLocalizedValue('patient');
  String get medicalHistory => _getLocalizedValue('medicalHistory');
  String get medicalRecords => _getLocalizedValue('medicalRecords');
  String get allergies => _getLocalizedValue('allergies');
  String get medications => _getLocalizedValue('medications');
  String get emergencyContact => _getLocalizedValue('emergencyContact');
  String get insurance => _getLocalizedValue('insurance');
  String get insuranceNumber => _getLocalizedValue('insuranceNumber');

  // Payments
  String get payments => _getLocalizedValue('payments');
  String get payment => _getLocalizedValue('payment');
  String get amount => _getLocalizedValue('amount');
  String get currency => _getLocalizedValue('currency');
  String get paymentMethod => _getLocalizedValue('paymentMethod');
  String get creditCard => _getLocalizedValue('creditCard');
  String get debitCard => _getLocalizedValue('debitCard');
  String get bankTransfer => _getLocalizedValue('bankTransfer');
  String get cash => _getLocalizedValue('cash');
  String get deposit => _getLocalizedValue('deposit');
  String get refund => _getLocalizedValue('refund');
  String get receipt => _getLocalizedValue('receipt');
  String get invoice => _getLocalizedValue('invoice');
  String get pending => _getLocalizedValue('pending');
  String get failed => _getLocalizedValue('failed');
  String get refunded => _getLocalizedValue('refunded');

  // Notifications
  String get reminder => _getLocalizedValue('reminder');
  String get confirmation => _getLocalizedValue('confirmation');
  String get cancellation => _getLocalizedValue('cancellation');
  String get reschedule => _getLocalizedValue('reschedule');
  String get emailNotification => _getLocalizedValue('emailNotification');
  String get smsNotification => _getLocalizedValue('smsNotification');
  String get whatsappNotification => _getLocalizedValue('whatsappNotification');
  String get pushNotification => _getLocalizedValue('pushNotification');
  
  // Dashboard Metrics
  String get upcomingAppointments => _getLocalizedValue('upcomingAppointments');
  String get newMessages => _getLocalizedValue('newMessages');
  String get newPatientsThisMonth => _getLocalizedValue('newPatientsThisMonth');
  String get messages => _getLocalizedValue('messages');
  String get status => _getLocalizedValue('status');
  String get viewAll => _getLocalizedValue('viewAll');
  String get noAppointmentsFound => _getLocalizedValue('noAppointmentsFound');
  String get noMessagesFound => _getLocalizedValue('noMessagesFound');

  // Calendar
  String get calendar => _getLocalizedValue('calendar');
  String get today => _getLocalizedValue('today');
  String get tomorrow => _getLocalizedValue('tomorrow');
  String get yesterday => _getLocalizedValue('yesterday');
  String get thisWeek => _getLocalizedValue('thisWeek');
  String get nextWeek => _getLocalizedValue('nextWeek');
  String get thisMonth => _getLocalizedValue('thisMonth');
  String get nextMonth => _getLocalizedValue('nextMonth');
  String get date => _getLocalizedValue('date');
  String get time => _getLocalizedValue('time');
  String get duration => _getLocalizedValue('duration');
  String get minutes => _getLocalizedValue('minutes');
  String get hours => _getLocalizedValue('hours');
  String get days => _getLocalizedValue('days');
  String get weeks => _getLocalizedValue('weeks');
  String get months => _getLocalizedValue('months');
  String get years => _getLocalizedValue('years');

  // Validation Messages
  String get requiredField => _getLocalizedValue('requiredField');
  String get invalidEmail => _getLocalizedValue('invalidEmail');
  String get invalidPhone => _getLocalizedValue('invalidPhone');
  String get passwordTooShort => _getLocalizedValue('passwordTooShort');
  String get passwordsDoNotMatch => _getLocalizedValue('passwordsDoNotMatch');
  String get invalidDate => _getLocalizedValue('invalidDate');
  String get invalidTime => _getLocalizedValue('invalidTime');
  String get pastDateNotAllowed => _getLocalizedValue('pastDateNotAllowed');
  String get tooFarInFuture => _getLocalizedValue('tooFarInFuture');

  // Error Messages
  String get networkError => _getLocalizedValue('networkError');
  String get serverError => _getLocalizedValue('serverError');
  String get unauthorizedError => _getLocalizedValue('unauthorizedError');
  String get forbiddenError => _getLocalizedValue('forbiddenError');
  String get notFoundError => _getLocalizedValue('notFoundError');
  String get validationError => _getLocalizedValue('validationError');
  String get unknownError => _getLocalizedValue('unknownError');

  // Success Messages
  String get appointmentBookedSuccess => _getLocalizedValue('appointmentBookedSuccess');
  String get appointmentCancelledSuccess => _getLocalizedValue('appointmentCancelledSuccess');
  String get appointmentRescheduledSuccess => _getLocalizedValue('appointmentRescheduledSuccess');
  String get paymentCompletedSuccess => _getLocalizedValue('paymentCompletedSuccess');
  String get profileUpdatedSuccess => _getLocalizedValue('profileUpdatedSuccess');

  // Format date and time
  String formatDate(DateTime date) {
    final formatter = DateFormat.yMMMd(locale.languageCode);
    return formatter.format(date);
  }

  String formatTime(DateTime time) {
    final formatter = DateFormat.Hm(locale.languageCode);
    return formatter.format(time);
  }

  String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat.yMMMd().add_Hm();
    return formatter.format(dateTime);
  }

  // Localized values map
  static final Map<String, Map<String, String>> _localizedValues = {
    'he': {
      'appTitle': 'מערכת תורים רפואיים',
      'loading': 'טוען...',
      'error': 'שגיאה',
      'success': 'הצלחה',
      'cancel': 'ביטול',
      'confirm': 'אישור',
      'save': 'שמירה',
      'delete': 'מחיקה',
      'edit': 'עריכה',
      'add': 'הוספה',
      'search': 'חיפוש',
      'filter': 'סינון',
      'sort': 'מיון',
      'refresh': 'רענון',
      'retry': 'נסה שוב',
      'back': 'חזרה',
      'next': 'הבא',
      'previous': 'הקודם',
      'close': 'סגירה',
      'optional': 'אופציונלי',
      'useCurrentLocation': 'השתמש במיקום הנוכחי',
      'openInGoogleMaps': 'פתח ב-Google Maps',
      'openInWaze': 'פתח ב-Waze',
      'enterLocationManually': 'הזן מיקום ידנית',
      'done': 'סיום',
      'yes': 'כן',
      'no': 'לא',
      'ok': 'אישור',
      
      // Authentication
      'login': 'התחברות',
      'logout': 'התנתקות',
      'register': 'הרשמה',
      'email': 'אימייל',
      'password': 'סיסמה',
      'confirmPassword': 'אישור סיסמה',
      'forgotPassword': 'שכחתי סיסמה',
      'resetPassword': 'איפוס סיסמה',
      'resetPasswordSubtitle': 'הזן את כתובת האימייל שלך ונשלח לך קישור לאיפוס הסיסמה',
      'changePassword': 'שינוי סיסמה',
      'currentPassword': 'סיסמה נוכחית',
      'newPassword': 'סיסמה חדשה',
      'verifyEmail': 'אימות אימייל',
      'resendVerification': 'שליחה חוזרת של אימות',
      'twoFactorAuth': 'אימות דו-שלבי',
      'enableTwoFactor': 'הפעלת אימות דו-שלבי',
      'disableTwoFactor': 'ביטול אימות דו-שלבי',
      'verificationCode': 'קוד אימות',
      'loginToYourAccount': 'התחבר לחשבון שלך',
      'dontHaveAccount': 'אין לך חשבון? הירשם עכשיו',
      'medicalAppointmentSystem': 'מערכת תורים רפואיים',
      'systemTagline': 'בריאותך היא העדיפות שלנו',
      'registerToSystem': 'הרשמה למערכת',
      'iWantToRegisterAs': 'אני רוצה להירשם כ:',
      'agreeToTerms': 'אני מסכים לתנאי השימוש ומדיניות הפרטיות',
      'termsAndPrivacy': 'תנאי השימוש ומדיניות הפרטיות',
      'agreeToTermsPatient': 'אני מסכים לתנאי השימוש ומדיניות הפרטיות למטופלים',
      'agreeToTermsDoctor': 'אני מסכים לתנאי השימוש ומדיניות הפרטיות לרופאים/מטפלים',
      'alreadyHaveAccount': 'יש לך כבר חשבון?',
      'loginHere': 'התחבר כאן',
      'licenseNumber': 'מספר רישיון',
      'specialty': 'התמחות',
      'specialtyRequired': 'נא לבחור לפחות התמחות אחת',
      'clinicAddress': 'כתובת הקליניקה',
      'street': 'רחוב',
      'city': 'עיר',
      'country': 'מדינה',
      'paymentInformation': 'פרטי תשלום לאימות',
      'visaCardNumber': 'מספר כרטיס אשראי (Visa)',
      'cardHolderName': 'שם בעל הכרטיס',
      'expiryDate': 'תאריך תפוגה (MM/YY)',
      'cvv': 'קוד אבטחה (CVV)',
      'idNumber': 'מספר תעודת זהות',
      'verificationNotice': 'המידע נדרש לאימות זהותך כרופא מורשה',
      'adminApprovalRequired': 'נדרש אישור מנהל',
      'doctorApprovalNotice': 'רישום כרופא/מטפל דורש אישור מנהל. לאחר הרישום, חשבונך ייבדק ואושר תוך 24-48 שעות.',
      'doctorOrTherapist': 'רופא/מטפל',
      'paymentInfoDescription': 'פרטי תשלום להגדרת חשבון ולקבלת תשלומים',
      'selectLocation': 'בחר מיקום',
      'selectSpecialties': 'בחר התמחויות',
      
      // Medical Specialties
      'osteopath': 'אוסטאופת',
      'physiotherapist': 'פיזיותרפיסט',
      'dentist': 'רופא שיניים',
      'dentalHygienist': 'שיננית',
      'massageTherapist': 'מעסה',
      'acupuncturist': 'מטפל בדיקור',
      'psychologist': 'פסיכולוג',
      'nutritionist': 'דיאטנית',
      'generalPractitioner': 'רופא משפחה',
      'specialist': 'מומחה',
      
      // Appointments
      'appointments': 'תורים',
      'appointment': 'תור',
      'bookAppointment': 'קביעת תור',
      'cancelAppointment': 'ביטול תור',
      'rescheduleAppointment': 'דחיית תור',
      'confirmAppointment': 'אישור תור',
      'appointmentDate': 'תאריך התור',
      'appointmentTime': 'שעת התור',
      'appointmentDuration': 'משך התור',
      'appointmentStatus': 'סטטוס התור',
      'scheduled': 'מתוזמן',
      'confirmed': 'מאושר',
      'completed': 'הושלם',
      'cancelled': 'בוטל',
      'noShow': 'לא הגיע',
      'rescheduled': 'נדחה',
      
      // Doctors
      'doctors': 'רופאים',
      'doctor': 'רופא',
      'paramedical': 'פרא-רפואי',
      'availability': 'זמינות',
      'workingHours': 'שעות עבודה',
      'experience': 'ניסיון',
      'education': 'השכלה',
      'certifications': 'תעודות',
      'languages': 'שפות',
      'reviews': 'ביקורות',
      'rating': 'דירוג',
      'location': 'מיקום',
      'telehealth': 'טלה-בריאות',
      'inPerson': 'פגישה פיזית',
      
      // Patients
      'patients': 'מטופלים',
      'patient': 'מטופל',
      'medicalHistory': 'היסטוריה רפואית',
      'medicalRecords': 'תיק רפואי',
      'allergies': 'אלרגיות',
      'medications': 'תרופות',
      'emergencyContact': 'איש קשר חירום',
      'insurance': 'ביטוח',
      'insuranceNumber': 'מספר ביטוח',
      
      // Payments
      'payments': 'תשלומים',
      'payment': 'תשלום',
      'amount': 'סכום',
      'currency': 'מטבע',
      'paymentMethod': 'אמצעי תשלום',
      'creditCard': 'כרטיס אשראי',
      'debitCard': 'כרטיס חיוב',
      'bankTransfer': 'העברה בנקאית',
      'cash': 'מזומן',
      'deposit': 'פיקדון',
      'refund': 'החזר',
      'receipt': 'קבלה',
      'invoice': 'חשבונית',
      'pending': 'ממתין',
      'failed': 'נכשל',
      'refunded': 'הוחזר',
      
      // Notifications
      'reminder': 'תזכורת',
      'confirmation': 'אישור',
      'cancellation': 'ביטול',
      'reschedule': 'דחייה',
      'emailNotification': 'התראה במייל',
      'smsNotification': 'התראה ב-SMS',
      'whatsappNotification': 'התראה בווטסאפ',
      'pushNotification': 'התראה באפליקציה',
      
      // Dashboard Metrics
      'upcomingAppointments': 'תורים קרובים',
      'newMessages': 'הודעות חדשות',
      'newPatientsThisMonth': 'מטופלים חדשים החודש',
      'messages': 'הודעות',
      'status': 'סטטוס',
      'viewAll': 'הצג הכל',
      'noAppointmentsFound': 'אין תורים להצגה',
      'noMessagesFound': 'אין הודעות',
      
      // Calendar
      'calendar': 'יומן',
      'today': 'היום',
      'tomorrow': 'מחר',
      'yesterday': 'אתמול',
      'thisWeek': 'השבוע',
      'nextWeek': 'השבוע הבא',
      'thisMonth': 'החודש',
      'nextMonth': 'החודש הבא',
      'date': 'תאריך',
      'time': 'שעה',
      'duration': 'משך',
      'minutes': 'דקות',
      'hours': 'שעות',
      'days': 'ימים',
      'weeks': 'שבועות',
      'months': 'חודשים',
      'years': 'שנים',
      
      // Validation Messages
      'requiredField': 'שדה חובה',
      'invalidEmail': 'כתובת אימייל לא תקינה',
      'invalidPhone': 'מספר טלפון לא תקין',
      'mobileOnly': 'נייד בלבד',
      'mobilePhoneHint': 'יש להזין מספר נייד בלבד (05X-XXXXXXX)',
      'passwordTooShort': 'הסיסמה קצרה מדי',
      'passwordsDoNotMatch': 'הסיסמאות אינן תואמות',
      'invalidDate': 'תאריך לא תקין',
      'invalidTime': 'שעה לא תקינה',
      'pastDateNotAllowed': 'לא ניתן לבחור תאריך בעבר',
      'tooFarInFuture': 'התאריך רחוק מדי בעתיד',
      
      // Error Messages
      'networkError': 'שגיאת רשת',
      'serverError': 'שגיאת שרת',
      'unauthorizedError': 'אין הרשאה',
      'forbiddenError': 'חסום',
      'notFoundError': 'לא נמצא',
      'validationError': 'שגיאת אימות',
      'unknownError': 'שגיאה לא ידועה',
      
      // Success Messages
      'appointmentBookedSuccess': 'התור נקבע בהצלחה',
      'appointmentCancelledSuccess': 'התור בוטל בהצלחה',
      'appointmentRescheduledSuccess': 'התור נדחה בהצלחה',
      'paymentCompletedSuccess': 'התשלום הושלם בהצלחה',
      'profileUpdatedSuccess': 'הפרופיל עודכן בהצלחה',
    },
    'ar': {
      'appTitle': 'نظام المواعيد الطبية',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'search': 'بحث',
      'filter': 'تصفية',
      'sort': 'ترتيب',
      'refresh': 'تحديث',
      'retry': 'إعادة المحاولة',
      'back': 'رجوع',
      'next': 'التالي',
      'previous': 'السابق',
      'close': 'إغلاق',
      'optional': 'اختياري',
      'useCurrentLocation': 'استخدم الموقع الحالي',
      'openInGoogleMaps': 'افتح في Google Maps',
      'openInWaze': 'افتح في Waze',
      'enterLocationManually': 'أدخل الموقع يدوياً',
      'done': 'تم',
      'yes': 'نعم',
      'no': 'لا',
      'ok': 'موافق',
      
      // Authentication
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'register': 'التسجيل',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور',
      'resetPassword': 'إعادة تعيين كلمة المرور',
      'resetPasswordSubtitle': 'أدخل عنوان بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور',
      'changePassword': 'تغيير كلمة المرور',
      'currentPassword': 'كلمة المرور الحالية',
      'newPassword': 'كلمة المرور الجديدة',
      'verifyEmail': 'التحقق من البريد الإلكتروني',
      'resendVerification': 'إعادة إرسال التحقق',
      'twoFactorAuth': 'المصادقة الثنائية',
      'enableTwoFactor': 'تفعيل المصادقة الثنائية',
      'disableTwoFactor': 'إلغاء المصادقة الثنائية',
      'verificationCode': 'رمز التحقق',
      'loginToYourAccount': 'تسجيل الدخول إلى حسابك',
      'dontHaveAccount': 'ليس لديك حساب؟ سجل الآن',
      'medicalAppointmentSystem': 'نظام المواعيد الطبية',
      'systemTagline': 'صحتك هي أولويتنا',
      'registerToSystem': 'إنشاء حساب',
      'iWantToRegisterAs': 'أريد التسجيل كـ:',
      'agreeToTerms': 'أوافق على شروط الاستخدام وسياسة الخصوصية',
      'termsAndPrivacy': 'شروط الاستخدام وسياسة الخصوصية',
      'agreeToTermsPatient': 'أوافق على شروط الاستخدام وسياسة الخصوصية للمرضى',
      'agreeToTermsDoctor': 'أوافق على شروط الاستخدام وسياسة الخصوصية للأطباء/المعالجين',
      'alreadyHaveAccount': 'هل لديك حساب بالفعل؟',
      'loginHere': 'تسجيل الدخول هنا',
      'licenseNumber': 'رقم الترخيص',
      'specialty': 'التخصص',
      'specialtyRequired': 'يرجى اختيار تخصص واحد على الأقل',
      'clinicAddress': 'عنوان العيادة',
      'street': 'شارع',
      'city': 'مدينة',
      'country': 'دولة',
      'paymentInformation': 'معلومات الدفع للتحقق',
      'visaCardNumber': 'رقم بطاقة فيزا',
      'cardHolderName': 'اسم حامل البطاقة',
      'expiryDate': 'تاريخ الانتهاء (MM/YY)',
      'cvv': 'رمز الأمان (CVV)',
      'idNumber': 'رقم الهوية',
      'verificationNotice': 'هذه المعلومات مطلوبة للتحقق من هويتك كطبيب مرخص',
      'adminApprovalRequired': 'يتطلب موافقة المدير',
      'doctorApprovalNotice': 'التسجيل كطبيب/معالج يتطلب موافقة المدير. بعد التسجيل، سيتم مراجعة حسابك والموافقة عليه خلال 24-48 ساعة.',
      'doctorOrTherapist': 'طبيب/معالج',
      'paymentInfoDescription': 'معلومات الدفع لإعداد الحساب واستلام المدفوعات',
      'selectLocation': 'اختر الموقع',
      'selectSpecialties': 'اختر التخصصات',
      
      // Medical Specialties
      'osteopath': 'أخصائي العظام',
      'physiotherapist': 'أخصائي العلاج الطبيعي',
      'dentist': 'طبيب أسنان',
      'dentalHygienist': 'أخصائي صحة الأسنان',
      'massageTherapist': 'أخصائي التدليك',
      'acupuncturist': 'أخصائي الوخز بالإبر',
      'psychologist': 'طبيب نفسي',
      'nutritionist': 'أخصائي التغذية',
      'generalPractitioner': 'طبيب عام',
      'specialist': 'أخصائي',
      
      // Appointments
      'appointments': 'المواعيد',
      'appointment': 'موعد',
      'bookAppointment': 'حجز موعد',
      'cancelAppointment': 'إلغاء الموعد',
      'rescheduleAppointment': 'تأجيل الموعد',
      'confirmAppointment': 'تأكيد الموعد',
      'appointmentDate': 'تاريخ الموعد',
      'appointmentTime': 'وقت الموعد',
      'appointmentDuration': 'مدة الموعد',
      'appointmentStatus': 'حالة الموعد',
      'scheduled': 'مجدول',
      'confirmed': 'مؤكد',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
      'noShow': 'لم يحضر',
      'rescheduled': 'مؤجل',
      
      // Doctors
      'doctors': 'الأطباء',
      'doctor': 'طبيب',
      'paramedical': 'طبيب مساعد',
      'availability': 'التوفر',
      'workingHours': 'ساعات العمل',
      'experience': 'الخبرة',
      'education': 'التعليم',
      'certifications': 'الشهادات',
      'languages': 'اللغات',
      'reviews': 'التقييمات',
      'rating': 'التقييم',
      'location': 'الموقع',
      'telehealth': 'الرعاية الصحية عن بُعد',
      'inPerson': 'زيارة شخصية',
      
      // Patients
      'patients': 'المرضى',
      'patient': 'مريض',
      'medicalHistory': 'التاريخ الطبي',
      'medicalRecords': 'السجلات الطبية',
      'allergies': 'الحساسية',
      'medications': 'الأدوية',
      'emergencyContact': 'جهة الاتصال في حالات الطوارئ',
      'insurance': 'التأمين',
      'insuranceNumber': 'رقم التأمين',
      
      // Payments
      'payments': 'المدفوعات',
      'payment': 'دفع',
      'amount': 'المبلغ',
      'currency': 'العملة',
      'paymentMethod': 'طريقة الدفع',
      'creditCard': 'بطاقة ائتمان',
      'debitCard': 'بطاقة خصم',
      'bankTransfer': 'تحويل بنكي',
      'cash': 'نقد',
      'deposit': 'وديعة',
      'refund': 'استرداد',
      'receipt': 'إيصال',
      'invoice': 'فاتورة',
      'pending': 'معلق',
      'failed': 'فشل',
      'refunded': 'مسترد',
      
      // Notifications
      'reminder': 'تذكير',
      'confirmation': 'تأكيد',
      'cancellation': 'إلغاء',
      'reschedule': 'تأجيل',
      'emailNotification': 'إشعار بالبريد الإلكتروني',
      'smsNotification': 'إشعار نصي',
      'whatsappNotification': 'إشعار واتساب',
      'pushNotification': 'إشعار التطبيق',
      
      // Dashboard Metrics
      'upcomingAppointments': 'المواعيد القادمة',
      'newMessages': 'رسائل جديدة',
      'newPatientsThisMonth': 'مرضى جدد هذا الشهر',
      'messages': 'الرسائل',
      'status': 'الحالة',
      'viewAll': 'عرض الكل',
      'noAppointmentsFound': 'لا توجد مواعيد للعرض',
      'noMessagesFound': 'لا توجد رسائل',
      
      // Calendar
      'calendar': 'التقويم',
      'today': 'اليوم',
      'tomorrow': 'غداً',
      'yesterday': 'أمس',
      'thisWeek': 'هذا الأسبوع',
      'nextWeek': 'الأسبوع القادم',
      'thisMonth': 'هذا الشهر',
      'nextMonth': 'الشهر القادم',
      'date': 'التاريخ',
      'time': 'الوقت',
      'duration': 'المدة',
      'minutes': 'دقائق',
      'hours': 'ساعات',
      'days': 'أيام',
      'weeks': 'أسابيع',
      'months': 'أشهر',
      'years': 'سنوات',
      
      // Validation Messages
      'requiredField': 'حقل مطلوب',
      'invalidEmail': 'عنوان بريد إلكتروني غير صحيح',
      'invalidPhone': 'رقم هاتف غير صحيح',
      'mobileOnly': 'جوال فقط',
      'mobilePhoneHint': 'يرجى إدخال رقم جوال فقط (05X-XXXXXXX)',
      'passwordTooShort': 'كلمة المرور قصيرة جداً',
      'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
      'invalidDate': 'تاريخ غير صحيح',
      'invalidTime': 'وقت غير صحيح',
      'pastDateNotAllowed': 'لا يمكن اختيار تاريخ في الماضي',
      'tooFarInFuture': 'التاريخ بعيد جداً في المستقبل',
      
      // Error Messages
      'networkError': 'خطأ في الشبكة',
      'serverError': 'خطأ في الخادم',
      'unauthorizedError': 'غير مخول',
      'forbiddenError': 'محظور',
      'notFoundError': 'غير موجود',
      'validationError': 'خطأ في التحقق',
      'unknownError': 'خطأ غير معروف',
      
      // Success Messages
      'appointmentBookedSuccess': 'تم حجز الموعد بنجاح',
      'appointmentCancelledSuccess': 'تم إلغاء الموعد بنجاح',
      'appointmentRescheduledSuccess': 'تم تأجيل الموعد بنجاح',
      'paymentCompletedSuccess': 'تم الدفع بنجاح',
      'profileUpdatedSuccess': 'تم تحديث الملف الشخصي بنجاح',
    },
    'en': {
      'appTitle': 'Medical Appointment System',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'refresh': 'Refresh',
      'retry': 'Retry',
      'back': 'Back',
      'next': 'Next',
      'previous': 'Previous',
      'close': 'Close',
      'optional': 'Optional',
      'useCurrentLocation': 'Use Current Location',
      'openInGoogleMaps': 'Open in Google Maps',
      'openInWaze': 'Open in Waze',
      'enterLocationManually': 'Enter Location Manually',
      'done': 'Done',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      
      // Authentication
      'login': 'Login',
      'logout': 'Logout',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password',
      'resetPassword': 'Reset Password',
      'resetPasswordSubtitle': 'Enter your email address and we\'ll send you a link to reset your password',
      'changePassword': 'Change Password',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'verifyEmail': 'Verify Email',
      'resendVerification': 'Resend Verification',
      'twoFactorAuth': 'Two-Factor Authentication',
      'enableTwoFactor': 'Enable Two-Factor Auth',
      'disableTwoFactor': 'Disable Two-Factor Auth',
      'verificationCode': 'Verification Code',
      'loginToYourAccount': 'Login to Your Account',
      'dontHaveAccount': 'Don\'t have an account? Register now',
      'medicalAppointmentSystem': 'Medical Appointment System',
      'systemTagline': 'Your Health, Our Priority',
      'registerToSystem': 'Create Account',
      'iWantToRegisterAs': 'I want to register as:',
      'agreeToTerms': 'I agree to the terms of use and privacy policy',
      'termsAndPrivacy': 'Terms of Use and Privacy Policy',
      'agreeToTermsPatient': 'I agree to the terms of use and privacy policy for patients',
      'agreeToTermsDoctor': 'I agree to the terms of use and privacy policy for doctors/therapists',
      'alreadyHaveAccount': 'Already have an account?',
      'loginHere': 'Login here',
      'licenseNumber': 'License Number',
      'specialty': 'Specialty',
      'specialtyRequired': 'Please select at least one specialty',
      'clinicAddress': 'Clinic Address',
      'street': 'Street',
      'city': 'City',
      'country': 'Country',
      'paymentInformation': 'Payment Information for Verification',
      'visaCardNumber': 'Visa Card Number',
      'cardHolderName': 'Card Holder Name',
      'expiryDate': 'Expiry Date (MM/YY)',
      'cvv': 'Security Code (CVV)',
      'idNumber': 'ID Number',
      'verificationNotice': 'This information is required to verify your identity as a licensed doctor',
      'adminApprovalRequired': 'Admin Approval Required',
      'doctorApprovalNotice': 'Registering as a doctor/therapist requires admin approval. After registration, your account will be reviewed and approved within 24-48 hours.',
      'doctorOrTherapist': 'Doctor/Therapist',
      'paymentInfoDescription': 'Payment information for account setup and receiving payments',
      'selectLocation': 'Select Location',
      'selectSpecialties': 'Select Specialties',
      
      // Medical Specialties
      'osteopath': 'Osteopath',
      'physiotherapist': 'Physiotherapist',
      'dentist': 'Dentist',
      'dentalHygienist': 'Dental Hygienist',
      'massageTherapist': 'Massage Therapist',
      'acupuncturist': 'Acupuncturist',
      'psychologist': 'Psychologist',
      'nutritionist': 'Nutritionist',
      'generalPractitioner': 'General Practitioner',
      'specialist': 'Specialist',
      
      // Appointments
      'appointments': 'Appointments',
      'appointment': 'Appointment',
      'bookAppointment': 'Book Appointment',
      'cancelAppointment': 'Cancel Appointment',
      'rescheduleAppointment': 'Reschedule Appointment',
      'confirmAppointment': 'Confirm Appointment',
      'appointmentDate': 'Appointment Date',
      'appointmentTime': 'Appointment Time',
      'appointmentDuration': 'Appointment Duration',
      'appointmentStatus': 'Appointment Status',
      'scheduled': 'Scheduled',
      'confirmed': 'Confirmed',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'noShow': 'No Show',
      'rescheduled': 'Rescheduled',
      
      // Doctors
      'doctors': 'Doctors',
      'doctor': 'Doctor',
      'paramedical': 'Paramedical',
      'availability': 'Availability',
      'workingHours': 'Working Hours',
      'experience': 'Experience',
      'education': 'Education',
      'certifications': 'Certifications',
      'languages': 'Languages',
      'reviews': 'Reviews',
      'rating': 'Rating',
      'location': 'Location',
      'telehealth': 'Telehealth',
      'inPerson': 'In-Person',
      
      // Patients
      'patients': 'Patients',
      'patient': 'Patient',
      'medicalHistory': 'Medical History',
      'medicalRecords': 'Medical Records',
      'allergies': 'Allergies',
      'medications': 'Medications',
      'emergencyContact': 'Emergency Contact',
      'insurance': 'Insurance',
      'insuranceNumber': 'Insurance Number',
      
      // Payments
      'payments': 'Payments',
      'payment': 'Payment',
      'amount': 'Amount',
      'currency': 'Currency',
      'paymentMethod': 'Payment Method',
      'creditCard': 'Credit Card',
      'debitCard': 'Debit Card',
      'bankTransfer': 'Bank Transfer',
      'cash': 'Cash',
      'deposit': 'Deposit',
      'refund': 'Refund',
      'receipt': 'Receipt',
      'invoice': 'Invoice',
      'pending': 'Pending',
      'failed': 'Failed',
      'refunded': 'Refunded',
      
      // Notifications
      'reminder': 'Reminder',
      'confirmation': 'Confirmation',
      'cancellation': 'Cancellation',
      'reschedule': 'Reschedule',
      'emailNotification': 'Email Notification',
      'smsNotification': 'SMS Notification',
      'whatsappNotification': 'WhatsApp Notification',
      'pushNotification': 'Push Notification',
      
      // Dashboard Metrics
      'upcomingAppointments': 'Upcoming Appointments',
      'newMessages': 'New Messages',
      'newPatientsThisMonth': 'New Patients This Month',
      'messages': 'Messages',
      'status': 'Status',
      'viewAll': 'View All',
      'noAppointmentsFound': 'No appointments found',
      'noMessagesFound': 'No messages found',
      
      // Calendar
      'calendar': 'Calendar',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'yesterday': 'Yesterday',
      'thisWeek': 'This Week',
      'nextWeek': 'Next Week',
      'thisMonth': 'This Month',
      'nextMonth': 'Next Month',
      'date': 'Date',
      'time': 'Time',
      'duration': 'Duration',
      'minutes': 'Minutes',
      'hours': 'Hours',
      'days': 'Days',
      'weeks': 'Weeks',
      'months': 'Months',
      'years': 'Years',
      
      // Validation Messages
      'requiredField': 'Required field',
      'invalidEmail': 'Invalid email address',
      'invalidPhone': 'Invalid phone number',
      'mobileOnly': 'Mobile Only',
      'mobilePhoneHint': 'Please enter mobile number only (05X-XXXXXXX)',
      'passwordTooShort': 'Password too short',
      'passwordsDoNotMatch': 'Passwords do not match',
      'invalidDate': 'Invalid date',
      'invalidTime': 'Invalid time',
      'pastDateNotAllowed': 'Past date not allowed',
      'tooFarInFuture': 'Date too far in future',
      
      // Error Messages
      'networkError': 'Network error',
      'serverError': 'Server error',
      'unauthorizedError': 'Unauthorized',
      'forbiddenError': 'Forbidden',
      'notFoundError': 'Not found',
      'validationError': 'Validation error',
      'unknownError': 'Unknown error',
      
      // Success Messages
      'appointmentBookedSuccess': 'Appointment booked successfully',
      'appointmentCancelledSuccess': 'Appointment cancelled successfully',
      'appointmentRescheduledSuccess': 'Appointment rescheduled successfully',
      'paymentCompletedSuccess': 'Payment completed successfully',
      'profileUpdatedSuccess': 'Profile updated successfully',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
