import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/validation_service.dart';

class ValidationTestPage extends StatefulWidget {
  const ValidationTestPage({super.key});

  @override
  State<ValidationTestPage> createState() => _ValidationTestPageState();
}

class _ValidationTestPageState extends State<ValidationTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('בדיקת ולידציה'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'בדיקת ולידציה בזמן אמת',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              // Phone Number Test
              const Text(
                'מספר טלפון (חייב להיות 10 ספרות):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'הזן מספר טלפון',
                ),
                validator: (value) {
                  if (value?.isEmpty == true) return 'מספר טלפון חובה';
                  if (!ValidationService.isValidPhoneNumber(value!)) {
                    return 'מספר טלפון חייב להיות 10 ספרות';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {}); // Trigger validation
                },
              ),
              const SizedBox(height: 24),
              
              // Israeli ID Test
              const Text(
                'מספר זהות ישראלי (חייב להיות תקין לפי אלגוריתם ישראלי):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'הזן מספר זהות',
                ),
                validator: (value) {
                  if (value?.isEmpty == true) return 'מספר זהות חובה';
                  if (!ValidationService.isValidIsraeliId(value!)) {
                    return 'מספר זהות לא תקין';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {}); // Trigger validation
                },
              ),
              const SizedBox(height: 32),
              
              // Test Examples
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'דוגמאות לבדיקה:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text('מספרי טלפון תקינים: 0501234567, 0529876543'),
                      const Text('מספרי טלפון לא תקינים: 123, 12345678901'),
                      const SizedBox(height: 8),
                      const Text('מספרי זהות תקינים: 123456782, 987654321'),
                      const Text('מספרי זהות לא תקינים: 123456789, 111111111'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Test Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('כל השדות תקינים!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('יש שגיאות בשדות'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('בדוק ולידציה'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
