import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class ChatWallpaperScreen extends StatefulWidget {
  const ChatWallpaperScreen({super.key});

  @override
  State<ChatWallpaperScreen> createState() => _ChatWallpaperScreenState();
}

class _ChatWallpaperScreenState extends State<ChatWallpaperScreen> {
  String _selectedWallpaper = 'Default';
  bool _blurWallpaper = false;
  double _brightness = 1.0;
  double _opacity = 1.0;

  final List<Map<String, dynamic>> _wallpapers = [
    {
      'name': 'Default',
      'type': 'color',
      'color': Colors.white,
    },
    {
      'name': 'Dark',
      'type': 'color',
      'color': const Color(0xFF121212),
    },
    {
      'name': 'Blue',
      'type': 'color',
      'color': const Color(0xFF1976D2),
    },
    {
      'name': 'Green',
      'type': 'color',
      'color': const Color(0xFF388E3C),
    },
    {
      'name': 'Purple',
      'type': 'color',
      'color': const Color(0xFF7B1FA2),
    },
    {
      'name': 'Ocean',
      'type': 'gradient',
      'colors': [Color(0xFF2196F3), Color(0xFF21CBF3)],
    },
    {
      'name': 'Sunset',
      'type': 'gradient',
      'colors': [Color(0xFFFF9800), Color(0xFFFF5722)],
    },
    {
      'name': 'Forest',
      'type': 'gradient',
      'colors': [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    },
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
          'Chat Wallpaper',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _saveWallpaper(),
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
      body: Column(
        children: [
          // Preview Section
          _buildPreviewSection(isDark),

          // Options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wallpaper Gallery
                  _buildSection(
                    title: 'Choose Wallpaper',
                    child: _buildWallpaperGrid(isDark),
                  ),

                  const SizedBox(height: 24),

                  // Adjustments
                  _buildSection(
                    title: 'Adjustments',
                    child: _buildAdjustments(isDark),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildSection(
                    title: 'Quick Actions',
                    child: _buildQuickActions(isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(bool isDark) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        child: Container(
          decoration: _getWallpaperDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sample chat messages
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This is how your messages will look with this wallpaper',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _getWallpaperDecoration() {
    final wallpaper = _wallpapers.firstWhere(
      (w) => w['name'] == _selectedWallpaper,
      orElse: () => _wallpapers[0],
    );

    if (wallpaper['type'] == 'color') {
      return BoxDecoration(
        color: wallpaper['color'],
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: wallpaper['colors'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
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
        child,
      ],
    );
  }

  Widget _buildWallpaperGrid(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _wallpapers.length,
        itemBuilder: (context, index) {
          final wallpaper = _wallpapers[index];
          final isSelected = wallpaper['name'] == _selectedWallpaper;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWallpaper = wallpaper['name'];
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppConfig.primaryColor : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  decoration: wallpaper['type'] == 'color'
                      ? BoxDecoration(color: wallpaper['color'])
                      : BoxDecoration(
                          gradient: LinearGradient(
                            colors: wallpaper['colors'],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdjustments(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        children: [
          // Brightness
          _buildSliderTile(
            title: 'Brightness',
            value: _brightness,
            onChanged: (value) {
              setState(() {
                _brightness = value;
              });
            },
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          // Opacity
          _buildSliderTile(
            title: 'Wallpaper Opacity',
            value: _opacity,
            onChanged: (value) {
              setState(() {
                _opacity = value;
              });
            },
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          // Blur
          _buildSwitchTile(
            title: 'Blur Wallpaper',
            subtitle: 'Apply blur effect to wallpaper',
            value: _blurWallpaper,
            onChanged: (value) {
              setState(() {
                _blurWallpaper = value;
              });
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        children: [
          _buildListTile(
            title: 'Upload Photo',
            subtitle: 'Choose from gallery',
            icon: Icons.photo_library,
            onTap: () => _uploadPhoto(),
            isDark: isDark,
          ),
          _buildListTile(
            title: 'Take Photo',
            subtitle: 'Use camera',
            icon: Icons.camera_alt,
            onTap: () => _takePhoto(),
            isDark: isDark,
          ),
          _buildListTile(
            title: 'Reset to Default',
            subtitle: 'Use default wallpaper',
            icon: Icons.restore,
            onTap: () => _resetToDefault(),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: 0.1,
                max: 2.0,
                onChanged: onChanged,
                activeColor: AppConfig.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
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
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withOpacity(0.1),
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
      onTap: onTap,
    );
  }

  void _saveWallpaper() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Wallpaper saved successfully'),
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

  void _uploadPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Upload photo feature coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _takePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Take photo feature coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _selectedWallpaper = 'Default';
      _blurWallpaper = false;
      _brightness = 1.0;
      _opacity = 1.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Wallpaper reset to default'),
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
