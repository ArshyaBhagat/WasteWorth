import 'package:flutter/material.dart';

class TermsConditionsPage extends StatefulWidget {
  const TermsConditionsPage({super.key});

  @override
  State<TermsConditionsPage> createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
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
          'Terms & Conditions',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildSection(
                title: '📜 Terms & Conditions',
                content: 'Last updated: December 2024',
                isHeader: true,
              ),
              _buildSection(
                title: 'Welcome to WasteWorth',
                content:
                    'These Terms & Conditions ("Terms") govern your use of our mobile application and services. By accessing or using WasteWorth, you agree to be bound by these Terms.',
              ),
              _buildSection(
                title: '1. Our Services',
                content:
                    'WasteWorth provides a platform for scheduling recyclable waste pickup services. We connect users with verified collectors to ensure convenient, safe, and eco-friendly waste disposal.\n\n🔹 Key Features\n• Convenient pickup scheduling\n• Verified collectors\n• Transparent pricing\n• Environment-friendly recycling',
              ),
              _buildSection(
                title: '2. User Responsibilities',
                content:
                    'By using WasteWorth, you agree to:\n\n• Provide accurate information while registering and booking pickups.\n• Use the service only for lawful purposes.\n• Ensure scrap materials are clean and accessible at pickup time.\n• Be available during the confirmed pickup slot.\n• Accept the final price based on actual weight and rates.',
              ),
              _buildSection(
                title: '3. Privacy & Data Protection',
                content:
                    'Your privacy is important to us. We collect and use your personal information in accordance with our Privacy Policy and take reasonable security measures to protect your data.',
              ),
              _buildSection(
                title: '4. Payment Terms',
                content:
                    'Payments are calculated based on type and weight of scrap collected.\n\n• Rates shown in the app are indicative and may change based on market conditions.\n• Final payment is confirmed after successful pickup.',
              ),
              _buildSection(
                title: '5. Cancellation Policy',
                content:
                    '• Users may cancel a pickup before driver assignment.\n• Cancellations after confirmation may not be allowed.',
              ),
              _buildSection(
                title: '6. Limitation of Liability',
                content:
                    'WasteWorth shall not be liable for any indirect, incidental, or consequential damages arising from the use of our services. Liability, if any, is limited to the amount paid for the service.',
              ),
              _buildSection(
                title: '7. Changes to Terms',
                content:
                    'We reserve the right to update these Terms at any time. Continued use of the app after changes implies acceptance of the updated Terms.',
              ),
              _buildSection(
                title: '📞 Contact Us',
                content:
                    'Email: support@wasteworth.com\n\nPhone: +91 1800-XXX-XXX\n\nAddress: WasteWorth HQ, India',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool isHeader = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isHeader ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
