import 'package:flutter/material.dart';
import 'user_profile_page.dart';
import 'schedule_pickup_page.dart';
import 'pickups_page.dart';
import 'product_rates_page.dart';
import 'api_service.dart';

class UserPage extends StatefulWidget {
  final String? username;
  final String token; // required token

  const UserPage({
    super.key,
    this.username,
    required this.token,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Home should always be selected on this screen
  int _selectedNavIndex = 0;

  // ✅ Theme colors (Dodger Blue + dark green)
  static const Color kDodgerBlue = Color(0xFF1E90FF); // Dodger Blue
  static const Color kLightDodgerBlue = Color(0xFFE8F3FF); // light bg
  static const Color kDarkGreenInitials = Color(0xFF1B5E20); // darker green

  String _userAddress = '';
  String _userPhone = '';
  String _userEmail = '';
  final TextEditingController _addressController = TextEditingController();
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (widget.token.isEmpty) return;

    try {
      final user = await _api.getCurrentUser(widget.token);
      if (mounted) {
        setState(() {
          _userEmail = user['email'] ?? '';
          _userPhone = user['phone_number'] ?? '';
          _userAddress = user['address'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          _buildTopHeader(), // uses SafeArea
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAddressCard(),
                  _buildInfoBannerCard(),
                  _buildSchedulePickupButton(),
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopHeader() {
    // If you want the fallback literally to be "username", change to:
    // final displayName = widget.username ?? 'username';
    final displayName = widget.username ?? 'User'; // current behavior
    final firstLetter =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi 👋, $displayName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to recycle today?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                      username: widget.username,
                      phone: _userPhone,
                      email: _userEmail,
                      address: _userAddress,
                      token: widget.token,
                      onAddressChanged: (phone, email, address) {
                        setState(() {
                          _userPhone = phone;
                          _userEmail = email;
                          _userAddress = address;
                        });
                      },
                    ),
                  ),
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F2FF), Color(0xFFDCFCE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
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

  Widget _buildAddressCard() {
    return GestureDetector(
      onTap: _showAddressDialog,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ Dodger Blue family background
          color: kLightDodgerBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.location_on, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Address',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userAddress.isEmpty ? 'Tap to add address' : _userAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressDialog() {
    _addressController.text = _userAddress;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Your Address',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your complete address',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF4CAF50),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ),
            Material(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () async {
                  final newAddress = _addressController.text.trim();
                  final currentContext = context;
                  try {
                    await _api.updateUser(
                      token: widget.token,
                      address: newAddress,
                    );
                    if (!mounted) return;

                    setState(() {
                      _userAddress = newAddress;
                    });

                    Navigator.of(currentContext).pop();
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      const SnackBar(
                          content: Text('Address saved successfully')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.of(currentContext).pop();
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoBannerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ Dodger Blue gradient
        gradient: const LinearGradient(
          colors: [Color(0xFF66B9FF), kDodgerBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.shield, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% Accuracy Guarantee',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'We ensure accurate waste segregation and pickup',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePickupButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Material(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SchedulePickupPage(
                  userAddress: _userAddress,
                  token: widget.token,
                  username: widget.username, // ✅ pass username forward
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              border: Border.all(
                // ✅ Dodger Blue border
                color: kDodgerBlue,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Schedule Pickup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '45,39,170 kg',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  // ✅ Dodger Blue light bg
                  color: kLightDodgerBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.eco, color: Color(0xFF4CAF50), size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Recycled',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Trusted by leading brands to save the environment',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
                    Row(
            children: [
              Expanded(child: _buildOrgIcon('Co', 'Green Cycle')),
              Expanded(child: _buildOrgIcon('NGO', 'Change Forge')),
              Expanded(child: _buildOrgIcon('Co', 'Circular Cycle')),
              Expanded(child: _buildOrgIcon('NGO', 'Hope Harbor')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrgIcon(String initials, String orgName) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: kLightDodgerBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: kDarkGreenInitials,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: 70, // keeps text from stretching layout
        child: Text(
          orgName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildBottomNavBar() {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Home'),
            _buildNavItem(1, Icons.shopping_bag_outlined, 'Products'),
            _buildNavItem(2, Icons.local_shipping_outlined, 'Pickups'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == _selectedNavIndex) return;

        if (index == 0) {
          return;
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProductRatesPage(
                token: widget.token,
                username: widget.username,
              ),
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PickupsPage(
                userAddress: _userAddress,
                token: widget.token,
                username: widget.username,
              ),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            // ✅ Dodger Blue for active nav
            color: isActive ? kDodgerBlue : const Color(0xFF9CA3AF),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              // ✅ Dodger Blue for active nav
              color: isActive ? kDodgerBlue : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
