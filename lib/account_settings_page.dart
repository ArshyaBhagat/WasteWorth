import 'package:flutter/material.dart';
import 'api_service.dart';

class AccountSettingsPage extends StatefulWidget {
  final String? username;
  final String? phone;
  final String? email;
  final String? address;
  final String? token;
  final Function(String phone, String email, String address)? onSave;

  const AccountSettingsPage({
    super.key,
    this.username,
    this.phone,
    this.email,
    this.address,
    this.token,
    this.onSave,
  });

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username ?? '');
    _phoneController = TextEditingController(text: widget.phone ?? '');
    _emailController = TextEditingController(text: widget.email ?? '');
    _addressController = TextEditingController(text: widget.address ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSettingsSection(
                      title: 'Account Information',
                      child: Column(
                        children: [
                          _buildInputField(
                            label: 'Username',
                            controller: _usernameController,
                            icon: Icons.person,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Email Address',
                            controller: _emailController,
                            icon: Icons.email,
                            enabled: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Phone Number',
                            controller: _phoneController,
                            icon: Icons.phone,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSettingsSection(
                      title: 'Delivery Address',
                      child: _buildInputField(
                        label: 'Your Address',
                        controller: _addressController,
                        icon: Icons.location_on,
                        enabled: _isEditing,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isEditing ? _saveChanges : _enableEditing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Edit',
                    style: const TextStyle(
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
      ),
    );
  }

  void _enableEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  Widget _buildSettingsSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: enabled ? Colors.white : const Color(0xFFF3F4F6),
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: enabled ? const Color(0xFF2196F3) : const Color(0xFF9CA3AF),
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF2196F3),
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    try {
      if (widget.token != null) {
        await _api.updateUser(
          token: widget.token!,
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
        });

        widget.onSave?.call(
          _phoneController.text.trim(),
          _emailController.text.trim(),
          _addressController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Changes saved successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
