import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/app_config.dart';
import '../../../models/message.dart';
import '../../../services/media_picker_service.dart';
import 'attachment_modal_bottom_sheet.dart';
import 'voice_note_recorder.dart';
import 'emoji_picker.dart';

class ChatInputToolbar extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final Function(MessageType, String, String) onSendMediaMessage;

  const ChatInputToolbar({
    super.key,
    required this.messageController,
    required this.onSendMessage,
    required this.onSendMediaMessage,
  });

  @override
  State<ChatInputToolbar> createState() => _ChatInputToolbarState();
}

class _ChatInputToolbarState extends State<ChatInputToolbar> {
  bool _isRecording = false;
  bool _isEmojiVisible = false;
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    widget.messageController.removeListener(_onTextChanged);
    super.dispose();
  }
  
  void _onTextChanged() {
    setState(() {
      _hasText = widget.messageController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxWidth: screenSize.width,
        minHeight: isTablet ? 70 : 60,
      ),
      padding: EdgeInsets.all(isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji Button
          IconButton(
            icon: Icon(
              _isEmojiVisible ? Icons.keyboard : Icons.emoji_emotions_outlined,
              color: _isEmojiVisible ? AppConfig.primaryColor : (isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781)),
            ),
            onPressed: () {
              if (_isEmojiVisible) {
                // Hide emoji picker
              setState(() {
                  _isEmojiVisible = false;
              });
              } else {
                // Show emoji picker
                _showEmojiPicker(context);
              }
            },
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            splashRadius: 20,
          ),
          
          // Attachment Button
          IconButton(
            icon: const Icon(Icons.attach_file),
            color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
            onPressed: () {
              _showAttachmentOptions();
            },
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            splashRadius: 20,
          ),
          
          // Message Input Field
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFFE5E5E5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.messageController,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: const Color(0xFF111B21),
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(
                          color: const Color(0xFF667781),
                          fontSize: isTablet ? 16 : 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 16 : 12,
                        ),
                      ),
                      maxLines: null,
                      minLines: 1,
                      maxLength: 4096,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => widget.onSendMessage(),
                    ),
                  ),
                  
                  // Camera Button (if message is empty)
                  if (!_hasText)
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      color: const Color(0xFF667781),
                      onPressed: () {
                        _showCameraOptions();
                      },
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      splashRadius: 18,
                    ),
                  
                  // Voice Message Button (if message is empty)
                  if (!_hasText)
                    GestureDetector(
                      onLongPressStart: (_) {
                        setState(() {
                          _isRecording = true;
                        });
                        _showVoiceNoteRecorder();
                      },
                      onLongPressEnd: (_) {
                        setState(() {
                          _isRecording = false;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isRecording ? AppConfig.errorColor : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: _isRecording ? Colors.white : const Color(0xFF667781),
                          size: isTablet ? 26 : 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Send Button (only show when there's text)
          if (_hasText)
            Container(
              margin: EdgeInsets.only(left: isTablet ? 8 : 4),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.white,
                onPressed: widget.onSendMessage,
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                splashRadius: 20,
              ),
            ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttachmentModalBottomSheet(
        onAttachmentSelected: widget.onSendMediaMessage,
      ),
    );
  }

  void _showCameraOptions() {
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
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCameraOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _selectImage(ImageSource.camera);
                  },
                ),
                _buildCameraOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _selectImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppConfig.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111B21),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final mediaPicker = MediaPickerService();
      final mediaSource = source == ImageSource.camera
          ? MediaSource.camera
          : MediaSource.gallery;

      final pickedFile = await mediaPicker.pickImage(mediaSource);

      if (pickedFile != null) {
        // Send the image as a message
        widget.onSendMediaMessage(
      MessageType.image,
          pickedFile.path,
          pickedFile.path.split('/').last,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
            content: const Text('Image sent successfully'),
            backgroundColor: AppConfig.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select image: $e'),
          backgroundColor: AppConfig.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
    }
  }



  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiPicker(
        onEmojiSelected: (emoji) {
          // Insert emoji at cursor position or at the end
          final text = widget.messageController.text;
          final selection = widget.messageController.selection;
          final newText = text.replaceRange(selection.start, selection.end, emoji);
          widget.messageController.text = newText;
          widget.messageController.selection = TextSelection.collapsed(
            offset: selection.start + emoji.length,
          );
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showVoiceNoteRecorder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => VoiceNoteRecorder(
        onRecordingComplete: (filePath, duration) {
          // Send voice message
          widget.onSendMediaMessage(
            MessageType.voice,
            filePath,
            'voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Voice message sent successfully'),
              backgroundColor: AppConfig.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        onRecordingCancelled: () {
          // Recording was cancelled, no action needed
        },
      ),
    );
  }
}


