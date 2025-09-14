import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../utils/animation_utils.dart';
import '../../models/message.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isLastMessage;

  const MessageBubble({
    super.key,
    required this.message,
    this.isLastMessage = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: AnimationDurations.normal,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: AnimationDurations.quick,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.message.isSentByCurrentUser
          ? const Offset(1.0, 0.0) // Slide from right for sent messages
          : const Offset(-1.0, 0.0), // Slide from left for received messages
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: AppAnimationCurves.bounceIn),
    );

    // Start animations with a slight delay for staggered effect
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 6 : 4,
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _slideController]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: widget.message.isSentByCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * (isTablet ? 0.6 : 0.75),
                    minWidth: 100,
                  ),
                  margin: EdgeInsets.only(
                    bottom: isTablet ? 8 : 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!widget.message.isSentByCurrentUser) ...[
                        _buildAvatar(isTablet),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: widget.message.isSentByCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!widget.message.isSentByCurrentUser)
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 2),
                                child: Text(
                                  widget.message.sender.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            _buildMessageContent(isTablet, isDark),
                            _buildMessageTime(isTablet, isDark),
                          ],
                        ),
                      ),
                      if (widget.message.isSentByCurrentUser) ...[
                        const SizedBox(width: 8),
                        _buildMessageStatus(isTablet, isDark),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(bool isTablet) {
    return CircleAvatar(
      radius: isTablet ? 16 : 14,
      backgroundColor: AppConfig.primaryColor.withOpacity(0.1),
      backgroundImage: widget.message.sender.profilePicture != null
          ? NetworkImage(widget.message.sender.profilePicture!)
          : null,
      child: widget.message.sender.profilePicture == null
          ? Text(
              widget.message.sender.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppConfig.primaryColor,
                fontSize: isTablet ? 12 : 10,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildMessageContent(bool isTablet, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: widget.message.isSentByCurrentUser
            ? AppConfig.primaryColor
            : (isDark ? AppConfig.darkSurface : Colors.white),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.message.isSentByCurrentUser ? 18 : 4),
          topRight: Radius.circular(widget.message.isSentByCurrentUser ? 4 : 18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: widget.message.isSentByCurrentUser
            ? null
            : Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                width: 0.5,
              ),
      ),
      child: _buildMessageBody(isTablet, isDark),
    );
  }

  Widget _buildMessageBody(bool isTablet, bool isDark) {
    switch (widget.message.type) {
      case MessageType.text:
        return Text(
          widget.message.content,
          style: TextStyle(
            color: widget.message.isSentByCurrentUser
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            fontSize: isTablet ? 16 : 14,
            height: 1.4,
          ),
        );

      case MessageType.voice:
        return _buildVoiceMessage(isTablet, isDark);

      case MessageType.image:
        return _buildImageMessage(isTablet, isDark);

      default:
        return Text(
          'Unsupported message type',
          style: TextStyle(
            color: widget.message.isSentByCurrentUser
                ? Colors.white70
                : (isDark ? Colors.white70 : Colors.black54),
            fontSize: isTablet ? 14 : 12,
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  Widget _buildVoiceMessage(bool isTablet, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.play_arrow,
          color: widget.message.isSentByCurrentUser
              ? Colors.white
              : AppConfig.primaryColor,
          size: isTablet ? 24 : 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated waveform
              Row(
                children: List.generate(
                  20,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 3,
                    height: (index % 3 + 1) * 6.0,
                    decoration: BoxDecoration(
                      color: widget.message.isSentByCurrentUser
                          ? Colors.white.withOpacity(0.7)
                          : AppConfig.primaryColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Voice message',
                style: TextStyle(
                  color: widget.message.isSentByCurrentUser
                      ? Colors.white70
                      : (isDark ? Colors.white70 : Colors.black54),
                  fontSize: isTablet ? 12 : 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '0:30',
          style: TextStyle(
            color: widget.message.isSentByCurrentUser
                ? Colors.white70
                : (isDark ? Colors.white70 : Colors.black54),
            fontSize: isTablet ? 12 : 10,
          ),
        ),
      ],
    );
  }

  Widget _buildImageMessage(bool isTablet, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isTablet ? 200 : 150,
          height: isTablet ? 150 : 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: AssetImage('assets/images/chat_back.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Icon(
            Icons.image,
            color: Colors.white70,
            size: 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.message.content.isNotEmpty
              ? widget.message.content
              : 'Photo',
          style: TextStyle(
            color: widget.message.isSentByCurrentUser
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            fontSize: isTablet ? 14 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageTime(bool isTablet, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.message.isSentByCurrentUser ? 0 : 4,
        right: widget.message.isSentByCurrentUser ? 4 : 0,
        top: 2,
      ),
      child: Text(
        _formatMessageTime(widget.message.timestamp),
        style: TextStyle(
          color: widget.message.isSentByCurrentUser
              ? Colors.white70
              : (isDark ? Colors.white60 : Colors.black54),
          fontSize: isTablet ? 11 : 9,
        ),
      ),
    );
  }

  Widget _buildMessageStatus(bool isTablet, bool isDark) {
    IconData icon;
    Color color;

    switch (widget.message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.white70;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.white70;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white70;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      default:
        icon = Icons.error;
        color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Icon(
        icon,
        size: isTablet ? 14 : 12,
        color: color,
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[timestamp.weekday - 1];
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}';
    }
  }
}
