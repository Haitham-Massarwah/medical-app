import 'package:flutter/material.dart';
import '../../services/user_registration_service.dart';

class EmailCompletionPage extends StatefulWidget {
  final String token;

  const EmailCompletionPage({
    super.key,
    required this.token,
  });

  @override
  State<EmailCompletionPage> createState() => _EmailCompletionPageState();
}

class _EmailCompletionPageState extends State<EmailCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  bool _isLoading = false;
  bool _isVerifying = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _verifyToken();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVerifying) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('אימות אימייל'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('מאמת את הקישור...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_userData == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('שגיאה'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('הקישור לא תקין או פג תוקף'),
                SizedBox(height: 16),
                Text('נא לפנות למנהל המערכת'),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('השלמת הרשמה'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: LayoutBuilder(
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
                        const Text(
                          'השלמת פרטי החשבון',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'שלום ${_userData!['firstName']} ${_userData!['lastName']}',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),

                        // Email (Read-only)
                        TextFormField(
                          initialValue: _userData!['email'],
                          decoration: const InputDecoration(
                            labelText: 'כתובת אימייל',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'סיסמה *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'נא להזין סיסמה';
                            }
                            if (!UserRegistrationService.isValidPassword(
                                value)) {
                              return 'הסיסמה חייבת להכיל לפחות 8 תווים, אות גדולה, אות קטנה ומספר';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'אישור סיסמה *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'נא לאשר את הסיסמה';
                            }
                            if (value != _passwordController.text) {
                              return 'הסיסמאות אינן תואמות';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'מספר טלפון *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                            hintText: '050-1234567',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'נא להזין מספר טלפון';
                            }
                            if (!UserRegistrationService.isValidPhone(value)) {
                              return 'מספר טלפון לא תקין';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date of Birth
                        InkWell(
                          onTap: _selectDateOfBirth,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'תאריך לידה',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedDateOfBirth != null
                                  ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                  : 'בחר תאריך לידה',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gender
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'מין',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: ['זכר', 'נקבה', 'אחר'].map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'כתובת',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // Emergency Contact
                        TextFormField(
                          controller: _emergencyContactController,
                          decoration: const InputDecoration(
                            labelText: 'איש קשר לחירום',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.emergency),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Emergency Phone
                        TextFormField(
                          controller: _emergencyPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'טלפון חירום',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                            hintText: '050-1234567',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!UserRegistrationService.isValidPhone(
                                  value)) {
                                return 'מספר טלפון לא תקין';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Complete Registration Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _completeRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'השלם הרשמה',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _verifyToken() async {
    try {
      // This would normally verify the token with the backend
      // For now, we'll simulate a successful verification
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isVerifying = false;
        _userData = {
          'firstName': 'שרה',
          'lastName': 'לוי',
          'email': 'sara@example.com',
        };
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _userData = null;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await UserRegistrationService.completeRegistration(
        token: widget.token,
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isNotEmpty
            ? _emergencyContactController.text.trim()
            : null,
        emergencyPhone: _emergencyPhoneController.text.trim().isNotEmpty
            ? _emergencyPhoneController.text.trim()
            : null,
        dateOfBirth: _selectedDateOfBirth,
        gender: _selectedGender,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
      );

      if (result['success']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('הרשמה הושלמה בהצלחה!'),
            content: const Text('החשבון שלך מוכן לשימוש'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('התחבר'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בהשלמת ההרשמה: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
