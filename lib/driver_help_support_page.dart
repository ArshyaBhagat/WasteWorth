import 'package:flutter/material.dart';

class DriverHelpSupportPage extends StatefulWidget {
  const DriverHelpSupportPage({super.key});

  @override
  State<DriverHelpSupportPage> createState() => _DriverHelpSupportPageState();
}

class _DriverHelpSupportPageState extends State<DriverHelpSupportPage> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I cancel an assigned pickup?',
      'answer':
          'Drivers cannot cancel pickups directly from the app.\n\nIf you are unable to complete a pickup due to genuine reasons (vehicle issue, emergency, incorrect location, etc.), you must contact the support team immediately through Call or Email.\n\nOur admin team will review the request and take the necessary action.'
    },
    {
      'question': 'What happens if I don\'t reach the pickup location?',
      'answer':
          'If you are unable to reach the location:\n• Inform the support team as soon as possible\n• Provide the reason and pickup details\n• Failure to inform support may affect your driver rating.'
    },
    {
      'question': 'What if the user is unavailable at the pickup location?',
      'answer':
          'If the user is unavailable:\n• Wait for a reasonable time\n• Try contacting the user\n• Report the issue to support\n\nThe admin team will decide the next steps.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 32),
            _buildFAQSection(),
            const SizedBox(height: 32),
            _buildContactSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded( // ✅ prevents overflow
              child: Text(
                '🚚 Help & Support – Driver',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Find answers to common questions and get in touch with our support team',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

Widget _buildFAQSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded( // ✅ FIX: prevents overflow
              child: Text(
                '❓ Frequently Asked Questions (FAQ)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...faqs.map((faq) =>
            _buildFAQCard(faq['question']!, faq['answer']!)),
      ],
    ),
  );
}

  Widget _buildFAQCard(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '📞 Need More Help?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            icon: '📱',
            title: 'Call Us',
            content: '+91 1800-XXX-XXX',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: '📧',
            title: 'Email Us',
            content: 'support@wasteworth.com',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildAddressCard(),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return Material(
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
    );
  }

  Widget _buildAddressCard() {
    return Container(
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
);
  }
}
