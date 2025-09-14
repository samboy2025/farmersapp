import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/group.dart';
import '../../models/message.dart';
import '../../services/mock_data_service.dart';
import 'widgets/chat_input_toolbar.dart';
import 'widgets/message_bubble.dart';
import 'location_sharing_screen.dart';
import 'contact_sharing_screen.dart';
import 'voice_message_recorder.dart';
import 'media_gallery_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final Group group;

  const GroupChatScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading messages
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages = MockDataService.getMessages(widget.group.id);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final currentUser = MockDataService.currentUser;
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.group.id,
      sender: currentUser,
      type: MessageType.text,
      content: messageText,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    // Update group's last activity
    widget.group.copyWith(
      lastMessage: newMessage,
      lastActivity: DateTime.now(),
    );
  }

  void _sendMediaMessage(MessageType type, String content, String fileName) {
    final currentUser = MockDataService.currentUser;
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.group.id,
      sender: currentUser,
      type: type,
      content: content,
      mediaUrl: content,
      fileName: fileName,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _scrollToBottom();

    // Update group's last activity
    widget.group.copyWith(
      lastMessage: newMessage,
      lastActivity: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Group avatar
            GestureDetector(
              onTap: () => _navigateToGroupInfo(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: widget.group.groupPicture != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.group.groupPicture!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.groups,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Group info
            Expanded(
              child: GestureDetector(
                onTap: () => _navigateToGroupInfo(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.group.members.length} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () => _startVideoCall(),
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startVoiceCall(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/chat_back.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                                                       final isCurrentUser = message.sender.id == MockDataService.currentUser.id;

                             return MessageBubble(
                               message: message,
                               isLastMessage: index == _messages.length - 1,
                             );
                          },
                        ),
            ),
          ),
          
          // Input toolbar
          ChatInputToolbar(
            messageController: _messageController,
            onSendMessage: _sendMessage,
            onSendMediaMessage: _sendMediaMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation by sending a message!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToGroupInfo() {
    Navigator.pushNamed(
      context,
      '/group-info',
      arguments: widget.group,
    );
  }

  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video call feature coming soon!')),
    );
  }

  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice call feature coming soon!')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Group Info'),
              onTap: () {
                Navigator.pop(context);
                _navigateToGroupInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Messages'),
              onTap: () {
                Navigator.pop(context);
                _searchMessages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.media_bluetooth_on),
              title: const Text('Media, Links, and Docs'),
              onTap: () {
                Navigator.pop(context);
                _showMedia();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                _toggleMute();
              },
            ),
            ListTile(
              leading: const Icon(Icons.wallpaper),
              title: const Text('Change Wallpaper'),
              onTap: () {
                Navigator.pop(context);
                _changeWallpaper();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                _reportGroup();
              },
            ),
          ],
        ),
      ),
    );
  }


  void _searchMessages() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search functionality coming soon!')),
    );
  }

  void _showMedia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaGalleryScreen(
          mediaMessages: _messages.where((msg) =>
            msg.type == MessageType.image ||
            msg.type == MessageType.video ||
            msg.type == MessageType.file
          ).toList(),
        ),
      ),
    );
  }

  void _toggleMute() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mute functionality coming soon!')),
    );
  }

  void _changeWallpaper() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallpaper change coming soon!')),
    );
  }

  void _reportGroup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report functionality coming soon!')),
    );
  }

  void _sendLocation(String title, String content) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.group.id,
      sender: MockDataService.currentUser,
      type: MessageType.location,
      content: content,
      timestamp: DateTime.now(),
      fileName: title,
    );

    setState(() {
      _messages.add(message);
    });

    _scrollToBottom();
  }

  void _sendContact(String title, String content) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.group.id,
      sender: MockDataService.currentUser,
      type: MessageType.contact,
      content: content,
      timestamp: DateTime.now(),
      fileName: title,
    );

    setState(() {
      _messages.add(message);
    });

    _scrollToBottom();
  }

  void _sendVoiceMessage(String title, String content) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.group.id,
      sender: MockDataService.currentUser,
      type: MessageType.voice,
      content: content,
      timestamp: DateTime.now(),
      fileName: title,
    );

    setState(() {
      _messages.add(message);
    });

    _scrollToBottom();
  }
}
