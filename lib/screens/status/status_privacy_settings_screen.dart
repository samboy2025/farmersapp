import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class StatusPrivacySettingsScreen extends StatefulWidget {
  const StatusPrivacySettingsScreen({super.key});

  @override
  State<StatusPrivacySettingsScreen> createState() => _StatusPrivacySettingsScreenState();
}

class _StatusPrivacySettingsScreenState extends State<StatusPrivacySettingsScreen> {
  String _selectedPrivacy = 'Contacts Only'; // Contacts Only, Everyone, Nobody
  bool _allowReplies = true;
  bool _allowForwarding = true;
  bool _showViewCount = false;
  List<String> _blockedUsers = []; // In a real app, this would be populated from backend

  final List<String> _privacyOptions = [
    'Everyone',
    'Contacts Only',
    'Nobody',
  ];

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
          'Status Privacy',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppConfig.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Who can see my status
            _buildSection(
              title: 'Who can see my status',
              child: _buildPrivacySelector(isDark),
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Interactions
            _buildSection(
              title: 'Interactions',
              child: _buildInteractionsSettings(isDark),
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Analytics
            _buildSection(
              title: 'Analytics',
              child: _buildAnalyticsSettings(isDark),
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Blocked Users
            _buildSection(
              title: 'Blocked Users',
              child: _buildBlockedUsers(isDark),
              isDark: isDark,
            ),

            const SizedBox(height: 32),

            // Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppConfig.darkCard : AppConfig.lightCard,
                borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppConfig.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your privacy settings apply to all your status updates. You can change these settings at any time.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildPrivacySelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        children: _privacyOptions.map((option) {
          final isSelected = option == _selectedPrivacy;
          return ListTile(
            title: Text(
              option,
              style: TextStyle(
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              _getPrivacyDescription(option),
              style: TextStyle(
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                fontSize: 12,
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check,
                    color: AppConfig.primaryColor,
                  )
                : null,
            onTap: () {
              setState(() {
                _selectedPrivacy = option;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInteractionsSettings(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Allow replies',
              style: TextStyle(
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            subtitle: Text(
              'Let others reply to your status',
              style: TextStyle(
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                fontSize: 12,
              ),
            ),
            value: _allowReplies,
            onChanged: (value) {
              setState(() {
                _allowReplies = value;
              });
            },
            activeColor: AppConfig.primaryColor,
          ),
          SwitchListTile(
            title: Text(
              'Allow forwarding',
              style: TextStyle(
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            subtitle: Text(
              'Let others forward your status',
              style: TextStyle(
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                fontSize: 12,
              ),
            ),
            value: _allowForwarding,
            onChanged: (value) {
              setState(() {
                _allowForwarding = value;
              });
            },
            activeColor: AppConfig.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSettings(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Show view count',
              style: TextStyle(
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            subtitle: Text(
              'Display how many people viewed your status',
              style: TextStyle(
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                fontSize: 12,
              ),
            ),
            value: _showViewCount,
            onChanged: (value) {
              setState(() {
                _showViewCount = value;
              });
            },
            activeColor: AppConfig.primaryColor,
          ),
          ListTile(
            title: Text(
              'View status insights',
              style: TextStyle(
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            subtitle: Text(
              'See who viewed your status and when',
              style: TextStyle(
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _viewInsights(),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUsers(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: _blockedUsers.isEmpty
          ? Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.block,
                    size: 48,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No blocked users',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Users you block won\'t be able to see your status',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _blockedUsers.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              itemBuilder: (context, index) {
                final user = _blockedUsers[index];
                return ListTile(
                  title: Text(
                    user,
                    style: TextStyle(
                      color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () => _unblockUser(user),
                    child: Text(
                      'Unblock',
                      style: TextStyle(
                        color: AppConfig.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _getPrivacyDescription(String option) {
    switch (option) {
      case 'Everyone':
        return 'All WhatsApp users can see your status';
      case 'Contacts Only':
        return 'Only people in your contacts can see your status';
      case 'Nobody':
        return 'No one can see your status updates';
      default:
        return '';
    }
  }

  void _viewInsights() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Status insights coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _unblockUser(String user) {
    setState(() {
      _blockedUsers.remove(user);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$user has been unblocked'),
        backgroundColor: AppConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Privacy settings saved successfully'),
        backgroundColor: AppConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.of(context).pop();
  }
}
