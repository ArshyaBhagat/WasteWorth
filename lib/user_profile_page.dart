import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'help_support_page.dart';
import 'terms_conditions_page.dart';
import 'about_us_page.dart';
import 'account_settings_page.dart';
import 'welcome_page.dart';

class UserProfilePage extends StatefulWidget {
  final String? username;
  final String? phone;
  final String? email;
  final String? address;
  final String? token;
  final Function(String phone, String email, String address)? onAddressChanged;

  const UserProfilePage({
    super.key,
    this.username,
    this.phone,
    this.email,
    this.address,
    this.token,
    this.onAddressChanged,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _showDropdown = false;

  // ✅ NEW: keep a resolved username so it doesn't flip to "User"
  String _resolvedUsername = '';

  @override
  void initState() {
    super.initState();
    _initResolvedUsername();
  }

  Future<void> _initResolvedUsername() async {
    // Prefer the value passed from previous page.
    final fromWidget = (widget.username ?? '').trim();
    if (fromWidget.isNotEmpty) {
      setState(() => _resolvedUsername = fromWidget);
      return;
    }

    // Fallback to SharedPreferences if available.
    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = (prefs.getString('username') ?? '').trim();

    if (!mounted) return;
    setState(() {
      _resolvedUsername = fromPrefs;
    });
  }

  Future<void> _logoutAndClearPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // clear keys used by splash auto-login
    await prefs.remove('token');
    await prefs.remove('user_role');
    await prefs.remove('username');

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Use resolved username first, then widget.username, then fallback
    final displayName = _resolvedUsername.isNotEmpty
        ? _resolvedUsername
        : (widget.username ?? 'User');

    final firstLetter =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildTopHeader(firstLetter, displayName),
                const SizedBox(height: 24),
                _buildHelpSupportCard(),
                _buildAccountSettingsCard(),
                _buildAboutUsCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // tap outside to close dropdown
          if (_showDropdown)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showDropdown = false;
                });
              },
              child: Container(color: Colors.transparent),
            ),

          // dropdown menu
          if (_showDropdown)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showDropdown = false;
                      });
                      _showLogoutDialog();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(String firstLetter, String displayName) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Color(0xFF111827), size: 24),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDropdown = !_showDropdown;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              firstLetter,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _showDropdown
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: const Color(0xFF6B7280),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Hi $displayName !',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logoutAndClearPrefs();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSupportCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItemWithDivider(
            icon: Icons.help_outline,
            label: 'Help & Support',
            isLast: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HelpSupportPage()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.description_outlined,
            label: 'Terms & Conditions',
            isLast: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const TermsConditionsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildMenuItem(
        icon: Icons.settings_outlined,
        label: 'Account Settings',
        isLast: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AccountSettingsPage(
                username: _resolvedUsername.isNotEmpty
                    ? _resolvedUsername
                    : widget.username,
                phone: widget.phone,
                email: widget.email,
                address: widget.address,
                token: widget.token,
                onSave: (phone, email, address) {
                  widget.onAddressChanged?.call(phone, email, address);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutUsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildMenuItem(
        icon: Icons.info_outline,
        label: 'About Us',
        isLast: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AboutUsPage()),
          );
        },
      ),
    );
  }

  Widget _buildMenuItemWithDivider({
    required IconData icon,
    required String label,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        _buildMenuItemContent(icon: icon, label: label, onTap: onTap),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: Colors.grey[200],
              height: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return _buildMenuItemContent(icon: icon, label: label, onTap: onTap);
  }

  Widget _buildMenuItemContent({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2196F3), size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF6B7280),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
