import 'package:flutter/material.dart';
import 'api_service.dart';

class AdminPanel extends StatefulWidget {
  final String? token;

  const AdminPanel({super.key, this.token});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final ApiService _apiService = ApiService();
  List<dynamic> drivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      final data = await _apiService.getDrivers(widget.token ?? '');
      setState(() {
        drivers = data;
        isLoading = false;
      });
    } catch (e) {
      // Fallback to mock data for demonstration/testing
      setState(() {
        drivers = [
          {
            'username': 'Ramesh Pawar',
            'phone_number': '9876543210',
            'email': 'ramesh@example.com',
            'address': 'Pune, Maharashtra',
            'vehicle_name': 'Tata Ace',
            'vehicle_number': 'MH 12 AB 1234',
            'is_online': true,
          },
          {
            'username': 'Suresh Patil',
            'phone_number': '9876543211',
            'email': 'suresh@example.com',
            'address': 'Mumbai, Maharashtra',
            'vehicle_name': 'Mahindra Bolero',
            'vehicle_number': 'MH 14 CD 5678',
            'is_online': false,
          },
          {
            'username': 'Rahul Deshmukh',
            'phone_number': '9876543212',
            'email': 'rahul@example.com',
            'address': 'Nashik, Maharashtra',
            'vehicle_name': 'Tata Intra',
            'vehicle_number': 'MH 15 EF 9012',
            'is_online': true,
          },
        ];
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading drivers: $e. Showing mock data.')),
        );
      }
    }
  }

  Future<void> _refreshDrivers() async {
    setState(() {
      isLoading = true;
    });
    await _loadDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      appBar: AppBar(
        title: const Text('Driver Management'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDrivers,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : drivers.isEmpty
                ? Center(
                    child: Text(
                      'No drivers found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        dataRowMinHeight: 70,
                        dataRowMaxHeight: 70,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFF1F2937),
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Driver Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Phone',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Address',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Vehicle Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Vehicle No',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: drivers.map<DataRow>((driver) {
                          final driverName =
                              driver['username'] ?? driver['name'] ?? 'N/A';
                          final phoneNo = driver['phone_number'] ?? 'N/A';
                          final email = driver['email'] ?? 'N/A';
                          final address = driver['address'] ?? 'N/A';
                          final vehicleName =
                              driver['vehicle_name'] ?? 'N/A';
                          final vehicleNo =
                              driver['vehicle_number'] ?? 'N/A';
                          final status = driver['is_online'] ?? false;
                          final statusText =
                              status ? 'Online' : 'Offline';
                          final statusColor = status
                              ? const Color(0xFF4CAF50)
                              : Colors.grey;

                          return DataRow(
                            color:
                                WidgetStateProperty.all(
                              Colors.white,
                            ),
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    driverName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    phoneNo,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    email,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    address,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    vehicleName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    vehicleNo,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
      ),
  );
 }
}
