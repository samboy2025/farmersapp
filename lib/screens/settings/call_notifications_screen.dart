import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class CallNotificationsScreen extends StatefulWidget {
  const CallNotificationsScreen({super.key});

  @override
  State<CallNotificationsScreen> createState() => _CallNotificationsScreenState();
}

class _CallNotificationsScreenState extends State<CallNotificationsScreen> {
  bool _callNotifications = true;
  bool _ringtoneEnabled = true;
  bool _vibrationEnabled = true;
  bool _silentMode = false;
  String _ringtone = 'Default';
  int _vibrationPattern = 0;

  final List<String> _ringtones = [
    'Default',
    'Classic Phone',
    'Digital',
    'Marimba',
    'Chimes',
    'Silent'
  ];

  final List<String> _vibrationPatterns = [
    'Default',
    'Short',
    'Long',
    'Pulse',
    'Heartbeat',
    'Off'
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
          'Call Notifications',
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
            // General Settings
            _buildSection(
              title: 'General',
              children: [
                _buildSwitchTile(
                  title: 'Call notifications',
                  subtitle: 'Receive notifications for incoming calls',
                  value: _callNotifications,
                  onChanged: (value) {
                    setState(() {
                      _callNotifications = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  title: 'Silent mode',
                  subtitle: 'Mute all call sounds and vibrations',
                  value: _silentMode,
                  onChanged: (value) {
                    setState(() {
                      _silentMode = value;
                      if (value) {
                        _ringtoneEnabled = false;
                        _vibrationEnabled = false;
                      }
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Ringtone Settings
            if (!_silentMode) ...[
              _buildSection(
                title: 'Ringtone',
                children: [
                  _buildSwitchTile(
                    title: 'Ringtone',
                    subtitle: 'Play ringtone for incoming calls',
                    value: _ringtoneEnabled,
                    onChanged: (value) {
                      setState(() {
                        _ringtoneEnabled = value;
                      });
                    },
                  ),
                  if (_ringtoneEnabled) ...[
                    _buildListTile(
                      title: 'Call ringtone',
                      subtitle: _ringtone,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showRingtoneSelector(),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Vibration Settings
              _buildSection(
                title: 'Vibration',
                children: [
                  _buildSwitchTile(
                    title: 'Vibration',
                    subtitle: 'Vibrate for incoming calls',
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    },
                  ),
                  if (_vibrationEnabled) ...[
                    _buildListTile(
                      title: 'Vibration pattern',
                      subtitle: _vibrationPatterns[_vibrationPattern],
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showVibrationSelector(),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),
            ],

            // Advanced Settings
            _buildSection(
              title: 'Advanced',
              children: [
                _buildListTile(
                  title: 'Call waiting tone',
                  subtitle: 'Play tone when receiving another call',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Handle call waiting tone
                    },
                    activeColor: AppConfig.primaryColor,
                  ),
                  onTap: () {},
                ),
                _buildListTile(
                  title: 'Call end tone',
                  subtitle: 'Play tone when call ends',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // Handle call end tone
                    },
                    activeColor: AppConfig.primaryColor,
                  ),
                  onTap: () {},
                ),
                _buildListTile(
                  title: 'Auto answer',
                  subtitle: 'Automatically answer calls after delay',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // Handle auto answer
                    },
                    activeColor: AppConfig.primaryColor,
                  ),
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Test Section
            _buildSection(
              title: 'Test',
              children: [
                _buildListTile(
                  title: 'Test ringtone',
                  subtitle: 'Play the selected ringtone',
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _testRingtone(),
                ),
                _buildListTile(
                  title: 'Test vibration',
                  subtitle: 'Test the vibration pattern',
                  trailing: const Icon(Icons.vibration),
                  onTap: () => _testVibration(),
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

  void _showRingtoneSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        title: Text(
          'Call Ringtone',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _ringtones.map((ringtone) {
            return RadioListTile<String>(
              title: Text(
                ringtone,
                style: TextStyle(
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              value: ringtone,
              groupValue: _ringtone,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _ringtone = value;
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

  void _showVibrationSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        title: Text(
          'Vibration Pattern',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _vibrationPatterns.asMap().entries.map((entry) {
            return RadioListTile<int>(
              title: Text(
                entry.value,
                style: TextStyle(
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              value: entry.key,
              groupValue: _vibrationPattern,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _vibrationPattern = value;
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

  void _testRingtone() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Playing ringtone...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _testVibration() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Testing vibration...'),
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
