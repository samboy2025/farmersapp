import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/theme_provider.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/standard_app_bar.dart';
import 'message_notifications_screen.dart';
import 'call_notifications_screen.dart';
import 'chat_backup_screen.dart';
import 'chat_wallpaper_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  // Removed unused field
  bool _autoDownloadMedia = true;
  bool _readReceipts = true;
  bool _typingIndicators = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];
  final List<String> _themes = ['System', 'Light', 'Dark'];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      appBar: StandardAppBar(
        title: 'Settings',
        showBackButton: true,
        showSearchButton: false,
        showCameraButton: false,
        showMoreOptions: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: isTablet ? 16 : 12,
          ),
          child: Column(
            children: [
              // Profile section
              _buildProfileSection(),
            
            // Notifications
            _buildSection(
              title: 'Notifications',
              children: [
                _buildSwitchTile(
                  title: 'Enable Notifications',
                  subtitle: 'Receive notifications for new messages',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                if (_notificationsEnabled) ...[
                  _buildListTile(
                    title: 'Message Notifications',
                    subtitle: 'Customize message notifications',
                    icon: Icons.message,
                    onTap: () => _showMessageNotifications(context),
                  ),
                  _buildListTile(
                    title: 'Call Notifications',
                    subtitle: 'Customize call notifications',
                    icon: Icons.call,
                    onTap: () => _showCallNotifications(context),
                  ),
                ],
              ],
            ),
            
            // Privacy
            _buildSection(
              title: 'Privacy',
              children: [
                _buildSwitchTile(
                  title: 'Read Receipts',
                  subtitle: 'Show when you read messages',
                  value: _readReceipts,
                  onChanged: (value) {
                    setState(() {
                      _readReceipts = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Typing Indicators',
                  subtitle: 'Show when you are typing',
                  value: _typingIndicators,
                  onChanged: (value) {
                    setState(() {
                      _typingIndicators = value;
                    });
                  },
                ),
                _buildListTile(
                  title: 'Last Seen',
                  subtitle: 'Control who can see your last seen',
                  icon: Icons.visibility,
                  onTap: () => _showLastSeenSettings(context),
                ),
                _buildListTile(
                  title: 'Profile Photo',
                  subtitle: 'Control who can see your profile photo',
                  icon: Icons.photo,
                  onTap: () => _showProfilePhotoSettings(context),
                ),
                _buildListTile(
                  title: 'About',
                  subtitle: 'Control who can see your about',
                  icon: Icons.info,
                  onTap: () => _showAboutSettings(context),
                ),
              ],
            ),
            
            // Chats
            _buildSection(
              title: 'Chats',
              children: [
                _buildSwitchTile(
                  title: 'Auto-download Media',
                  subtitle: 'Automatically download media files',
                  value: _autoDownloadMedia,
                  onChanged: (value) {
                    setState(() {
                      _autoDownloadMedia = value;
                    });
                  },
                ),
                _buildListTile(
                  title: 'Chat Backup',
                  subtitle: 'Backup your chats to cloud',
                  icon: Icons.backup,
                  onTap: () => _showChatBackup(context),
                ),
                _buildListTile(
                  title: 'Chat History',
                  subtitle: 'Manage your chat history',
                  icon: Icons.history,
                  onTap: () => _showChatHistory(context),
                ),
                _buildListTile(
                  title: 'Storage and Data',
                  subtitle: 'Manage storage and data usage',
                  icon: Icons.storage,
                  onTap: () => _showStorageAndData(context),
                ),
              ],
            ),
            
            // Appearance
            _buildSection(
              title: 'Appearance',
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildListTile(
                      title: 'Theme',
                      subtitle: themeProvider.themeModeString,
                      icon: Icons.palette,
                      onTap: () => _showThemeSelector(context, themeProvider),
                    );
                  },
                ),
                _buildListTile(
                  title: 'Language',
                  subtitle: _selectedLanguage,
                  icon: Icons.language,
                  onTap: () => _showLanguageSelector(context),
                ),
                _buildListTile(
                  title: 'Chat Wallpaper',
                  subtitle: 'Customize chat background',
                  icon: Icons.wallpaper,
                  onTap: () => _showChatWallpaper(context),
                ),
                _buildListTile(
                  title: 'Font Size',
                  subtitle: 'Adjust text size in chats',
                  icon: Icons.text_fields,
                  onTap: () => _showFontSizeSettings(context),
                ),
              ],
            ),
            
            // Calls
            _buildSection(
              title: 'Calls',
              children: [
                _buildListTile(
                  title: 'Call Settings',
                  subtitle: 'Configure call preferences',
                  icon: Icons.settings,
                  onTap: () => _showCallSettings(context),
                ),
                _buildListTile(
                  title: 'Call History',
                  subtitle: 'Manage your call history',
                  icon: Icons.history,
                  onTap: () => _showCallHistory(context),
                ),
              ],
            ),
            
            // Help & Support
            _buildSection(
              title: 'Help & Support',
              children: [
                _buildListTile(
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  icon: Icons.help,
                  onTap: () => _showHelpCenter(context),
                ),
                _buildListTile(
                  title: 'Contact Us',
                  subtitle: 'Get in touch with our team',
                  icon: Icons.contact_support,
                  onTap: () => _showContactUs(context),
                ),
                _buildListTile(
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  icon: Icons.privacy_tip,
                  onTap: () => _showPrivacyPolicy(context),
                ),
                _buildListTile(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  icon: Icons.description,
                  onTap: () => _showTermsOfService(context),
                ),
              ],
            ),
            
              // About
              _buildSection(
                title: 'About',
                children: [
                  _buildListTile(
                    title: 'App Version',
                    subtitle: '1.0.0',
                    icon: Icons.info,
                    onTap: null,
                  ),
                  _buildListTile(
                    title: 'Licenses',
                    subtitle: 'View open source licenses',
                    icon: Icons.description,
                    onTap: () => _showLicenses(context),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 32 : 20),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfileSection() {
    final currentUser = MockDataService.currentUser;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppConfig.primaryColor.withValues(alpha: 0.2),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: isTablet ? 45 : 40,
              backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
              backgroundImage: currentUser.profilePicture != null
                  ? NetworkImage(currentUser.profilePicture!)
                  : null,
              child: currentUser.profilePicture == null
                  ? Text(
                      currentUser.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: AppConfig.primaryColor,
                        fontSize: isTablet ? 36 : 32,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser.name,
                  style: TextStyle(
                    color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
                    fontSize: isTablet ? 22 : 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  currentUser.phoneNumber,
                  style: TextStyle(
                    color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  currentUser.about ?? 'Hey there! I am using ChatWave.',
                  style: TextStyle(
                    color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                    fontSize: isTablet ? 14 : 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit, 
                color: AppConfig.primaryColor,
                size: isTablet ? 24 : 20,
              ),
              onPressed: () => _editProfile(context),
              constraints: BoxConstraints(
                minWidth: isTablet ? 48 : 44,
                minHeight: isTablet ? 48 : 44,
              ),
              splashRadius: isTablet ? 24 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 24 : 20,
              isTablet ? 20 : 16,
              isTablet ? 24 : 20,
              isTablet ? 8 : 4,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
              ),
            ),
          ),
          ...children,
          SizedBox(height: isTablet ? 8 : 4),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConfig.primaryColor,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppConfig.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? AppConfig.darkText : AppConfig.lightText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _editProfile(BuildContext context) {
    // Navigate to profile edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening profile editor...')),
    );
  }

  void _showMessageNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MessageNotificationsScreen(),
      ),
    );
  }

  void _showCallNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CallNotificationsScreen(),
      ),
    );
  }

  void _showLastSeenSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Last Seen'),
        content: const Text('Last seen privacy settings coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProfilePhotoSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Photo'),
        content: const Text('Profile photo privacy settings coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text('About privacy settings coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChatBackup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatBackupScreen(),
      ),
    );
  }

  void _showChatHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat History'),
        content: const Text('Chat history management coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showStorageAndData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage and Data'),
        content: const Text('Storage and data management coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _themes.map((theme) {
            return RadioListTile<String>(
              title: Text(theme),
              value: theme,
              groupValue: themeProvider.themeModeString,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeFromString(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showChatWallpaper(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatWallpaperScreen(),
      ),
    );
  }

  void _showFontSizeSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: const Text('Font size settings coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCallSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Settings'),
        content: const Text('Call settings coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCallHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call History'),
        content: const Text('Call history management coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpCenterScreen(),
      ),
    );
  }

  void _showContactUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Text('Contact us functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('Terms of service content coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Licenses'),
        content: const Text('Open source licenses coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
