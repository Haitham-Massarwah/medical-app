import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/language_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;
  bool _showEmailError = false;
  bool _emailExists = false;
  bool _emailValidated = false;
  String? _emailValidationMessage;
  Locale _currentLocale = const Locale('en', '');

  @override
  void initState() {
    super.initState();
    _loadCurrentLocale();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getCurrentLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload locale when dependencies change (e.g., after language change)
    _loadCurrentLocale();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<String> _getErrorMessage(String key) async {
    final language = await LanguageService.getCurrentLanguage();
    final messages = {
      'emailRequired': {
        'עברית': 'נא להזין כתובת אימייל',
        'العربية': 'يرجى إدخال عنوان بريد إلكتروني',
        'English': 'Please enter email address',
      },
      'emailInvalid': {
        'עברית': 'פורמט כתובת האימייל לא תקין. אנא הזן כתובת אימייל תקינה.',
        'العربية': 'تنسيق عنوان البريد الإلكتروني غير صحيح. يرجى إدخال عنوان بريد إلكتروني صالح.',
        'English': 'Email format is not correct. Please enter a valid email address.',
      },
      'emailSent': {
        'עברית': 'קישור לאיפוס סיסמה נשלח לאימייל שלך',
        'العربية': 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
        'English': 'Password reset link sent to your email',
      },
      'error': {
        'עברית': 'שגיאה בשליחת האימייל. אנא נסה שוב.',
        'العربية': 'خطأ في إرسال البريد الإلكتروني. يرجى المحاولة مرة أخرى.',
        'English': 'Error sending email. Please try again.',
      },
    };
    return messages[key]?[language] ?? messages[key]!['English']!;
  }

  Future<String?> _getEmailError(String key, String? value) async {
    if (value == null || value.trim().isEmpty) {
      return await _getErrorMessage('emailRequired');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value.trim())) {
      return await _getErrorMessage('emailInvalid');
    }
    return null;
  }

  void _handleForgotPassword() async {
    // First validate email format
    final email = _emailController.text.trim();
    
    setState(() {
      _showEmailError = true; // Show email error if any
    });
    
    // Check email format - show error below field, not in SnackBar
    if (email.isEmpty) {
      // Error will show below field via FutureBuilder
      return;
    }
    
    // Validate email format - show error below field, not in SnackBar
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      // Error will show below field via FutureBuilder
      return;
    }

    setState(() {
      _isLoading = true;
      _emailSent = false;
    });

    bool emailExists = false;
    try {
      // Check if email exists in database with 10 second timeout
      emailExists = await _authService.checkEmailExists(email)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (mounted) {
                LanguageService.getCurrentLanguage().then((language) {
                  final timeoutMsg = {
                    'עברית': 'פג תוקף הבקשה (10 שניות). אנא נסה שוב.',
                    'العربية': 'انتهت مهلة الطلب (10 ثوانٍ). يرجى المحاولة مرة أخرى.',
                    'English': 'Request timeout (10 seconds). Please try again.',
                  }[language] ?? 'Request timeout (10 seconds). Please try again.';
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(timeoutMsg),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                });
                setState(() {
                  _isLoading = false;
                });
              }
              return false; // Return false on timeout instead of throwing
            },
          );
    } catch (e) {
      if (e.toString().contains('TIMEOUT') || e.toString().contains('timeout')) {
        // Timeout already handled
        return;
      }
      // Other errors - show message and stop loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final language = await LanguageService.getCurrentLanguage();
        final errorMsg = {
          'עברית': 'שגיאה בבדיקת האימייל. אנא נסה שוב.',
          'العربية': 'خطأ في التحقق من البريد الإلكتروني. يرجى المحاولة مرة أخرى.',
          'English': 'Error checking email. Please try again.',
        }[language] ?? 'Error checking email. Please try again.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    
    if (!emailExists) {
      // Email not found in database
      if (mounted) {
        final language = await LanguageService.getCurrentLanguage();
        final message = {
          'עברית': 'כתובת האימייל לא נמצאה במערכת. אנא בדוק את כתובת האימייל ונסה שוב.',
          'العربية': 'عنوان البريد الإلكتروني غير موجود في النظام. يرجى التحقق من عنوان البريد الإلكتروني والمحاولة مرة أخرى.',
          'English': 'Email address not found in the system. Please check your email address and try again.',
        }[language] ?? 'Email address not found in the system. Please check your email address and try again.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    
    // Email exists, send reset link with 10 second timeout
    try {
      await _authService.forgotPassword(email)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (mounted) {
                LanguageService.getCurrentLanguage().then((language) {
                  final timeoutMsg = {
                    'עברית': 'פג תוקף הבקשה (10 שניות). אנא נסה שוב.',
                    'العربية': 'انتهت مهلة الطلب (10 ثوانٍ). يرجى المحاولة مرة أخرى.',
                    'English': 'Request timeout (10 seconds). Please try again.',
                  }[language] ?? 'Request timeout (10 seconds). Please try again.';
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(timeoutMsg),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                });
                setState(() {
                  _isLoading = false;
                });
              }
              throw Exception('TIMEOUT');
            },
          );
      
      if (mounted) {
        final language = await LanguageService.getCurrentLanguage();
        final message = {
          'עברית': 'קישור לאיפוס סיסמה נשלח לכתובת האימייל שלך. אנא בדוק את תיבת הדואר הנכנס.',
          'العربية': 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني. يرجى التحقق من صندوق الوارد.',
          'English': 'Password reset link has been sent to your email address. Please check your inbox.',
        }[language] ?? 'Password reset link has been sent to your email address. Please check your inbox.';
        
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Don't show error if timeout was already handled
        if (e.toString().contains('TIMEOUT') || e.toString().contains('timeout')) {
          return; // Timeout message already shown
        }
        
        final language = await LanguageService.getCurrentLanguage();
        final errorMsg = await _getErrorMessage('error');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MaterialApp's locale for real-time updates
    final appLocale = Localizations.localeOf(context);
    // Update _currentLocale immediately for text direction
    if (appLocale != _currentLocale) {
      _currentLocale = appLocale;
    }
    // Get localizations using MaterialApp's locale
    final localizations = AppLocalizations(appLocale);
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
              actions: const [],
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Icon(
                            Icons.lock_reset,
                            size: 80,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 24),
                          
                          // Title
                          Text(
                            localizations.forgotPassword,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          
                          // Description
                          Text(
                            localizations.resetPasswordSubtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          if (!_emailSent) ...[
                            // Email Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textDirection: TextDirection.ltr,
                                  onChanged: (value) {
                                    // Real-time validation
                                    setState(() {
                                      _showEmailError = value.isNotEmpty;
                                      _emailValidated = false;
                                      _emailValidationMessage = null;
                                    });
                                    
                                    // Validate email format and check existence
                                    if (value.trim().isNotEmpty) {
                                      final email = value.trim();
                                      final isValidFormat = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
                                      
                                      if (isValidFormat) {
                                        // Check if email exists
                                        _authService.checkEmailExists(email)
                                            .timeout(const Duration(seconds: 5))
                                            .then((exists) {
                                              if (mounted) {
                                                _getErrorMessage('emailNotFound').then((notFoundMsg) {
                                                  setState(() {
                                                    _emailValidated = true;
                                                    _emailExists = exists;
                                                    if (!exists) {
                                                      // Valid format but not found - RED (can't reset password for non-existent email)
                                                      _emailValidationMessage = notFoundMsg;
                                                    } else {
                                                      // Valid format and found - GREEN (email exists, can reset password)
                                                      _emailValidationMessage = null; // No message needed, email exists
                                                    }
                                                  });
                                                });
                                              }
                                            })
                                            .catchError((e) {
                                              // Timeout or error - don't show validation
                                              if (mounted) {
                                                setState(() {
                                                  _emailValidated = false;
                                                });
                                              }
                                            });
                                      } else {
                                        // Invalid format - RED
                                        _getErrorMessage('emailInvalid').then((invalidMsg) {
                                          if (mounted) {
                                            setState(() {
                                              _emailValidated = true;
                                              _emailExists = false;
                                              _emailValidationMessage = invalidMsg;
                                            });
                                          }
                                        });
                                      }
                                    }
                                  },
                                  onEditingComplete: () {
                                    // Validate when moving away from field
                                    setState(() {
                                      _showEmailError = true;
                                    });
                                    _formKey.currentState?.validate();
                                  },
                                  decoration: InputDecoration(
                                    labelText: localizations.email,
                                    hintText: 'example@email.com',
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _emailValidated 
                                            ? (_emailExists ? Colors.green : Colors.red)
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _emailValidated 
                                            ? (_emailExists ? Colors.green : Colors.red)
                                            : Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    errorText: null, // We'll show error below
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return ' '; // Will show error below - empty
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$')
                                        .hasMatch(value)) {
                                      return ' '; // Will show error below - format
                                    }
                                    return null;
                                  },
                                ),
                                // Show validation message below email field
                                if (_emailValidated && _emailValidationMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                                    child: Text(
                                      _emailValidationMessage!,
                                      style: TextStyle(
                                        color: _emailExists ? Colors.green : Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleForgotPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        localizations.resetPassword,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ] else ...[
                            // Success Message
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 64,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(height: 16),
                                  FutureBuilder<String>(
                                    future: _getErrorMessage('emailSent'),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green.shade900,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _emailController.text.trim(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Back to Login Button
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                localizations.back,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ), // Closes Scaffold
    ); // Closes PopScope
  }

  String _getDescriptionText(AppLocalizations localizations) {
    // Use AppLocalizations instead of hardcoded language check
    return localizations.resetPasswordSubtitle;
  }
}

