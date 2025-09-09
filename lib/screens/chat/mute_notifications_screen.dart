import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/chat.dart';

class MuteNotificationsScreen extends StatefulWidget {
  final Chat chat;

  const MuteNotificationsScreen({
    super.key,
    required this.chat,
  });

  @override
  State<MuteNotificationsScreen> createState() => _MuteNotificationsScreenState();
}

class _MuteNotificationsScreenState extends State<MuteNotificationsScreen> {
  String _selectedMuteOption = '8_hours';
  bool _showNotifications = true;
  bool _showPreview = true;

  final List<Map<String, String>> _muteOptions = [
    {'value': '8_hours', 'label': '8 hours', 'description': 'Mute for 8 hours'},
    {'value': '1_week', 'label': '1 week', 'description': 'Mute for 1 week'},
    {'value': 'always', 'label': 'Always', 'description': 'Mute until you unmute'},
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
            Icons.close,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mute notifications',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveMuteSettings,
            style: TextButton.styleFrom(
              foregroundColor: AppConfig.primaryColor,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chat info header
            _buildChatInfoHeader(isDark),

            const SizedBox(height: 24),

            // Mute duration options
            _buildMuteDurationSection(isDark),

            const SizedBox(height: 24),

            // Additional settings
            _buildAdditionalSettings(isDark),

            const SizedBox(height: 24),

            // Information text
            _buildInfoText(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInfoHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : AppConfig.lightSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: Image.asset(
                widget.chat.isGroup
                    ? 'assets/images/icons/Group placeholder.png'
                    : 'assets/images/icons/userPlaceholder.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => CircleAvatar(
                  radius: 24,
                  backgroundColor: AppConfig.primaryColor,
                  child: Icon(
                    widget.chat.isGroup ? Icons.group : Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: TextStyle(
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.chat.isGroup
                      ? '${widget.chat.participants.length} members'
                      : 'Individual chat',
                  style: TextStyle(
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuteDurationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mute duration',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : AppConfig.lightSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _muteOptions.map((option) {
              final isSelected = _selectedMuteOption == option['value'];
              return RadioListTile<String>(
                value: option['value']!,
                groupValue: _selectedMuteOption,
                onChanged: (value) {
                  setState(() {
                    _selectedMuteOption = value!;
                  });
                },
                title: Text(
                  option['label']!,
                  style: TextStyle(
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  option['description']!,
                  style: TextStyle(
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                activeColor: AppConfig.primaryColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalSettings(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional settings',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : AppConfig.lightSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              SwitchListTile(
                value: _showNotifications,
                onChanged: (value) {
                  setState(() {
                    _showNotifications = value;
                  });
                },
                title: Text(
                  'Show notifications',
                  style: TextStyle(
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Allow notifications for this chat',
                  style: TextStyle(
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                activeColor: AppConfig.primaryColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                value: _showPreview,
                onChanged: (value) {
                  setState(() {
                    _showPreview = value;
                  });
                },
                title: Text(
                  'Show preview',
                  style: TextStyle(
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Show message preview in notifications',
                  style: TextStyle(
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                activeColor: AppConfig.primaryColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppConfig.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You can unmute this chat anytime from the chat options menu.',
              style: TextStyle(
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveMuteSettings() {
    // TODO: Implement saving mute settings to backend/local storage
    // For now, just show success message and navigate back

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedMuteOption == 'always'
              ? 'Chat muted successfully'
              : 'Chat muted for ${_muteOptions.firstWhere((option) => option['value'] == _selectedMuteOption)['label']}',
        ),
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
