import 'package:flutter/material.dart';
import 'api_service.dart';
import 'driver_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverPickupsPage extends StatefulWidget {
  final String? token;
  final String? username;

  const DriverPickupsPage({super.key, this.token, this.username});

  @override
  State<DriverPickupsPage> createState() => _DriverPickupsPageState();
}

class _DriverPickupsPageState extends State<DriverPickupsPage> {
  int _selectedTabIndex = 0;
  List<Map<String, dynamic>> _pickups = [];
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  bool _isSubmittingReport = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadPickups();
  }

  // ✅ FIX: Proper capitalization for manpower (display only)
  String _formatManpower(dynamic manpower) {
    final v = (manpower ?? '').toString().trim().toLowerCase();

    // Handle both correct + common typo
    if (v == 'less than four' || v == 'less then four') return 'Less than four';
    if (v == 'more than four' || v == 'more then four') return 'More than four';

    if (v.isEmpty) return 'N/A';
    return v[0].toUpperCase() + v.substring(1);
  }

  // ✅ NEW: time slot spacing formatter
  // "5-8pm" -> "5-8 pm"
  // "10-2pm" -> "10-2 pm"
  String _formatTimeSlot(dynamic slot) {
    final v = (slot ?? '').toString().trim().toLowerCase();

    if (v.isEmpty) return 'N/A';

    if (v.contains('pm') && !v.contains(' pm')) {
      return v.replaceAll('pm', ' pm');
    }

    if (v.contains('am') && !v.contains(' am')) {
      return v.replaceAll('am', ' am');
    }

    return v;
  }

  Future<void> _loadPickups() async {
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

      final driverDetails = await _apiService.getDriverDetails(token);

      if (driverDetails.isEmpty || driverDetails['id'] == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showIncompleteProfileDialog();
        }
        return;
      }

      final pickups = await _apiService.getDriverPickups(token);
      final reports = await _apiService.getDriverReports(token);
      final bills = await _apiService.getDriverBills(token);
      final products = await _apiService.getProducts();

      debugPrint('===== DRIVER PICKUPS PAGE =====');
      debugPrint('Current Driver ID: ${driverDetails['id']}');
      debugPrint('Loaded ${(pickups as List).length} driver pickups');
      debugPrint('Loaded ${(reports as List).length} driver reports');
      debugPrint('Loaded ${(bills as List).length} driver bills');
      debugPrint('Loaded ${(products as List).length} products');

      for (var pickup in (pickups as List)) {
        final driverDetailsInPickup = pickup['driver_details'];
        debugPrint(
            'Pickup #${pickup['id']}: status=${pickup['status']}, driver_id=${driverDetailsInPickup?['id']}');
      }

      if (mounted) {
        setState(() {
          _pickups = List<Map<String, dynamic>>.from(pickups as List);
          _reports = List<Map<String, dynamic>>.from(reports as List);
          _bills = List<Map<String, dynamic>>.from(bills as List);
          _products = List<Map<String, dynamic>>.from(products as List);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading pickups: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showIncompleteProfileDialog();
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredPickups() {
    if (_selectedTabIndex == 0) {
      return _pickups
          .where((p) {
            final pickupStatus = (p['status'] as String?)?.toLowerCase();
            return pickupStatus == 'accepted' || pickupStatus == 'scheduled';
          })
          .toList();
    } else if (_selectedTabIndex == 1) {
      return _bills;
    } else {
      return _reports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPickups = _getFilteredPickups();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Pickups',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStatusTabs(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF4CAF50),
                        ),
                        SizedBox(height: 16),
                        Text('Loading pickups...'),
                      ],
                    ),
                  )
                : filteredPickups.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        child: _buildPickupsList(filteredPickups),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    final tabs = [
      {'label': 'Scheduled', 'icon': Icons.local_shipping},
      {'label': 'Completed', 'icon': Icons.check_circle},
      {'label': 'Report', 'icon': Icons.assignment},
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
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      Container(
                        height: 3,
                        color: const Color(0xFF4CAF50),
                      )
                    else
                      Container(
                        height: 3,
                        color: Colors.transparent,
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

  Widget _buildPickupsList(List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          if (_selectedTabIndex == 0) {
            return _buildScheduledPickupCard(item);
          } else if (_selectedTabIndex == 1) {
            return _buildBillCard(item);
          } else {
            return _buildReportCard(item);
          }
        }).toList(),
      ),
    );
  }

  // ===============================================================
  // ✅ UPDATED: Bill & Report buttons now SAME WIDTH
  // ===============================================================
  Widget _buildScheduledPickupCard(Map<String, dynamic> pickup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickup['user']?['username'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      '📱 ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Expanded(
                      child: Text(
                        pickup['user']?['phone_number'] ?? 'No phone',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  pickup['address'] ?? 'No address provided',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 32,
                width: 70, // ✅ FIXED WIDTH
                child: Material(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () {
                      _showBillModal(pickup);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: const Center(
                      child: Text(
                        'Bill',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 32,
                width: 70, // ✅ FIXED WIDTH
                child: Material(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () {
                      _showReportModal(pickup);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: const Center(
                      child: Text(
                        'Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPickupCard(Map<String, dynamic> pickup) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pickup #${pickup['id']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(pickup['status'])
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (pickup['status'] as String?)?.toUpperCase() ?? 'N/A',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(pickup['status']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('📍 Address:', pickup['address'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('📅 Date:', pickup['date'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('🕐 Time:', pickup['time_slot'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('⚖️ Weight:', pickup['weight'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('🛠️ Manpower:', _formatManpower(pickup['manpower'])),
        ],
      ),
    );
  }

  // -------------------------- BILL CARD --------------------------
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
                _buildDetailRow('🕐 Time:', bill['pickup_time'] ?? 'N/A'),
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
                    '⚖️ Weight:', bill['pickup_details']?['weight'] ?? 'N/A'),
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
                      (bill['pickup_details']?['categories'] as List?)
                              ?.join(', ') ??
                          'N/A')
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

  // -------------------------- REPORT CARD --------------------------
  Widget _buildReportCard(Map<String, dynamic> report) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report #${report['id']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                report['created_at']?.toString().split('T')[0] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
              '👤 Customer Name:', report['user_pickup_name'] ?? 'N/A'),
          const SizedBox(height: 10),
          _buildDetailRow('📱 Phone Number:', report['phone_number'] ?? 'N/A'),
          const SizedBox(height: 10),
          _buildDetailRow('📍 Address:', report['address'] ?? 'N/A'),
          const SizedBox(height: 16),
          const Text(
            'Report Message:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              report['message'] ?? 'No message provided',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
                height: 1.5,
              ),
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

  Widget _buildEmptyState() {
    final tabNames = ['Scheduled', 'Completed', 'Report'];
    final totalPickups = _pickups.length;
    final filteredPickups = _getFilteredPickups().length;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${tabNames[_selectedTabIndex].toLowerCase()} pickups',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${tabNames[_selectedTabIndex].toLowerCase()} pickups will appear here',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Info:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total pickups in system: $totalPickups',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Filtered pickups: $filteredPickups',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current tab: ${tabNames[_selectedTabIndex]}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ✅ UPDATED: Error now shows inside TextField using errorText
  // ===============================================================
  void _showReportModal(Map<String, dynamic> pickup) {
  final TextEditingController reportController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      String? reportErrorText;

      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,

                  // ✅🔥 FIXED HERE
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).padding.bottom +
                      30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Report Issue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 24),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔹 PICKUP DETAILS CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pickup Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildDetailRow(
                            '👤 Customer Name:',
                            pickup['user']?['username'] ?? 'N/A',
                          ),
                          const SizedBox(height: 10),

                          _buildDetailRow(
                            '📱 Phone Number:',
                            pickup['user']?['phone_number'] ?? 'N/A',
                          ),
                          const SizedBox(height: 10),

                          _buildDetailRow(
                            '📅 Scheduled Date:',
                            pickup['date'] ?? 'N/A',
                          ),
                          const SizedBox(height: 10),

                          _buildDetailRow(
                            '🕐 Scheduled Time:',
                            _formatTimeSlot(pickup['time_slot']),
                          ),
                          const SizedBox(height: 10),

                          _buildDetailRow(
                            '⚖️ Estimated Weight:',
                            pickup['weight'] ?? 'N/A',
                          ),
                          const SizedBox(height: 10),

                          _buildDetailRow(
                            '📍 Address:',
                            pickup['address'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 REPORT MESSAGE
                    const Text(
                      'Report Message',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: reportController,
                      maxLines: 4,
                      onChanged: (value) {
                        if (reportErrorText != null) {
                          setModalState(() {
                            reportErrorText = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Describe the issue...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        errorText: reportErrorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2196F3),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 SUBMIT BUTTON (SAFE AREA FIX)
                    SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Material(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: _isSubmittingReport
                                ? null
                                : () async {
                                    final message =
                                        reportController.text.trim();

                                    if (message.isEmpty) {
                                      setModalState(() {
                                        reportErrorText =
                                            'Please describe the issue';
                                      });
                                      return;
                                    }

                                    setModalState(() {
                                      reportErrorText = null;
                                    });

                                    setState(() {
                                      _isSubmittingReport = true;
                                    });

                                    try {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final token = widget.token ??
                                          prefs.getString('token') ??
                                          '';

                                      if (token.isEmpty) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Authentication error. Please login again.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      await _apiService.createReport(
                                        token: token,
                                        pickupId: pickup['id'],
                                        message: message,
                                      );

                                      if (mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(this.context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Issue reported successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        _loadPickups();
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(this.context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isSubmittingReport = false;
                                        });
                                      }
                                    }
                                  },
                            borderRadius: BorderRadius.circular(8),
                            child: _isSubmittingReport
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Text(
                                      'Submit Report',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
              ),
            ),
          );
        },
      );
    },
  );
}

  void _showBillModal(Map<String, dynamic> pickup) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BillPage(
          pickup: pickup,
          products: _products,
          apiService: _apiService,
          onBillSubmitted: _loadPickups,
          token: widget.token,
        );
      },
    );
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
          'Please fill in your driver details to start accepting pickups.',
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
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Fill Profile',
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

  Color _getStatusColor(dynamic status) {
    final statusStr = (status as String?)?.toLowerCase() ?? '';
    switch (statusStr) {
      case 'scheduled':
        return const Color(0xFF2196F3);
      case 'accepted':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// --------------------------- BILL PAGE (UNCHANGED) ---------------------------

class _BillPage extends StatefulWidget {
  final Map<String, dynamic> pickup;
  final List<Map<String, dynamic>> products;
  final ApiService apiService;
  final VoidCallback onBillSubmitted;
  final String? token;

  const _BillPage({
    required this.pickup,
    required this.products,
    required this.apiService,
    required this.onBillSubmitted,
    this.token,
  });

  @override
  State<_BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<_BillPage> {
  String? _selectedCategory;
  List<Map<String, dynamic>> _billItems = [];
  int? _selectedProductId;
  int _selectedQuantity = 1;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  List<String> _getCategories() {
    final categories = <String>{};
    for (var product in widget.products) {
      categories.add(product['product_category'] ?? '');
    }
    final result = categories.toList()..sort();
    return result;
  }

  List<Map<String, dynamic>> _getProductsByCategory(String category) {
    return widget.products.where((p) => p['product_category'] == category).toList();
  }

  num _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is num) return price;
    if (price is String) {
      final numericPart = price.replaceAll(RegExp(r'[^\d.]'), '');
      final parsed = num.tryParse(numericPart);
      return parsed ?? 0;
    }
    return 0;
  }

  void _addProductToBill() {
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    List<Map<String, dynamic>> searchList = widget.products;
    if (_selectedCategory != null) {
      searchList = _getProductsByCategory(_selectedCategory!);
    }

    final product = searchList.firstWhere((p) => p['id'] == _selectedProductId,
        orElse: () => {});

    if (product.isEmpty) return;

    final price = _parsePrice(product['product_price']);
    final total = price * _selectedQuantity;

    setState(() {
      _billItems.add({
        'product_id': _selectedProductId,
        'product_name': product['product_name'],
        'price': price,
        'quantity': _selectedQuantity,
        'total': total,
      });
      _selectedProductId = null;
      _selectedQuantity = 1;
      _quantityController.text = '1';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['product_name']} added to bill'),
        backgroundColor: Colors.green,
      ),
    );
  }

  num _getGrandTotal() {
    return _billItems.fold<num>(0, (sum, item) => sum + (item['total'] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories();
    final selectedCategoryProducts =
        _selectedCategory != null ? _getProductsByCategory(_selectedCategory!) : [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom +
    MediaQuery.of(context).padding.bottom +
    30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generate Bill',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                        _selectedProductId = null;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF2196F3),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : const Color(0xFFE5E7EB),
                    ),
                  );
                }).toList(),
              ),
              if (_selectedCategory != null) ...[
                const SizedBox(height: 20),
                const Text(
                  'Select Product',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedProductId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  hint: const Text('Choose a product'),
                  items: selectedCategoryProducts.map((product) {
                    final priceStr = product['product_price']
                        .toString()
                        .replaceAll(RegExp(r'[^\d.]'), '');
                    return DropdownMenuItem<int>(
                      value: product['id'],
                      child: Text('${product['product_name']} (₹$priceStr)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProductId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _quantityController,
                        onChanged: (value) {
                          final qty = int.tryParse(value) ?? 1;
                          if (qty > 0) {
                            setState(() {
                              _selectedQuantity = qty;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: Material(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: _addProductToBill,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Text(
                                'ADD',
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
              ],
              if (_billItems.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Bill Items',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: _billItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['product_name'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item['price']} x ${item['quantity']} = ₹${item['total']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _billItems.removeAt(index);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index < _billItems.length - 1)
                            const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
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
                        '₹${_getGrandTotal()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Material(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () async {
                        if (_billItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please add at least one item to bill'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final token =
                              widget.token ?? prefs.getString('token') ?? '';

                          if (token.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Authentication error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          final items = _billItems.map((item) {
                            return {
                              'product_id': item['product_id'],
                              'product_name': item['product_name'],
                              'price': (item['price'] as num).toDouble(),
                              'quantity': item['quantity'],
                              'total': (item['total'] as num).toDouble(),
                            };
                          }).toList();

                          final grandTotal = (_getGrandTotal() as num).toDouble();

                          await widget.apiService.createBill(
                            token: token,
                            pickupId: widget.pickup['id'],
                            items: items,
                            grandTotal: grandTotal,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bill submitted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            widget.onBillSubmitted();
                          }
                        } catch (e) {
                          debugPrint('Error submitting bill: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          'Submit Bill',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
