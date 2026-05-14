import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'driver_page.dart';
import 'welcome_page.dart';
import 'user_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wasteworth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LogoSplashScreen(),
    );
  }
}

class LogoSplashScreen extends StatefulWidget {
  const LogoSplashScreen({super.key});

  @override
  State<LogoSplashScreen> createState() => _LogoSplashScreenState();
}

class _LogoSplashScreenState extends State<LogoSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  String? _userRole;
  String? _token;
  String? _username;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // ✅ NEW: Always 2+ second splash
    _runSplashFlow();
  }

  Future<void> _runSplashFlow() async {
    // Wait minimum 2 seconds no matter how fast prefs load
    final minSplashDuration = Future.delayed(const Duration(seconds: 2));

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _userRole = prefs.getString('user_role');
      _username = prefs.getString('username');

      if (mounted) {
        setState(() {}); // ✅ Update welcome text immediately
      }
    } catch (e) {
      debugPrint('Splash error: $e');
    }

    // ✅ Wait for minimum 2 seconds
    await minSplashDuration;

    if (!mounted) return;

    await _fadeController.forward();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => _getHomePage()),
    );
  }

  Widget _getHomePage() {
    if (_token != null && _userRole == 'driver') {
      return DriverPage(token: _token!, username: _username);
    } else if (_token != null && _userRole == 'user') {
      return UserPage(username: _username, token: _token!);
    } else {
      return const WelcomePage();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF43A047),
                  Color(0xFF66BB6A),
                ],
              ),
            ),
          ),
          // Fade overlay
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Container(
                color: Colors.black.withOpacity(_fadeController.value * 0.3),
              );
            },
          ),
          // Logo + text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/images/app_logo.jpeg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.eco,
                          size: 120,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Wasteworth',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ Shows username like "Welcome back, Queen!"
                Text(
                  _username != null && _username!.isNotEmpty
                      ? 'Welcome back, ${_username!.substring(0, 1).toUpperCase()}${_username!.substring(1)}!'
                      : 'Sustainable waste management',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
