import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../config/app_config.dart';
import '../../utils/animation_utils.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../chat/chat_screen.dart';
import '../../widgets/chat_app_bar.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  Future<void> _onRefresh() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would trigger a refresh of chat data
    // For demo purposes, just show a brief feedback
    // You could dispatch a refresh event to the ChatBloc here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      appBar: const ChatAppBar(
        title: 'ChatWave',
      ),
      floatingActionButton: ScaleAnimation(
        beginScale: 0.8,
        endScale: 1.1,
        duration: AnimationDurations.quick,
        curve: AppAnimationCurves.microBounce,
        onTap: () => Navigator.pushNamed(context, '/select-contact'),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/select-contact'),
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
          elevation: 6,
          child: const Icon(Icons.chat_bubble_outline, size: 28),
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppConfig.primaryColor,
              ),
            );
          } else if (state is ChatsLoadSuccess) {
            return _buildChatsList(context, state.chats);
          } else if (state is ChatError) {
            return _buildErrorState(context, state.message);
          } else {
            return _buildEmptyState(context);
          }
        },
      ),
    );
  }



  Widget _buildChatsList(BuildContext context, List<Chat> chats) {
    if (chats.isEmpty) {
      return _buildEmptyState(context);
    }

    final sortedChats = List<Chat>.from(chats)..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppConfig.primaryColor,
      backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
      displacement: 20,
      strokeWidth: 3,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80, top: 8),
        physics: const BouncingScrollPhysics(), // Add bounce physics
        children: sortedChats.asMap().entries.map((entry) {
          final index = entry.key;
          final chat = entry.value;
          return Column(
            children: [
              _WhatsAppChatTile(chat: chat),
              if (index < sortedChats.length - 1)
                Divider(
                  height: 1,
                  thickness: 0,
                  indent: 74,
                  color: isDark ? Colors.grey.shade700 : const Color(0xFFE8E8E8),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

    Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No chats yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start messaging your contacts',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                color: isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<ChatBloc>().add(ChatsFetched()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Try again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMuteChat(BuildContext context, Chat chat) {
    // In a real app, this would update the chat in the backend
    // For demo purposes, we'll just show a confirmation
    final newMuteStatus = !chat.isMuted;
    final action = newMuteStatus ? 'muted' : 'unmuted';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat ${chat.name} has been $action'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, this would revert the change
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Action undone')),
            );
          },
        ),
      ),
    );
  }

  void _toggleArchiveChat(BuildContext context, Chat chat) {
    // In a real app, this would update the chat in the backend
    // For demo purposes, we'll just show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat ${chat.name} has been archived'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, this would unarchive the chat
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chat unarchived')),
            );
          },
        ),
      ),
    );
  }
}



class _WhatsAppChatTile extends StatefulWidget {
  final Chat chat;
  const _WhatsAppChatTile({required this.chat});

  @override
  State<_WhatsAppChatTile> createState() => _WhatsAppChatTileState();
}

class _WhatsAppChatTileState extends State<_WhatsAppChatTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ChatScreen(chat: widget.chat)),
      ),
      onLongPress: () => _showChatOptions(context, widget.chat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar - Fixed size for grid consistency
            _buildAvatar(widget.chat),
            
            const SizedBox(width: 12),
            
            // Content area with proper hierarchy
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Name and Time
                  _buildTopRow(),
                  
                  const SizedBox(height: 2),
                  
                  // Bottom row: Message preview and unread count
                  _buildBottomRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
                    children: [
        // Name with high contrast
                      Expanded(
                              child: Text(
                                widget.chat.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: widget.chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
              color: isDark ? AppConfig.darkText : const Color(0xFF111B21), // High contrast dark color
              height: 1.2,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Time with proper contrast
        Text(
          _formatTime(widget.chat.lastActivity),
          style: TextStyle(
            fontSize: 12,
            color: widget.chat.unreadCount > 0
                ? AppConfig.primaryColor
                : (isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781)), // Proper contrast gray
            fontWeight: widget.chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
                // Message status icon if sent by current user
        // TODO: Update when current user ID is available
        if (widget.chat.lastMessage?.sender.id == 'current_user_id') ...[
          Icon(
            Icons.done_all, // Simplified for now
            size: 16,
            color: AppConfig.primaryColor,
          ),
          const SizedBox(width: 4),
        ],

        // Message preview
                      Expanded(
                        child: Text(
                          _getLastMessagePreview(widget.chat.lastMessage),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: widget.chat.unreadCount > 0
                  ? (isDark ? Colors.grey.shade300 : const Color(0xFF3B4A54)) // Darker gray for unread
                  : (isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781)), // Standard gray
              height: 1.3,
                          ),
                        ),
                      ),

        // Unread badge with high visibility
        if (widget.chat.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                        Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.chat.unreadCount > 99 ? 6 : 7,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor,
              borderRadius: BorderRadius.circular(11),
            ),
            constraints: const BoxConstraints(minWidth: 22),
            child: Text(
              widget.chat.unreadCount > 99 ? '99+' : widget.chat.unreadCount.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              ),
            ),
          ],

        // Pin indicator
        if (widget.chat.isPinned && widget.chat.unreadCount == 0) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.push_pin,
            size: 16,
            color: isDark ? Colors.grey.shade500 : const Color(0xFF8696A0),
          ),
        ],
      ],
    );
  }

  void _toggleMuteChat(BuildContext context, Chat chat) {
    // In a real app, this would update the chat in the backend
    // For demo purposes, we'll just show a confirmation
    final newMuteStatus = !chat.isMuted;
    final action = newMuteStatus ? 'muted' : 'unmuted';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat ${chat.name} has been $action'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, this would revert the change
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Action undone')),
            );
          },
        ),
      ),
    );
  }

  void _toggleArchiveChat(BuildContext context, Chat chat) {
    // In a real app, this would update the chat in the backend
    // For demo purposes, we'll just show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat ${chat.name} has been archived'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, this would unarchive the chat
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chat unarchived')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(Chat chat) {
    // Consistent 48x48 avatar size for unified grid
    const double avatarSize = 48;

    if (chat.isGroup) {
      return SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: Image.asset(
              'assets/images/icons/Group placeholder.png',
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: AppConfig.primaryColor,
                child: Icon(Icons.group, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: Image.asset(
              'assets/images/icons/userPlaceholder.png',
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: AppConfig.primaryColor,
                child: Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      );
    }
  }


  // WhatsApp-like avatar colors
  static const List<Color> _avatarColors = [
    Color(0xFF00A884), // WhatsApp green
    Color(0xFF1BA0E2), // Blue
    Color(0xFFA8860D), // Gold
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF009688), // Teal
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
  ];

  String _getLastMessagePreview(Message? message) {
    if (message == null) return 'Tap to start chatting';
    
    // Add emoji indicators for better visual hierarchy
    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.file:
        return '📎 ${message.fileName ?? 'Document'}';
      case MessageType.contact:
        return '👤 Contact';
      case MessageType.location:
        return '📍 Location';
      case MessageType.voice:
        return '🎤 Voice message';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    // Today: show time
    if (_isToday(time)) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    
    // Yesterday
    if (_isYesterday(time)) {
      return 'Yesterday';
    }
    
    // This week: show day name
    if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[time.weekday - 1];
    }
    
    // Older: show date
    return '${time.day}/${time.month}/${time.year.toString().substring(2)}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
    }

  void _showChatOptions(BuildContext context, Chat chat) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Chat name header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildAvatar(chat),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
                          ),
                        ),
                        if (chat.lastMessage != null)
                          Text(
                            _formatTime(chat.lastActivity),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Options
            _buildOptionTile(
              icon: chat.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              title: chat.isPinned ? 'Unpin' : 'Pin',
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement pin functionality
              },
            ),

            _buildOptionTile(
              icon: chat.isMuted ? Icons.notifications_off : Icons.notifications_off_outlined,
              title: chat.isMuted ? 'Unmute notifications' : 'Mute notifications',
              onTap: () {
                Navigator.pop(context);
                _toggleMuteChat(context, chat);
              },
            ),

            _buildOptionTile(
              icon: Icons.archive_outlined,
              title: 'Archive',
              onTap: () {
                Navigator.pop(context);
                _toggleArchiveChat(context, chat);
              },
            ),

            _buildOptionTile(
              icon: Icons.delete_outline,
              title: 'Delete chat',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, chat);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Chat chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete chat?'),
        content: Text('Delete your chat with "${chat.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
                Navigator.pop(context);
              // TODO: Implement delete
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat deleted')),
                );
              },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            ),
          ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: color ?? (isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781)),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color ?? (isDark ? AppConfig.darkText : const Color(0xFF111B21)),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

}


