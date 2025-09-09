import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class MessageNotificationsScreen extends StatefulWidget {
  const MessageNotificationsScreen({super.key});

  @override
  State<MessageNotificationsScreen> createState() => _MessageNotificationsScreenState();
}

class _MessageNotificationsScreenState extends State<MessageNotificationsScreen> {
  bool _messageNotifications = true;
  bool _groupNotifications = true;
  bool _showPreview = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _lightEnabled = true;
  String _notificationSound = 'Default';
  int _popupNotification = 1; // 0: No popup, 1: Show popup, 2: Show popup with name

  final List<String> _sounds = [
    'Default',
    'Chime',
    'Bell',
    'Ding',
    'Pop',
    'Tone',
    'Silent'
  ];

  final List<String> _popupOptions = [
    'No popup',
    'Show popup',
    'Show popup with name'
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
          'Message Notifications',
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
            // General Notifications
            _buildSection(
              title: 'General',
              children: [
                _buildSwitchTile(
                  title: 'Message notifications',
                  subtitle: 'Receive notifications for new messages',
                  value: _messageNotifications,
                  onChanged: (value) {
                    setState(() {
                      _messageNotifications = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Group notifications',
                  subtitle: 'Receive notifications for group messages',
                  value: _groupNotifications,
                  onChanged: (value) {
                    setState(() {
                      _groupNotifications = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Show preview',
                  subtitle: 'Show message content in notifications',
                  value: _showPreview,
                  onChanged: (value) {
                    setState(() {
                      _showPreview = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sound & Vibration
            _buildSection(
              title: 'Sound & Vibration',
              children: [
                _buildSwitchTile(
                  title: 'Sound',
                  subtitle: 'Play sound for notifications',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
                if (_soundEnabled) ...[
                  _buildListTile(
                    title: 'Notification sound',
                    subtitle: _notificationSound,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showSoundSelector(),
                  ),
                ],
                _buildSwitchTile(
                  title: 'Vibration',
                  subtitle: 'Vibrate for notifications',
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Light',
                  subtitle: 'Use LED light for notifications',
                  value: _lightEnabled,
                  onChanged: (value) {
                    setState(() {
                      _lightEnabled = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Popup Notifications
            _buildSection(
              title: 'Popup Notifications',
              children: [
                _buildListTile(
                  title: 'Popup notification',
                  subtitle: _popupOptions[_popupNotification],
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPopupSelector(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Priority Settings
            _buildSection(
              title: 'Priority',
              children: [
                _buildListTile(
                  title: 'High priority notifications',
                  subtitle: 'Show high priority notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Handle high priority toggle
                    },
                    activeColor: AppConfig.primaryColor,
                  ),
                  onTap: () {},
                ),
                _buildListTile(
                  title: 'Override Do Not Disturb',
                  subtitle: 'Show notifications even when DND is on',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // Handle DND override toggle
                    },
                    activeColor: AppConfig.primaryColor,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
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

  void _showSoundSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        title: Text(
          'Notification Sound',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sounds.map((sound) {
            return RadioListTile<String>(
              title: Text(
                sound,
                style: TextStyle(
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              value: sound,
              groupValue: _notificationSound,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _notificationSound = value;
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

  void _showPopupSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        title: Text(
          'Popup Notification',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _popupOptions.asMap().entries.map((entry) {
            return RadioListTile<int>(
              title: Text(
                entry.value,
                style: TextStyle(
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              value: entry.key,
              groupValue: _popupNotification,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _popupNotification = value;
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
}
