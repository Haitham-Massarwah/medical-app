import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/config/release_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    setState(() => _isLoading = true);
    try {
      if (email.toLowerCase() == ReleaseConfig.adminEmail.toLowerCase() && password == ReleaseConfig.adminPassword) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false,
          arguments: {'role': 'developer', 'email': email, 'name': 'Admin'});
        return;
      }
      final response = await _authService.login(email, password);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false,
        arguments: {'role': response['data']?['user']?['role'] ?? 'patient', 'email': email, 'name': response['data']?['user']?['name'] ?? ''});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Error'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF0F4F8), // Light grey-blue - professional & visible
        ),
      ),
      home: Scaffold(
        body: Row(
          children: [
            // LEFT PANEL - With logo pattern
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0E2C70),
                      Color(0xFF1C4DD8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Logo7 pattern (10 copies in background)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.08,
                        child: Wrap(
                          spacing: 30,
                          runSpacing: 30,
                          children: List.generate(10, (index) {
                            return ColorFiltered(
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              child: Image.asset('assets/images/logo7.png', width: 80, height: 80, fit: BoxFit.contain),
                            );
                          }),
                        ),
                      ),
                    ),
                    // Main content
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main Logo7 - WHITE
                          ColorFiltered(
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            child: Image.asset('assets/images/logo7.png', width: 150, height: 150, fit: BoxFit.contain),
                          ),
                          SizedBox(height: 30),
                          // H.M text only (no "Appointments")
                          Text(
                            'H.M',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                              shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                          ),
                          SizedBox(height: 45),
                          // Main title
                          Text(
                            'Medical Appointment\nSystem',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                              letterSpacing: 0.3,
                              shadows: [Shadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'מערכת תורים רפואיים',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 40),
                          // Tagline box
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'Efficient • Secure • Easy to Use\nYour Health, Our Priority',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                height: 1.8,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
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
            
            // RIGHT PANEL - Login
            Expanded(
              flex: 3,
              child: Container(
                color: Color(0xFFF5F5F5),
                child: Center(
                  child: Container(
                    width: 450,
                    padding: EdgeInsets.all(45),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo4 - CENTER (blends with white)
                        Image.asset(
                          'assets/images/logo4.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to logo1 if logo4 not found
                            return Image.asset('assets/images/logo1.png', width: 100, height: 100, fit: BoxFit.contain);
                          },
                        ),
                        SizedBox(height: 25),
                        // H.M text - LARGER
                        Text(
                          'H.M',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A2B48),
                            letterSpacing: 4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        // Title
                        Text(
                          'Login to Your Account',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF6C757D)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40),
                        
                        // EMAIL
                        TextFormField(
                          controller: _emailController,
                          style: TextStyle(fontSize: 16, color: Color(0xFF1A2B48), fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Color(0xFF6C757D)),
                            hintText: 'your@email.com',
                            hintStyle: TextStyle(color: Color(0xFFADB5BD)),
                            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF6C757D)),
                            filled: true,
                            fillColor: Color(0xFFF0F4F8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFDEE2E6), width: 1.5)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF00C6FB), width: 2)),
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // PASSWORD
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(fontSize: 16, color: Color(0xFF1A2B48), fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Color(0xFF6C757D)),
                            hintText: '••••••••',
                            hintStyle: TextStyle(color: Color(0xFFADB5BD)),
                            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6C757D)),
                            filled: true,
                            fillColor: Color(0xFFF0F4F8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFDEE2E6), width: 1.5)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF00C6FB), width: 2)),
                          ),
                          onFieldSubmitted: (_) => _login(),
                        ),
                        SizedBox(height: 35),
                        
                        // LOGIN Button
                        Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xFF00C6FB), Color(0xFF005BEA)]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Color(0xFF00C6FB).withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('LOGIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Forgot Password?', style: TextStyle(color: Color(0xFF6C757D))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
