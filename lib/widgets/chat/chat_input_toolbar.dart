import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../utils/animation_utils.dart';

class ChatInputToolbar extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final Function(String, String) onSendMediaMessage;

  const ChatInputToolbar({
    super.key,
    required this.messageController,
    required this.onSendMessage,
    required this.onSendMediaMessage,
  });

  @override
  State<ChatInputToolbar> createState() => _ChatInputToolbarState();
}

class _ChatInputToolbarState extends State<ChatInputToolbar>
    with TickerProviderStateMixin {
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    _sendButtonController = AnimationController(
      duration: AnimationDurations.quick,
      vsync: this,
    );

    _sendButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _sendButtonController, curve: AppAnimationCurves.bounceIn),
    );

    widget.messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    widget.messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });

      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  void _sendMessage() {
    if (_hasText) {
      widget.onSendMessage();
      // Add a small bounce animation when sending
      _sendButtonController.reset();
      _sendButtonController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            ScaleAnimation(
              beginScale: 0.8,
              endScale: 1.1,
              duration: AnimationDurations.micro,
              child: IconButton(
                onPressed: () {
                  // Show attachment options
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Attachment options coming soon!')),
                  );
                },
                icon: Icon(
                  Icons.attach_file,
                  color: AppConfig.primaryColor,
                  size: isTablet ? 24 : 20,
                ),
              ),
            ),

            // Text input field
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.messageController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                            fontSize: isTablet ? 16 : 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 12,
                            vertical: isTablet ? 12 : 8,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ),

                    // Emoji button
                    ScaleAnimation(
                      beginScale: 0.8,
                      endScale: 1.1,
                      duration: AnimationDurations.micro,
                      child: IconButton(
                        onPressed: () {
                          // Show emoji picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Emoji picker coming soon!')),
                          );
                        },
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: AppConfig.primaryColor,
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Send button with morph animation
            AnimatedBuilder(
              animation: _sendButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _hasText ? 1.0 : 0.8,
                  child: Opacity(
                    opacity: _sendButtonAnimation.value,
                    child: ScaleAnimation(
                      beginScale: 0.9,
                      endScale: 1.1,
                      duration: AnimationDurations.micro,
                      onTap: _sendMessage,
                      child: Container(
                        width: isTablet ? 48 : 40,
                        height: isTablet ? 48 : 40,
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppConfig.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _hasText ? Icons.send : Icons.mic,
                          color: Colors.white,
                          size: isTablet ? 20 : 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
