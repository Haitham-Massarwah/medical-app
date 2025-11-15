import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      // Check if admin credentials
      if (email.toLowerCase() == ReleaseConfig.adminEmail.toLowerCase() &&
          password == ReleaseConfig.adminPassword) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/developer-control');
        }
        return;
      }

      // Login through database
      final response = await _authService.login(email, password);
      final role = response['data']?['user']?['role'] ?? 'patient';

      if (mounted) {
        // Navigate based on role
        if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        } else if (role == 'patient' || role == 'customer') {
          Navigator.pushReplacementNamed(context, '/home', arguments: {
            'role': 'patient',
            'email': email,
            'name': response['data']?['user']?['name'] ?? ''
          });
        } else if (role == 'developer' || role == 'admin') {
          Navigator.pushReplacementNamed(context, '/developer-control');
        } else {
          Navigator.pushReplacementNamed(context, '/home', arguments: {
            'role': role,
            'email': email,
            'name': response['data']?['user']?['name'] ?? ''
          });
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Login Error'), backgroundColor: Colors.red));
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
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF0F4F8),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('en', ''),
      ],
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            final isSmallHeight = constraints.maxHeight < 700;

            if (isMobile) return _buildMobileLayout();

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
                              Image.asset('assets/images/logo15.png',
                                  width: 150, height: 150),
                              const SizedBox(height: 40),
                              const Text('Medical Appointment\nSystem',
                                  style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.3)),
                              const SizedBox(height: 15),
                              const Text('מערכת תורים רפואיים',
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.white70)),
                              const SizedBox(height: 35),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                      width: 1.5),
                                ),
                                child: const Text(
                                    'Efficient • Secure • Easy to Use\nYour Health, Our Priority',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                        height: 1.8)),
                              ),
                            ],
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
                    child: Center(
                      child: isSmallHeight
                          ? SingleChildScrollView(child: _buildLoginCard())
                          : _buildLoginCard(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: 450,
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(45),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo14.png', width: 100, height: 100),
          SizedBox(height: 30),
          Text('Login to Your Account',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B48))),
          SizedBox(height: 40),
          TextFormField(
            key: const Key('login_email_field'),
            controller: _emailController,
            style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A2B48),
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'your@email.com',
              prefixIcon: Icon(Icons.person_outline),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            key: const Key('login_password_field'),
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A2B48),
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onFieldSubmitted: (_) => _login(),
          ),
          SizedBox(height: 35),
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('LOGIN',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text('Forgot Password?',
                  style: TextStyle(color: Color(0xFF6C757D))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xFF0E2C70), Color(0xFF1C4DD8)])),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: _buildLoginCard(),
        ),
      ),
    );
  }
}
