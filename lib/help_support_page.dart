import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
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
          'Help & Support',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // FAQ heading
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '📌 Frequently Asked Questions (FAQ)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FAQ items
            _buildFaqItem(
              question: 'How do I schedule a pickup?',
              answer:
                  'To schedule a pickup, open the app and go to Schedule Pickup.\nSelect the scrap categories, enter approximate quantity, choose 3 preferred date & time slots, and submit the request. Our admin will confirm one slot.',
            ),
            _buildFaqItem(
              question: 'What types of scrap do you collect?',
              answer:
                  'We collect the following recyclable items:\n\n• Plastic\n• Paper & Cardboard\n• Metal\n• Glass\n• E-waste (mobiles, chargers, small electronics)\n\nAvailability may vary by location.',
            ),
            _buildFaqItem(
              question: 'How is the payment calculated?',
              answer:
                  'Payment is calculated based on:\n\n• Type of scrap\n• Actual weight measured during pickup\n• Current market rates\n\nThe final amount is shown after pickup confirmation.',
            ),
            _buildFaqItem(
              question: 'Can I cancel a scheduled pickup?',
              answer:
                  'Yes. You can cancel a pickup from My Pickups section before the driver is assigned.\nOnce a driver is assigned, cancellation may not be allowed.',
            ),
            _buildFaqItem(
              question: 'How do I track my pickup status?',
              answer:
                  'You can track your pickup status in real-time under My Pickups:\n\n• Pending Approval\n• Pickup Confirmed\n• Driver Assigned\n• Completed\n\nNotifications are sent for every update.',
            ),

            const SizedBox(height: 28),

            // Contact heading
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '📞 Need More Help?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact cards (same style as driver)
            _buildContactItem(
              icon: '📱',
              title: 'Call Us',
              content: '+91 1800-XXX-XXX',
              onTap: () {
                // TODO: launch dialer
              },
            ),
            _buildContactItem(
              icon: '📧',
              title: 'Email Us',
              content: 'support@wasteworth.com',
              onTap: () {
                // TODO: launch email
              },
            ),
            _buildAddressCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ---------- FAQ card (same width) ----------

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              '❓ $question',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Contact cards copied from driver page ----------

  Widget _buildContactItem({
    required String icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text(
              '📍',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'WasteWorth HQ, India',
                    style: TextStyle(
                      fontSize: 13,
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
}
