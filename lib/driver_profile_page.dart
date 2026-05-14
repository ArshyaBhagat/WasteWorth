import 'package:flutter/material.dart';
import 'driver_help_support_page.dart';
import 'driver_terms_conditions_page.dart';
import 'driver_account_settings.dart';
import 'driver_page.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'welcome_page.dart'; // ✅ ADDED

class DriverProfilePage extends StatefulWidget {
  final String? token;
  final String? username;

  const DriverProfilePage({super.key, this.token, this.username});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  bool _showDropdown = false;
  Map<String, dynamic>? _driverDetails;
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadDriverDetails();
  }

  Future<void> _loadDriverDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = widget.token ?? prefs.getString('token') ?? '';

      if (token.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final details = await _apiService.getDriverDetails(token);
      if (mounted) {
        setState(() {
          _driverDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading driver details: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.username ?? 'Driver';
    final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'D';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () {
            debugPrint('BACK TAPPED APPBAR');
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildAvatarSection(firstLetter),
                const SizedBox(height: 12),
                _buildGreetingSection(displayName),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                    ),
                  )
                else if (_driverDetails != null)
                  _buildDetailsCard()
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 24),
                _buildSupportLegalCard(),
                const SizedBox(height: 16),
                _buildAccountSettingsCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_showDropdown) _buildDropdownMenu(),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final details = _driverDetails!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(icon: '👤', label: 'Driver Name', value: details['driver_name'] ?? 'N/A'),
          const SizedBox(height: 14),
          _buildDetailRow(icon: '📱', label: 'Phone Number', value: details['phone_number'] ?? 'N/A'),
          const SizedBox(height: 14),
          _buildDetailRow(icon: '📧', label: 'Email ID', value: details['email_id'] ?? 'N/A'),
          const SizedBox(height: 14),
          _buildDetailRow(icon: '📍', label: 'Address', value: details['address'] ?? 'N/A'),
          const SizedBox(height: 14),
          _buildDetailRow(icon: '🚗', label: 'Vehicle Name', value: details['vehicle_name'] ?? 'N/A'),
          const SizedBox(height: 14),
          _buildDetailRow(icon: '🔢', label: 'Vehicle Number', value: details['vehicle_number'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(String firstLetter) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showDropdown = !_showDropdown;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F0FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FF),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF2F80ED), width: 2),
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F80ED),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.expand_more,
                color: Color(0xFF2F80ED),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(String displayName) {
    return Center(
      child: Text(
        'Hi $displayName!',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF222222),
        ),
      ),
    );
  }

  Widget _buildSupportLegalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          _buildMenuRow(
            icon: Icons.help_outline,
            label: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DriverHelpSupportPage()),
              );
            },
            isFirst: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 1,
              color: Colors.grey[200],
            ),
          ),
          _buildMenuRow(
            icon: Icons.description_outlined,
            label: 'Terms & Conditions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DriverTermsConditionsPage()),
              );
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildMenuRow(
        icon: Icons.settings_outlined,
        label: 'Account Settings',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverAccountSettingsPage(
                token: widget.token,
                username: widget.username,
              ),
            ),
          );
        },
        isFirst: true,
        isLast: true,
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            isFirst ? 16 : 12,
            16,
            isLast ? 16 : 12,
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2F80ED), size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownMenu() {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showDropdown = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE6F0FF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleLogout,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFFE53935), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final prefs = await SharedPreferences.getInstance();

                // ✅ IMPORTANT: remove all auth keys used by splash auto-login
                await prefs.remove('token'); // [page:1]
                await prefs.remove('user_role'); // [page:1]
                await prefs.remove('username'); // [page:1]

                // (Optional) If you saved any other auth keys, remove them too.

                if (!mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Color(0xFFE53935)),
              ),
            ),
          ],
        );
      },
    );
  }
}
