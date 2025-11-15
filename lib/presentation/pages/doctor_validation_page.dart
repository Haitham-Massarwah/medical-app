import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoctorValidationPage extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String visaNumber;
  final String visaExpiry;
  final String cvv;
  final String cardholderName;

  const DoctorValidationPage({
    super.key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.visaNumber,
    required this.visaExpiry,
    required this.cvv,
    required this.cardholderName,
  });

  @override
  State<DoctorValidationPage> createState() => _DoctorValidationPageState();
}

class _DoctorValidationPageState extends State<DoctorValidationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;

  // Controllers for editable fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _certificationsController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();

  // Working hours
  Map<String, Map<String, String>> _workingHours = {};
  List<String> _selectedDays = [];
  final List<String> _daysOfWeek = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];

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
    _selectedDays = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('השלמת רישום רופא'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) {
                if (step < _currentStep) {
                  setState(() {
                    _currentStep = step;
                  });
                }
              },
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('חזור'),
                      ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(_currentStep == 2 ? 'סיום רישום' : 'המשך'),
                    ),
                  ],
                );
              },
              steps: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('פרטים אישיים'),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            // Pre-filled information (read-only)
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'פרטים שמולאו על ידי המפתח:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text('שם: ${widget.firstName} ${widget.lastName}'),
                    Text('אימייל: ${widget.email}'),
                    Text('כרטיס: ****${widget.visaNumber.substring(widget.visaNumber.length - 4)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Editable fields
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'טלפון *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true ? 'שדה חובה' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: 'מספר זהות *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => value?.isEmpty == true ? 'שדה חובה' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'כתובת *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'שדה חובה' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'עיר *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'שדה חובה' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'מיקוד *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => value?.isEmpty == true ? 'שדה חובה' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('פרטים מקצועיים'),
      content: Column(
        children: [
          TextFormField(
            controller: _specialtyController,
            decoration: const InputDecoration(
              labelText: 'התמחות *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.medical_services),
            ),
            validator: (value) => value?.isEmpty == true ? 'שדה חובה' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _experienceController,
            decoration: const InputDecoration(
              labelText: 'שנות ניסיון',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'ביוגרפיה',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _educationController,
            decoration: const InputDecoration(
              labelText: 'השכלה',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _certificationsController,
            decoration: const InputDecoration(
              labelText: 'תעודות והסמכות',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _languagesController,
            decoration: const InputDecoration(
              labelText: 'שפות',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('שעות עבודה'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'בחר את ימי העבודה ושעות העבודה:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._daysOfWeek.map((day) => _buildDaySchedule(day)),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(String day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
          value: _selectedDays.contains(day),
          onChanged: (bool? value) {
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep == 1) {
      if (_specialtyController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('התמחות היא שדה חובה')),
        );
        return;
      }
      setState(() {
        _currentStep++;
      });
    } else if (_currentStep == 2) {
      _completeRegistration();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _completeRegistration() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('רישום הושלם בהצלחה!'),
        content: const Text('הפרופיל שלך נוצר בהצלחה. כעת תוכל להתחיל להשתמש במערכת.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacementNamed('/home'); // Go to main page
            },
            child: const Text('המשך למערכת'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
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
    super.dispose();
  }
}







