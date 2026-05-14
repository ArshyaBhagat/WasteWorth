import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ ADDED
import 'api_service.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'user_page.dart';
import 'driver_page.dart';

const kPrimaryGreen = Color(0xFF43A047);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  final ApiService _api = ApiService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _api.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      final token = result['token'] as String?;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully')),
      );

      if (token != null) {
        final me = await _api.getCurrentUser(token);
        debugPrint('Current user: $me');

        if (mounted) {
          final role = me['role'] as String?;
          final username = me['username'] as String?;
          
          // ✅ CRITICAL: SAVE TO SharedPreferences for splash screen!
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('user_role', role ?? 'user'); // ✅ 'driver' or 'user'
          await prefs.setString('username', username ?? '');

          Widget nextPage;

          if (role == 'driver') {
            nextPage = DriverPage(token: token, username: username);
          } else {
            nextPage = UserPage(username: username, token: token);
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => nextPage),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _goToSignup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
    _usernameController.clear();
    _passwordController.clear();
    setState(() {
      _error = null;
    });
  }

  Future<void> _goToForgotPassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
    _usernameController.clear();
    _passwordController.clear();
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Welcome Back',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width - 24,
                ),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 40.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Times New Roman',
                              letterSpacing: 1.1,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[300]!),
                              ),
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          if (_error != null) const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: kPrimaryGreen,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: kPrimaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter username'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: kPrimaryGreen,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: kPrimaryGreen,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: kPrimaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter password'
                                    : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _goToForgotPassword,
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: kPrimaryGreen,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Material(
                              color: kPrimaryGreen,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: _isLoading ? null : _login,
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Log In',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: _goToSignup,
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: kPrimaryGreen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
