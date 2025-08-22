import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      size: 40,
                      color: Color(0xFF6B46C1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We\'re Here to Help',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF6B46C1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you need support, have questions, or are in crisis, please reach out.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Emergency Section
            _buildSection(
              context,
              'Emergency Support',
              Icons.emergency,
              Colors.red,
              [
                HelpItem(
                  title: 'National Crisis Helpline',
                  subtitle: '24/7 Crisis Support',
                  description: 'If you\'re in immediate danger or crisis, call this number for immediate help.',
                  action: 'Call 988',
                  onAction: () => _showComingSoon(context, 'Phone calling'),
                  icon: Icons.phone,
                  color: Colors.red,
                ),
                HelpItem(
                  title: 'Emergency Services',
                  subtitle: 'Police, Fire, Ambulance',
                  description: 'For life-threatening emergencies, call emergency services immediately.',
                  action: 'Call 911',
                  onAction: () => _showComingSoon(context, 'Emergency services'),
                  icon: Icons.emergency,
                  color: Colors.red,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Support Resources
            _buildSection(
              context,
              'Support Resources',
              Icons.support_agent,
              const Color(0xFF6B46C1),
              [
                HelpItem(
                  title: 'Mental Health Support',
                  subtitle: 'Professional Counseling',
                  description: 'Connect with licensed mental health professionals for confidential support.',
                  action: 'Find Support',
                  onAction: () => _showComingSoon(context, 'Mental health resources'),
                  icon: Icons.psychology,
                  color: const Color(0xFF6B46C1),
                ),
                HelpItem(
                  title: 'Domestic Violence Support',
                  subtitle: 'Safe Space & Resources',
                  description: 'Get help and resources for domestic violence situations.',
                  action: 'Get Help',
                  onAction: () => _showComingSoon(context, 'Domestic violence support'),
                  icon: Icons.shield,
                  color: const Color(0xFF6B46C1),
                ),
                HelpItem(
                  title: 'LGBTQ+ Support',
                  subtitle: 'Community & Resources',
                  description: 'Find support and resources specifically for LGBTQ+ individuals.',
                  action: 'Find Community',
                  onAction: () => _showComingSoon(context, 'LGBTQ+ support'),
                  icon: Icons.favorite,
                  color: const Color(0xFF6B46C1),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // App Support
            _buildSection(
              context,
              'App Support',
              Icons.support,
              Colors.orange,
              [
                HelpItem(
                  title: 'FAQ & Help Center',
                  subtitle: 'Common Questions',
                  description: 'Find answers to frequently asked questions about using the app.',
                  action: 'View FAQ',
                  onAction: () => _showComingSoon(context, 'FAQ section'),
                  icon: Icons.question_answer,
                  color: Colors.orange,
                ),
                HelpItem(
                  title: 'Contact Support Team',
                  subtitle: 'Get in Touch',
                  description: 'Reach out to our support team for technical or app-related issues.',
                  action: 'Email Support',
                  onAction: () => _showComingSoon(context, 'Email support'),
                  icon: Icons.email,
                  color: Colors.orange,
                ),
                HelpItem(
                  title: 'Feedback & Suggestions',
                  subtitle: 'Help Us Improve',
                  description: 'Share your feedback and suggestions to help us improve the app.',
                  action: 'Send Feedback',
                  onAction: () => _showComingSoon(context, 'Feedback form'),
                  icon: Icons.feedback,
                  color: Colors.orange,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // About Section
            _buildSection(
              context,
              'About NazarRiya',
              Icons.info,
              Colors.blue,
              [
                HelpItem(
                  title: 'Our Mission',
                  subtitle: 'Creating Change',
                  description: 'NazarRiya is dedicated to fostering meaningful conversations about gender, consent, masculinity, and empathy among young Indian men.',
                  action: 'Learn More',
                  onAction: () => _showComingSoon(context, 'About page'),
                  icon: Icons.info,
                  color: Colors.blue,
                ),
                HelpItem(
                  title: 'Privacy & Safety',
                  subtitle: 'Your Data Matters',
                  description: 'Learn about how we protect your privacy and ensure your safety while using the app.',
                  action: 'Privacy Policy',
                  onAction: () => _showComingSoon(context, 'Privacy policy'),
                  icon: Icons.privacy_tip,
                  color: Colors.blue,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Footer
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Color(0xFF6B46C1),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Remember: You\'re not alone',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF6B46C1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reaching out for help is a sign of strength, not weakness.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<HelpItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildHelpItem(context, item)),
      ],
    );
  }

  Widget _buildHelpItem(BuildContext context, HelpItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: item.onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: item.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(item.action),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: const Color(0xFF6B46C1),
      ),
    );
  }
}

class HelpItem {
  final String title;
  final String subtitle;
  final String description;
  final String action;
  final VoidCallback onAction;
  final IconData icon;
  final Color color;

  HelpItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.action,
    required this.onAction,
    required this.icon,
    required this.color,
  });
}
