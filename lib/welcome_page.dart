import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ FIXED: Logo on LEFT, no right logo, safe spacing
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        
        // ✅ REMOVED: No more right-side logo
        flexibleSpace: null,
        
        // ✅ LEFT: Logo replaces recycle icon
        leadingWidth: 56, // Gives logo more space
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/app_logo.jpeg',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.eco,
                color: Colors.white,
                size: 28,
              );
            },
          ),
        ),
        
        // ✅ Title with safe top spacing
        title: const Text(
          'WasteWorth',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // ✅ FIXED: SafeArea prevents clash with status bar/time
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 48.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Center logo (unchanged)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2E7D32).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/app_logo.jpeg',
                                height: 120,
                                width: 120,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.eco,
                                    size: 60,
                                    color: Color(0xFF2E7D32),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Welcome to WasteWorth',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Manage your waste efficiently and contribute to a sustainable future.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Get Started (Signup)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Material(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const SignupPage(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: const Center(
                                  child: Text(
                                    'Get Started',
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

                          const SizedBox(height: 16),

                          // Log In
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _goToLogin,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF2E7D32),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
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
