import 'package:flutter/material.dart';
import 'schedule_pickup_page.dart';
import 'api_service.dart';
import 'user_page.dart';
import 'product_rates_page.dart';

class PickupsPage extends StatefulWidget {
  final String? userAddress;
  final String token; // token is required
  final String? username; // carry username

  const PickupsPage({
    super.key,
    required this.token,
    this.userAddress,
    this.username,
  });

  @override
  State<PickupsPage> createState() => _PickupsPageState();
}

class _PickupsPageState extends State<PickupsPage> {
  // Bottom nav: 0 = Home, 1 = Products, 2 = Pickups
  final int _selectedNavIndex = 2;

  int _selectedTabIndex = 0;
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _pickups = [];
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;

  // ----------- Mapping helpers (NEW) -----------

  String _formatTimeSlot(dynamic raw) {
    final v = (raw ?? '').toString().trim().toLowerCase();
    if (v == '10-2pm') return '10:00 AM - 2:00 PM';
    if (v == '5-8pm') return '5:00 PM - 8:00 PM';
    return (raw ?? 'N/A').toString();
  }

  String _formatManpower(dynamic raw) {
    final v = (raw ?? '').toString().trim().toLowerCase();

    // Support old backend values
    if (v == 'lessthanfour') return 'Less than four';
    if (v == 'morethanfour') return 'More than four';

    // Support new backend values
    if (v == 'less than four') return 'Less than four';
    if (v == 'more than four') return 'More than four';

    // If backend sends something like "less_than_four"
    if (v.replaceAll('_', ' ') == 'less than four') return 'Less than four';
    if (v.replaceAll('_', ' ') == 'more than four') return 'More than four';

    return (raw ?? 'N/A').toString();
  }

  String _formatCategories(dynamic raw) {
    if (raw == null) return 'N/A';
    if (raw is List) return raw.join(', ');
    return raw.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadPickups();
  }

  Future<void> _loadPickups() async {
    if (widget.token.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final pickups = await _api.getPickups(widget.token);
      final bills = await _api.getUserBills(widget.token);
      if (mounted) {
        setState(() {
          _pickups = List<Map<String, dynamic>>.from(
            pickups.map((p) => p as Map<String, dynamic>),
          );
          _bills = List<Map<String, dynamic>>.from(
            bills.map((b) => b as Map<String, dynamic>),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading pickups: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelPickup(int pickupId) async {
    try {
      await _api.cancelPickup(
        token: widget.token,
        pickupId: pickupId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup cancelled'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadPickups();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredPickups() {
    if (_selectedTabIndex == 0) {
      return _pickups.where((p) {
        final status = (p['status'] as String?)?.toLowerCase();
        return status == 'scheduled' || status == 'accepted';
      }).toList();
    } else {
      final statusMap = {
        1: 'completed',
        2: 'cancelled',
      };
      final status = statusMap[_selectedTabIndex];
      return _pickups
          .where((p) => (p['status'] as String?)?.toLowerCase() == status)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPageTitle(),
                    _buildStatusTabs(),
                    if (_selectedTabIndex == 0) _buildSchedulePickupButton(),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50),
                        ),
                      )
                    else if (_selectedTabIndex == 1)
                      if (_bills.isEmpty)
                        _buildEmptyState()
                      else
                        _buildBillsList(_bills)
                    else if (_getFilteredPickups().isEmpty)
                      _buildEmptyState()
                    else
                      _buildPickupsList(_getFilteredPickups()),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildPageTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: const Text(
        'PICKUPS',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusTabs() {
    final tabs = [
      {'label': 'Scheduled', 'icon': Icons.local_shipping},
      {'label': 'Completed', 'icon': Icons.card_giftcard},
      {'label': 'Cancelled', 'icon': Icons.delete_outline},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final isActive = _selectedTabIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabs[index]['icon'] as IconData,
                            color: isActive
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF9CA3AF),
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tabs[index]['label'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 3,
                      color: isActive
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPickupsList(List<Map<String, dynamic>> pickups) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: pickups.map((pickup) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup #${pickup['id'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${pickup['date'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Time: ${_formatTimeSlot(pickup['time_slot'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manpower: ${_formatManpower(pickup['manpower'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (pickup['weight'] ?? 'N/A').toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Categories: ${_formatCategories(pickup['categories'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedTabIndex == 0) ...[
                  if (pickup['status'] == 'scheduled') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFE69C),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '⚠️ Cancellation is not allowed once a driver has been assigned.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF856404),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _cancelPickup(pickup['id'] as int);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          side: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else if (pickup['status'] == 'accepted') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFC8E6C9),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '✅ The driver confirmed your pickup',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (pickup['driver_details'] != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Driver Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDriverDetailRow(
                              '👤 Driver Name:',
                              pickup['driver_details']['driver_name'] ?? 'N/A',
                            ),
                            const SizedBox(height: 6),
                            _buildDriverDetailRow(
                              '📱 Phone No:',
                              pickup['driver_details']['phone_number'] ?? 'N/A',
                            ),
                            const SizedBox(height: 6),
                            _buildDriverDetailRow(
                              '🚗 Vehicle Name:',
                              pickup['driver_details']['vehicle_name'] ?? 'N/A',
                            ),
                            const SizedBox(height: 6),
                            _buildDriverDetailRow(
                              '📍 Vehicle No:',
                              pickup['driver_details']['vehicle_number'] ??
                                  'N/A',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBillsList(List<Map<String, dynamic>> bills) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: bills.map((bill) => _buildBillCard(bill)).toList(),
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill) {
    final items = (bill['items'] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill #${bill['id']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  bill['created_at']?.toString().split('T')[0] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailRow('👤 Name:', bill['user_name'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow('📱 Phone:', bill['user_phone'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow('📍 Address:', bill['user_address'] ?? 'N/A'),
                const SizedBox(height: 16),
                const Text(
                  'Pickup Schedule',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailRow('📅 Date:', bill['pickup_date'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow(
                  '🕐 Time:',
                  _formatTimeSlot(bill['pickup_time'] ?? 'N/A'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'User Pickup Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  '⚖️ Weight:',
                  bill['pickup_details']?['weight']?.toString() ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  '🛠️ Manpower:',
                  _formatManpower(bill['pickup_details']?['manpower']),
                ),
                const SizedBox(height: 8),
                if ((bill['pickup_details']?['categories'] as List?)
                        ?.isNotEmpty ??
                    false)
                  _buildDetailRow(
                    '📦 Categories:',
                    (bill['pickup_details']?['categories'] as List?)?.join(', ') ??
                        'N/A',
                  )
                else
                  _buildDetailRow('📦 Categories:', 'N/A'),
                const SizedBox(height: 16),
                const Text(
                  'Driver Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailRow('👨‍💼 Name:', bill['driver_name'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow('📱 Phone:', bill['driver_phone'] ?? 'N/A'),
                const SizedBox(height: 16),
                const Text(
                  'Bill Items',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                if (items.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['product_name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${item['price']} × ${item['quantity']} = ₹${item['total']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index < items.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  )
                else
                  const Text(
                    'No items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '₹${bill['grand_total']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulePickupButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Material(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SchedulePickupPage(
                  userAddress: widget.userAddress,
                  token: widget.token,
                  username: widget.username, // ✅ pass username forward
                ),
              ),
            );
            _loadPickups();
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Schedule Pickup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTruckIllustration(),
          const SizedBox(height: 40),
          const Text(
            'No scheduled pickups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start getting paid for your scrap now!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTruckIllustration() {
    return Container(
      width: 200,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_shipping,
                  size: 60,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Home'),
            _buildNavItem(1, Icons.shopping_bag_outlined, 'Products'),
            _buildNavItem(2, Icons.local_shipping_outlined, 'Pickups',
                isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label,
      {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        if (index == 2) return;

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserPage(
                username: widget.username,
                token: widget.token,
              ),
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProductRatesPage(
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
            color: isActive ? const Color(0xFF2196F3) : const Color(0xFF9CA3AF),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color:
                  isActive ? const Color(0xFF2196F3) : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
