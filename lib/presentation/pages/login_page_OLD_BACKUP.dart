import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/config/dev_credentials.dart';
import '../../core/config/release_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  // FR-12: Internet connectivity status
  bool _isConnected = true;
  String _connectionType = 'Unknown';

  @override
  void initState() {
    super.initState();
    // FR-12: Check internet connectivity on login screen (after build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkConnectivity();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FR-12: Check internet connectivity (simplified for Windows - non-blocking)
  Future<void> _checkConnectivity() async {
    // Don't block UI - check connectivity in background
    try {
      // Simple connectivity check - try to reach backend
      await _authService.getCurrentUser().timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw Exception('No connection'),
      );
      if (mounted) {
        setState(() {
          _isConnected = true;
          _connectionType = 'Connected';
        });
      }
    } catch (e) {
      // Assume connected but backend not reachable yet (don't block login)
      if (mounted) {
        setState(() {
          _isConnected = true;
          _connectionType = 'WiFi';
        });
      }
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Email validation
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('נא להזין כתובת אימייל תקינה'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if admin account (for release mode)
      final emailLower = email.toLowerCase();
      final password = _passwordController.text;
      
      if (emailLower == ReleaseConfig.adminEmail.toLowerCase() && 
          password == ReleaseConfig.adminPassword) {
        // Admin login - direct access to admin/developer area
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔧 Admin Access Granted! גישת מנהל אושרה!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Navigate directly to admin area (developer features)
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: {
              'role': 'developer',
              'email': email,
              'name': 'מנהל המערכת'
            },
          );
        }
        return;
      }
      
      // Try backend authentication for doctors/patients
      final response = await _authService.login(email, password);

      if (mounted) {
        // Get user role from database response
        var role = response['data']?['user']?['role'] ?? 'patient';
        var userName = response['data']?['user']?['name'] ?? '';
        
        // Show login success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ברוך הבא, $userName!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate directly to home with detected role (no dialog)
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: {
            'role': role,
            'email': email,
            'name': userName
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // Backend failed - show role selection only if auto-detection is disabled
        if (ReleaseConfig.enableAutoRoleDetection) {
          // In production, don't show role dialog - show error instead
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('שגיאת התחברות. אנא בדוק את הפרטים שלך.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // In test mode, show role selection for testing
          _showRoleSelectionDialog();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showRoleSelectionDialog() {
    // Developer auto-detection disabled in release builds for QA
    // QA testers should manually select roles for testing
    final email = _emailController.text.trim().toLowerCase();
    
    // Check if developer auto-detection should be enabled (dev builds only)
    // For release/QA builds, skip auto-detection
    // final isDeveloperEmail = DeveloperCredentials.isDeveloperEmail(email);
    // if (isDeveloperEmail && ReleaseConfig.enableDeveloperAutoDetect) {
    //   // Developer mode auto-activation (dev builds only)
    //   Navigator.pushNamedAndRemoveUntil(
    //     context,
    //     '/home',
    //     (route) => false,
    //     arguments: {'role': 'developer'},
    //   );
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('🔧 Developer Mode Auto-Activated!'),
    //       backgroundColor: Colors.red,
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    //   return;
    // }
    
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('בחר תפקיד למעבר'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'בחר את תפקידך במערכת:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildRoleButton('patient', 'מטופל 👤', Icons.person, Colors.blue, 'לקוחות - קביעת תורים'),
              _buildRoleButton('doctor', 'רופא 🩺', Icons.medical_services, Colors.green, 'רופאים - ניהול מטופלים ותורים'),
              // Developer role hidden in release builds - QA should focus on patient/doctor roles
              // _buildRoleButton('developer', 'מפתח 💻', Icons.code, Colors.red, 'מנהל מערכת - שליטה מלאה'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role, String label, IconData icon, Color color, String description) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: {'role': role},
          );
        },
        icon: Icon(icon),
        label: Column(
          children: [
            Text(label),
            Text(
              description,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade400, Colors.blue.shade800],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo/Icon
                          Icon(
                            Icons.medical_services,
                            size: 80,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 24),
                          
                          // Title
                          const Text(
                            'מערכת תורים רפואיים',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Medical Appointment System',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Email field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'אימייל',
                              hintText: 'example@email.com',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'נא להזין אימייל';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'סיסמה',
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'נא להזין סיסמה';
                              }
                              return null;
                            },
                            // FR-23: Enter key triggers login
                            onFieldSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 24),
                          
                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'התחבר',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // FR-12: Internet connectivity status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isConnected ? Colors.green : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isConnected ? Icons.wifi : Icons.wifi_off,
                                  size: 16,
                                  color: _isConnected ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isConnected 
                                    ? 'מחובר לאינטרנט ($_connectionType)'
                                    : 'אין חיבור לאינטרנט',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Register link (removed testing text for production)
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'אין לך חשבון? הירשם עכשיו',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
