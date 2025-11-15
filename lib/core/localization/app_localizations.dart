import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import '../utils/app_constants.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = AppConstants.supportedLocales;

  // Common
  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get filter => _localizedValues[locale.languageCode]!['filter']!;
  String get sort => _localizedValues[locale.languageCode]!['sort']!;
  String get refresh => _localizedValues[locale.languageCode]!['refresh']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get previous => _localizedValues[locale.languageCode]!['previous']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get done => _localizedValues[locale.languageCode]!['done']!;
  String get yes => _localizedValues[locale.languageCode]!['yes']!;
  String get no => _localizedValues[locale.languageCode]!['no']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;

  // Authentication
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get confirmPassword => _localizedValues[locale.languageCode]!['confirmPassword']!;
  String get forgotPassword => _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get resetPassword => _localizedValues[locale.languageCode]!['resetPassword']!;
  String get changePassword => _localizedValues[locale.languageCode]!['changePassword']!;
  String get currentPassword => _localizedValues[locale.languageCode]!['currentPassword']!;
  String get newPassword => _localizedValues[locale.languageCode]!['newPassword']!;
  String get verifyEmail => _localizedValues[locale.languageCode]!['verifyEmail']!;
  String get resendVerification => _localizedValues[locale.languageCode]!['resendVerification']!;
  String get twoFactorAuth => _localizedValues[locale.languageCode]!['twoFactorAuth']!;
  String get enableTwoFactor => _localizedValues[locale.languageCode]!['enableTwoFactor']!;
  String get disableTwoFactor => _localizedValues[locale.languageCode]!['disableTwoFactor']!;
  String get verificationCode => _localizedValues[locale.languageCode]!['verificationCode']!;

  // User Profile
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get firstName => _localizedValues[locale.languageCode]!['firstName']!;
  String get lastName => _localizedValues[locale.languageCode]!['lastName']!;
  String get fullName => _localizedValues[locale.languageCode]!['fullName']!;
  String get phone => _localizedValues[locale.languageCode]!['phone']!;
  String get address => _localizedValues[locale.languageCode]!['address']!;
  String get city => _localizedValues[locale.languageCode]!['city']!;
  String get country => _localizedValues[locale.languageCode]!['country']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get privacy => _localizedValues[locale.languageCode]!['privacy']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;

  // Medical Specialties
  String get osteopath => _localizedValues[locale.languageCode]!['osteopath']!;
  String get physiotherapist => _localizedValues[locale.languageCode]!['physiotherapist']!;
  String get dentist => _localizedValues[locale.languageCode]!['dentist']!;
  String get dentalHygienist => _localizedValues[locale.languageCode]!['dentalHygienist']!;
  String get massageTherapist => _localizedValues[locale.languageCode]!['massageTherapist']!;
  String get acupuncturist => _localizedValues[locale.languageCode]!['acupuncturist']!;
  String get psychologist => _localizedValues[locale.languageCode]!['psychologist']!;
  String get nutritionist => _localizedValues[locale.languageCode]!['nutritionist']!;
  String get generalPractitioner => _localizedValues[locale.languageCode]!['generalPractitioner']!;
  String get specialist => _localizedValues[locale.languageCode]!['specialist']!;

  // Appointments
  String get appointments => _localizedValues[locale.languageCode]!['appointments']!;
  String get appointment => _localizedValues[locale.languageCode]!['appointment']!;
  String get bookAppointment => _localizedValues[locale.languageCode]!['bookAppointment']!;
  String get cancelAppointment => _localizedValues[locale.languageCode]!['cancelAppointment']!;
  String get rescheduleAppointment => _localizedValues[locale.languageCode]!['rescheduleAppointment']!;
  String get confirmAppointment => _localizedValues[locale.languageCode]!['confirmAppointment']!;
  String get appointmentDate => _localizedValues[locale.languageCode]!['appointmentDate']!;
  String get appointmentTime => _localizedValues[locale.languageCode]!['appointmentTime']!;
  String get appointmentDuration => _localizedValues[locale.languageCode]!['appointmentDuration']!;
  String get appointmentStatus => _localizedValues[locale.languageCode]!['appointmentStatus']!;
  String get scheduled => _localizedValues[locale.languageCode]!['scheduled']!;
  String get confirmed => _localizedValues[locale.languageCode]!['confirmed']!;
  String get completed => _localizedValues[locale.languageCode]!['completed']!;
  String get cancelled => _localizedValues[locale.languageCode]!['cancelled']!;
  String get noShow => _localizedValues[locale.languageCode]!['noShow']!;
  String get rescheduled => _localizedValues[locale.languageCode]!['rescheduled']!;

  // Doctors
  String get doctors => _localizedValues[locale.languageCode]!['doctors']!;
  String get doctor => _localizedValues[locale.languageCode]!['doctor']!;
  String get paramedical => _localizedValues[locale.languageCode]!['paramedical']!;
  String get availability => _localizedValues[locale.languageCode]!['availability']!;
  String get workingHours => _localizedValues[locale.languageCode]!['workingHours']!;
  String get experience => _localizedValues[locale.languageCode]!['experience']!;
  String get education => _localizedValues[locale.languageCode]!['education']!;
  String get certifications => _localizedValues[locale.languageCode]!['certifications']!;
  String get languages => _localizedValues[locale.languageCode]!['languages']!;
  String get reviews => _localizedValues[locale.languageCode]!['reviews']!;
  String get rating => _localizedValues[locale.languageCode]!['rating']!;
  String get location => _localizedValues[locale.languageCode]!['location']!;
  String get telehealth => _localizedValues[locale.languageCode]!['telehealth']!;
  String get inPerson => _localizedValues[locale.languageCode]!['inPerson']!;

  // Patients
  String get patients => _localizedValues[locale.languageCode]!['patients']!;
  String get patient => _localizedValues[locale.languageCode]!['patient']!;
  String get medicalHistory => _localizedValues[locale.languageCode]!['medicalHistory']!;
  String get medicalRecords => _localizedValues[locale.languageCode]!['medicalRecords']!;
  String get allergies => _localizedValues[locale.languageCode]!['allergies']!;
  String get medications => _localizedValues[locale.languageCode]!['medications']!;
  String get emergencyContact => _localizedValues[locale.languageCode]!['emergencyContact']!;
  String get insurance => _localizedValues[locale.languageCode]!['insurance']!;
  String get insuranceNumber => _localizedValues[locale.languageCode]!['insuranceNumber']!;

  // Payments
  String get payments => _localizedValues[locale.languageCode]!['payments']!;
  String get payment => _localizedValues[locale.languageCode]!['payment']!;
  String get amount => _localizedValues[locale.languageCode]!['amount']!;
  String get currency => _localizedValues[locale.languageCode]!['currency']!;
  String get paymentMethod => _localizedValues[locale.languageCode]!['paymentMethod']!;
  String get creditCard => _localizedValues[locale.languageCode]!['creditCard']!;
  String get debitCard => _localizedValues[locale.languageCode]!['debitCard']!;
  String get bankTransfer => _localizedValues[locale.languageCode]!['bankTransfer']!;
  String get cash => _localizedValues[locale.languageCode]!['cash']!;
  String get deposit => _localizedValues[locale.languageCode]!['deposit']!;
  String get refund => _localizedValues[locale.languageCode]!['refund']!;
  String get receipt => _localizedValues[locale.languageCode]!['receipt']!;
  String get invoice => _localizedValues[locale.languageCode]!['invoice']!;
  String get pending => _localizedValues[locale.languageCode]!['pending']!;
  String get failed => _localizedValues[locale.languageCode]!['failed']!;
  String get refunded => _localizedValues[locale.languageCode]!['refunded']!;

  // Notifications
  String get reminder => _localizedValues[locale.languageCode]!['reminder']!;
  String get confirmation => _localizedValues[locale.languageCode]!['confirmation']!;
  String get cancellation => _localizedValues[locale.languageCode]!['cancellation']!;
  String get reschedule => _localizedValues[locale.languageCode]!['reschedule']!;
  String get emailNotification => _localizedValues[locale.languageCode]!['emailNotification']!;
  String get smsNotification => _localizedValues[locale.languageCode]!['smsNotification']!;
  String get whatsappNotification => _localizedValues[locale.languageCode]!['whatsappNotification']!;
  String get pushNotification => _localizedValues[locale.languageCode]!['pushNotification']!;

  // Calendar
  String get calendar => _localizedValues[locale.languageCode]!['calendar']!;
  String get today => _localizedValues[locale.languageCode]!['today']!;
  String get tomorrow => _localizedValues[locale.languageCode]!['tomorrow']!;
  String get yesterday => _localizedValues[locale.languageCode]!['yesterday']!;
  String get thisWeek => _localizedValues[locale.languageCode]!['thisWeek']!;
  String get nextWeek => _localizedValues[locale.languageCode]!['nextWeek']!;
  String get thisMonth => _localizedValues[locale.languageCode]!['thisMonth']!;
  String get nextMonth => _localizedValues[locale.languageCode]!['nextMonth']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get time => _localizedValues[locale.languageCode]!['time']!;
  String get duration => _localizedValues[locale.languageCode]!['duration']!;
  String get minutes => _localizedValues[locale.languageCode]!['minutes']!;
  String get hours => _localizedValues[locale.languageCode]!['hours']!;
  String get days => _localizedValues[locale.languageCode]!['days']!;
  String get weeks => _localizedValues[locale.languageCode]!['weeks']!;
  String get months => _localizedValues[locale.languageCode]!['months']!;
  String get years => _localizedValues[locale.languageCode]!['years']!;

  // Validation Messages
  String get requiredField => _localizedValues[locale.languageCode]!['requiredField']!;
  String get invalidEmail => _localizedValues[locale.languageCode]!['invalidEmail']!;
  String get invalidPhone => _localizedValues[locale.languageCode]!['invalidPhone']!;
  String get passwordTooShort => _localizedValues[locale.languageCode]!['passwordTooShort']!;
  String get passwordsDoNotMatch => _localizedValues[locale.languageCode]!['passwordsDoNotMatch']!;
  String get invalidDate => _localizedValues[locale.languageCode]!['invalidDate']!;
  String get invalidTime => _localizedValues[locale.languageCode]!['invalidTime']!;
  String get pastDateNotAllowed => _localizedValues[locale.languageCode]!['pastDateNotAllowed']!;
  String get tooFarInFuture => _localizedValues[locale.languageCode]!['tooFarInFuture']!;

  // Error Messages
  String get networkError => _localizedValues[locale.languageCode]!['networkError']!;
  String get serverError => _localizedValues[locale.languageCode]!['serverError']!;
  String get unauthorizedError => _localizedValues[locale.languageCode]!['unauthorizedError']!;
  String get forbiddenError => _localizedValues[locale.languageCode]!['forbiddenError']!;
  String get notFoundError => _localizedValues[locale.languageCode]!['notFoundError']!;
  String get validationError => _localizedValues[locale.languageCode]!['validationError']!;
  String get unknownError => _localizedValues[locale.languageCode]!['unknownError']!;

  // Success Messages
  String get appointmentBookedSuccess => _localizedValues[locale.languageCode]!['appointmentBookedSuccess']!;
  String get appointmentCancelledSuccess => _localizedValues[locale.languageCode]!['appointmentCancelledSuccess']!;
  String get appointmentRescheduledSuccess => _localizedValues[locale.languageCode]!['appointmentRescheduledSuccess']!;
  String get paymentCompletedSuccess => _localizedValues[locale.languageCode]!['paymentCompletedSuccess']!;
  String get profileUpdatedSuccess => _localizedValues[locale.languageCode]!['profileUpdatedSuccess']!;

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
      'changePassword': 'שינוי סיסמה',
      'currentPassword': 'סיסמה נוכחית',
      'newPassword': 'סיסמה חדשה',
      'verifyEmail': 'אימות אימייל',
      'resendVerification': 'שליחה חוזרת של אימות',
      'twoFactorAuth': 'אימות דו-שלבי',
      'enableTwoFactor': 'הפעלת אימות דו-שלבי',
      'disableTwoFactor': 'ביטול אימות דו-שלבי',
      'verificationCode': 'קוד אימות',
      
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
      'changePassword': 'تغيير كلمة المرور',
      'currentPassword': 'كلمة المرور الحالية',
      'newPassword': 'كلمة المرور الجديدة',
      'verifyEmail': 'التحقق من البريد الإلكتروني',
      'resendVerification': 'إعادة إرسال التحقق',
      'twoFactorAuth': 'المصادقة الثنائية',
      'enableTwoFactor': 'تفعيل المصادقة الثنائية',
      'disableTwoFactor': 'إلغاء المصادقة الثنائية',
      'verificationCode': 'رمز التحقق',
      
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
      'changePassword': 'Change Password',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'verifyEmail': 'Verify Email',
      'resendVerification': 'Resend Verification',
      'twoFactorAuth': 'Two-Factor Authentication',
      'enableTwoFactor': 'Enable Two-Factor Auth',
      'disableTwoFactor': 'Disable Two-Factor Auth',
      'verificationCode': 'Verification Code',
      
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
