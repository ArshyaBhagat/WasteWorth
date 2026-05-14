import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_page.dart';

const kPrimaryGreen = Color(0xFF43A047); // lighter green

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _usernameError;
  String? _emailError;
  String? _phoneError;

  final ApiService _api = ApiService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _usernameError = null;
      _emailError = null;
      _phoneError = null;
    });

    try {
      await _api.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered successfully')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().replaceFirst('Exception: ', '');
      print('REGISTER ERROR: $msg');

      setState(() {
        final lower = msg.toLowerCase();

        // Ignore generic DRF message if it appears
        if (lower.contains('invalid registration details')) {
          return;
        }

        // Username already exists
        if (lower.contains('"username"') ||
            lower.contains('Username already exists')) {
          _usernameError = 'Username already exists.';
          return;
        }

        // Email already exists
        if (lower.contains('"email"') ||
            lower.contains('a user with that email already exists')) {
          _emailError = 'A user with that email already exists.';
          return;
        }

        // Phone already exists
        if (lower.contains('"phone"') ||
            lower.contains('phone number already exists') ||
            lower.contains('phone already exists')) {
          _phoneError = 'A user with that phone number already exists.';
          return;
        }

        // Any other unexpected error -> snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          'Create Account',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
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
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Times New Roman',
                              letterSpacing: 1.1,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: kPrimaryGreen,
                              ),
                              errorText: _usernameError,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter Username';
                              }
                              if (value.trim().length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(
                                Icons.mail_outline,
                                color: kPrimaryGreen,
                              ),
                              errorText: _emailError,
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
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter email';
                              }
                              final emailRegex =
                                  RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: const Icon(
                                Icons.phone_outlined,
                                color: kPrimaryGreen,
                              ),
                              hintText: '+91 XXXXX XXXXX',
                              errorText: _phoneError,
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
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter phone number';
                              }

                              final digits =
                                  value.replaceAll(RegExp(r'\D'), '');

                              // 12 digits: country code + 10‑digit number
                              if (digits.length != 12) {
                                return 'Phone number must be 12 digits (with country code)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
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
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Min 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Material(
                              color: kPrimaryGreen,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: _isLoading ? null : _submit,
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
                                          'Create Account',
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
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Log In',
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
}
