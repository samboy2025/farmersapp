import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class ChatBackupScreen extends StatefulWidget {
  const ChatBackupScreen({super.key});

  @override
  State<ChatBackupScreen> createState() => _ChatBackupScreenState();
}

class _ChatBackupScreenState extends State<ChatBackupScreen> {
  bool _backupEnabled = true;
  bool _includeVideos = true;
  bool _backupOverWifiOnly = true;
  bool _autoBackup = true;
  String _backupFrequency = 'Daily';
  String _lastBackup = '2 hours ago';
  double _backupSize = 2.4; // GB

  final List<String> _frequencies = [
    'Manual only',
    'Daily',
    'Weekly',
    'Monthly'
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
          'Chat Backup',
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
            // Backup Status
            _buildStatusCard(isDark),

            const SizedBox(height: 24),

            // Backup Settings
            _buildSection(
              title: 'Backup Settings',
              children: [
                _buildSwitchTile(
                  title: 'Enable backup',
                  subtitle: 'Automatically backup your chats',
                  value: _backupEnabled,
                  onChanged: (value) {
                    setState(() {
                      _backupEnabled = value;
                    });
                  },
                ),
                if (_backupEnabled) ...[
                  _buildListTile(
                    title: 'Backup frequency',
                    subtitle: _backupFrequency,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showFrequencySelector(),
                  ),
                  _buildSwitchTile(
                    title: 'Auto backup',
                    subtitle: 'Backup automatically when connected',
                    value: _autoBackup,
                    onChanged: (value) {
                      setState(() {
                        _autoBackup = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Include videos',
                    subtitle: 'Include video files in backup',
                    value: _includeVideos,
                    onChanged: (value) {
                      setState(() {
                        _includeVideos = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Wi-Fi only',
                    subtitle: 'Backup only when connected to Wi-Fi',
                    value: _backupOverWifiOnly,
                    onChanged: (value) {
                      setState(() {
                        _backupOverWifiOnly = value;
                      });
                    },
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Backup Actions
            if (_backupEnabled) ...[
              _buildSection(
                title: 'Actions',
                children: [
                  _buildListTile(
                    title: 'Backup now',
                    subtitle: 'Create a backup immediately',
                    trailing: const Icon(Icons.backup),
                    onTap: () => _backupNow(),
                  ),
                  _buildListTile(
                    title: 'Restore backup',
                    subtitle: 'Restore from a previous backup',
                    trailing: const Icon(Icons.restore),
                    onTap: () => _restoreBackup(),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],

            // Backup History
            _buildSection(
              title: 'Backup History',
              children: [
                _buildListTile(
                  title: 'Last backup',
                  subtitle: _lastBackup,
                  trailing: const Icon(Icons.history),
                  onTap: () => _showBackupHistory(),
                ),
                _buildListTile(
                  title: 'Backup size',
                  subtitle: '${_backupSize.toStringAsFixed(1)} GB',
                  trailing: const Icon(Icons.storage),
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Storage Information
            _buildSection(
              title: 'Storage',
              children: [
                _buildListTile(
                  title: 'Local storage',
                  subtitle: 'Manage local backup files',
                  trailing: const Icon(Icons.folder),
                  onTap: () => _manageLocalStorage(),
                ),
                _buildListTile(
                  title: 'Google Drive',
                  subtitle: 'Backup to Google Drive',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      _toggleGoogleDriveBackup(value);
                    },
                    activeColor: AppConfig.primaryColor,
                  ),
                  onTap: () {},
                ),
                _buildListTile(
                  title: 'iCloud',
                  subtitle: 'Backup to iCloud',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      _toggleICloudBackup(value);
                    },
                    activeColor: AppConfig.primaryColor,
                  ),
                  onTap: () {},
                ),
              ],
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
                    'Backups include your messages, photos, videos, and documents. Backups are encrypted and stored securely.',
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

  Widget _buildStatusCard(bool isDark) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppConfig.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.backup,
              color: AppConfig.successColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backup Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _backupEnabled ? 'Backup is enabled' : 'Backup is disabled',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _backupEnabled ? Icons.check_circle : Icons.cancel,
            color: _backupEnabled ? AppConfig.successColor : Colors.red,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        Container(
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
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConfig.primaryColor,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
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
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showFrequencySelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        title: Text(
          'Backup Frequency',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _frequencies.map((frequency) {
            return RadioListTile<String>(
              title: Text(
                frequency,
                style: TextStyle(
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              value: frequency,
              groupValue: _backupFrequency,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _backupFrequency = value;
                  });
                  Navigator.pop(context);
                }
              },
              activeColor: AppConfig.primaryColor,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _backupNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Creating backup...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _restoreBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Restoring backup...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showBackupHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Backup history coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _manageLocalStorage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Local storage management coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _toggleGoogleDriveBackup(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Google Drive backup coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _toggleICloudBackup(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('iCloud backup coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
