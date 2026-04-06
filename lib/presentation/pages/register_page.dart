import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/language_service.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/card_validators.dart';
import '../widgets/privacy_policy_popup.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Doctor-specific fields
  final _licenseNumberController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  List<String> _selectedSpecialties = [];
  final _visaCardNumberController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _idNumberController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _hasValidated = false; // Track if validation has been triggered
  bool _showEmailError = false; // Track if email error should be shown
  String _selectedRole = 'doctor'; // Default to doctor as per backend requirement
  Locale _currentLocale = const Locale('en', 'US');
  Timer? _passwordVisibilityTimer; // Timer for password visibility timeout

  @override
  void initState() {
    super.initState();
    _loadCurrentLocale();
    // Set default country to Israel
    _countryController.text = 'Israel';
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getCurrentLocale();
    if (mounted) {
      setState(() {
        // Ensure locale matches supported locales
        if (locale.languageCode == 'he') {
          _currentLocale = const Locale('he', 'IL');
        } else if (locale.languageCode == 'ar') {
          _currentLocale = const Locale('ar', 'IL');
        } else {
          _currentLocale = const Locale('en', 'US');
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload locale when dependencies change (e.g., after language change)
    _loadCurrentLocale();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseNumberController.dispose();
    _specialtyController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _visaCardNumberController.dispose();
    _cardHolderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  Future<String?> _getValidationError(String key, String? value) async {
    final language = await LanguageService.getCurrentLanguage();
    
    final messages = {
      'firstNameRequired': {
        'עברית': 'נא להזין שם פרטי',
        'العربية': 'يرجى إدخال الاسم الأول',
        'English': 'Please enter first name',
      },
      'lastNameRequired': {
        'עברית': 'נא להזין שם משפחה',
        'العربية': 'يرجى إدخال اسم العائلة',
        'English': 'Please enter last name',
      },
      'emailRequired': {
        'עברית': 'נא להזין כתובת אימייל',
        'العربية': 'يرجى إدخال عنوان بريد إلكتروني',
        'English': 'Please enter email address',
      },
      'emailInvalid': {
        'עברית': 'כתובת אימייל לא תקינה',
        'العربية': 'عنوان بريد إلكتروني غير صحيح',
        'English': 'Invalid email address',
      },
      'phoneRequired': {
        'עברית': 'נא להזין מספר טלפון',
        'العربية': 'يرجى إدخال رقم الهاتف',
        'English': 'Please enter phone number',
      },
      'passwordRequired': {
        'עברית': 'נא להזין סיסמה',
        'العربية': 'يرجى إدخال كلمة المرور',
        'English': 'Please enter password',
      },
      'passwordMinLength': {
        'עברית': 'סיסמה חייבת להכיל לפחות 8 תווים',
        'العربية': 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل',
        'English': 'Password must contain at least 8 characters',
      },
      'confirmPasswordRequired': {
        'עברית': 'נא לאשר את הסיסמה',
        'العربية': 'يرجى تأكيد كلمة المرور',
        'English': 'Please confirm password',
      },
      'passwordsNotMatch': {
        'עברית': 'הסיסמאות אינן תואמות',
        'العربية': 'كلمات المرور غير متطابقة',
        'English': 'Passwords do not match',
      },
      'licenseRequired': {
        'עברית': 'נא להזין מספר רישיון',
        'العربية': 'يرجى إدخال رقم الترخيص',
        'English': 'Please enter license number',
      },
      'specialtyRequired': {
        'עברית': 'נא להזין התמחות',
        'العربية': 'يرجى إدخال التخصص',
        'English': 'Please enter specialty',
      },
      'clinicAddressRequired': {
        'עברית': 'נא להזין כתובת קליניקה',
        'العربية': 'يرجى إدخال عنوان العيادة',
        'English': 'Please enter clinic address',
      },
      'bankNameRequired': {
        'עברית': 'נא להזין שם בנק',
        'العربية': 'يرجى إدخال اسم البنك',
        'English': 'Please enter bank name',
      },
      'visaCardRequired': {
        'עברית': 'נא להזין מספר כרטיס אשראי',
        'العربية': 'يرجى إدخال رقم بطاقة الائتمان',
        'English': 'Please enter Visa card number',
      },
      'idNumberRequired': {
        'עברית': 'נא להזין מספר תעודת זהות',
        'العربية': 'يرجى إدخال رقم الهوية',
        'English': 'ID number is required.',
      },
      'idNumberInvalid': {
        'עברית': 'מספר תעודת זהות לא תקין.',
        'العربية': 'رقم الهوية غير صحيح.',
        'English': 'ID number is invalid.',
      },
      'cardNumberRequired': {
        'עברית': 'מספר כרטיס אשראי נדרש.',
        'العربية': 'رقم بطاقة الائتمان مطلوب.',
        'English': 'Visa card number is required.',
      },
      'cardNumberInvalid': {
        'עברית': 'מספר כרטיס אשראי לא תקין.',
        'العربية': 'رقم بطاقة الائتمان غير صحيح.',
        'English': 'Card number is invalid.',
      },
      'cardHolderNameRequired': {
        'עברית': 'שם בעל הכרטיס נדרש.',
        'العربية': 'اسم حامل البطاقة مطلوب.',
        'English': 'Card holder name is required.',
      },
      'expiryDateRequired': {
        'עברית': 'תאריך תפוגה נדרש.',
        'العربية': 'تاريخ انتهاء الصلاحية مطلوب.',
        'English': 'Expiry date is required.',
      },
      'expiryDateInvalid': {
        'עברית': 'תאריך תפוגה לא תקין או פג תוקף.',
        'العربية': 'تاريخ انتهاء الصلاحية غير صحيح أو منتهي الصلاحية.',
        'English': 'Expiry date is invalid or expired.',
      },
      'cvvRequired': {
        'עברית': 'קוד אבטחה נדרש.',
        'العربية': 'رمز الأمان مطلوب.',
        'English': 'CVV code is required.',
      },
      'cvvInvalid': {
        'עברית': 'קוד אבטחה לא תקין.',
        'العربية': 'رمز الأمان غير صحيح.',
        'English': 'CVV code is invalid.',
      },
      'cardDeclined': {
        'עברית': 'הכרטיס נדחה על ידי הבנק.',
        'العربية': 'تم رفض البطاقة من قبل البنك.',
        'English': 'Card was declined by the bank.',
      },
      'cardVerificationFailed': {
        'עברית': 'לא ניתן לאמת את פרטי הכרטיס, אנא נסה כרטיס אחר.',
        'العربية': 'تعذر التحقق من تفاصيل البطاقة، يرجى المحاولة ببطاقة أخرى.',
        'English': 'Unable to verify card details, please try another card.',
      },
      'phoneInvalid': {
        'עברית': 'מספר טלפון לא תקין.',
        'العربية': 'رقم الهاتف غير صحيح.',
        'English': 'Phone number is invalid.',
      },
    };
    
    if (value == null || value.isEmpty) {
      return messages[key]?[language] ?? messages[key]!['English'];
    }
    return null;
  }

  // Get email validation error message
  Future<String?> _getEmailValidationError(String? value) async {
    if (value == null || value.trim().isEmpty) {
      return await _getValidationError('emailRequired', value);
    }
    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value.trim())) {
      return await _getValidationError('emailInvalid', value);
    }
    return null;
  }

  // Get field-specific validation error messages
  Future<String?> _getFieldValidationError(String fieldName, String? value, {String? role}) async {
    if (role != null && role != _selectedRole) return null; // Don't validate if wrong role
    
    final language = await LanguageService.getCurrentLanguage();
    
    // If empty, return required message
    if (value == null || value.trim().isEmpty) {
      final requiredMessages = {
        'firstName': {
          'עברית': 'שם פרטי נדרש.',
          'العربية': 'الاسم الأول مطلوب.',
          'English': 'First name is required.',
        },
        'lastName': {
          'עברית': 'שם משפחה נדרש.',
          'العربية': 'اسم العائلة مطلوب.',
          'English': 'Last name is required.',
        },
        'email': {
          'עברית': 'כתובת אימייל נדרשת.',
          'العربية': 'عنوان البريد الإلكتروني مطلوب.',
          'English': 'Email address is required.',
        },
        'phone': {
          'עברית': 'מספר טלפון נדרש.',
          'العربية': 'رقم الهاتف مطلوب.',
          'English': 'Phone number is required.',
        },
        'password': {
          'עברית': 'סיסמה נדרשת.',
          'العربية': 'كلمة المرور مطلوبة.',
          'English': 'Password is required.',
        },
        'confirmPassword': {
          'עברית': 'אישור סיסמה נדרש.',
          'العربية': 'تأكيد كلمة المرور مطلوب.',
          'English': 'Password confirmation is required.',
        },
        'specialty': {
          'עברית': 'התמחות נדרשת.',
          'العربية': 'التخصص مطلوب.',
          'English': 'Specialty is required.',
        },
        'street': {
          'עברית': 'רחוב נדרש.',
          'العربية': 'الشارع مطلوب.',
          'English': 'Street is required.',
        },
        'city': {
          'עברית': 'עיר נדרשת.',
          'العربية': 'المدينة مطلوبة.',
          'English': 'City is required.',
        },
        'visaCardNumber': {
          'עברית': 'מספר כרטיס אשראי נדרש.',
          'العربية': 'رقم بطاقة الائتمان مطلوب.',
          'English': 'Visa card number is required.',
        },
        'cardHolderName': {
          'עברית': 'שם בעל הכרטיס נדרש.',
          'العربية': 'اسم حامل البطاقة مطلوب.',
          'English': 'Card holder name is required.',
        },
        'expiryDate': {
          'עברית': 'תאריך תפוגה נדרש.',
          'العربية': 'تاريخ انتهاء الصلاحية مطلوب.',
          'English': 'Expiry date is required.',
        },
        'cvv': {
          'עברית': 'קוד אבטחה נדרש.',
          'العربية': 'رمز الأمان مطلوب.',
          'English': 'CVV code is required.',
        },
        'idNumber': {
          'עברית': 'מספר תעודת זהות נדרש.',
          'العربية': 'رقم الهوية مطلوب.',
          'English': 'ID number is required.',
        },
      };
      return requiredMessages[fieldName]?[language] ?? requiredMessages[fieldName]?['English'];
    }
    
    // Field-specific format validation
    switch (fieldName) {
      case 'email':
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value.trim())) {
          final invalidMessages = {
            'עברית': 'Email address is invalid.',
            'العربية': 'عنوان البريد الإلكتروني غير صحيح.',
            'English': 'Email address is invalid.',
          };
          return invalidMessages[language] ?? invalidMessages['English'];
        }
        break;
      case 'phone':
        // Israeli mobile phone validation (05X only)
        final digitsOnly = value.trim().replaceAll(RegExp(r'[^\d]'), '');
        if (digitsOnly.length != 10 || !RegExp(r'^05\d{8}$').hasMatch(digitsOnly)) {
          final invalidMessages = {
            'עברית': 'יש להזין מספר נייד בלבד (05X-XXXXXXX)',
            'العربية': 'يرجى إدخال رقم جوال فقط (05X-XXXXXXX)',
            'English': 'Please enter mobile number only (05X-XXXXXXX)',
          };
          return invalidMessages[language] ?? invalidMessages['English'];
        }
        break;
      case 'password':
        if (value.length < 8) {
          final invalidMessages = {
            'עברית': 'Password must contain at least 8 characters.',
            'العربية': 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل.',
            'English': 'Password must contain at least 8 characters.',
          };
          return invalidMessages[language] ?? invalidMessages['English'];
        }
        break;
      case 'visaCardNumber':
        final cleaned = value.replaceAll(' ', '');
        if (cleaned.length < 13 || cleaned.length > 19) {
          final invalidMessages = {
            'עברית': 'Card number is invalid.',
            'العربية': 'رقم البطاقة غير صحيح.',
            'English': 'Card number is invalid.',
          };
          return invalidMessages[language] ?? invalidMessages['English'];
        }
        if (!CardValidators.validateLuhn(value)) {
          final invalidMessages = {
            'עברית': 'Card number is invalid.',
            'العربية': 'رقم البطاقة غير صحيح.',
            'English': 'Card number is invalid.',
          };
          return invalidMessages[language] ?? invalidMessages['English'];
        }
        break;
      case 'expiryDate':
        if (!CardValidators.validateExpiryFormat(value)) {
          final invalidMessages = {
            'עברית': 'Expiry date is invalid or expired.',
            'العربية': 'تاريخ انتهاء الصلاحية غير صحيح أو منتهي الصلاحية.',
            'English': 'Expiry date is invalid or expired.',
          };
          return invalidMessages[language] ?? invalidMessages['English'];
        }
        if (!CardValidators.validateExpiryNotExpired(value)) {
          final invalidMessages = {
            'עברית': 'Expiry date is invalid or expired.',
            'العربية': 'تاريخ انتهاء الصلاحية غير صحيح أو منتهي الصلاحية.',
            'English': 'Expiry date is invalid or expired.',
          };
          return invalidMessages[language] ?? invalidMessages['English'];
        }
        break;
      case 'cvv':
        if (!CardValidators.validateCVV(value)) {
          final invalidMessages = {
            'עברית': 'CVV code is invalid.',
            'العربية': 'رمز الأمان غير صحيح.',
            'English': 'CVV code is invalid.',
          };
          return invalidMessages[language] ?? invalidMessages['English'];
        }
        break;
      case 'idNumber':
        if (!CardValidators.validateIsraeliID(value)) {
          final invalidMessages = {
            'עברית': 'ID number is invalid.',
            'العربية': 'رقم الهوية غير صحيح.',
            'English': 'ID number is invalid.',
          };
          return invalidMessages[language] ?? invalidMessages['English'];
        }
        break;
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Use MaterialApp's locale for real-time updates
    final appLocale = Localizations.localeOf(context);
    // Update _currentLocale immediately for text direction
    if (appLocale != _currentLocale) {
      _currentLocale = appLocale;
    }
    // Get localizations using MaterialApp's locale
    final localizations = AppLocalizations(appLocale);
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Directionality(
                textDirection: _currentLocale.languageCode == 'ar' || _currentLocale.languageCode == 'he' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                tooltip: 'Back',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
              actions: const [],
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double formWidth =
                      (constraints.maxWidth * 0.5).clamp(320.0, 700.0);
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(), // Enable scrolling on all screen
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: formWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
                            Text(
                              localizations.registerToSystem,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.register,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 32),

                            // Registration Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Role Selection
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations.iWantToRegisterAs,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: RadioListTile<String>(
                                                title: Text(localizations.patient),
                                                value: 'patient',
                                                groupValue: _selectedRole,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedRole = value!;
                                                    _hasValidated = false; // Reset validation when role changes
                                                    _agreeToTerms = false; // Reset terms checkbox when role changes
                                                    // Clear ALL fields when switching to patient - user must fill again
                                                    _firstNameController.clear();
                                                    _lastNameController.clear();
                                                    _emailController.clear();
                                                    _phoneController.clear();
                                                    _passwordController.clear();
                                                    _confirmPasswordController.clear();
                                                    _licenseNumberController.clear();
                                                    _selectedSpecialties.clear();
                                                    _streetController.clear();
                                                    _cityController.clear();
                                                    _visaCardNumberController.clear();
                                                    _cardHolderNameController.clear();
                                                    _expiryDateController.clear();
                                                    _cvvController.clear();
                                                    _idNumberController.clear();
                                                    _obscurePassword = true;
                                                    _obscureConfirmPassword = true;
                                                    _showEmailError = false;
                                                  });
                                                },
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                            Expanded(
                                              child: RadioListTile<String>(
                                                title: Text(localizations.doctorOrTherapist),
                                                value: 'doctor',
                                                groupValue: _selectedRole,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedRole = value!;
                                                    _hasValidated = false; // Reset validation when role changes
                                                    _agreeToTerms = false; // Reset terms checkbox when role changes
                                                    // Clear ALL fields when switching to doctor - user must fill again
                                                    _firstNameController.clear();
                                                    _lastNameController.clear();
                                                    _emailController.clear();
                                                    _phoneController.clear();
                                                    _passwordController.clear();
                                                    _confirmPasswordController.clear();
                                                    _obscurePassword = true;
                                                    _obscureConfirmPassword = true;
                                                    _showEmailError = false;
                                                  });
                                                },
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Admin Approval Notice for Doctors
                                        if (_selectedRole == 'doctor') ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.orange.shade200),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    localizations.doctorApprovalNotice,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.orange.shade900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Name Fields
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              controller: _firstNameController,
                                              textDirection: _currentLocale.languageCode == 'ar' || _currentLocale.languageCode == 'he' 
                                                  ? TextDirection.rtl 
                                                  : TextDirection.ltr,
                                              textInputAction: TextInputAction.next,
                                              textCapitalization: TextCapitalization.words,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\u0590-\u05FF\u0600-\u06FF]')),
                                                TextInputFormatter.withFunction((oldValue, newValue) {
                                                  if (newValue.text.isNotEmpty) {
                                                    // Capitalize first letter of each word
                                                    final words = newValue.text.split(' ');
                                                    final capitalizedWords = words.map((word) {
                                                      if (word.isEmpty) return word;
                                                      return word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : '');
                                                    }).toList();
                                                    final capitalizedText = capitalizedWords.join(' ');
                                                    return TextEditingValue(
                                                      text: capitalizedText,
                                                      selection: TextSelection.collapsed(offset: capitalizedText.length),
                                                    );
                                                  }
                                                  return newValue;
                                                }),
                                              ],
                                              decoration: InputDecoration(
                                                labelText: localizations.firstName,
                                                prefixIcon: const Icon(Icons.person_outline),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              onEditingComplete: () {
                                                // Trigger validation when moving to next field
                                                setState(() {
                                                  _hasValidated = true;
                                                });
                                                _formKey.currentState?.validate();
                                              },
                                              validator: _hasValidated ? (value) {
                                                if (value == null || value.isEmpty) {
                                                  return ' '; // Will show error below
                                                }
                                                return null;
                                              } : null,
                                            ),
                                            if (_hasValidated)
                                              FutureBuilder<String?>(
                                                future: _getFieldValidationError('firstName', _firstNameController.text, role: null),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData && snapshot.data != null) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                                      child: Text(
                                                        snapshot.data!,
                                                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox.shrink();
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              controller: _lastNameController,
                                              textDirection: _currentLocale.languageCode == 'ar' || _currentLocale.languageCode == 'he' 
                                                  ? TextDirection.rtl 
                                                  : TextDirection.ltr,
                                              textInputAction: TextInputAction.next,
                                              textCapitalization: TextCapitalization.words,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\u0590-\u05FF\u0600-\u06FF]')),
                                                TextInputFormatter.withFunction((oldValue, newValue) {
                                                  if (newValue.text.isNotEmpty) {
                                                    // Capitalize first letter of each word
                                                    final words = newValue.text.split(' ');
                                                    final capitalizedWords = words.map((word) {
                                                      if (word.isEmpty) return word;
                                                      return word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : '');
                                                    }).toList();
                                                    final capitalizedText = capitalizedWords.join(' ');
                                                    return TextEditingValue(
                                                      text: capitalizedText,
                                                      selection: TextSelection.collapsed(offset: capitalizedText.length),
                                                    );
                                                  }
                                                  return newValue;
                                                }),
                                              ],
                                              decoration: InputDecoration(
                                                labelText: localizations.lastName,
                                                prefixIcon: const Icon(Icons.person_outline),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              onEditingComplete: () {
                                                // Trigger validation when moving to next field
                                                setState(() {
                                                  _hasValidated = true;
                                                });
                                                _formKey.currentState?.validate();
                                              },
                                              validator: _hasValidated ? (value) {
                                                if (value == null || value.isEmpty) {
                                                  return ' '; // Will show error below
                                                }
                                                return null;
                                              } : null,
                                            ),
                                            if (_hasValidated)
                                              FutureBuilder<String?>(
                                                future: _getFieldValidationError('lastName', _lastNameController.text, role: null),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData && snapshot.data != null) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                                      child: Text(
                                                        snapshot.data!,
                                                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox.shrink();
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Email Field (Username)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        textDirection: TextDirection.ltr, // Email is always LTR
                                        textInputAction: TextInputAction.next,
                                        onChanged: (value) {
                                          // Real-time validation - show error if format is invalid
                                          if (value.isNotEmpty) {
                                            setState(() {
                                              _showEmailError = true;
                                            });
                                            _formKey.currentState?.validate();
                                          }
                                        },
                                        onEditingComplete: () {
                                          // Validate when moving to next field
                                          setState(() {
                                            _showEmailError = true;
                                          });
                                          _formKey.currentState?.validate();
                                        },
                                        decoration: InputDecoration(
                                          labelText: '${localizations.email} (${localizations.username})',
                                          hintText: 'example@email.com',
                                          prefixIcon: const Icon(Icons.email_outlined),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          errorText: null, // We'll show error below
                                        ),
                                        validator: _hasValidated ? (value) {
                                          if (value == null || value.isEmpty) {
                                            return ' '; // Will show error below
                                          }
                                          // Validate email format (it's the username)
                                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
                                            return ' '; // Will show error below
                                          }
                                          return null;
                                        } : null,
                                      ),
                                      // Show email validation error below field
                                      if (_showEmailError && _emailController.text.isNotEmpty)
                                        Builder(
                                          builder: (context) {
                                            final email = _emailController.text;
                                            if (email.isEmpty) {
                                              return const SizedBox.shrink();
                                            }
                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
                                              return FutureBuilder<String?>(
                                                future: _getEmailValidationError(email),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData && snapshot.data != null) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                                      child: Text(
                                                        snapshot.data!,
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox.shrink();
                                                },
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      if (_hasValidated && _emailController.text.isEmpty)
                                        FutureBuilder<String?>(
                                          future: _getEmailValidationError(_emailController.text),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData && snapshot.data != null) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                                child: Text(
                                                  snapshot.data!,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Phone Field (Israeli mobile only - 05X)
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textDirection: TextDirection.ltr,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10), // Israeli mobile phones are 10 digits
                                    ],
                                    onEditingComplete: () {
                                      // Trigger validation when moving to next field
                                      setState(() {
                                        _hasValidated = true;
                                      });
                                      _formKey.currentState?.validate();
                                    },
                                    decoration: InputDecoration(
                                      labelText: '${localizations.phone} (${localizations.mobileOnly})',
                                      hintText: '0501234567',
                                      helperText: localizations.mobilePhoneHint,
                                      prefixIcon: const Icon(Icons.phone_android_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    validator: _hasValidated ? (value) {
                                      if (value == null || value.isEmpty) {
                                        return ' '; // Will show error below
                                      }
                                      // Israeli mobile phone validation: 10 digits, must start with 05
                                      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                                      if (digitsOnly.length != 10) {
                                        return ' '; // Will show error below
                                      }
                                      // Must start with 05 (mobile only)
                                      if (!RegExp(r'^05\d{8}$').hasMatch(digitsOnly)) {
                                        return ' '; // Will show error below
                                      }
                                      return null;
                                    } : null,
                                  ),
                                  // Show phone validation error below field
                                  if (_hasValidated && _phoneController.text.isNotEmpty)
                                    FutureBuilder<String?>(
                                      future: _getFieldValidationError('phone', _phoneController.text, role: null),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData && snapshot.data != null) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                            child: Text(
                                              snapshot.data!,
                                              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  if (_hasValidated && _phoneController.text.isEmpty)
                                    FutureBuilder<String?>(
                                      future: _getFieldValidationError('phone', '', role: null),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData && snapshot.data != null) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                            child: Text(
                                              snapshot.data!,
                                              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),

                                  // Doctor-specific fields
                                  if (_selectedRole == 'doctor') ...[
                                    const SizedBox(height: 16),
                                    
                                    // License Number (Optional)
                                    TextFormField(
                                      controller: _licenseNumberController,
                                      textDirection: TextDirection.ltr,
                                      decoration: InputDecoration(
                                        labelText: '${localizations.licenseNumber} (${localizations.optional})',
                                        hintText: localizations.licenseNumber,
                                        prefixIcon: const Icon(Icons.badge_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      // No validator - optional field
                                    ),

                                    const SizedBox(height: 16),

                                    // Specialty Multi-Select
                                    GestureDetector(
                                      onTap: () => _showSpecialtySelector(context, localizations),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.medical_services_outlined, color: Colors.grey),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _selectedSpecialties.isEmpty
                                                  ? Text(
                                                      localizations.selectSpecialties,
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 16,
                                                      ),
                                                    )
                                                  : Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: _selectedSpecialties.map((spec) {
                                                        final name = localizations.getSpecialtyName(spec);
                                                        return Chip(
                                                          label: Text(name[_currentLocale.languageCode] ?? spec),
                                                          onDeleted: () {
                                                            setState(() {
                                                              _selectedSpecialties.remove(spec);
                                                            });
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                            ),
                                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_selectedRole == 'doctor' && _selectedSpecialties.isEmpty && _hasValidated)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, right: 12),
                                        child: Text(
                                          localizations.specialtyRequired,
                                          style: const TextStyle(color: Colors.red, fontSize: 12),
                                        ),
                                      ),

                                    const SizedBox(height: 16),

                                    // Street Address
                                    TextFormField(
                                      controller: _streetController,
                                      textDirection: _currentLocale.languageCode == 'ar' || _currentLocale.languageCode == 'he' 
                                          ? TextDirection.rtl 
                                          : TextDirection.ltr,
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: () {
                                        // Trigger validation when moving to next field
                                        setState(() {
                                          _hasValidated = true;
                                        });
                                        _formKey.currentState?.validate();
                                      },
                                      decoration: InputDecoration(
                                        labelText: localizations.street,
                                        hintText: localizations.street,
                                        prefixIcon: const Icon(Icons.home_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      validator: (_hasValidated && _selectedRole == 'doctor') ? (value) {
                                        if (value == null || value.isEmpty) {
                                          return ' '; // Will show error below
                                        }
                                        return null;
                                      } : null,
                                    ),

                                    const SizedBox(height: 16),

                                    // City
                                    TextFormField(
                                      controller: _cityController,
                                      textDirection: _currentLocale.languageCode == 'ar' || _currentLocale.languageCode == 'he' 
                                          ? TextDirection.rtl 
                                          : TextDirection.ltr,
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: () {
                                        // Trigger validation when moving to next field
                                        setState(() {
                                          _hasValidated = true;
                                        });
                                        _formKey.currentState?.validate();
                                      },
                                      decoration: InputDecoration(
                                        labelText: localizations.city,
                                        hintText: localizations.city,
                                        prefixIcon: const Icon(Icons.location_city_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      validator: (_hasValidated && _selectedRole == 'doctor') ? (value) {
                                        if (value == null || value.isEmpty) {
                                          return ' '; // Will show error below
                                        }
                                        return null;
                                      } : null,
                                    ),

                                    const SizedBox(height: 16),

                                    // Country (Default: Israel, Disabled)
                                    TextFormField(
                                      controller: _countryController,
                                      textDirection: _currentLocale.languageCode == 'ar' || _currentLocale.languageCode == 'he' 
                                          ? TextDirection.rtl 
                                          : TextDirection.ltr,
                                      enabled: false, // Disabled for now
                                      decoration: InputDecoration(
                                        labelText: localizations.country,
                                        hintText: 'Israel',
                                        prefixIcon: const Icon(Icons.public_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade100, // Gray background to show disabled
                                      ),
                                      // No validator - always has value (Israel)
                                    ),

                                    const SizedBox(height: 16),

                                    // Payment Information Section for Verification
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.payment, color: Colors.blue.shade700),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  localizations.paymentInformation,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.blue.shade900,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Payment Information Description
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    localizations.paymentInfoDescription,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue.shade900,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Visa Card Number
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextFormField(
                                                controller: _visaCardNumberController,
                                                keyboardType: TextInputType.number,
                                                textDirection: TextDirection.ltr,
                                                textInputAction: TextInputAction.next,
                                                inputFormatters: [
                                                  CardNumberFormatter(),
                                                  FilteringTextInputFormatter.digitsOnly,
                                                ],
                                                onEditingComplete: () {
                                                  // Trigger validation when moving to next field
                                                  setState(() {
                                                    _hasValidated = true;
                                                  });
                                                  _formKey.currentState?.validate();
                                                },
                                                decoration: InputDecoration(
                                                  labelText: localizations.visaCardNumber,
                                                  hintText: '1234 5678 9012 3456',
                                                  prefixIcon: const Icon(Icons.credit_card),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                validator: (_hasValidated && _selectedRole == 'doctor') ? (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return ' '; // Will show error below
                                                  }
                                                  final cleaned = value.replaceAll(' ', '');
                                                  if (cleaned.length < 13 || cleaned.length > 19) {
                                                    return ' '; // Invalid length
                                                  }
                                                  if (!CardValidators.validateLuhn(value)) {
                                                    return ' '; // Luhn check failed
                                                  }
                                                  return null;
                                                } : null,
                                              ),
                                              if (_hasValidated && _selectedRole == 'doctor')
                                                FutureBuilder<String?>(
                                                  future: _getFieldValidationError('visaCardNumber', _visaCardNumberController.text, role: 'doctor'),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData && snapshot.data != null) {
                                                      return Padding(
                                                        padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                                        child: Text(
                                                          snapshot.data!,
                                                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox.shrink();
                                                  },
                                                ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          // Card Holder Name
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextFormField(
                                                controller: _cardHolderNameController,
                                                textDirection: _currentLocale.languageCode == 'ar' || _currentLocale.languageCode == 'he' 
                                                    ? TextDirection.rtl 
                                                    : TextDirection.ltr,
                                                textInputAction: TextInputAction.next,
                                                onEditingComplete: () {
                                                  // Trigger validation when moving to next field
                                                  setState(() {
                                                    _hasValidated = true;
                                                  });
                                                  _formKey.currentState?.validate();
                                                },
                                                decoration: InputDecoration(
                                                  labelText: localizations.cardHolderName,
                                                  hintText: localizations.cardHolderName,
                                                  prefixIcon: const Icon(Icons.person),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                validator: (_hasValidated && _selectedRole == 'doctor') ? (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return ' '; // Will show error below
                                                  }
                                                  return null;
                                                } : null,
                                              ),
                                              if (_hasValidated && _selectedRole == 'doctor')
                                                FutureBuilder<String?>(
                                                  future: _getFieldValidationError('cardHolderName', _cardHolderNameController.text, role: 'doctor'),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData && snapshot.data != null) {
                                                      return Padding(
                                                        padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                                        child: Text(
                                                          snapshot.data!,
                                                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox.shrink();
                                                  },
                                                ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          // Expiry Date and CVV Row
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextFormField(
                                                      controller: _expiryDateController,
                                                      keyboardType: TextInputType.number,
                                                      textDirection: TextDirection.ltr,
                                                      textInputAction: TextInputAction.next,
                                                      inputFormatters: [
                                                        ExpiryDateFormatter(),
                                                      ],
                                                      onEditingComplete: () {
                                                        // Trigger validation when moving to next field
                                                        setState(() {
                                                          _hasValidated = true;
                                                        });
                                                        _formKey.currentState?.validate();
                                                      },
                                                      decoration: InputDecoration(
                                                        labelText: localizations.expiryDate,
                                                        hintText: 'MM/YY',
                                                        prefixIcon: const Icon(Icons.calendar_today),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      validator: (_hasValidated && _selectedRole == 'doctor') ? (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return ' '; // Will show error below
                                                        }
                                                        if (!CardValidators.validateExpiryFormat(value)) {
                                                          return ' '; // Invalid format
                                                        }
                                                        if (!CardValidators.validateExpiryNotExpired(value)) {
                                                          return ' '; // Expired or invalid date
                                                        }
                                                        return null;
                                                      } : null,
                                                    ),
                                                    if (_hasValidated && _selectedRole == 'doctor')
                                                      FutureBuilder<String?>(
                                                        future: _getFieldValidationError('expiryDate', _expiryDateController.text, role: 'doctor'),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.hasData && snapshot.data != null) {
                                                            return Padding(
                                                              padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                                              child: Text(
                                                                snapshot.data!,
                                                                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                                              ),
                                                            );
                                                          }
                                                          return const SizedBox.shrink();
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TextFormField(
                                                      controller: _cvvController,
                                                      keyboardType: TextInputType.number,
                                                      textDirection: TextDirection.ltr,
                                                      textInputAction: TextInputAction.next,
                                                      obscureText: true,
                                                      inputFormatters: [
                                                        CVVFormatter(),
                                                        FilteringTextInputFormatter.digitsOnly,
                                                      ],
                                                      onEditingComplete: () {
                                                        // Trigger validation when moving to next field
                                                        setState(() {
                                                          _hasValidated = true;
                                                        });
                                                        _formKey.currentState?.validate();
                                                      },
                                                      decoration: InputDecoration(
                                                        labelText: localizations.cvv,
                                                        hintText: '123',
                                                        prefixIcon: const Icon(Icons.lock),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                      ),
                                                      validator: (_hasValidated && _selectedRole == 'doctor') ? (value) {
                                                        if (value == null || value.isEmpty) {
                                                          return ' '; // Will show error below
                                                        }
                                                        if (!CardValidators.validateCVV(value)) {
                                                          return ' '; // Invalid CVV format
                                                        }
                                                        return null;
                                                      } : null,
                                                    ),
                                                    if (_hasValidated && _selectedRole == 'doctor')
                                                      FutureBuilder<String?>(
                                                        future: _getFieldValidationError('cvv', _cvvController.text, role: 'doctor'),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.hasData && snapshot.data != null) {
                                                            return Padding(
                                                              padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                                              child: Text(
                                                                snapshot.data!,
                                                                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                                              ),
                                                            );
                                                          }
                                                          return const SizedBox.shrink();
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          // ID Number
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextFormField(
                                                controller: _idNumberController,
                                                keyboardType: TextInputType.number,
                                                textDirection: TextDirection.ltr,
                                                textInputAction: TextInputAction.next,
                                                inputFormatters: [
                                                  IsraeliIDFormatter(),
                                                  FilteringTextInputFormatter.digitsOnly,
                                                ],
                                                onEditingComplete: () {
                                                  // Trigger validation when moving to next field
                                                  setState(() {
                                                    _hasValidated = true;
                                                  });
                                                  _formKey.currentState?.validate();
                                                },
                                                decoration: InputDecoration(
                                                  labelText: localizations.idNumber,
                                                  hintText: '123456789',
                                                  prefixIcon: const Icon(Icons.badge),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                validator: (_hasValidated && _selectedRole == 'doctor') ? (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return ' '; // Will show error below
                                                  }
                                                  if (!CardValidators.validateIsraeliID(value)) {
                                                    return ' '; // Invalid ID format
                                                  }
                                                  return null;
                                                } : null,
                                              ),
                                              if (_hasValidated && _selectedRole == 'doctor')
                                                FutureBuilder<String?>(
                                                  future: _getFieldValidationError('idNumber', _idNumberController.text, role: 'doctor'),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData && snapshot.data != null) {
                                                      return Padding(
                                                        padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                                        child: Text(
                                                          snapshot.data!,
                                                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox.shrink();
                                                  },
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textDirection: TextDirection.ltr,
                                    textInputAction: TextInputAction.next,
                                    onEditingComplete: () {
                                      // Trigger validation when moving to next field
                                      setState(() {
                                        _hasValidated = true;
                                      });
                                      _formKey.currentState?.validate();
                                    },
                                    decoration: InputDecoration(
                                      labelText: localizations.password,
                                      hintText: localizations.password,
                                      prefixIcon: const Icon(Icons.lock_outlined),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                          // Auto-hide password after 5 seconds
                                          _passwordVisibilityTimer?.cancel();
                                          if (!_obscurePassword) {
                                            _passwordVisibilityTimer = Timer(const Duration(seconds: 5), () {
                                              if (mounted) {
                                                setState(() {
                                                  _obscurePassword = true;
                                                });
                                              }
                                            });
                                          }
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    validator: _hasValidated ? (value) {
                                      if (value == null || value.isEmpty) {
                                        return ' '; // Will show error below
                                      }
                                      if (value.length < 8) {
                                        return ' '; // Will show error below
                                      }
                                      return null;
                                    } : null,
                                  ),

                                  const SizedBox(height: 16),

                                  // Confirm Password Field
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    textDirection: TextDirection.ltr,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: () {
                                      // Trigger validation when moving to next field
                                      setState(() {
                                        _hasValidated = true;
                                      });
                                      _formKey.currentState?.validate();
                                    },
                                    decoration: InputDecoration(
                                      labelText: localizations.confirmPassword,
                                      hintText: localizations.confirmPassword,
                                      prefixIcon: const Icon(Icons.lock_outlined),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword = !_obscureConfirmPassword;
                                          });
                                          // Auto-hide confirm password after 5 seconds
                                          _passwordVisibilityTimer?.cancel();
                                          if (!_obscureConfirmPassword) {
                                            _passwordVisibilityTimer = Timer(const Duration(seconds: 5), () {
                                              if (mounted) {
                                                setState(() {
                                                  _obscureConfirmPassword = true;
                                                });
                                              }
                                            });
                                          }
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    validator: _hasValidated ? (value) {
                                      if (value == null || value.isEmpty) {
                                        return ' '; // Will show error below
                                      }
                                      if (value != _passwordController.text) {
                                        return ' '; // Will show error below
                                      }
                                      return null;
                                    } : null,
                                  ),

                                  const SizedBox(height: 16),

                                  // Terms Agreement with Privacy Policy Link
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeToTerms = value ?? false;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _agreeToTerms = !_agreeToTerms;
                                            });
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(fontSize: 14, color: Colors.black87),
                                              children: [
                                                // Display the same terms text for both roles
                                                TextSpan(
                                                  text: localizations.agreeToTerms.replaceAll(localizations.termsAndPrivacy, '').trim(),
                                                ),
                                                const TextSpan(text: ' '),
                                                WidgetSpan(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      PrivacyPolicyPopup.show(context);
                                                    },
                                                    child: Text(
                                                      localizations.termsAndPrivacy,
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        decoration: TextDecoration.underline,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Register Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                      child: ElevatedButton(
                                      onPressed: (_isLoading || !_agreeToTerms) ? null : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
                                                        Colors.white),
                                              ),
                                            )
                                          : Text(
                                              localizations.register,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Login Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('${localizations.alreadyHaveAccount} '),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacementNamed('/login');
                                        },
                                        child: Text(
                                          localizations.loginHere,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ), // Closes Column
                      ), // Closes ConstrainedBox
                    ), // Closes Center
                  ); // Closes SingleChildScrollView and ends return
                }, // Closes LayoutBuilder builder function
              ), // Closes LayoutBuilder
            ), // Closes SafeArea (body property)
          ), // Closes Scaffold
      ), // Closes Directionality
    ); // Closes PopScope
  }

  // Separate validation methods for Patient and Doctor
  bool _validatePatientFields() {
    bool isValid = true;
    
    if (_firstNameController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_lastNameController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_emailController.text.trim().isEmpty || 
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(_emailController.text.trim())) {
      isValid = false;
    }
    if (_phoneController.text.trim().isEmpty) {
      isValid = false;
    }
    // Validate Israeli mobile phone (05X only)
    final phoneDigits = _phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (phoneDigits.length != 10 || !RegExp(r'^05\d{8}$').hasMatch(phoneDigits)) {
      isValid = false;
    }
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      isValid = false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      isValid = false;
    }
    
    return isValid;
  }
  
  bool _validateDoctorFields() {
    bool isValid = true;
    
    if (_firstNameController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_lastNameController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_emailController.text.trim().isEmpty || 
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(_emailController.text.trim())) {
      isValid = false;
    }
    if (_phoneController.text.trim().isEmpty) {
      isValid = false;
    }
    // Validate Israeli mobile phone (05X only)
    final phoneDigits = _phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (phoneDigits.length != 10 || !RegExp(r'^05\d{8}$').hasMatch(phoneDigits)) {
      isValid = false;
    }
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      isValid = false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      isValid = false;
    }
    if (_selectedSpecialties.isEmpty) {
      isValid = false;
    }
    if (_streetController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_cityController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_visaCardNumberController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_cardHolderNameController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_expiryDateController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_cvvController.text.trim().isEmpty) {
      isValid = false;
    }
    if (_idNumberController.text.trim().isEmpty) {
      isValid = false;
    }
    
    return isValid;
  }

  void _handleRegister() async {
    // Set validation flag to true so errors will show
    setState(() {
      _hasValidated = true;
      _showEmailError = true; // Show email error if any
    });
    
    // Validate form first - this will validate all visible fields
    bool isValid = _formKey.currentState!.validate();
    
    // Then validate based on role to ensure all required fields are filled
    if (isValid) {
      if (_selectedRole == 'patient') {
        isValid = _validatePatientFields();
      } else if (_selectedRole == 'doctor') {
        isValid = _validateDoctorFields();
      } else {
        isValid = false;
      }
    }
    
    if (!isValid) {
      // Show popup dialog with generic message
      final language = await LanguageService.getCurrentLanguage();
      final message = {
        'עברית': 'נא למלא את כל השדות הנדרשים',
        'العربية': 'يرجى ملء جميع الحقول المطلوبة',
        'English': 'Please fill in all required fields',
      }[language] ?? 'Please fill in all required fields';
      
      // Show popup dialog
      if (mounted) {
        final dialogLocalizations = AppLocalizations(Localizations.localeOf(context));
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(dialogLocalizations.error),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(dialogLocalizations.ok),
              ),
            ],
          ),
        );
      }
      
      // Form validation will trigger and show field-specific errors below each field
      return;
    }

    if (!_agreeToTerms) {
      final language = await LanguageService.getCurrentLanguage();
      final message = {
        'עברית': 'נא לאשר את תנאי השימוש',
        'العربية': 'يرجى الموافقة على الشروط',
        'English': 'Please agree to the terms',
      }[language] ?? 'Please agree to the terms';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate specialties for doctors only
    if (_selectedRole == 'doctor' && _selectedSpecialties.isEmpty) {
      final language = await LanguageService.getCurrentLanguage();
      final message = {
        'עברית': 'נא לבחור לפחות התמחות אחת',
        'العربية': 'يرجى اختيار تخصص واحد على الأقل',
        'English': 'Please select at least one specialty',
      }[language] ?? 'Please select at least one specialty';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if email already exists
    try {
      final authService = AuthService();
      final emailExists = await authService.checkEmailExists(_emailController.text.trim())
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout. Please try again.');
            },
          );
      
      if (emailExists) {
        final language = await LanguageService.getCurrentLanguage();
        final message = {
          'עברית': 'כתובת האימייל כבר קיימת במערכת. אנא השתמש בכתובת אימייל אחרת או התחבר לחשבון הקיים.',
          'العربية': 'عنوان البريد الإلكتروني موجود بالفعل في النظام. يرجى استخدام عنوان بريد إلكتروني آخر أو تسجيل الدخول إلى الحساب الموجود.',
          'English': 'Email address already exists in the system. Please use a different email address or login to your existing account.',
        }[language] ?? 'Email address already exists in the system. Please use a different email address or login to your existing account.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      // If email check fails, continue with registration (backend will handle it)
      if (mounted && !e.toString().contains('timeout')) {
        // Only show error if it's not a timeout (timeout is handled by backend)
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        // Doctor-specific card details
        visaCardNumber: _selectedRole == 'doctor' ? _visaCardNumberController.text.trim() : null,
        cardHolderName: _selectedRole == 'doctor' ? _cardHolderNameController.text.trim() : null,
        expiryDate: _selectedRole == 'doctor' ? _expiryDateController.text.trim() : null,
        cvv: _selectedRole == 'doctor' ? _cvvController.text.trim() : null,
        idNumber: _selectedRole == 'doctor' ? _idNumberController.text.trim() : null,
      );

      if (mounted) {
        final language = await LanguageService.getCurrentLanguage();
        final dialogLocalizations = AppLocalizations(Localizations.localeOf(context));
        
        final title = {
          'עברית': 'הרשמה הושלמה בהצלחה',
          'العربية': 'تم التسجيل بنجاح',
          'English': 'Registration Successful',
        }[language] ?? 'Registration Successful';
        
        final successMessage = {
          'עברית': _selectedRole == 'doctor' 
              ? 'נרשמת בהצלחה כרופא/מטפל! חשבונך ממתין לאישור מנהל. נא לבדוק את תיבת הדואר לאימות כתובת האימייל.'
              : 'נרשמת בהצלחה! נא לבדוק את תיבת הדואר לאימות כתובת האימייל.',
          'العربية': _selectedRole == 'doctor'
              ? 'تم التسجيل بنجاح كطبيب/معالج! حسابك في انتظار موافقة المدير. يرجى التحقق من بريدك الإلكتروني للتحقق من عنوان البريد الإلكتروني.'
              : 'تم التسجيل بنجاح! يرجى التحقق من بريدك الإلكتروني للتحقق من عنوان البريد الإلكتروني.',
          'English': _selectedRole == 'doctor'
              ? 'Successfully registered as doctor/therapist! Your account is pending admin approval. Please check your email to verify your email address.'
              : 'Successfully registered! Please check your email to verify your email address.',
        }[language] ?? 'Successfully registered!';
        
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Text(successMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login
                },
                child: Text(dialogLocalizations.ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final language = await LanguageService.getCurrentLanguage();
        final errorMessage = {
          'עברית': 'שגיאה בהרשמה: ${e.toString()}',
          'العربية': 'خطأ في التسجيل: ${e.toString()}',
          'English': 'Registration error: ${e.toString()}',
        }[language] ?? 'Registration error: ${e.toString()}';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSpecialtySelector(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.selectSpecialties),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppConstants.medicalSpecialties.map((specKey) {
                  final name = localizations.getSpecialtyName(specKey);
                  final isSelected = _selectedSpecialties.contains(specKey);
                  return CheckboxListTile(
                    title: Text(name[_currentLocale.languageCode] ?? specKey),
                    value: isSelected,
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedSpecialties.add(specKey);
                        } else {
                          _selectedSpecialties.remove(specKey);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(localizations.save),
          ),
        ],
      ),
    );
  }

}
