import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/call/call_bloc.dart';
import '../models/call.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../config/app_config.dart';
import '../services/call_service.dart';
import '../services/mock_data_service.dart';

/// Call buttons widget that can be used in chat headers, contact lists, etc.
class CallButtons extends StatelessWidget {
  final User user;
  final bool showLabels;
  final double buttonSize;
  final EdgeInsets? margin;

  const CallButtons({
    super.key,
    required this.user,
    this.showLabels = false,
    this.buttonSize = 40,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Voice call button
        _CallButton(
          icon: Icons.call,
          label: showLabels ? 'Call' : null,
          color: AppConfig.successColor,
          size: buttonSize,
          margin: margin,
          onPressed: () => _makeCall(context, CallType.voice),
        ),
        
        const SizedBox(width: 8),
        
        // Video call button
        _CallButton(
          icon: Icons.videocam,
          label: showLabels ? 'Video' : null,
          color: AppConfig.accentColor,
          size: buttonSize,
          margin: margin,
          onPressed: () => _makeCall(context, CallType.video),
        ),
      ],
    );
  }

  void _makeCall(BuildContext context, CallType type) {
    final callService = CallService();
    
    // Check if user is already in a call
    if (callService.isUserInCall(user.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} is already in a call'),
          backgroundColor: AppConfig.warningColor,
        ),
      );
      return;
    }

    // Initiate call through bloc
    context.read<CallBloc>().add(CallInitiated(
      receiverId: user.id,
      type: type,
    ));

    // Navigate to call screen
    Navigator.pushNamed(
      context,
      '/call',
      arguments: {
        'chat': _createChatFromUser(user),
        'isVideo': type == CallType.video,
        'isIncoming': false,
      },
    );
  }

  Chat _createChatFromUser(User user) {
    // Create a temporary chat object for navigation
    // In a real app, this would be fetched from the chat repository
    return Chat(
      id: 'temp_${user.id}',
      name: user.name,
      participants: [MockDataService.currentUser, user],
      lastMessage: null,
      unreadCount: 0,
      lastActivity: DateTime.now(),
      isGroup: false,
      isPinned: false,
      createdAt: DateTime.now(),
    );
  }
}

/// Call buttons for chat header
class ChatCallButtons extends StatelessWidget {
  final Chat chat;
  final bool showLabels;

  const ChatCallButtons({
    super.key,
    required this.chat,
    this.showLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser = chat.participants.firstWhere(
      (user) => user.id != MockDataService.currentUser.id,
    );

    return CallButtons(
      user: otherUser,
      showLabels: showLabels,
      buttonSize: 36,
    );
  }
}

/// Individual call button
class _CallButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final double size;
  final EdgeInsets? margin;
  final VoidCallback onPressed;

  const _CallButton({
    required this.icon,
    this.label,
    required this.color,
    required this.size,
    this.margin,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(icon, size: size * 0.5),
              color: Colors.white,
              onPressed: onPressed,
              padding: EdgeInsets.zero,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Floating call button for quick access
class FloatingCallButton extends StatelessWidget {
  final User user;
  final CallType type;
  final VoidCallback? onPressed;

  const FloatingCallButton({
    super.key,
    required this.user,
    required this.type,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () => _makeCall(context),
      backgroundColor: type == CallType.video ? AppConfig.accentColor : AppConfig.successColor,
      child: Icon(
        type == CallType.video ? Icons.videocam : Icons.call,
        color: Colors.white,
      ),
    );
  }

  void _makeCall(BuildContext context) {
    final callService = CallService();
    
    if (callService.isUserInCall(user.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} is already in a call'),
          backgroundColor: AppConfig.warningColor,
        ),
      );
      return;
    }

    context.read<CallBloc>().add(CallInitiated(
      receiverId: user.id,
      type: type,
    ));

    Navigator.pushNamed(
      context,
      '/call',
      arguments: {
        'chat': _createChatFromUser(user),
        'isVideo': type == CallType.video,
        'isIncoming': false,
      },
    );
  }

  Chat _createChatFromUser(User user) {
    return Chat(
      id: 'temp_${user.id}',
      name: user.name,
      participants: [MockDataService.currentUser, user],
      lastMessage: null,
      unreadCount: 0,
      lastActivity: DateTime.now(),
      isGroup: false,
      isPinned: false,
      createdAt: DateTime.now(),
    );
  }
}

/// Call status indicator widget
class CallStatusIndicator extends StatelessWidget {
  final String userId;
  final double size;

  const CallStatusIndicator({
    super.key,
    required this.userId,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallBloc, CallState>(
      builder: (context, state) {
        final callService = CallService();
        final callStatus = callService.getUserCallStatus(userId);
        
        if (callStatus == null) return const SizedBox.shrink();

        IconData icon;
        Color color;

        switch (callStatus) {
          case CallStatus.dialing:
            icon = Icons.call_made;
            color = AppConfig.warningColor;
            break;
          case CallStatus.incoming:
            icon = Icons.call_received;
            color = AppConfig.successColor;
            break;
          case CallStatus.connecting:
            icon = Icons.call_merge;
            color = AppConfig.primaryColor;
            break;
          case CallStatus.connected:
            icon = Icons.call;
            color = AppConfig.successColor;
            break;
          default:
            return const SizedBox.shrink();
        }

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: size * 0.6,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

/// Call history item widget
class CallHistoryItem extends StatelessWidget {
  final Call call;
  final User contact;
  final VoidCallback? onTap;
  final VoidCallback? onCallBack;
  final VoidCallback? onVideoCall;

  const CallHistoryItem({
    super.key,
    required this.call,
    required this.contact,
    this.onTap,
    this.onCallBack,
    this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: contact.profilePicture != null
            ? NetworkImage(contact.profilePicture!)
            : null,
        child: contact.profilePicture == null
            ? Text(contact.name.substring(0, 1).toUpperCase())
            : null,
      ),
      title: Text(contact.name),
      subtitle: _buildSubtitle(),
      trailing: _buildTrailingActions(),
      onTap: onTap,
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getCallStatusIcon(),
              size: 16,
              color: _getCallStatusColor(),
            ),
            const SizedBox(width: 4),
            Text(
              _getCallStatusText(),
              style: TextStyle(
                color: _getCallStatusColor(),
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (call.duration != null && call.duration! > Duration.zero)
          Text(
            _formatDuration(call.duration!),
            style: const TextStyle(fontSize: 12),
          ),
        Text(
          _formatTimestamp(call.startTime),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTrailingActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: onCallBack,
          color: AppConfig.successColor,
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: onVideoCall,
          color: AppConfig.accentColor,
        ),
      ],
    );
  }

  IconData _getCallStatusIcon() {
    switch (call.status) {
      case CallStatus.ended:
        return call.isIncoming ? Icons.call_received : Icons.call_made;
      case CallStatus.missed:
        return Icons.call_missed;
      case CallStatus.rejected:
        return Icons.call_end;
      default:
        return Icons.call;
    }
  }

  Color _getCallStatusColor() {
    switch (call.status) {
      case CallStatus.ended:
        return AppConfig.successColor;
      case CallStatus.missed:
      case CallStatus.rejected:
        return AppConfig.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getCallStatusText() {
    switch (call.status) {
      case CallStatus.ended:
        return call.isIncoming ? 'Incoming' : 'Outgoing';
      case CallStatus.missed:
        return 'Missed';
      case CallStatus.rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
