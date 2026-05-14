import 'package:flutter/material.dart';

class DriverTermsConditionsPage extends StatelessWidget {
  const DriverTermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSectionTitle('📜 Terms & Conditions – Driver'),
              _buildText('Last updated: December 2024', style: 'subtitle'),
              const SizedBox(height: 24),
              _buildSectionTitle('Welcome to WasteWorth (Driver)'),
              _buildText(
                'These Terms & Conditions ("Terms") govern the employment and use of the WasteWorth Driver application by registered drivers. By accessing or using the WasteWorth Driver app, you acknowledge that you are an authorized employee of WasteWorth and agree to comply with these Terms.',
              ),
              const SizedBox(height: 24),
              _buildNumberedSection('1. Employment Relationship', [
                'All drivers using the WasteWorth Driver application are employees of WasteWorth.',
                'As an employee driver, you are expected to:',
                '  • Follow company policies and operational guidelines',
                '  • Perform assigned duties responsibly',
                '  • Represent WasteWorth professionally during pickups',
                'WasteWorth reserves full managerial and operational control over driver activities.',
              ]),
              const SizedBox(height: 20),
              _buildNumberedSection('2. Driver Duties & Responsibilities', [
                'As a WasteWorth driver, you agree to:',
                '  • Report on time for assigned pickups',
                '  • Collect recyclable waste as per assigned categories',
                '  • Handle materials safely and responsibly',
                '  • Accurately measure and record scrap weight',
                '  • Update pickup status correctly in the app',
                '  • Maintain respectful behavior with users',
                'Any misconduct or negligence may lead to disciplinary action.',
              ]),
              const SizedBox(height: 20),
              _buildNumberedSection('3. Pickup Assignment & Workflow', [
                'Pickup assignments are managed by WasteWorth',
                'Drivers must accept and complete assigned pickups',
                'Pickup status must be updated at each stage (Assigned, On the Way, Completed)',
                'Failure to follow workflow instructions may impact performance evaluation.',
              ]),
              const SizedBox(height: 20),
              _buildNumberedSection('4. Cancellation Policy (Driver)', [
                'Drivers are not allowed to cancel pickups directly through the app.',
                'In case of emergencies or unavoidable issues, drivers must contact WasteWorth support or their supervisor immediately.',
                'All pickup cancellations are handled by the admin team.',
                'Unauthorized non-completion of pickups may lead to disciplinary action.',
              ]),
              const SizedBox(height: 20),
              _buildNumberedSection('5. Salary & Payments', [
                'Driver compensation is determined by WasteWorth and may include:',
                '  • Fixed salary',
                '  • Performance-based incentives',
                '  • Additional earnings based on completed pickups',
                'Payments are processed as per company payroll policies.',
              ]),
              const SizedBox(height: 20),
              _buildNumberedSection('6. Performance Monitoring', [
                'Driver performance may be evaluated based on:',
                '  • Punctuality',
                '  • Pickup completion rate',
                '  • Accuracy of data entry',
                '  • User feedback',
                '  • Compliance with company rules',
                'Consistent poor performance may result in warnings, suspension, or termination.',
              ]),
              const SizedBox(height: 20),
              _buildNumberedSection('7. Privacy & Confidentiality', [
                'Drivers must maintain confidentiality of:',
                '  • User information',
                '  • Company data',
                '  • Pickup details',
                'Any misuse or unauthorized sharing of data is strictly prohibited.',
              ]),
              const SizedBox(height: 20),
              _buildNumberedSection('8. Limitation of Liability', [
                'WasteWorth is not liable for:',
                '  • Losses caused by incorrect user information',
                '  • Delays due to unforeseen circumstances',
                'Driver liability, if any, will be handled as per company policy and applicable law.',
              ]),
              const SizedBox(height: 20),
              _buildNumberedSection('9. Disciplinary Action & Termination', [
                'WasteWorth reserves the right to:',
                '  • Issue warnings',
                '  • Suspend driver access',
                '  • Terminate employment',
                'In cases of policy violation, misconduct, fraud, or repeated non-compliance.',
              ]),
              const SizedBox(height: 20),
              _buildNumberedSection('10. Changes to Terms', [
                'WasteWorth may modify these Terms at any time.',
                'Continued employment and app usage imply acceptance of the updated Terms.',
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('📞 Contact Support'),
              _buildContactInfo(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildText(String text, {String style = 'body'}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: style == 'subtitle' ? 12 : 14,
        color: style == 'subtitle' ? Colors.grey[600] : Colors.grey[700],
        height: 1.6,
      ),
    );
  }

  Widget _buildNumberedSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 12),
        ...points.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildText(point),
            )),
      ],
    );
  }

  Widget _buildContactInfo() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactRow('📧 Email:', 'support@wasteworth.com'),
          const SizedBox(height: 12),
          _buildContactRow('📱 Phone:', '+91 1800-XXX-XXX'),
          const SizedBox(height: 12),
          _buildContactRow('📍 Address:', 'WasteWorth HQ, India'),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
