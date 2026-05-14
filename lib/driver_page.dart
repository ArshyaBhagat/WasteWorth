import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'driver_pickups_page.dart';
import 'driver_profile_page.dart';

class DriverPage extends StatefulWidget {
  final String? token;
  final String? username;

  const DriverPage({super.key, this.token, this.username});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int _selectedNavIndex = 0;

  bool _isOnline = false;
  bool _isUpdatingStatus = false;

  List<Map<String, dynamic>> _availablePickups = [];
  bool _isLoadingPickup = true;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadDriverStatus();
    _loadCurrentPickup();
  }

  // ---- Time slot display mapping (supports old + new backend values) ----
  String _formatTimeSlot(dynamic raw) {
    if (raw == null) return '';
    final s = raw.toString().trim();

    // If backend sends already formatted label, keep it.
    if (s.contains('AM') || s.contains('PM')) return s;

    const map = {
      // old underscore values
      '10_2pm': '10:00 AM - 2:00 PM',
      '5_8pm': '5:00 PM - 8:00 PM',

      // new hyphen values
      '10-2pm': '10:00 AM - 2:00 PM',
      '5-8pm': '5:00 PM - 8:00 PM',
    };

    return map[s] ?? s.replaceAll('_', '-');
  }

  // ✅ Manpower display mapping (Less/More with proper capitalization)
  String _formatManpower(dynamic raw) {
    if (raw == null) return 'N/A';
    final s = raw.toString().trim().toLowerCase();

    // New backend values
    if (s == 'less than four') return 'Less than four';
    if (s == 'more than four') return 'More than four';

    // Old backend values
    if (s == 'lessthanfour') return 'Less than four';
    if (s == 'morethanfour') return 'More than four';

    // Other possible formats
    if (s.replaceAll('_', ' ') == 'less than four') return 'Less than four';
    if (s.replaceAll('_', ' ') == 'more than four') return 'More than four';

    return raw.toString();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return widget.token ?? prefs.getString('token') ?? '';
  }

  Future<void> _loadDriverStatus() async {
    try {
      final token = await _getToken();
      if (token.isEmpty) return;

      try {
        final details = await _apiService.getDriverDetails(token);
        if (!mounted) return;
        setState(() {
          _isOnline = details['status'] == 'online';
        });
      } catch (e) {
        if (e.toString().contains('not found') || e.toString().contains('404')) {
          if (!mounted) return;
          setState(() => _isOnline = false);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Error loading driver status: $e');
    }
  }

  Future<void> _updateStatus(bool value) async {
    setState(() => _isUpdatingStatus = true);

    try {
      final token = await _getToken();
      if (token.isEmpty) throw Exception('No token found');

      await _apiService.updateDriverDetails(
        token: token,
        status: value ? 'online' : 'offline',
      );

      if (!mounted) return;
      setState(() {
        _isOnline = value;
        _isUpdatingStatus = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isUpdatingStatus = false);

      if (e.toString().contains('No DriverDetails matches') || e.toString().contains('404')) {
        _showIncompleteProfileDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showIncompleteProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        content: const Text(
          'Please fill in your driver details to go online and start accepting pickups.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Material(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverProfilePage(
                        token: widget.token,
                        username: widget.username,
                      ),
                    ),
                  ).then((_) => _loadDriverStatus());
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Complete Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _loadCurrentPickup() async {
    try {
      final token = await _getToken();

      if (token.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoadingPickup = false);
        return;
      }

      final pickups = await _apiService.getAvailablePickups(token);

      if (!mounted) return;
      setState(() {
        _availablePickups = List<Map<String, dynamic>>.from(pickups as List);
        _isLoadingPickup = false;
      });
    } catch (e) {
      debugPrint('Error loading current pickup: $e');
      if (!mounted) return;
      setState(() => _isLoadingPickup = false);
    }
  }

  Future<void> _acceptPickup(int pickupId) async {
    try {
      final token = await _getToken();

      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No token found'), backgroundColor: Colors.red),
        );
        return;
      }

      await _apiService.acceptPickup(token: token, pickupId: pickupId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup accepted successfully!'), backgroundColor: Colors.green),
      );

      await _loadCurrentPickup();

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DriverPickupsPage(
              token: widget.token,
              username: widget.username,
            ),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains('Driver details not found') ||
          e.toString().contains('complete your driver profile')) {
        _showIncompleteProfileDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept pickup: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadDriverStatus();
    await _loadCurrentPickup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            _buildDriverStatusCard(),
            Expanded(child: _buildCurrentPickupCard()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopHeader() {
    final displayName = widget.username ?? 'Driver';
    final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'D';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                'Ready for today\'s pickups',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverProfilePage(
                    token: widget.token,
                    username: widget.username,
                  ),
                ),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFFDCFCE7)],
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFF4CAF50) : Colors.grey,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Status: ${_isOnline ? 'Online' : 'Offline'}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          Switch(
            value: _isOnline,
            onChanged: _isUpdatingStatus ? null : _updateStatus,
            activeThumbColor: const Color(0xFF4CAF50),
            inactiveThumbColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPickupCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(18),
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
          const Text(
            'Available Pickups',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          if (_isLoadingPickup)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_availablePickups.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No scheduled pickups available today',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _availablePickups.length,
                  itemBuilder: (context, index) {
                    final pickup = _availablePickups[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildPickupItem(pickup),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPickupItem(Map<String, dynamic> pickup) {
    final timeSlotText = _formatTimeSlot(
      pickup['time_slot_display'] ?? pickup['time_slot'],
    );

    final manpowerText = _formatManpower(
      pickup['manpower_display'] ?? pickup['manpower'],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPickupDetail('👤', pickup['user']?['username'] ?? 'Unknown User', Colors.grey[700]!),
          const SizedBox(height: 8),
          _buildPickupDetail('📱', pickup['user']?['phone_number'] ?? 'N/A', Colors.grey[700]!),
          const SizedBox(height: 8),
          _buildPickupDetail('📍', pickup['address'] ?? 'Address not provided', Colors.grey[700]!),
          const SizedBox(height: 8),
          _buildPickupDetail('📅', pickup['date'] ?? '', Colors.grey[700]!),
          const SizedBox(height: 8),
          _buildPickupDetail('🕐', timeSlotText, Colors.grey[700]!),
          const SizedBox(height: 8),
          _buildPickupDetail('⚖️', 'Weight: ${pickup['weight'] ?? ''}', Colors.grey[700]!),
          const SizedBox(height: 8),
          _buildPickupDetail('🛠️', 'Manpower: $manpowerText', Colors.grey[700]!),
          const SizedBox(height: 8),
          _buildPickupDetail(
            '🗂️',
            (pickup['categories'] is List)
                ? 'Categories: ${(pickup['categories'] as List).join(', ')}'
                : 'Categories: ${pickup['categories'] ?? 'N/A'}',
            Colors.grey[700]!,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => _acceptPickup(pickup['id']),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Start Pickup',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildPickupDetail(String icon, String text, Color color) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: color, height: 1.25),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Home'),
            _buildNavItem(1, Icons.local_shipping_outlined, 'Pickups'),
            _buildNavItem(2, Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DriverPickupsPage(
                token: widget.token,
                username: widget.username,
              ),
            ),
          );
        } else if (index == 2) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DriverProfilePage(
                token: widget.token,
                username: widget.username,
              ),
            ),
          );
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF2196F3) : const Color(0xFF9CA3AF),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF2196F3) : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
