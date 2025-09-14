import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../../../models/message.dart';
import '../../../services/mock_data_service.dart';
import '../media_viewer_screen.dart';
import 'reaction_picker.dart';
import 'voice_note_player.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isLastMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isLastMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.sender.id == MockDataService.currentUser.id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConfig.smallPadding),
                      child: Row(
          mainAxisAlignment: isCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCurrentUser) ...[
              _buildSenderAvatar(),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: GestureDetector(
                onLongPress: () => _showMessageOptions(context),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.55,
                  ),
                  padding: const EdgeInsets.all(AppConfig.smallPadding),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? AppConfig.sentMessageColor
                      : AppConfig.receivedMessageColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppConfig.messageBorderRadius),
                    topRight: const Radius.circular(AppConfig.messageBorderRadius),
                    bottomLeft: Radius.circular(
                      isCurrentUser ? AppConfig.messageBorderRadius : 4,
                    ),
                    bottomRight: Radius.circular(
                      isCurrentUser ? 4 : AppConfig.messageBorderRadius,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender name for group chats
                    if (!isCurrentUser && message.chatId.contains('group'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          message.sender.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppConfig.primaryColor,
                          ),
                        ),
                      ),
                    
                    // Message content
                    _buildMessageContent(context),
                    
                    // Reactions
                    if (message.reactions != null && message.reactions!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child:                         MessageReactions(
                          reactions: message.reactions,
                          currentUserId: MockDataService.currentUser.id,
                          onReactionTap: (emoji) {
                            // TODO: Handle reaction tap
                          },
                        ),
                      ),
                    
                    // Message status and time
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 4),
                          _buildMessageStatus(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            _buildSenderAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildSenderAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Image.asset(
          'assets/images/icons/userPlaceholder.png',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => CircleAvatar(
            radius: 16,
            backgroundColor: AppConfig.primaryColor,
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: const TextStyle(
            fontSize: 16,
            color: AppConfig.sentMessageTextColor,
          ),
        );
      case MessageType.image:
        return _buildImageMessage(context);
      case MessageType.video:
        return _buildVideoMessage(context);
      case MessageType.file:
        return _buildFileMessage();
      case MessageType.contact:
        return _buildContactMessage();
      case MessageType.location:
        return _buildLocationMessage();
      case MessageType.voice:
        return _buildVoiceMessage();
    }
  }

  Widget _buildImageMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.mediaUrl != null)
          GestureDetector(
            onTap: () => _openMediaViewer(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.mediaUrl!,
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
        if (message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 16,
                color: AppConfig.sentMessageTextColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.mediaUrl != null)
          GestureDetector(
            onTap: () => _openMediaViewer(context),
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    message.mediaUrl!,
                    width: 200,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.videocam_off,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 16,
                color: AppConfig.sentMessageTextColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFileMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.attach_file,
            color: AppConfig.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (message.fileSize != null)
                  Text(
                    _formatFileSize(message.fileSize!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person,
            color: AppConfig.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Contact',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              size: 40,
              color: AppConfig.primaryColor,
            ),
          ),
          if (message.content.isNotEmpty)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  message.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage() {
    final isCurrentUser = message.sender.id == MockDataService.currentUser.id;
    return VoiceNotePlayer(
      filePath: message.content,
      duration: message.voiceDuration ?? Duration.zero,
      isFromMe: isCurrentUser,
    );
  }

  Widget _buildMessageStatus() {
    switch (message.status) {
      case MessageStatus.sending:
        return const Icon(
          Icons.schedule,
          size: 16,
          color: Colors.grey,
        );
      case MessageStatus.sent:
        return const Icon(
          Icons.done,
          size: 16,
          color: Colors.grey,
        );
      case MessageStatus.delivered:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.grey,
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: AppConfig.primaryColor,
        );
      case MessageStatus.failed:
        return const Icon(
          Icons.error,
          size: 16,
          color: AppConfig.errorColor,
        );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.day}/${time.month}';
    } else if (difference.inHours > 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    } else {
      return 'now';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _openMediaViewer(BuildContext context) {
    // TODO: Get all media messages from the chat to show in viewer
    // For now, just show the current message
    final mediaMessages = [message];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaViewerScreen(
          message: message,
          mediaMessages: mediaMessages,
          initialIndex: 0,
        ),
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ReactionPicker(
        onReactionSelected: (emoji) {
          // TODO: Add reaction to message via Bloc
          print('Reaction selected: $emoji for message: ${message.id}');
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    final List<PopupMenuEntry<String>> options = [
      const PopupMenuItem(
        value: 'forward',
        child: Text('Forward'),
      ),
      const PopupMenuItem(
        value: 'react',
        child: Text('React'),
      ),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 100, // Adjust position to be outside the bubble
        MediaQuery.of(context).size.height - 100,
        MediaQuery.of(context).size.width - 100,
        MediaQuery.of(context).size.height - 100,
      ),
      items: options,
    ).then((value) {
      if (value == 'forward') {
        // TODO: Implement forward logic
        print('Forwarding message: ${message.id}');
      } else if (value == 'react') {
        _showReactionPicker(context);
      }
    });
  }
}
