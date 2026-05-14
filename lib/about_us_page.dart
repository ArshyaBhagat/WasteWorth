import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
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
          'About Us',
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
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSection(
                title: '👋 Who We Are',
                content:
                    'WasteWorth is a technology-driven recycling platform that connects households and businesses with verified scrap collectors.\nOur goal is to make waste recycling simple, transparent, and environmentally responsible.\n\nWhether it\'s paper, plastic, metal, glass, or e-waste, we ensure that recyclable materials are collected responsibly and processed sustainably — not dumped into landfills.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '🎯 Our Mission',
                content:
                    'To simplify waste management through smart technology while promoting fair value for scrap and contributing to a cleaner, greener planet for future generations.\n\n"Recycle smart. Earn fair. Protect the planet." 🌍',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '🧰 What We Do',
                content:
                    'We provide a smooth and reliable recycling experience for users:',
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: '📅',
                title: 'Convenient Scheduling',
                description:
                    'Book scrap pickups at your preferred date and time directly from the app.',
              ),
              _buildFeatureItem(
                icon: '✅',
                title: 'Verified Collectors',
                description:
                    'All collectors are background-checked and trained for professional service.',
              ),
              _buildFeatureItem(
                icon: '💰',
                title: 'Transparent Pricing',
                description:
                    'Fair, real-time rates based on scrap type and actual weight — no hidden charges.',
              ),
              _buildFeatureItem(
                icon: '♻️',
                title: 'Sustainable Recycling',
                description:
                    'Materials are recycled responsibly to reduce environmental impact.',
              ),
              _buildFeatureItem(
                icon: '🚪',
                title: 'Doorstep Pickup',
                description: 'No heavy lifting — we come directly to your location.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '❤️ Our Core Values',
                content: '',
              ),
              const SizedBox(height: 8),
              _buildValueItem(
                title: '🌍 Environmental Responsibility',
                description:
                    'We support a circular economy by reducing waste and maximizing reuse.',
              ),
              _buildValueItem(
                title: '🤝 Trust & Reliability',
                description:
                    'Transparency, punctuality, and professionalism in every pickup.',
              ),
              _buildValueItem(
                title: '⚖️ Fair Pricing',
                description:
                    'Honest rates that reflect true market value of recyclable materials.',
              ),
              _buildValueItem(
                title: '🚀 Innovation',
                description:
                    'Using modern technology to make recycling faster, smarter, and easier.',
              ),
              const SizedBox(height: 28),
              _buildContactSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          const Text(
            '🌱 About WasteWorth ♻️',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your trusted partner for hassle-free waste pickup and sustainable recycling solutions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
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
        if (content.isNotEmpty) ...[
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
      ],
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            '$icon $title',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem({
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
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
          const Text(
            '📞 Get in Touch',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Have questions or need help? We\'re here for you.',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          _buildContactLine(
            icon: Icons.email,
            label: 'Email:',
            value: 'support@wasteworth.com',
          ),
          const SizedBox(height: 10),
          _buildContactLine(
            icon: Icons.phone,
            label: 'Phone:',
            value: '+91 1800-XXX-XXX',
          ),
          const SizedBox(height: 10),
          _buildContactLine(
            icon: Icons.language,
            label: 'Website:',
            value: 'www.wasteworth.com',
          ),
        ],
      ),
    );
  }

  Widget _buildContactLine({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2196F3), size: 18),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
