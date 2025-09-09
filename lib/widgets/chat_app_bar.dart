import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../screens/chat/search_screen.dart';
import '../screens/group/create_group_screen.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onCameraTap;
  final VoidCallback? onMenuTap;
  final String title;
  final bool showBackButton;

  const ChatAppBar({
    super.key,
    this.onSearchTap,
    this.onCameraTap,
    this.onMenuTap,
    this.title = 'ChatWave',
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppConfig.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: widget.showBackButton,
      titleSpacing: widget.showBackButton ? null : 16,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
      actions: [
        // Search button
        IconButton(
          onPressed: widget.onSearchTap ?? () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          ),
          icon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
          tooltip: 'Search',
          splashRadius: 20,
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
        ),
        
        // Camera button
        IconButton(
          onPressed: widget.onCameraTap ?? () => _showCameraOptions(context),
          icon: const Icon(
            Icons.camera_alt_outlined,
            color: Colors.white,
          ),
          tooltip: 'Camera',
          splashRadius: 20,
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
        ),
        
        // More options (three dots)
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuSelection(context, value),
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          tooltip: 'More options',
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          position: PopupMenuPosition.under,
          splashRadius: 20,
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          itemBuilder: (BuildContext context) => [
            _buildMenuItem('new_group', 'New group', Icons.group_add),
            _buildMenuItem('new_broadcast', 'New broadcast', Icons.campaign),
            _buildMenuItem('linked_devices', 'Linked devices', Icons.devices),
            _buildMenuItem('starred_messages', 'Starred messages', Icons.star_outline),
            _buildMenuItem('settings', 'Settings', Icons.settings),
          ],
        ),
        
        SizedBox(width: MediaQuery.of(context).size.width * 0.02), // Responsive padding
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String text, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'new_group':
        _showNewGroupBottomSheet(context);
        break;
      case 'new_broadcast':
        Navigator.pushNamed(context, '/new-broadcast');
        break;
      case 'linked_devices':
        Navigator.pushNamed(context, '/linked-devices');
        break;
      case 'starred_messages':
        _showFeatureComingSoon(context, 'Starred messages');
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  void _showCameraOptions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text('Camera'),
              subtitle: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon(context, 'Camera');
              },
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text('Gallery'),
              subtitle: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon(context, 'Gallery');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewGroupBottomSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }

  void _showFeatureComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
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
