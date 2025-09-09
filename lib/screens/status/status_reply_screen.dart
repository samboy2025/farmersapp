import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/status.dart';

class StatusReplyScreen extends StatefulWidget {
  final Status status;
  final User author;

  const StatusReplyScreen({
    super.key,
    required this.status,
    required this.author,
  });

  @override
  State<StatusReplyScreen> createState() => _StatusReplyScreenState();
}

class _StatusReplyScreenState extends State<StatusReplyScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
          'Reply to ${widget.author.name}',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _messageController.text.trim().isNotEmpty ? _sendReply : null,
            child: Text(
              'Send',
              style: TextStyle(
                color: _messageController.text.trim().isNotEmpty
                    ? AppConfig.primaryColor
                    : (isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Preview
          _buildStatusPreview(isDark),

          // Reply Input
          _buildReplyInput(isDark),
        ],
      ),
    );
  }

  Widget _buildStatusPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Author Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppConfig.primaryColor,
            backgroundImage: widget.author.profilePicture != null
                ? NetworkImage(widget.author.profilePicture!)
                : null,
            child: widget.author.profilePicture == null
                ? Text(
                    widget.author.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Status Content Preview
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.author.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusPreview(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Status Type Icon
          Icon(
            _getStatusTypeIcon(),
            size: 16,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInput(bool isDark) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppConfig.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        child: Column(
          children: [
            // Text Input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Write a reply...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    fontSize: 16,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Emoji Button
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    ),
                    onPressed: () {
                      // Open emoji picker
                    },
                  ),

                  // Attachment Button
                  IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    ),
                    onPressed: () {
                      // Open attachment options
                    },
                  ),

                  const Spacer(),

                  // Character Count
                  Text(
                    '${_messageController.text.length}/1000',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Send Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _messageController.text.trim().isNotEmpty
                          ? AppConfig.primaryColor
                          : (isDark ? AppConfig.darkCard : Colors.grey.shade200),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isSending ? Icons.hourglass_empty : Icons.send,
                        color: _messageController.text.trim().isNotEmpty
                            ? Colors.white
                            : (isDark ? AppConfig.darkTextSecondary : Colors.grey.shade400),
                        size: 20,
                      ),
                      onPressed: _messageController.text.trim().isNotEmpty ? _sendReply : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusPreview() {
    if (widget.status.content != null && widget.status.content!.isNotEmpty) {
      return widget.status.content!;
    } else if (widget.status.mediaUrl != null) {
      return '📷 Photo status';
    } else {
      return 'Status update';
    }
  }

  IconData _getStatusTypeIcon() {
    if (widget.status.mediaUrl != null) {
      return Icons.photo;
    } else {
      return Icons.text_fields;
    }
  }

  void _sendReply() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isSending = true;
    });

    // Simulate sending reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reply sent successfully'),
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
    });
  }
}
