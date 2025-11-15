import 'package:flutter/material.dart';

class LoginEnhancedPage extends StatefulWidget {
  const LoginEnhancedPage({super.key});

  @override
  State<LoginEnhancedPage> createState() => _LoginEnhancedPageState();
}

class _LoginEnhancedPageState extends State<LoginEnhancedPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  String _selectedRole = 'customer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'התחברות' : 'הרשמה'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Logo or Title
              Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 16),
              Text(
                'מערכת תורים רפואיים',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Role Selection (only for registration)
              if (!_isLogin) ...[
                Text(
                  'בחר סוג משתמש:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('לקוח/מטופל'),
                          subtitle: const Text('הזמנת תורים וניהול תיק רפואי'),
                          value: 'customer',
                          groupValue: _selectedRole,
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                        const Divider(),
                        RadioListTile<String>(
                          title: const Text('רופא/מטפל'),
                          subtitle: const Text('ניהול תורים וטיפולים (רק על ידי מפתח המערכת)'),
                          value: 'doctor',
                          groupValue: _selectedRole,
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'רופאים ומטפלים נרשמים רק על ידי מפתח המערכת',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'כתובת אימייל',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'נא להזין כתובת אימייל';
                  }
                  if (!value.contains('@')) {
                    return 'כתובת אימייל לא תקינה';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'סיסמה',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'נא להזין סיסמה';
                  }
                  if (value.length < 6) {
                    return 'סיסמה חייבת להכיל לפחות 6 תווים';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name Field (only for registration)
              if (!_isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'שם מלא',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'נא להזין שם מלא';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Field (only for registration)
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'מספר טלפון',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'נא להזין מספר טלפון';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Login/Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isLogin ? 'התחבר' : 'הירשם'),
              ),
              const SizedBox(height: 16),

              // Toggle Login/Register
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _selectedRole = 'customer'; // Reset to customer
                  });
                },
                child: Text(
                  _isLogin 
                      ? 'אין לך חשבון? הירשם כאן'
                      : 'יש לך חשבון? התחבר כאן',
                ),
              ),

              const SizedBox(height: 24),

              // Developer Login
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'כניסה למפתח המערכת',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loginAsDeveloper,
                icon: const Icon(Icons.code),
                label: const Text('התחבר כמפתח'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (_isLogin) {
      _handleLogin();
    } else {
      _handleRegistration();
    }
  }

  void _handleLogin() {
    final email = _emailController.text;
    
    // Check if it's a developer email
    if (email == 'developer@medicalapp.com') {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // Check if it's a doctor email
    if (email.contains('doctor') || email.contains('medical')) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // Default to customer
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _handleRegistration() {
    if (_selectedRole == 'doctor') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('רופאים ומטפלים נרשמים רק על ידי מפתח המערכת'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Customer registration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ההרשמה הושלמה בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to main app
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _loginAsDeveloper() {
    setState(() {
      _isLoading = true;
    });

    // Simulate developer login
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
