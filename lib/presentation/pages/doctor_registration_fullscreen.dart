import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/validation_service.dart';

class DoctorRegistrationFullscreenPage extends StatefulWidget {
  const DoctorRegistrationFullscreenPage({super.key});

  @override
  State<DoctorRegistrationFullscreenPage> createState() => _DoctorRegistrationFullscreenPageState();
}

class _DoctorRegistrationFullscreenPageState extends State<DoctorRegistrationFullscreenPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Personal Information
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  // Visa/Payment Information
  final TextEditingController _visaNumberController = TextEditingController();
  final TextEditingController _visaExpiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardholderNameController = TextEditingController();
  final TextEditingController _monthlyPaymentController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();

  // Working Hours
  Map<String, Map<String, String>> _workingHours = {};
  List<String> _selectedDays = [];
  final List<String> _daysOfWeek = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];

  // Additional Information
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _certificationsController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeWorkingHours();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('רישום רופא/מטפל חדש'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDraft,
            child: const Text('שמור טיוטה', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildPersonalInfoPage(),
                  _buildVisaPaymentPage(),
                  _buildWorkingHoursPage(),
                  _buildAdditionalInfoPage(),
                  _buildReviewPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index <= _currentPage ? Colors.blue : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'שלב ${_currentPage + 1} מתוך 5: ${_getPageTitle(_currentPage)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int page) {
    switch (page) {
      case 0: return 'מידע אישי';
      case 1: return 'פרטי תשלום';
      case 2: return 'שעות עבודה';
      case 3: return 'מידע נוסף';
      case 4: return 'סיכום ואישור';
      default: return '';
    }
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('מידע אישי בסיסי'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'שם פרטי *',
                    validator: (value) => value?.isEmpty == true ? 'שם פרטי חובה' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'שם משפחה *',
                    validator: (value) => value?.isEmpty == true ? 'שם משפחה חובה' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'כתובת אימייל *',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty == true) return 'כתובת אימייל חובה';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'כתובת אימייל לא תקינה';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _passwordController,
                    label: 'סיסמה *',
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'סיסמה חובה';
                      if (value!.length < 8) return 'סיסמה חייבת להכיל לפחות 8 תווים';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'אישור סיסמה *',
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'אישור סיסמה חובה';
                      if (value != _passwordController.text) return 'סיסמאות לא תואמות';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _phoneController,
                    label: 'מספר טלפון *',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value?.isEmpty == true) return 'מספר טלפון חובה';
                      if (!ValidationService.isValidPhoneNumber(value!)) {
                        return 'מספר טלפון חייב להיות 10 ספרות';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _idNumberController,
                    label: 'מספר זהות *',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (value) {
                      if (value?.isEmpty == true) return 'מספר זהות חובה';
                      if (!ValidationService.isValidIsraeliId(value!)) {
                        return 'מספר זהות לא תקין';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('מידע מקצועי'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _licenseNumberController,
                    label: 'מספר רישיון *',
                    validator: (value) => value?.isEmpty == true ? 'מספר רישיון חובה' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _specialtyController,
                    label: 'התמחות *',
                    validator: (value) => value?.isEmpty == true ? 'התמחות חובה' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _experienceController,
              label: 'שנות ניסיון *',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => value?.isEmpty == true ? 'שנות ניסיון חובה' : null,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('כתובת'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'כתובת מלאה *',
              maxLines: 2,
              validator: (value) => value?.isEmpty == true ? 'כתובת חובה' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'עיר *',
                    validator: (value) => value?.isEmpty == true ? 'עיר חובה' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _zipCodeController,
                    label: 'מיקוד *',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => value?.isEmpty == true ? 'מיקוד חובה' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisaPaymentPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('פרטי כרטיס אשראי'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cardholderNameController,
            label: 'שם בעל הכרטיס *',
            validator: (value) => value?.isEmpty == true ? 'שם בעל הכרטיס חובה' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _visaNumberController,
            label: 'מספר כרטיס אשראי *',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              CardNumberInputFormatter(),
            ],
            validator: (value) {
              if (value?.isEmpty == true) return 'מספר כרטיס חובה';
              if (value!.length < 16) return 'מספר כרטיס לא תקין';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _visaExpiryController,
                  label: 'תאריך תפוגה (MM/YY) *',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    ExpiryDateInputFormatter(),
                  ],
                  validator: (value) {
                    if (value?.isEmpty == true) return 'תאריך תפוגה חובה';
                    if (value!.length != 5) return 'תאריך תפוגה לא תקין';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _cvvController,
                  label: 'קוד אבטחה (CVV) *',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (value) {
                    if (value?.isEmpty == true) return 'קוד אבטחה חובה';
                    if (value!.length != 3) return 'קוד אבטחה לא תקין';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('הגדרות תשלום חודשי'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _monthlyPaymentController,
            label: 'סכום תשלום חודשי (₪) *',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value?.isEmpty == true) return 'סכום תשלום חודשי חובה';
              if (double.tryParse(value!) == null) return 'סכום לא תקין';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _paymentDateController,
            label: 'תאריך חיוב חודשי (1-31) *',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            validator: (value) {
              if (value?.isEmpty == true) return 'תאריך חיוב חודשי חובה';
              int? day = int.tryParse(value!);
              if (day == null || day < 1 || day > 31) return 'תאריך חיוב לא תקין (1-31)';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'מידע על תשלומים',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• התשלום החודשי ייגבה אוטומטית בתאריך שצוין\n'
                    '• ניתן לשנות את התאריך עד 3 ימים לפני החיוב\n'
                    '• במקרה של כישלון בחיוב, יישלח הודעה לכתובת האימייל',
                    style: TextStyle(color: Colors.blue.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('שעות עבודה'),
          const SizedBox(height: 16),
          Text(
            'בחר את ימי העבודה וקבע את השעות לכל יום:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ..._daysOfWeek.map((day) => _buildDayWorkingHours(day)),
        ],
      ),
    );
  }

  Widget _buildDayWorkingHours(String day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
              value: _selectedDays.contains(day),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedDays.add(day);
                    // Initialize working hours for this day if not already set
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
              },
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
                      onChanged: (value) {
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
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(
                      label: 'שעת סיום',
                      value: _workingHours[day]?['end'] ?? '17:00',
                      onChanged: (value) {
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
                      },
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
                      onChanged: (value) {
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
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(
                      label: 'סיום הפסקה',
                      value: _workingHours[day]?['breakEnd'] ?? '14:00',
                      onChanged: (value) {
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
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: int.parse(value.split(':')[0]),
                minute: int.parse(value.split(':')[1]),
              ),
            );
            if (time != null) {
              onChanged('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 16)),
                const Icon(Icons.access_time, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('מידע נוסף'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _bioController,
            label: 'תיאור מקצועי',
            maxLines: 4,
            hintText: 'ספר על עצמך, ההתמחות שלך והניסיון שלך...',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _educationController,
            label: 'השכלה',
            maxLines: 3,
            hintText: 'תארים, מוסדות לימוד, שנות סיום...',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _certificationsController,
            label: 'תעודות והסמכות',
            maxLines: 3,
            hintText: 'תעודות מקצועיות, הסמכות מיוחדות...',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _languagesController,
            label: 'שפות',
            hintText: 'עברית, אנגלית, ערבית...',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('סיכום פרטי הרופא'),
          const SizedBox(height: 16),
          _buildReviewCard('מידע אישי', [
            'שם: ${_firstNameController.text} ${_lastNameController.text}',
            'אימייל: ${_emailController.text}',
            'טלפון: ${_phoneController.text}',
            'מספר זהות: ${_idNumberController.text}',
            'כתובת: ${_addressController.text}, ${_cityController.text} ${_zipCodeController.text}',
          ]),
          const SizedBox(height: 16),
          _buildReviewCard('מידע מקצועי', [
            'רישיון: ${_licenseNumberController.text}',
            'התמחות: ${_specialtyController.text}',
            'ניסיון: ${_experienceController.text} שנים',
          ]),
          const SizedBox(height: 16),
          _buildReviewCard('פרטי תשלום', [
            'כרטיס: ****${_visaNumberController.text.length >= 4 ? _visaNumberController.text.substring(_visaNumberController.text.length - 4) : _visaNumberController.text}',
            'תפוגה: ${_visaExpiryController.text}',
            'תשלום חודשי: ₪${_monthlyPaymentController.text}',
            'תאריך חיוב: ${_paymentDateController.text}',
          ]),
          const SizedBox(height: 16),
          _buildReviewCard('שעות עבודה', _selectedDays.map((day) {
            final hours = _workingHours[day];
            if (hours == null) return '$day: לא נבחר';
            return '$day: ${hours['start']} - ${hours['end']} (הפסקה: ${hours['breakStart']} - ${hours['breakEnd']})';
          }).toList()),
          const SizedBox(height: 16),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'אימות אימייל',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'לאחר הרישום, יישלח קוד אימות לכתובת האימייל ${_emailController.text}.\n'
                    'יש לאמת את החשבון כדי להשלים את תהליך הרישום.',
                    style: TextStyle(color: Colors.orange.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 0 ? _previousPage : null,
            child: const Text('הקודם'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPage == 4 ? Colors.green : Colors.blue,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(_currentPage == 4 ? 'הרשמה' : 'הבא'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool obscureText = false,
    String? Function(String?)? validator,
    AutovalidateMode? autovalidateMode,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 4) {
      if (_currentPage == 0 && !_formKey.currentState!.validate()) {
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _registerDoctor();
    }
  }

  void _saveDraft() {
    // TODO: Implement draft saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('הטיוטה נשמרה בהצלחה')),
    );
  }

  void _registerDoctor() async {
    if (!_formKey.currentState!.validate()) {
      _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('הרישום הושלם בהצלחה!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('פרטי הרופא נשמרו במערכת.'),
            const SizedBox(height: 8),
            Text('קוד אימות נשלח לכתובת: ${_emailController.text}'),
            const SizedBox(height: 8),
            const Text('יש לבדוק את תיבת הדואר ולאמת את החשבון.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close registration page
            },
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _licenseNumberController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _visaNumberController.dispose();
    _visaExpiryController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    _monthlyPaymentController.dispose();
    _paymentDateController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _certificationsController.dispose();
    _languagesController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

// Custom input formatters
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += text[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll('/', '');
    if (text.length >= 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
