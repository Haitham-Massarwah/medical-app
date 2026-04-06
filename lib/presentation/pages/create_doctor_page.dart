import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../services/doctor_service.dart';
import '../../services/user_service.dart';

class CreateDoctorPage extends StatefulWidget {
  final bool isAdmin;

  const CreateDoctorPage({super.key, this.isAdmin = false});

  @override
  State<CreateDoctorPage> createState() => _CreateDoctorPageState();
}

class _CreateDoctorPageState extends State<CreateDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _adminService = AdminService();
  final DoctorService _doctorService = DoctorService();
  final UserService _userService = UserService();
  bool _doctorPaymentsEnabled = true; // Default to enabled

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _bioController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _calculatedPriceController =
      TextEditingController();
  final double _monthlyBasePrice = 150.0;

  final List<String> _selectedSpecialties = ['כללי'];
  List<String> _selectedLanguages = ['עברית'];
  String? _specialtyDropdownValue;
  String? _languageDropdownValue;
  bool _isLoading = false;
  bool _licenseInfoEnabled = false;
  bool _bankDetailsEnabled = false;
  bool _doctorBillingEnabled = false;
  bool _appPaymentsEnabled = false;
  bool _doctorApproved = false;
  bool _feeDeductionEnabled = false;
  String _selectedPlanId = 'plan_1_month';
  int _selectedInstallments = 1;
  final TextEditingController _feePercentageController =
      TextEditingController();
  final bool _isFeeExemptionActive =
      true; // TODO: Replace with backend flag when available
  late final List<int> _installmentOptions =
      List<int>.generate(36, (index) => index + 1);

  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'id': 'plan_1_month',
      'label': 'חודש',
      'months': 1,
    },
    {
      'id': 'plan_3_months',
      'label': '3 חודשים',
      'months': 3,
    },
    {
      'id': 'plan_6_months',
      'label': '6 חודשים',
      'months': 6,
    },
    {
      'id': 'plan_1_year',
      'label': 'שנה',
      'months': 12,
    },
    {
      'id': 'plan_2_years',
      'label': 'שנתיים',
      'months': 24,
    },
    {
      'id': 'plan_3_years',
      'label': '3 שנים',
      'months': 36,
    },
    {
      'id': 'plan_5_years',
      'label': '5 שנים',
      'months': 60,
    },
  ];

  final List<String> _specialties = [
    // 🦷 Dental & Oral Care
    'רופא שיניים',
    'היגייניסט דנטלי',
    'אורתודונט',
    'פריודונט',
    'כירורג פה ולסת',
    'מומחה הלבנת שיניים',
    'רופא שיניים לילדים',

    // 💆 Physical Therapy & Body Treatments
    'פיזיותרפיסט',
    'אוסטיאופת',
    'כירופרקט',
    'מעסה',
    'רפלקסולוג',
    'דיקור סיני',
    'מטפל בכוסות רוח',
    'מטפל שיאצו',
    'מעסה ספורט',
    'מטפל שחרור מיופציאלי',
    'מומחה נקודות טריגר',

    // 💅 Aesthetic & Beauty Treatments
    'מומחה הסרת שיער',
    'מומחה טיפוח פנים',
    'אחות קוסמטית',
    'מומחה קונטור גוף',
    'מומחה אנטי אייג\'ינג',
    'מומחה הסרת קעקועים',

    // 🌿 Complementary & Holistic Medicine
    'נטורופת',
    'מטפל ברפואת צמחים',
    'הומאופת',
    'ארומתרפיסט',
    'מטפל רייקי',
    'מטפל אנרגיה',
    'מטפל איורוודה',
    'מטפל רפואה סינית',

    // 🧘 Wellness & Rehabilitation
    'תזונאי',
    'דיאטן',
    'מאמן בריאות',
    'מדריך יוגה טיפולית',
    'מדריך פילאטיס שיקומי',
    'מאמן כושר רפואי',
    'מומחה שיקום',

    // 🧠 Mental Health & Emotional Support
    'פסיכולוג',
    'פסיכותרפיסט',
    'יועץ',
    'מטפל באמנות',
    'מטפל במוזיקה',
    'היפנותרפיסט',
    'מאמן חיים',
    'מטפל CBT',

    // 👂 Sensory & Communication Therapies
    'קלינאי תקשורת',
    'מומחה מכשירי שמיעה',
    'מרפא בעיסוק',
    'מטפל ראייה',

    // 👶 Family & Women's Health
    'מיילדת',
    'דולה',
    'יועצת הנקה',
    'מטפל טרום/אחרי לידה',
    'מרפא בעיסוק ילדים',
    'מומחה רצפת אגן נשים',

    // 🦾 Rehabilitation & Medical Support
    'אורטוטיסט/פרוסטיטיסט',
    'אחות שיקום',
    'מומחה ניהול כאב',
    'מומחה שיקום ספורט',

    // General
    'כללי',
    'קרדיולוגיה',
    'נוירולוגיה',
    'אורתופדיה',
    'רפואת עיניים',
    'רפואת עור',
    'רפואת נשים',
    'רפואת ילדים',
    'פסיכיאטריה',
    'אנדוקרינולוגיה',
  ];

  final List<String> _languages = [
    'עברית',
    'ערבית',
    'אנגלית',
    'רוסית',
    'צרפתית',
    'ספרדית',
    'גרמנית',
    'איטלקית',
    'פורטוגזית',
    'הולנדית',
    'אמהרית',
    'תורכית',
    'פרסית',
    'אוקראינית',
    'פולנית',
    'תאילנדית',
    'סינית',
    'יפנית',
    'הינדי',
  ];

  @override
  void initState() {
    super.initState();
    _discountController.addListener(() {
      setState(() {
        _refreshCalculatedPrice();
      });
    });
    _refreshCalculatedPrice();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    try {
      final permissions = await _adminService.getPermissions();
      if (mounted) {
        setState(() {
          _doctorPaymentsEnabled = permissions['doctor_payments_enabled'] ?? true;
          // If payments disabled, disable billing
          if (!_doctorPaymentsEnabled) {
            _doctorBillingEnabled = false;
          }
        });
      }
    } catch (e) {
      // Default to enabled if error
      setState(() {
        _doctorPaymentsEnabled = true;
      });
    }
  }

  Map<String, dynamic> get _currentPlan =>
      _subscriptionPlans.firstWhere((plan) => plan['id'] == _selectedPlanId);

  double _calculatePlanBasePrice() {
    final months = (_currentPlan['months'] as int);
    return months * _monthlyBasePrice;
  }

  double _calculatePlanPrice() {
    final basePrice = _calculatePlanBasePrice();
    final discountRaw =
        double.tryParse(_discountController.text.replaceAll(',', '.').trim()) ??
            0;
    final discount = discountRaw.clamp(0, 100);
    return basePrice * (1 - discount / 100);
  }

  void _refreshCalculatedPrice() {
    _calculatedPriceController.text = _calculatePlanPrice().toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final currentPlan = _currentPlan;
    final int currentPlanMonths = currentPlan['months'] as int;
    final double basePlanPrice = _calculatePlanBasePrice();
    final double discountedPlanPrice = _calculatePlanPrice();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('יצירת רופא חדש'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final double formWidth =
                      (constraints.maxWidth * 0.3).clamp(320.0, 560.0);
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: formWidth),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Personal Information Section
                            _buildSectionHeader('פרטים אישיים'),
                            if (!widget.isAdmin)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.orange.shade200),
                                  ),
                                  child: const Text(
                                    'רק מנהלים יכולים לעדכן חיוב רופא ותוכנית מנוי. הבקשה תישמר לסקירת מנהל.',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),

                            // First Name
                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'שם פרטי',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין שם פרטי';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Last Name
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'שם משפחה',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין שם משפחה';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'כתובת אימייל',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין כתובת אימייל';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'נא להזין כתובת אימייל תקינה';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'מספר טלפון',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין מספר טלפון';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: 'עיר',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין עיר';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Medical Information Section
                            _buildSectionHeader('מידע רפואי'),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              value: _specialtyDropdownValue,
                              decoration: InputDecoration(
                                labelText: 'בחר התמחות',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              dropdownColor: Colors.white,
                              items: _specialties.map((specialty) {
                                final isSelected =
                                    _selectedSpecialties.contains(specialty);
                                return DropdownMenuItem<String>(
                                  value: specialty,
                                  enabled: !isSelected,
                                  child: Text(
                                    specialty,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  if (!_selectedSpecialties.contains(value)) {
                                    _selectedSpecialties.add(value);
                                  }
                                  _specialtyDropdownValue = null;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedSpecialties.map((specialty) {
                                return Chip(
                                  label: Text(specialty),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedSpecialties.remove(specialty);
                                      if (_selectedSpecialties.isEmpty) {
                                        _selectedSpecialties.add('כללי');
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            CheckboxListTile(
                              value: _licenseInfoEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _licenseInfoEnabled = value ?? false;
                                  if (!_licenseInfoEnabled) {
                                    _licenseNumberController.clear();
                                    _yearsOfExperienceController.clear();
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title:
                                  const Text('להזין מספר רישיון ושנות ניסיון'),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _licenseNumberController,
                              enabled: _licenseInfoEnabled,
                              decoration: InputDecoration(
                                labelText: 'מספר רישיון',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (!_licenseInfoEnabled) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין מספר רישיון';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _yearsOfExperienceController,
                              enabled: _licenseInfoEnabled,
                              decoration: const InputDecoration(
                                labelText: 'שנות ניסיון',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (!_licenseInfoEnabled) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין שנות ניסיון';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Consultation Fee
                            TextFormField(
                              controller: _consultationFeeController,
                              decoration: const InputDecoration(
                                labelText: 'עלות ייעוץ (₪)',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין עלות ייעוץ';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _bioController,
                              decoration: InputDecoration(
                                labelText: 'תיאור מקצועי',
                                border: const OutlineInputBorder(),
                                hintText: 'ספר על עצמך והתמחותך',
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                                hintStyle:
                                    const TextStyle(color: Colors.black54),
                              ),
                              style: const TextStyle(color: Colors.black),
                              maxLines: 3,
                            ),

                            const SizedBox(height: 16),

                            // Languages Selection
                            Text(
                              'שפות',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _languageDropdownValue,
                              decoration: InputDecoration(
                                labelText: 'בחר שפה',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              dropdownColor: Colors.white,
                              items: _languages.map((language) {
                                final isSelected =
                                    _selectedLanguages.contains(language);
                                return DropdownMenuItem<String>(
                                  value: language,
                                  enabled: !isSelected,
                                  child: Text(
                                    language,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  if (!_selectedLanguages.contains(value)) {
                                    _selectedLanguages.add(value);
                                  }
                                  _languageDropdownValue = null;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedLanguages.map((language) {
                                return Chip(
                                  label: Text(language),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedLanguages.remove(language);
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 32),

                            // Doctor approval (required for patient payments)
                            _buildSectionHeader('אישור מנהל'),
                            CheckboxListTile(
                              value: _doctorApproved,
                              onChanged: (value) {
                                setState(() {
                                  _doctorApproved = value ?? false;
                                  if (!_doctorApproved) {
                                    _appPaymentsEnabled = false;
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text('הרופא אושר למערכת'),
                            ),
                            const SizedBox(height: 16),

                            // Doctor billing (subscription + Visa)
                            _buildSectionHeader('חיוב רופא ותוכנית מנוי'),
                            if (!_doctorPaymentsEnabled)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'תשלומים מרופאים כבויים במערכת. פרטי כרטיס אשראי לא נדרשים.',
                                        style: TextStyle(color: Colors.orange.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            CheckboxListTile(
                              value: _doctorBillingEnabled,
                              onChanged: widget.isAdmin && _doctorPaymentsEnabled
                                  ? (value) {
                                      setState(() {
                                        _doctorBillingEnabled = value ?? false;
                                        if (!_doctorBillingEnabled) {
                                          _cardHolderController.clear();
                                          _cardNumberController.clear();
                                          _cardExpiryController.clear();
                                          _cardCvvController.clear();
                                          _selectedPlanId = (_subscriptionPlans
                                                  .first['id'] as String?) ??
                                              'plan_1_month';
                                          _discountController.clear();
                                          _selectedInstallments = 1;
                                        }
                                        _refreshCalculatedPrice();
                                      });
                                    }
                                  : null,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title:
                                  const Text('חייב רופא באמצעות כרטיס אשראי'),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedPlanId,
                              validator: (value) {
                                if (!_doctorBillingEnabled) return null;
                                if (value == null || value.isEmpty) {
                                  return 'נא לבחור תוכנית חיוב';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'בחר תוכנית חיוב',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              dropdownColor: Colors.white,
                              style: TextStyle(
                                  color: _doctorBillingEnabled
                                      ? Colors.black
                                      : Colors.grey),
                              items: _subscriptionPlans.map((plan) {
                                final months = plan['months'] as int;
                                final price = months * _monthlyBasePrice;
                                return DropdownMenuItem<String>(
                                  value: plan['id'] as String,
                                  enabled: _doctorBillingEnabled,
                                  child: Text(
                                    '${plan['label']} - ${price.toStringAsFixed(0)} ₪',
                                    style: TextStyle(
                                        color: _doctorBillingEnabled
                                            ? Colors.black
                                            : Colors.grey),
                                  ),
                                );
                              }).toList(),
                              onChanged: _doctorBillingEnabled && widget.isAdmin
                                  ? (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _selectedPlanId = value;
                                        _refreshCalculatedPrice();
                                      });
                                    }
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            if (_doctorBillingEnabled && widget.isAdmin && _doctorPaymentsEnabled) ...[
                              Text(
                                'עלות בסיסית (לפני הנחה): ${basePlanPrice.toStringAsFixed(0)} ₪ עבור $currentPlanMonths חודשים',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _discountController,
                                enabled:
                                    _doctorBillingEnabled && widget.isAdmin,
                                decoration: const InputDecoration(
                                  labelText: 'הנחה באחוזים',
                                  hintText: 'לדוגמה: 10',
                                  suffixText: '%',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelStyle: TextStyle(color: Colors.black87),
                                ),
                                style: const TextStyle(color: Colors.black),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (value) {
                                  if (!_doctorBillingEnabled ||
                                      !widget.isAdmin) {
                                    return null;
                                  }
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  final numeric = double.tryParse(
                                      value.replaceAll(',', '.'));
                                  if (numeric == null) {
                                    return 'נא להזין ערך מספרי תקין';
                                  }
                                  if (numeric < 0 || numeric > 100) {
                                    return 'ההנחה חייבת להיות בין 0 ל-100';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _calculatedPriceController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'עלות לאחר הנחה (₪)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelStyle: TextStyle(color: Colors.black87),
                                ),
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                value: _selectedInstallments,
                                decoration: const InputDecoration(
                                  labelText: 'מספר תשלומים (עד 36)',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelStyle: TextStyle(color: Colors.black87),
                                ),
                                items: _installmentOptions
                                    .map((installment) => DropdownMenuItem<int>(
                                          value: installment,
                                          child: Text('$installment'),
                                        ))
                                    .toList(),
                                onChanged:
                                    _doctorBillingEnabled && widget.isAdmin
                                        ? (value) {
                                            if (value == null) return;
                                            setState(() =>
                                                _selectedInstallments = value);
                                          }
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'עלות לאחר הנחה: ${discountedPlanPrice.toStringAsFixed(2)} ₪',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (_doctorPaymentsEnabled) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cardHolderController,
                                enabled: _doctorBillingEnabled,
                                decoration: const InputDecoration(
                                  labelText: 'שם בעל הכרטיס',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelStyle: TextStyle(color: Colors.black87),
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: (value) {
                                  if (!_doctorBillingEnabled) return null;
                                  if (value == null || value.isEmpty) {
                                    return 'נא להזין שם בעל הכרטיס';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cardNumberController,
                                enabled: _doctorBillingEnabled,
                                decoration: const InputDecoration(
                                  labelText: 'מספר כרטיס',
                                  hintText: '1234 5678 9012 3456',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelStyle: TextStyle(color: Colors.black87),
                                ),
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (!_doctorBillingEnabled) return null;
                                  if (value == null || value.isEmpty) {
                                    return 'נא להזין מספר כרטיס';
                                  }
                                  if (value.replaceAll(' ', '').length < 12) {
                                    return 'מספר כרטיס לא תקין';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _cardExpiryController,
                                      enabled: _doctorBillingEnabled,
                                      decoration: const InputDecoration(
                                        labelText: 'תוקף (MM/YY)',
                                        hintText: '05/28',
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelStyle:
                                            TextStyle(color: Colors.black87),
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                      validator: (value) {
                                        if (!_doctorBillingEnabled) return null;
                                        if (value == null || value.isEmpty) {
                                          return 'נא להזין תאריך תוקף';
                                        }
                                        if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                                            .hasMatch(value)) {
                                          return 'פורמט לא תקין';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _cardCvvController,
                                      enabled: _doctorBillingEnabled,
                                      decoration: const InputDecoration(
                                        labelText: 'CVV',
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelStyle:
                                            TextStyle(color: Colors.black87),
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                      keyboardType: TextInputType.number,
                                      obscureText: true,
                                      validator: (value) {
                                        if (!_doctorBillingEnabled) return null;
                                        if (value == null || value.isEmpty) {
                                          return 'נא להזין CVV';
                                        }
                                        if (value.length < 3) {
                                          return 'CVV לא תקין';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 32),

                            // App payments availability
                            _buildSectionHeader(
                                'תשלומים דרך האפליקציה ללקוחות'),
                            CheckboxListTile(
                              value: _appPaymentsEnabled,
                              onChanged: (value) {
                                final enableRequest = value ?? false;
                                if (!_doctorApproved && enableRequest) {
                                  setState(() => _appPaymentsEnabled = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'יש לאשר את הרופא לפני הפעלת תשלומים דרך האפליקציה'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _appPaymentsEnabled = enableRequest;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text(
                                  'אפשר תשלום דרך האפליקציה בעת קביעת תור'),
                              subtitle: Text(
                                _doctorApproved
                                    ? 'כאשר האפשרות פעילה ניתן יהיה להגדיר טיפולים ומחירים בפרופיל הרופא'
                                    : 'תשלום יופעל לאחר שהרופא יאושר. כרגע אפשרות זו תישמר ככבויה.',
                              ),
                            ),
                            if (_appPaymentsEnabled)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: const Text(
                                    'לאחר יצירת הרופא ניתן יהיה להגדיר טיפולים ותמחור בפרופיל הרופא.',
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 32),

                            // Bank Account Section
                            _buildSectionHeader('פרטי חשבון בנק'),
                            CheckboxListTile(
                              value: _bankDetailsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _bankDetailsEnabled = value ?? false;
                                  if (!_bankDetailsEnabled) {
                                    _bankNameController.clear();
                                    _branchNumberController.clear();
                                    _bankAccountController.clear();
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title:
                                  const Text('להפעיל פרטי חשבון בנק (לא חובה)'),
                            ),
                            const SizedBox(height: 8),

                            TextFormField(
                              controller: _bankNameController,
                              enabled: _bankDetailsEnabled,
                              decoration: InputDecoration(
                                labelText: 'שם הבנק',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (value) {
                                if (!_bankDetailsEnabled) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין שם הבנק';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Branch Number
                            TextFormField(
                              controller: _branchNumberController,
                              enabled: _bankDetailsEnabled,
                              decoration: const InputDecoration(
                                labelText: 'מספר סניף',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (!_bankDetailsEnabled) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין מספר סניף';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Bank Account
                            TextFormField(
                              controller: _bankAccountController,
                              enabled: _bankDetailsEnabled,
                              decoration: const InputDecoration(
                                labelText: 'מספר חשבון',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (!_bankDetailsEnabled) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין מספר חשבון';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            const SizedBox(height: 32),

                            if (widget.isAdmin) ...[
                              _buildSectionHeader('עמלת מערכת'),
                              CheckboxListTile(
                                value: _feeDeductionEnabled,
                                onChanged: (value) {
                                  final enableRequest = value ?? false;
                                  setState(() {
                                    _feeDeductionEnabled = enableRequest;
                                    if (!enableRequest) {
                                      _feePercentageController.clear();
                                    }
                                  });
                                  if (_isFeeExemptionActive && enableRequest) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'תקופת פטור מעמלה פעילה – ניכוי האחוזים לא יופעל עד לסיום התקופה'),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: const Text('הפעל ניכוי אחוז תשלום'),
                              ),
                              if (_feeDeductionEnabled)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: TextFormField(
                                    controller: _feePercentageController,
                                    decoration: const InputDecoration(
                                      labelText: 'אחוז ניכוי מהתשלום',
                                      hintText: 'לדוגמה: 5 עבור 5%',
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelStyle:
                                          TextStyle(color: Colors.black87),
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (!_feeDeductionEnabled) return null;
                                      final percentage =
                                          double.tryParse(value ?? '');
                                      if (percentage == null) {
                                        return 'נא להזין אחוז ניכוי תקין';
                                      }
                                      if (percentage < 0 || percentage > 100) {
                                        return 'האחוז חייב להיות בין 0 ל-100';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              if (_isFeeExemptionActive &&
                                  !_feeDeductionEnabled)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: const Text(
                                    'המערכת נמצאת בתקופת פטור מעמלה – כל התשלומים יועברו במלואם לרופא.',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                            ],

                            const SizedBox(height: 32),

                            // Create Button
                            SizedBox(
                              width: formWidth,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _createDoctor,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'צור רופא',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }

  void _createDoctor() async {
    final formState = _formKey.currentState;
    if (formState != null && !formState.validate()) return;

    if (_selectedSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('נא לבחור לפחות התמחות אחת לרופא'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registerResponse = await _authService.register(
        email: _emailController.text.trim(),
        password: 'Doctor123',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: 'doctor',
        storeToken: false,
      );

      final userId = registerResponse['data']?['user']?['id']?.toString();
      if (userId == null || userId.isEmpty) {
        throw Exception('User creation failed');
      }

      final doctorData = <String, dynamic>{
        'user_id': userId,
        'specialty':
            _selectedSpecialties.isNotEmpty ? _selectedSpecialties.first : 'General',
        'license_number':
            _licenseInfoEnabled ? _licenseNumberController.text.trim() : null,
        'bio': _bioController.text.trim(),
        'languages': _selectedLanguages,
      };

      await _doctorService.createDoctor(doctorData);

      if (_cityController.text.trim().isNotEmpty) {
        await _userService.updateUser(
          userId: userId,
          data: {
            'city': _cityController.text.trim(),
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('הרופא נוצר בהצלחה! נשלח אימייל לאימות'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // FR-5: Email notification sent (backend handles this)
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה ביצירת הרופא: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _licenseNumberController.dispose();
    _yearsOfExperienceController.dispose();
    _consultationFeeController.dispose();
    _bioController.dispose();
    _bankAccountController.dispose();
    _bankNameController.dispose();
    _branchNumberController.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _discountController.dispose();
    _calculatedPriceController.dispose();
    _feePercentageController.dispose();
    super.dispose();
  }
}
