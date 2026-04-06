import 'package:flutter/material.dart';
import '../../services/patient_service.dart';
import '../../services/user_service.dart';

class CreatePatientPage extends StatefulWidget {
  const CreatePatientPage({super.key});

  @override
  State<CreatePatientPage> createState() => _CreatePatientPageState();
}

class _CreatePatientPageState extends State<CreatePatientPage> {
  final _formKey = GlobalKey<FormState>();
  final PatientService _patientService = PatientService();
  final UserService _userService = UserService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  // FR-3: Medical Information section removed (bloodType, height, weight, allergies, etc.)
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  bool _isLoading = false;
  bool _emergencyContactEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('יצירת מטופל חדש'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
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
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Personal Information Section
                            _buildSectionHeader('פרטים אישיים'),
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
                              textCapitalization: TextCapitalization.words,
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
                              textCapitalization: TextCapitalization.words,
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

                            // FR-3: Medical Information Section REMOVED per requirements

                            // Emergency Contact Section
                            _buildSectionHeader('איש קשר לחירום (לא חובה)'),
                            CheckboxListTile(
                              value: _emergencyContactEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _emergencyContactEnabled = value ?? false;
                                  if (!_emergencyContactEnabled) {
                                    _emergencyContactNameController.clear();
                                    _emergencyContactPhoneController.clear();
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text('הזן איש קשר לחירום'),
                              subtitle: const Text(
                                  'ברירת מחדל: לא חובה – ניתן להפעיל במידת הצורך'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emergencyContactNameController,
                              enabled: _emergencyContactEnabled,
                              decoration: InputDecoration(
                                labelText: 'שם איש קשר',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (!_emergencyContactEnabled) return null;
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין שם איש קשר';
                                }
                                // FR-2: Validate emergency contact name ≠ user name
                                final fullName =
                                    '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
                                if (value.trim().toLowerCase() ==
                                    fullName.trim().toLowerCase()) {
                                  return 'שם איש קשר חייב להיות שונה משם המטופל';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emergencyContactPhoneController,
                              enabled: _emergencyContactEnabled,
                              decoration: InputDecoration(
                                labelText: 'טלפון איש קשר',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (!_emergencyContactEnabled) return null;
                                if (value == null || value.isEmpty) {
                                  return 'נא להזין טלפון איש קשר';
                                }
                                // FR-2: Validate emergency contact ≠ user details
                                if (value == _phoneController.text.trim()) {
                                  return 'טלפון איש קשר חייב להיות שונה ממספר הטלפון של המטופל';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Create Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _createPatient,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'צור מטופל',
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
        color: Colors.blue,
      ),
    );
  }

  void _createPatient() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אנא ודא שכל פרטי המטופל מולאו כראוי'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    formState.save();

    setState(() => _isLoading = true);

    try {
      final patientData = {
        'email': _emailController.text.trim(),
        'password': 'Patient123', // Temporary password until first login
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'emergency_contact_enabled': _emergencyContactEnabled,
        'emergency_contact_name': _emergencyContactEnabled
            ? _emergencyContactNameController.text.trim()
            : null,
        'emergency_contact_phone': _emergencyContactEnabled
            ? _emergencyContactPhoneController.text.trim()
            : null,
      };
      
      final patient = await _patientService.createPatient(patientData);
      final userId = patient['user_id']?.toString();
      if (userId != null && _cityController.text.trim().isNotEmpty) {
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
            content: Text('המטופל נוצר בהצלחה!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה ביצירת המטופל: $e'),
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
    // FR-3: Medical info controllers removed
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }
}
