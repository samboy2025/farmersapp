import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last updated
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppConfig.darkCard : AppConfig.lightCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Last updated: January 1, 2024',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Content sections
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, send messages, or contact us for support. This includes your phone number, profile information, and the content of your messages.',
              isDark,
            ),

            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, process transactions, send you technical notices and support messages, and respond to your comments and questions.',
              isDark,
            ),

            _buildSection(
              'Information Sharing',
              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy or as required by law.',
              isDark,
            ),

            _buildSection(
              'Data Security',
              'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. Your messages are encrypted in transit and at rest.',
              isDark,
            ),

            _buildSection(
              'Your Rights',
              'You have the right to access, update, or delete your personal information. You can also opt out of certain data collection and processing activities.',
              isDark,
            ),

            _buildSection(
              'Cookies and Tracking',
              'We use cookies and similar technologies to enhance your experience, analyze usage patterns, and provide personalized content.',
              isDark,
            ),

            _buildSection(
              'Third-Party Services',
              'Our service may contain links to third-party websites or services. We are not responsible for the privacy practices of these external sites.',
              isDark,
            ),

            _buildSection(
              'Children\'s Privacy',
              'Our service is not intended for children under 13. We do not knowingly collect personal information from children under 13.',
              isDark,
            ),

            _buildSection(
              'Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.',
              isDark,
            ),

            _buildSection(
              'Contact Us',
              'If you have any questions about this privacy policy, please contact us at privacy@chatwave.com or through the app\'s support system.',
              isDark,
            ),

            const SizedBox(height: 32),

            // Accept/Decline buttons (for first-time users)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppConfig.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'By using ChatWave, you agree to our Privacy Policy and Terms of Service.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppConfig.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Decline',
                            style: TextStyle(color: AppConfig.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Privacy policy accepted'),
                                backgroundColor: AppConfig.successColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConfig.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppConfig.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
