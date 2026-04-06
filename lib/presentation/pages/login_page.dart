import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/utils/error_handler.dart';
import '../../services/language_service.dart';
import '../../core/localization/app_localizations.dart';

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
  bool _showEmailError = false;
  bool _showPasswordError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ' '; // Return space to trigger validation
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return ' '; // Return space to trigger validation
    }
    return null; // Valid
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return ' '; // Return space to trigger validation
    }
    return null; // Valid
  }

  // Get validation error messages in selected language
  Future<String?> _getEmailError(String? value) async {
    final language = await LanguageService.getCurrentLanguage();
    
    if (value == null || value.trim().isEmpty) {
      return {
        'עברית': 'נא להזין אימייל',
        'العربية': 'يرجى إدخال البريد الإلكتروني',
        'English': 'Please enter email',
      }[language] ?? 'נא להזין אימייל';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return {
        'עברית': 'נא להזין כתובת אימייל תקינה',
        'العربية': 'يرجى إدخال عنوان بريد إلكتروني صحيح',
        'English': 'Please enter valid email address',
      }[language] ?? 'נא להזין כתובת אימייל תקינה';
    }
    return null;
  }

  Future<String?> _getPasswordError(String? value) async {
    final language = await LanguageService.getCurrentLanguage();
    
    if (value == null || value.isEmpty) {
      return {
        'עברית': 'נא להזין סיסמה',
        'العربية': 'يرجى إدخال كلمة المرور',
        'English': 'Please enter password',
      }[language] ?? 'נא להזין סיסמה';
    }
    return null;
  }

  Future<void> _showLoginDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('אישור'),
          ),
        ],
      ),
    );
  }

  // Get login error message in selected language
  Future<String> _getLoginErrorMessage(dynamic error) async {
    final language = await LanguageService.getCurrentLanguage();
    final errorStr = error.toString().toLowerCase();
    
    // Check if it's an ApiException with specific message
    if (errorStr.contains('invalid email or password') || 
        errorStr.contains('401') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('404') ||
        errorStr.contains('not found') ||
        errorStr.contains('user not found') ||
        errorStr.contains('account not found')) {
      return {
        'עברית': 'אימייל או סיסמה שגויים. אנא נסה שוב.',
        'العربية': 'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.',
        'English': 'Invalid email or password. Please try again.',
      }[language] ?? 'אימייל או סיסמה שגויים. אנא נסה שוב.';
    } else if (errorStr.contains('network') || 
               errorStr.contains('socketexception') ||
               errorStr.contains('failed host lookup')) {
      return {
        'עברית': 'אין חיבור לאינטרנט. אנא בדוק את החיבור שלך.',
        'العربية': 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.',
        'English': 'No internet connection. Please check your connection.',
      }[language] ?? 'אין חיבור לאינטרנט. אנא בדוק את החיבור שלך.';
    } else if (errorStr.contains('timeout')) {
      return {
        'עברית': 'הבקשה ארכה זמן רב מדי. אנא נסה שוב.',
        'العربية': 'استغرقت الطلب وقتًا طويلاً. يرجى المحاولة مرة أخرى.',
        'English': 'Request took too long. Please try again.',
      }[language] ?? 'הבקשה ארכה זמן רב מדי. אנא נסה שוב.';
    } else if (errorStr.contains('500') || 
               errorStr.contains('internal server error')) {
      return {
        'עברית': 'שגיאת שרת. אנא נסה שוב מאוחר יותר.',
        'العربية': 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقًا.',
        'English': 'Server error. Please try again later.',
      }[language] ?? 'שגיאת שרת. אנא נסה שוב מאוחר יותר.';
    }
    
    // Default error message - show for any error including undefined accounts
    return {
      'עברית': 'אימייל או סיסמה שגויים. אנא נסה שוב.',
      'العربية': 'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.',
      'English': 'Invalid email or password. Please try again.',
    }[language] ?? 'אימייל או סיסמה שגויים. אנא נסה שוב.';
  }

  String? _passwordErrorMessage; // Store password error message
  String? _emailNotFoundMessage; // Store email not found message

  void _login() async {
    // Reset error messages
    setState(() {
      _showEmailError = true;
      _showPasswordError = true;
      _passwordErrorMessage = null;
      _emailNotFoundMessage = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    final emailError = await _getEmailError(email);
    final passwordError = await _getPasswordError(password);

    if (emailError != null || passwordError != null) {
      final language = await LanguageService.getCurrentLanguage();
      final combinedMessage = (emailError != null && passwordError != null)
          ? ({
                'עברית': 'נא להזין אימייל וסיסמה תקינים.',
                'العربية': 'يرجى إدخال البريد الإلكتروني وكلمة المرور بشكل صحيح.',
                'English': 'Please enter a valid email and password.',
              }[language] ??
              'נא להזין אימייל וסיסמה תקינים.')
          : (emailError ?? passwordError ?? '');

      await _showLoginDialog(
        title: {
          'עברית': 'שגיאת התחברות',
          'العربية': 'خطأ في تسجيل الدخول',
          'English': 'Login Error',
        }[language] ?? 'שגיאת התחברות',
        message: combinedMessage,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Login through database
      final response = await _authService.login(email, password);
      final role = response['data']?['user']?['role'] ?? 'patient';

      if (mounted) {
        // Navigate based on role
        if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        } else if (role == 'receptionist') {
          Navigator.pushReplacementNamed(context, '/receptionist-dashboard');
        } else if (role == 'patient' || role == 'customer') {
          Navigator.pushReplacementNamed(context, '/home', arguments: {
            'role': 'patient',
            'email': email,
            'name': response['data']?['user']?['name'] ?? ''
          });
        } else if (role == 'developer' || role == 'admin') {
          Navigator.pushReplacementNamed(
            context,
            '/developer-control',
            arguments: {'role': role},
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home', arguments: {
            'role': role,
            'email': email,
            'name': response['data']?['user']?['name'] ?? ''
          });
        }
      }
    } catch (e) {
      if (mounted) {
        try {
          final language = await LanguageService.getCurrentLanguage();
          final errorStr = e.toString().toLowerCase();
          
          // Check if email not found (404 or "not found")
          if (errorStr.contains('404') || 
              errorStr.contains('not found') || 
              errorStr.contains('user not found') ||
              errorStr.contains('account not found') ||
              errorStr.contains('email not found')) {
            await _showLoginDialog(
              title: {
                'עברית': 'החשבון לא נמצא',
                'العربية': 'الحساب غير موجود',
                'English': 'Account Not Found',
              }[language] ?? 'החשבון לא נמצא',
              message: {
                'עברית': 'האימייל שהזנת לא נמצא במערכת. אנא הירשם כדי ליצור חשבון חדש.',
                'العربية': 'البريد الإلكتروني الذي أدخلته غير موجود في النظام. يرجى التسجيل لإنشاء حساب جديد.',
                'English': 'The email you entered is not found in the system. Please register to create a new account.',
              }[language] ?? 'האימייל שהזנת לא נמצא במערכת. אנא הירשם כדי ליצור חשבון חדש.',
            );
          } else if (errorStr.contains('401') || 
                     errorStr.contains('unauthorized') ||
                     errorStr.contains('invalid') ||
                     errorStr.contains('incorrect password') ||
                     errorStr.contains('wrong password')) {
            final emailExists = await _authService.checkEmailExists(email);
            if (emailExists) {
              await _showLoginDialog(
                title: {
                  'עברית': 'סיסמה שגויה',
                  'العربية': 'كلمة المرور غير صحيحة',
                  'English': 'Incorrect Password',
                }[language] ?? 'סיסמה שגויה',
                message: {
                  'עברית': 'הסיסמה שהזנת שגויה. אנא נסה שוב.',
                  'العربية': 'كلمة المرور التي أدخلتها غير صحيحة. يرجى المحاولة مرة أخرى.',
                  'English': 'The password you entered is incorrect. Please try again.',
                }[language] ?? 'הסיסמה שהזנת שגויה. אנא נסה שוב.',
              );
            } else {
              await _showLoginDialog(
                title: {
                  'עברית': 'החשבון לא נמצא',
                  'العربية': 'الحساب غير موجود',
                  'English': 'Account Not Found',
                }[language] ?? 'החשבון לא נמצא',
                message: {
                  'עברית': 'האימייל שהזנת לא נמצא במערכת. אנא הירשם כדי ליצור חשבון חדש.',
                  'العربية': 'البريد الإلكتروني الذي أدخلته غير موجود في النظام. يرجى التسجيل لإنشاء حساب جديد.',
                  'English': 'The email you entered is not found in the system. Please register to create a new account.',
                }[language] ?? 'האימייל שהזנת לא נמצא במערכת. אנא הירשם כדי ליצור חשבון חדש.',
              );
            }
          } else if (errorStr.contains('network') || 
                     errorStr.contains('socketexception') ||
                     errorStr.contains('failed host lookup')) {
            await _showLoginDialog(
              title: {
                'עברית': 'שגיאת רשת',
                'العربية': 'خطأ في الشبكة',
                'English': 'Network Error',
              }[language] ?? 'שגיאת רשת',
              message: {
                'עברית': 'אין חיבור לאינטרנט. אנא בדוק את החיבור שלך.',
                'العربية': 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.',
                'English': 'No internet connection. Please check your connection.',
              }[language] ?? 'אין חיבור לאינטרנט. אנא בדוק את החיבור שלך.',
            );
          } else {
            final errorMessage = await _getLoginErrorMessage(e);
            await _showLoginDialog(
              title: {
                'עברית': 'שגיאת התחברות',
                'العربية': 'خطأ في تسجيل الدخول',
                'English': 'Login Error',
              }[language] ?? 'שגיאת התחברות',
              message: errorMessage,
            );
          }
        } catch (_) {
          // ScaffoldMessenger not available in test environment - ignore
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'he' || locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;
                final isSmallHeight = constraints.maxHeight < 700;

                if (isMobile) return _buildMobileLayout(localizations);

                return Row(
                  children: [
                    // LEFT PANEL
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF0E2C70), Color(0xFF1C4DD8)],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Squares pattern (top)
                            Positioned(
                              top: 20,
                              left: 20,
                              right: 20,
                              child: Opacity(
                                opacity: 0.1,
                                child: Wrap(
                                  spacing: 25,
                                  runSpacing: 25,
                                  children: List.generate(
                                      10,
                                      (index) => Image.asset(
                                          'assets/images/logo15.png',
                                          width: 70,
                                          height: 70)),
                                ),
                              ),
                            ),
                            // Main content
                            Padding(
                              padding: const EdgeInsets.all(50),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Medical services icon
                                  Icon(
                                    Icons.medical_services,
                                    size: 150,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 40),
                                  Text(
                                    localizations.medicalAppointmentSystem,
                                    style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                            // Tagline at bottom (no box, just text)
                            Positioned(
                              bottom: 40,
                              left: 50,
                              right: 50,
                              child: Text(
                                localizations.systemTagline,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // RIGHT PANEL
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: const Color(0xFFF5F5F5),
                        child: Stack(
                          children: [
                            Center(
                              child: isSmallHeight
                                  ? SingleChildScrollView(child: _buildLoginCard(localizations))
                                  : _buildLoginCard(localizations),
                            ),
                            // Language locked to Hebrew
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF1A2B48).withOpacity(0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.language, size: 20, color: Color(0xFF1A2B48)),
                                    SizedBox(width: 6),
                                    Text('עברית', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A2B48))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo14.png', width: 100, height: 100),
              const SizedBox(height: 30),
              Text(
                localizations.loginToYourAccount,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B48)),
              ),
              const SizedBox(height: 40),
              // Email field
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  key: const Key('login_email_field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  onChanged: (_) => setState(() {}), // Trigger validation
                  style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A2B48),
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: localizations.email,
                    hintText: 'your@email.com',
                    prefixIcon: const Icon(Icons.email),
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    errorText: null, // We'll show error below
                  ),
                ),
                // Validation error below field - only show if validation was triggered
                if (_showEmailError)
                  FutureBuilder<String?>(
                    future: _getEmailError(_emailController.text),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4, right: 12),
                          child: Text(
                            snapshot.data!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Password field with visibility toggle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  key: const Key('login_password_field'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  onChanged: (_) => setState(() {}), // Trigger validation
                  style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A2B48),
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: localizations.password,
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    errorText: null, // We'll show error below
                  ),
                  onFieldSubmitted: (_) => _login(),
                ),
                // Validation error below field - show validation or login error
                if (_showPasswordError)
                  Builder(
                    builder: (context) {
                      // Show password error message if login failed
                      if (_passwordErrorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                          child: Text(
                            _passwordErrorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      // Show validation error
                      return FutureBuilder<String?>(
                        future: _getPasswordError(_passwordController.text),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                              child: Text(
                                snapshot.data!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Login button
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF00C6FB), Color(0xFF005BEA)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                key: const Key('login_button'),
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        localizations.login.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            // Forgot Password and Register links - matching design
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: Text(
                    localizations.forgotPassword,
                    style: const TextStyle(
                      color: Color(0xFF005BEA),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: Text(
                    localizations.dontHaveAccount,
                    style: const TextStyle(
                      color: Color(0xFF005BEA),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(AppLocalizations localizations) {
    return Container(
      decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xFF0E2C70), Color(0xFF1C4DD8)])),
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildLoginCard(localizations),
            ),
          ),
          // Language switcher in top right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language, size: 20, color: Colors.white),
                  SizedBox(width: 6),
                  Text('עברית', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
