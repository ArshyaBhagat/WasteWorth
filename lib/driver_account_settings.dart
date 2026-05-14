import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverAccountSettingsPage extends StatefulWidget {
  final String? username;
  final String? token;

  const DriverAccountSettingsPage({super.key, this.username, this.token});

  @override
  State<DriverAccountSettingsPage> createState() =>
      _DriverAccountSettingsPageState();
}

class _DriverAccountSettingsPageState extends State<DriverAccountSettingsPage> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCreating = false;

  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _vehicleNameController;
  late TextEditingController _vehicleNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _vehicleNameController = TextEditingController();
    _vehicleNumberController = TextEditingController();
    _loadDriverDetails();
  }

  void _loadDriverDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = widget.token ?? prefs.getString('token') ?? '';

      if (token.isEmpty) {
        throw Exception('No token found');
      }

      final details = await _apiService.getDriverDetails(token);

      setState(() {
        _nameController.text = details['driver_name'] ?? '';
        _phoneController.text = details['phone_number'] ?? '';
        _emailController.text = details['email_id'] ?? '';
        _addressController.text = details['address'] ?? '';
        _vehicleNameController.text = details['vehicle_name'] ?? '';
        _vehicleNumberController.text = details['vehicle_number'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.toString().contains('not found') || e.toString().contains('404')) {
        _showCreateForm();
      } else {
        _showSnackError('Failed to load driver details: $e');
      }
    }
  }

  void _showCreateForm() {
    setState(() {
      _nameController.text = widget.username ?? '';
      _isEditing = true;
      _isCreating = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create your driver profile')),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() async {
    // validate all fields -> each field will show its own error
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final vehicleName = _vehicleNameController.text.trim();
    final vehicleNumber = _vehicleNumberController.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = widget.token ?? prefs.getString('token') ?? '';

      if (token.isEmpty) {
        throw Exception('No token found');
      }

      if (_isCreating) {
        await _apiService.createDriverDetails(
          token: token,
          driverName: name,
          phoneNumber: phone,
          emailId: email,
          address: address,
          vehicleName: vehicleName,
          vehicleNumber: vehicleNumber,
        );
      } else {
        await _apiService.updateDriverDetails(
          token: token,
          driverName: name,
          phoneNumber: phone,
          emailId: email,
          address: address,
          vehicleName: vehicleName,
          vehicleNumber: vehicleNumber,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
        setState(() {
          _isEditing = false;
          _isSaving = false;
          _isCreating = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showSnackError('Failed to save: $e');
    }
  }

  void _showSnackError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          _buildTextField(
                              label: 'Driver Name',
                              controller: _nameController,
                              enabled: false, // ✅ FIXED (always disabled)
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) {
                                  return 'Driver name is required';
                                }
                                if (v.length < 2) {
                                  return 'Driver name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Phone Number',
                            controller: _phoneController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return 'Phone number is required';
                              }
                              final reg = RegExp(r'^\+91\d{10}$');
                              if (!reg.hasMatch(v)) {
                                return 'Use format +91XXXXXXXXXX';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Email ID',
                            controller: _emailController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return 'Email is required';
                              }
                              final reg =
                                  RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
                              if (!reg.hasMatch(v)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Address',
                            controller: _addressController,
                            enabled: _isEditing,
                            maxLines: 3,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return 'Address is required';
                              }
                              if (v.length < 5) {
                                return 'Address must be at least 5 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Vehicle Name',
                            controller: _vehicleNameController,
                            enabled: _isEditing,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return 'Vehicle name is required';
                              }
                              if (v.length < 2) {
                                return 'Vehicle name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Vehicle Number',
                            controller: _vehicleNumberController,
                            enabled: _isEditing,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return 'Vehicle number is required';
                              }
                              final reg =
                                  RegExp(r'^[A-Za-z0-9\- ]{5,}$');
                              if (!reg.hasMatch(v)) {
                                return 'Enter a valid vehicle number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomButton(),
              ],
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            color: enabled ? Colors.black : Colors.grey[700],
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    enabled ? const Color(0xFFD1D5DB) : Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF1F2937), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

Widget _buildBottomButton() {
  return SafeArea(
    child: Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,

        // ✅ MAGIC FIX
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed:
              _isSaving ? null : (_isEditing ? _saveChanges : _toggleEdit),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F2937),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _isEditing ? 'Save Changes' : 'Edit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    ),
  );
}
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _vehicleNameController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }
}
