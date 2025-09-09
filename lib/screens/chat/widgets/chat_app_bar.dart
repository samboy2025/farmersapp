import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../../../models/chat.dart';
import '../../contact/contact_detail_screen.dart';
import '../media_gallery_screen.dart';
import '../mute_notifications_screen.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Chat chat;
  final VoidCallback? onVoiceCall;
  final VoidCallback? onVideoCall;
  final VoidCallback? onAvatarTap;

  const ChatAppBar({
    super.key,
    required this.chat,
    this.onVoiceCall,
    this.onVideoCall,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return AppBar(
      backgroundColor: AppConfig.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            splashRadius: 20,
          ),
          
          // Avatar and user info - taking most of the space
          Expanded(
            child: GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                padding: EdgeInsets.only(left: isTablet ? 8 : 4),
                child: Row(
                  children: [
                    _buildAvatar(isTablet),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            chat.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 18 : 16,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isTablet ? 2 : 1),
                          Text(
                            _getStatusText(),
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Voice call button
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: onVoiceCall ?? () => _showCallOptions(context, isVideo: false),
          tooltip: 'Voice Call',
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          splashRadius: 20,
        ),
        // Video call button
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: onVideoCall ?? () => _showCallOptions(context, isVideo: true),
          tooltip: 'Video Call',
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          splashRadius: 20,
        ),
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuSelection(context, value),
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
          itemBuilder: (context) => [
            _buildMenuItem('search', 'Search in chat', Icons.search),
            _buildMenuItem('view_contact', 'View contact', Icons.contact_page),
            _buildMenuItem('media', 'Media, links, and docs', Icons.photo_library),
            _buildMenuItem('mute', 'Mute notifications', Icons.notifications_off),
            _buildMenuItem('clear', 'Clear chat', Icons.clear_all),
            _buildMenuItem('delete', 'Delete chat', Icons.delete, isDestructive: true),
          ],
        ),
        
        SizedBox(width: screenSize.width * 0.02), // Responsive padding
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String text, IconData icon, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? Colors.red : const Color(0xFF667781),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isDestructive ? Colors.red : const Color(0xFF111B21),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isTablet) {
    final double radius = isTablet ? 24 : 20;

    if (chat.isGroup) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image.asset(
            'assets/images/icons/Group placeholder.png',
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => CircleAvatar(
              radius: radius,
              backgroundColor: AppConfig.primaryColor,
              child: Icon(Icons.group, color: Colors.white, size: radius),
            ),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image.asset(
            'assets/images/icons/userPlaceholder.png',
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => CircleAvatar(
              radius: radius,
              backgroundColor: AppConfig.primaryColor,
              child: Icon(Icons.person, color: Colors.white, size: radius),
            ),
          ),
        ),
      );
    }
  }

  String _getStatusText() {
    if (chat.isGroup) {
      return '${chat.participants.length} members';
    } else {
      final participant = chat.participants.first;
      if (participant.isOnline) {
        return 'Online';
      } else {
        // Calculate last seen
        final now = DateTime.now();
        final lastSeen = participant.lastSeen;
        final difference = now.difference(lastSeen);
        
        if (difference.inMinutes < 1) {
          return 'Just now';
        } else if (difference.inHours < 1) {
          return '${difference.inMinutes}m ago';
        } else if (difference.inDays < 1) {
          return '${difference.inHours}h ago';
        } else {
          return '${difference.inDays}d ago';
        }
      }
    }
  }

  void _showCallOptions(BuildContext context, {required bool isVideo}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isVideo ? Icons.videocam : Icons.call,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: Text(
                '${isVideo ? 'Video' : 'Voice'} Call',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111B21),
                ),
              ),
              subtitle: Text(
                'Call ${chat.name}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667781),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/call', arguments: {
                  'chat': chat,
                  'isVideo': isVideo,
                  'isIncoming': false,
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'search':
        // Navigate back to chat screen to enable search mode
        Navigator.of(context).pop(); // Close the menu
        // The search functionality will be handled by the ChatScreen
        break;
      case 'view_contact':
        // Navigate to contact detail screen
        Navigator.of(context).pop(); // Close the menu
        if (!chat.isGroup && chat.participants.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactDetailScreen(contact: chat.participants.first),
            ),
          );
        }
        break;
      case 'media':
        // Navigate to media gallery screen
        Navigator.of(context).pop(); // Close the menu
        // TODO: Get actual media messages from chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaGalleryScreen(mediaMessages: []),
          ),
        );
        break;
      case 'mute':
        // Navigate to mute notifications screen
        Navigator.of(context).pop(); // Close the menu
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MuteNotificationsScreen(chat: chat),
          ),
        );
        break;
      case 'clear':
        // Show clear chat dialog
        _showClearChatDialog(context);
        break;
      case 'delete':
        // Show delete chat dialog
        _showDeleteChatDialog(context);
        break;
    }
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Clear chat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111B21),
          ),
        ),
        content: Text(
          'Are you sure you want to clear all messages in ${chat.name}? This action cannot be undone.',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF667781),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF667781),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear chat
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Chat cleared'),
                  backgroundColor: AppConfig.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Clear',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete chat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111B21),
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${chat.name}? This action cannot be undone.',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF667781),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF667781),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete chat
              Navigator.pop(context); // Go back to chat list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Chat deleted'),
                  backgroundColor: AppConfig.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
