import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../services/secure_visa_service.dart';
import '../../services/validation_service.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // Form validation state
  bool _isPersonalInfoValid = true;
  bool _isContactInfoValid = true;
  bool _isSpecialtyInfoValid = true;
  bool _isAdditionalInfoValid = true;
  bool _isVisaInfoValid = true;

  // Edit mode for each section
  bool _isEditingPersonalInfo = false;
  bool _isEditingContactInfo = false;
  bool _isEditingSpecialtyInfo = false;
  bool _isEditingVisaInfo = false;
  bool _isEditingWorkingHours = false;
  bool _isEditingAdditionalInfo = false;
  bool _isLoading = false;

  // Doctor information controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _certificationsController =
      TextEditingController();
  final TextEditingController _languagesController = TextEditingController();

  // Visa/Payment information controllers
  final TextEditingController _visaNumberController = TextEditingController();
  final TextEditingController _visaExpiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardholderNameController =
      TextEditingController();

  // Visa security
  bool _visaDetailsVisible = false;
  bool _isAuthorizing = false;
  bool _visaAuthorized = false;
  final TextEditingController _visaPasswordController = TextEditingController();
  Timer? _visaTimer;

  // Working hours
  Map<String, Map<String, String>> _workingHours = {};
  List<String> _selectedDays = [];
  final List<String> _daysOfWeek = [
    'ראשון',
    'שני',
    'שלישי',
    'רביעי',
    'חמישי',
    'שישי',
    'שבת'
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
    _initializeWorkingHours();
  }

  void _loadDoctorData() {
    // Mock data - in real app, this would come from database
    _firstNameController.text = 'ד"ר יוסי';
    _lastNameController.text = 'כהן';
    _emailController.text = 'doctor@medicalapp.com';
    _phoneController.text = '050-1234567';
    _idNumberController.text = '123456789';
    _specialtyController.text = 'רפואה פנימית';
    _experienceController.text = '15';
    _addressController.text = 'רחוב הרצל 123';
    _cityController.text = 'תל אביב';
    _zipCodeController.text = '12345';
    _bioController.text = 'רופא מומחה ברפואה פנימית עם ניסיון של 15 שנים';
    _educationController.text = 'אוניברסיטת תל אביב - רפואה';
    _certificationsController.text = 'מומחה ברפואה פנימית, מומחה בקרדיולוגיה';
    _languagesController.text = 'עברית, אנגלית, ערבית';

    // Visa information (pre-filled by developer)
    _visaNumberController.text = '1234 5678 9012 3456';
    _visaExpiryController.text = '12/25';
    _cvvController.text = '123';
    _cardholderNameController.text = 'ד"ר יוסי כהן';
  }

  void _initializeWorkingHours() {
    for (String day in _daysOfWeek) {
      _workingHours[day] = {
        'start': '09:00',
        'end': '17:00',
        'breakStart': '13:00',
        'breakEnd': '14:00',
      };
    }
    _selectedDays = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי'];
  }

  // Validation methods for each section
  bool _validatePersonalInfo() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        ValidationService.isValidName(_firstNameController.text) &&
        ValidationService.isValidName(_lastNameController.text);
  }

  bool _validateContactInfo() {
    return _phoneController.text.isNotEmpty &&
        _idNumberController.text.isNotEmpty &&
        ValidationService.isValidPhoneNumber(_phoneController.text) &&
        ValidationService.isValidIsraeliId(_idNumberController.text);
  }

  bool _validateSpecialtyInfo() {
    return _specialtyController.text.isNotEmpty;
  }

  bool _validateAdditionalInfo() {
    bool experienceValid = _experienceController.text.isEmpty ||
        (int.tryParse(_experienceController.text) != null &&
            int.parse(_experienceController.text) >= 0 &&
            int.parse(_experienceController.text) <= 50);
    return experienceValid;
  }

  bool _validateVisaInfo() {
    if (!_visaAuthorized) return true; // Don't validate if not authorized
    return _visaNumberController.text.isNotEmpty &&
        _visaExpiryController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty &&
        _cardholderNameController.text.isNotEmpty &&
        ValidationService.isValidCardNumber(_visaNumberController.text) &&
        ValidationService.isValidExpiryDate(_visaExpiryController.text) &&
        ValidationService.isValidCVV(_cvvController.text) &&
        ValidationService.isValidName(_cardholderNameController.text);
  }

  void _updateValidationState() {
    setState(() {
      _isPersonalInfoValid = _validatePersonalInfo();
      _isContactInfoValid = _validateContactInfo();
      _isSpecialtyInfoValid = _validateSpecialtyInfo();
      _isAdditionalInfoValid = _validateAdditionalInfo();
      _isVisaInfoValid = _validateVisaInfo();
    });
  }

  bool _canSaveSection(String section) {
    switch (section) {
      case 'personal':
        return _isEditingPersonalInfo && _isPersonalInfoValid;
      case 'contact':
        return _isEditingContactInfo && _isContactInfoValid;
      case 'specialty':
        return _isEditingSpecialtyInfo && _isSpecialtyInfoValid;
      case 'additional':
        return _isEditingAdditionalInfo && _isAdditionalInfoValid;
      case 'visa':
        return _isEditingVisaInfo && _isVisaInfoValid;
      default:
        return false;
    }
  }

  Widget _buildValidationSummary() {
    List<String> invalidSections = [];

    if (_isEditingPersonalInfo && !_isPersonalInfoValid) {
      invalidSections.add('מידע אישי');
    }
    if (_isEditingContactInfo && !_isContactInfoValid) {
      invalidSections.add('פרטי התקשרות');
    }
    if (_isEditingSpecialtyInfo && !_isSpecialtyInfoValid) {
      invalidSections.add('התמחות מקצועית');
    }
    if (_isEditingAdditionalInfo && !_isAdditionalInfoValid) {
      invalidSections.add('מידע נוסף');
    }
    if (_isEditingVisaInfo && !_isVisaInfoValid) {
      invalidSections.add('פרטי כרטיס');
    }

    if (invalidSections.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'יש לתקן שגיאות לפני שמירה:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...invalidSections.map((section) => Padding(
                  padding: const EdgeInsets.only(left: 24, top: 4),
                  child: Text(
                    '• $section',
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('פרופיל רופא'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Section-based editing - no global edit button needed
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final double formWidth =
                    (constraints.maxWidth * 0.5).clamp(320.0, 700.0);
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: formWidth),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Validation Summary
                            _buildValidationSummary(),
                            if (_buildValidationSummary() !=
                                const SizedBox.shrink())
                              const SizedBox(height: 16),

                            _buildPersonalInfoSection(),
                            const SizedBox(height: 24),
                            _buildSpecialtySection(),
                            const SizedBox(height: 24),
                            _buildContactInfoSection(),
                            const SizedBox(height: 24),
                            _buildVisaInfoSection(),
                            const SizedBox(height: 24),
                            _buildWorkingHoursSection(),
                            const SizedBox(height: 24),
                            _buildAdditionalInfoSection(),
                            const SizedBox(height: 24),
                            // Section-based editing - no global action buttons needed
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'מידע אישי',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isEditingPersonalInfo
                      ? (_canSaveSection('personal')
                          ? () {
                              setState(() {
                                _isEditingPersonalInfo = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('מידע אישי נשמר בהצלחה'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null)
                      : () {
                          setState(() {
                            _isEditingPersonalInfo = true;
                          });
                          _updateValidationState();
                        },
                  icon: Icon(_isEditingPersonalInfo ? Icons.save : Icons.edit),
                  label: Text(_isEditingPersonalInfo ? 'שמור' : 'עריכה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isEditingPersonalInfo && !_canSaveSection('personal')
                            ? Colors.grey
                            : Colors.transparent,
                    foregroundColor:
                        _isEditingPersonalInfo && !_canSaveSection('personal')
                            ? Colors.grey
                            : Colors.blue,
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'שם פרטי',
                      border: OutlineInputBorder(),
                    ),
                    enabled: _isEditingPersonalInfo,
                    validator: (value) =>
                        value?.isEmpty == true ? 'שדה חובה' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'שם משפחה',
                      border: OutlineInputBorder(),
                    ),
                    enabled: _isEditingPersonalInfo,
                    validator: (value) =>
                        value?.isEmpty == true ? 'שדה חובה' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'אימייל',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              enabled: false, // Pre-filled by developer
              style: const TextStyle(
                  color: Colors.black), // Black text instead of grey
              validator: (value) => value?.isEmpty == true ? 'שדה חובה' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'התמחות מקצועית',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isEditingSpecialtyInfo
                      ? (_canSaveSection('specialty')
                          ? () {
                              setState(() {
                                _isEditingSpecialtyInfo = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('מידע מקצועי נשמר בהצלחה'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null)
                      : () {
                          setState(() {
                            _isEditingSpecialtyInfo = true;
                          });
                          _updateValidationState();
                        },
                  icon: Icon(_isEditingSpecialtyInfo ? Icons.save : Icons.edit),
                  label: Text(_isEditingSpecialtyInfo ? 'שמור' : 'עריכה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isEditingSpecialtyInfo && !_canSaveSection('specialty')
                            ? Colors.grey
                            : Colors.transparent,
                    foregroundColor:
                        _isEditingSpecialtyInfo && !_canSaveSection('specialty')
                            ? Colors.grey
                            : Colors.blue,
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialtyController,
              decoration: _buildFieldDecoration('התמחות *',
                  icon: Icons.medical_services,
                  isEnabled: _isEditingSpecialtyInfo),
              enabled: _isEditingSpecialtyInfo,
              validator: (value) => value?.isEmpty == true ? 'שדה חובה' : null,
              style: _getFieldTextStyle(_isEditingSpecialtyInfo),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'פרטי התקשרות',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isEditingContactInfo
                      ? (_canSaveSection('contact')
                          ? () {
                              setState(() {
                                _isEditingContactInfo = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('פרטי התקשרות נשמרו בהצלחה'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null)
                      : () {
                          setState(() {
                            _isEditingContactInfo = true;
                          });
                          _updateValidationState();
                        },
                  icon: Icon(_isEditingContactInfo ? Icons.save : Icons.edit),
                  label: Text(_isEditingContactInfo ? 'שמור' : 'עריכה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isEditingContactInfo && !_canSaveSection('contact')
                            ? Colors.grey
                            : Colors.transparent,
                    foregroundColor:
                        _isEditingContactInfo && !_canSaveSection('contact')
                            ? Colors.grey
                            : Colors.blue,
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: _buildFieldDecoration('טלפון',
                  icon: Icons.phone, isEnabled: _isEditingContactInfo),
              keyboardType: TextInputType.phone,
              enabled: _isEditingContactInfo,
              style: _getFieldTextStyle(_isEditingContactInfo),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (value) {
                if (_isEditingContactInfo) {
                  setState(() {}); // Trigger validation
                  _updateValidationState();
                }
              },
              validator: _isEditingContactInfo
                  ? (value) {
                      if (value?.isEmpty == true) return 'שדה חובה';
                      if (!ValidationService.isValidPhoneNumber(value!)) {
                        return 'מספר טלפון חייב להיות 10 ספרות';
                      }
                      return null;
                    }
                  : null,
              autovalidateMode: _isEditingContactInfo
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _idNumberController,
              decoration: _buildFieldDecoration('מספר זהות',
                  icon: Icons.badge, isEnabled: _isEditingContactInfo),
              keyboardType: TextInputType.number,
              enabled: _isEditingContactInfo,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              style: _getFieldTextStyle(_isEditingContactInfo),
              onChanged: (value) {
                if (_isEditingContactInfo) {
                  setState(() {}); // Trigger validation
                  _updateValidationState();
                }
              },
              validator: _isEditingContactInfo
                  ? (value) {
                      if (value?.isEmpty == true) return 'שדה חובה';
                      if (!ValidationService.isValidIsraeliId(value!)) {
                        return 'מספר זהות לא תקין';
                      }
                      return null;
                    }
                  : null,
              autovalidateMode: _isEditingContactInfo
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _addressController,
                    decoration: _buildFieldDecoration('כתובת',
                        icon: Icons.location_on,
                        isEnabled: _isEditingContactInfo),
                    enabled: _isEditingContactInfo,
                    style: _getFieldTextStyle(_isEditingContactInfo),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: _buildFieldDecoration('עיר',
                        isEnabled: _isEditingContactInfo),
                    enabled: _isEditingContactInfo,
                    style: _getFieldTextStyle(_isEditingContactInfo),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _zipCodeController,
                    decoration: _buildFieldDecoration('מיקוד',
                        isEnabled: _isEditingContactInfo),
                    keyboardType: TextInputType.number,
                    enabled: _isEditingContactInfo,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: _getFieldTextStyle(_isEditingContactInfo),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisaInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'פרטי תשלום (Visa/Mastercard)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!_visaAuthorized)
                  ElevatedButton.icon(
                    onPressed: _isAuthorizing ? null : _showPasswordDialog,
                    icon: _isAuthorizing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.security),
                    label: Text(_isAuthorizing ? 'מאמת...' : 'הצג פרטים'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: _isEditingVisaInfo
                        ? (_canSaveSection('visa')
                            ? () {
                                setState(() {
                                  _isEditingVisaInfo = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('פרטי כרטיס נשמרו בהצלחה'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            : null)
                        : () {
                            setState(() {
                              _isEditingVisaInfo = true;
                            });
                            _updateValidationState();
                          },
                    icon: Icon(_isEditingVisaInfo ? Icons.save : Icons.edit),
                    label: Text(_isEditingVisaInfo ? 'שמור' : 'עריכה'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isEditingVisaInfo && !_canSaveSection('visa')
                              ? Colors.grey
                              : Colors.transparent,
                      foregroundColor:
                          _isEditingVisaInfo && !_canSaveSection('visa')
                              ? Colors.grey
                              : Colors.blue,
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _hideVisaDetails,
                    icon: const Icon(Icons.visibility_off),
                    label: const Text('הסתר פרטים'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (_visaAuthorized)
              Text(
                _isEditingVisaInfo
                    ? 'עריכת פרטי הכרטיס'
                    : 'פרטים אלה מולאו על ידי המפתח',
                style: TextStyle(
                    fontSize: 12,
                    color: _isEditingVisaInfo ? Colors.blue : Colors.grey),
              ),
            const SizedBox(height: 16),
            if (_visaAuthorized) ...[
              // Visa details - editable when authorized and in edit mode
              _buildEditableVisaField(
                label: 'מספר כרטיס',
                controller: _visaNumberController,
                icon: Icons.credit_card,
                isEditing: _isEditingVisaInfo,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildEditableVisaField(
                      label: 'תאריך תפוגה',
                      controller: _visaExpiryController,
                      isEditing: _isEditingVisaInfo,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEditableVisaField(
                      label: 'CVV',
                      controller: _cvvController,
                      isEditing: _isEditingVisaInfo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildEditableVisaField(
                label: 'שם בעל הכרטיס',
                controller: _cardholderNameController,
                isEditing: _isEditingVisaInfo,
                isCardholderName: true,
              ),
            ] else ...[
              // Masked visa details
              _buildMaskedVisaField(
                label: 'מספר כרטיס',
                value: _visaNumberController.text,
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMaskedVisaField(
                      label: 'תאריך תפוגה',
                      value: _visaExpiryController.text,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMaskedVisaField(
                      label: 'CVV',
                      value: _cvvController.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMaskedVisaField(
                label: 'שם בעל הכרטיס',
                value: _cardholderNameController.text,
                isCardholderName: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecureVisaField({
    required String label,
    required String value,
    IconData? icon,
    bool isEncrypted = false,
  }) {
    return TextFormField(
      initialValue: isEncrypted ? _encryptValue(value) : value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        suffixIcon:
            isEncrypted ? const Icon(Icons.lock, color: Colors.green) : null,
      ),
      enabled: false,
      style: const TextStyle(color: Colors.black),
    );
  }

  Widget _buildMaskedVisaField({
    required String label,
    required String value,
    IconData? icon,
    bool isCardholderName = false,
  }) {
    return TextFormField(
      initialValue:
          isCardholderName ? _maskCardholderName(value) : _maskValue(value),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
      ),
      enabled: false,
      style: const TextStyle(color: Colors.black),
    );
  }

  String _maskCardholderName(String value) {
    if (value.isEmpty) return '';
    // Completely mask the cardholder name
    return '*' * value.length;
  }

  String _maskValue(String value) {
    if (value.isEmpty) return '';

    // Use secure service for masking
    if (value.contains(' ')) {
      // Card number format
      return SecureVisaService.maskCardNumber(value);
    } else {
      // Other sensitive data
      return SecureVisaService.maskSensitiveData(value);
    }
  }

  String _encryptValue(String value) {
    if (value.isEmpty) return '';

    // Use secure service for encryption
    return SecureVisaService.encryptVisaData(value);
  }

  void _authorizeVisaAccess() async {
    final password = _visaPasswordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אנא הזן סיסמה'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Close the dialog
    Navigator.of(context).pop();

    setState(() {
      _isAuthorizing = true;
    });

    try {
      // Use secure visa service for authorization with password
      final isAuthorized = await SecureVisaService.authorizeVisaAccess(
        doctorId: 'doctor_123', // In real app, get from user session
        biometricData: 'mock_biometric', // In real app, get from device
        pinCode: password, // Use the entered password
      );

      if (isAuthorized) {
        setState(() {
          _isAuthorizing = false;
          _visaAuthorized = true;
          _visaDetailsVisible = true;
        });

        // Start 3-second timer to auto-hide visa details
        _visaTimer?.cancel();
        _visaTimer = Timer(const Duration(seconds: 3), () {
          setState(() {
            _visaAuthorized = false;
            _visaDetailsVisible = false;
            _isEditingVisaInfo = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('פרטי הכרטיס הוסתרו אוטומטית לאחר 3 שניות'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        });

        // Log successful access
        SecureVisaService.logSecurityEvent(
          event: 'VISA_ACCESS_GRANTED',
          doctorId: 'doctor_123',
          details: 'Doctor accessed visa details with password',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('אישור הצלח - פרטי הכרטיס זמינים למשך 3 שניות'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _isAuthorizing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('סיסמה שגויה - נסה שוב'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAuthorizing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה באישור - נסה שוב'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _visaPasswordController.clear();
    }
  }

  void _hideVisaDetails() {
    _visaTimer?.cancel(); // Cancel the auto-hide timer
    setState(() {
      _visaAuthorized = false;
      _visaDetailsVisible = false;
      _isEditingVisaInfo = false;
    });
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('אישור גישה לפרטי הכרטיס'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('הזן סיסמה לאישור גישה לפרטי הכרטיס:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _visaPasswordController,
                decoration: const InputDecoration(
                  labelText: 'סיסמה',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                autofocus: true,
                onFieldSubmitted: (value) => _authorizeVisaAccess(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _visaPasswordController.clear();
              },
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: _authorizeVisaAccess,
              child: const Text('אישור'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableVisaField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    required bool isEditing,
    bool isCardholderName = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: !isEditing,
        fillColor: !isEditing ? Colors.grey.shade100 : null,
        suffixIcon:
            !isEditing ? const Icon(Icons.lock, color: Colors.green) : null,
      ),
      enabled: isEditing,
      style: const TextStyle(color: Colors.black),
      obscureText: isCardholderName && !isEditing,
      onChanged: isEditing
          ? (value) {
              setState(() {}); // Trigger validation
              _updateValidationState();
            }
          : null,
      validator: isEditing
          ? (value) {
              if (value?.isEmpty == true) return 'שדה חובה';
              if (label.contains('מספר כרטיס') &&
                  !ValidationService.isValidCardNumber(value!)) {
                return 'מספר כרטיס לא תקין';
              }
              if (label.contains('תאריך תפוגה') &&
                  !ValidationService.isValidExpiryDate(value!)) {
                return 'תאריך תפוגה לא תקין';
              }
              if (label.contains('CVV') &&
                  !ValidationService.isValidCVV(value!)) {
                return 'CVV חייב להיות 3-4 ספרות';
              }
              if (isCardholderName && !ValidationService.isValidName(value!)) {
                return 'שם בעל הכרטיס חייב להכיל אותיות בלבד';
              }
              return null;
            }
          : null,
      autovalidateMode: isEditing
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
    );
  }

  InputDecoration _buildFieldDecoration(String label,
      {IconData? icon, bool isEnabled = true}) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: !isEnabled,
      fillColor: !isEnabled ? Colors.grey.shade100 : null,
    );
  }

  TextStyle _getFieldTextStyle(bool isEnabled) {
    return const TextStyle(color: Colors.black); // Always black text
  }

  Widget _buildWorkingHoursSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'שעות עבודה',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditingWorkingHours = !_isEditingWorkingHours;
                    });
                  },
                  icon: Icon(_isEditingWorkingHours ? Icons.save : Icons.edit),
                  label: Text(_isEditingWorkingHours ? 'שמור' : 'עריכה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._daysOfWeek.map((day) => _buildDaySchedule(day)),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text(day,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          value: _selectedDays.contains(day),
          onChanged: _isEditingWorkingHours
              ? (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedDays.add(day);
                      if (!_workingHours.containsKey(day)) {
                        _workingHours[day] = {
                          'start': '09:00',
                          'end': '17:00',
                          'breakStart': '13:00',
                          'breakEnd': '14:00',
                        };
                      }
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                }
              : null,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (_selectedDays.contains(day)) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'שעת התחלה',
                  value: _workingHours[day]?['start'] ?? '09:00',
                  onChanged: _isEditingWorkingHours
                      ? (value) {
                          setState(() {
                            if (!_workingHours.containsKey(day)) {
                              _workingHours[day] = {
                                'start': '09:00',
                                'end': '17:00',
                                'breakStart': '13:00',
                                'breakEnd': '14:00',
                              };
                            }
                            _workingHours[day]!['start'] = value;
                          });
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeField(
                  label: 'שעת סיום',
                  value: _workingHours[day]?['end'] ?? '17:00',
                  onChanged: _isEditingWorkingHours
                      ? (value) {
                          setState(() {
                            if (!_workingHours.containsKey(day)) {
                              _workingHours[day] = {
                                'start': '09:00',
                                'end': '17:00',
                                'breakStart': '13:00',
                                'breakEnd': '14:00',
                              };
                            }
                            _workingHours[day]!['end'] = value;
                          });
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'תחילת הפסקה',
                  value: _workingHours[day]?['breakStart'] ?? '13:00',
                  onChanged: _isEditingWorkingHours
                      ? (value) {
                          setState(() {
                            if (!_workingHours.containsKey(day)) {
                              _workingHours[day] = {
                                'start': '09:00',
                                'end': '17:00',
                                'breakStart': '13:00',
                                'breakEnd': '14:00',
                              };
                            }
                            _workingHours[day]!['breakStart'] = value;
                          });
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeField(
                  label: 'סיום הפסקה',
                  value: _workingHours[day]?['breakEnd'] ?? '14:00',
                  onChanged: _isEditingWorkingHours
                      ? (value) {
                          setState(() {
                            if (!_workingHours.containsKey(day)) {
                              _workingHours[day] = {
                                'start': '09:00',
                                'end': '17:00',
                                'breakStart': '13:00',
                                'breakEnd': '14:00',
                              };
                            }
                            _workingHours[day]!['breakEnd'] = value;
                          });
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          enabled: onChanged != null,
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'מידע נוסף',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isEditingAdditionalInfo
                      ? (_canSaveSection('additional')
                          ? () {
                              setState(() {
                                _isEditingAdditionalInfo = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('מידע נוסף נשמר בהצלחה'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null)
                      : () {
                          setState(() {
                            _isEditingAdditionalInfo = true;
                          });
                          _updateValidationState();
                        },
                  icon:
                      Icon(_isEditingAdditionalInfo ? Icons.save : Icons.edit),
                  label: Text(_isEditingAdditionalInfo ? 'שמור' : 'עריכה'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditingAdditionalInfo &&
                            !_canSaveSection('additional')
                        ? Colors.grey
                        : Colors.transparent,
                    foregroundColor: _isEditingAdditionalInfo &&
                            !_canSaveSection('additional')
                        ? Colors.grey
                        : Colors.blue,
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _experienceController,
              decoration: _buildFieldDecoration('שנות ניסיון',
                  icon: Icons.work, isEnabled: _isEditingAdditionalInfo),
              keyboardType: TextInputType.number,
              enabled: _isEditingAdditionalInfo,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              style: _getFieldTextStyle(_isEditingAdditionalInfo),
              onChanged: (value) {
                if (_isEditingAdditionalInfo) {
                  setState(() {}); // Trigger validation
                  _updateValidationState();
                }
              },
              validator: _isEditingAdditionalInfo
                  ? (value) {
                      if (value?.isNotEmpty == true) {
                        int? years = int.tryParse(value!);
                        if (years == null || years < 0 || years > 50) {
                          return 'שנות ניסיון חייבות להיות בין 0 ל-50';
                        }
                      }
                      return null;
                    }
                  : null,
              autovalidateMode: _isEditingAdditionalInfo
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _educationController,
              decoration: _buildFieldDecoration('השכלה',
                  isEnabled: _isEditingAdditionalInfo),
              enabled: _isEditingAdditionalInfo,
              style: _getFieldTextStyle(_isEditingAdditionalInfo),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _certificationsController,
              decoration: _buildFieldDecoration('תעודות והסמכות',
                  isEnabled: _isEditingAdditionalInfo),
              enabled: _isEditingAdditionalInfo,
              style: _getFieldTextStyle(_isEditingAdditionalInfo),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _languagesController,
              decoration: _buildFieldDecoration('שפות',
                  isEnabled: _isEditingAdditionalInfo),
              enabled: _isEditingAdditionalInfo,
              style: _getFieldTextStyle(_isEditingAdditionalInfo),
            ),
          ],
        ),
      ),
    );
  }

  // Section-based editing methods removed - each section handles its own editing

  @override
  void dispose() {
    _visaTimer?.cancel(); // Cancel any running timer
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _certificationsController.dispose();
    _languagesController.dispose();
    _visaNumberController.dispose();
    _visaExpiryController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    _visaPasswordController.dispose();
    super.dispose();
  }
}
