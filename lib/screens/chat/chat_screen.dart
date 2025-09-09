import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/message_bloc.dart';
import '../../config/app_config.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/mock_data_service.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/chat_input_toolbar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_search_bar.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;
  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(MessagesFetched(chatId: widget.chat.id));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
    });
    if (!_isSearchMode) {
      context.read<MessageBloc>().add(const MessageSearchCleared());
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      sender: MockDataService.currentUser,
      type: MessageType.text,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    context.read<MessageBloc>().add(MessageSent(message));
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToSearchResult(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final itemHeight = 80.0; // Approximate height of a message item
        final targetPosition = index * itemHeight;
        _scrollController.animateTo(
          targetPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      appBar: ChatAppBar(
        chat: widget.chat,
        onVoiceCall: () => _showCallOptions(context, isVideo: false),
        onVideoCall: () => _showCallOptions(context, isVideo: true),
        onAvatarTap: () => _showChatOptions(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
          if (_isSearchMode) ...[
            ChatSearchBar(
              chatId: widget.chat.id,
              onClose: _toggleSearchMode,
            ),
            const SearchResultsCounter(),
          ],
          Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/chat_back.png'),
                    fit: BoxFit.cover,
                  ),
                  color: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
                ),
            child: BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) {
                if (state is MessagesLoadSuccess) {
                      return _buildMessagesList(state.messages, isTablet);
                } else if (state is MessagesLoadInProgress) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppConfig.primaryColor,
                        ),
                      );
                } else if (state is MessageSearchSuccess) {
                      return _buildSearchResults(state, isTablet);
                } else if (state is MessageSearchNoResults) {
                      return _buildNoSearchResults(state, isTablet);
                } else if (state is MessageSearchInProgress) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppConfig.primaryColor,
                        ),
                      );
                } else {
                      return _buildEmptyState(isTablet);
                }
              },
            ),
          ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppConfig.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
            child: ChatInputToolbar(
              messageController: _messageController,
              onSendMessage: _sendMessage,
              onSendMediaMessage: _sendMediaMessage,
                ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(List<Message> messages, bool isTablet) {
    if (messages.isEmpty) {
      return _buildEmptyState(isTablet);
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        
        return MessageBubble(
          message: message,
          isLastMessage: index == messages.length - 1,
        );
      },
    );
  }

  Widget _buildSearchResults(MessageSearchSuccess state, bool isTablet) {
    // Auto-scroll to highlighted result
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSearchResult(state.currentResultIndex);
    });

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final message = state.searchResults[index];
        final isHighlighted = index == state.currentResultIndex;
        
        return Container(
          margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
          decoration: isHighlighted
              ? BoxDecoration(
                  border: Border.all(
                    color: AppConfig.primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: MessageBubble(
            message: message,
            isLastMessage: index == state.searchResults.length - 1,
          ),
        );
      },
    );
  }

  Widget _buildNoSearchResults(MessageSearchNoResults state, bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
              size: isTablet ? 80 : 64,
            color: Colors.grey.shade400,
          ),
            SizedBox(height: isTablet ? 24 : 16),
          Text(
            'No results found for "${state.query}"',
            style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Try different keywords or check spelling',
            style: TextStyle(
                fontSize: isTablet ? 16 : 14,
              color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: isTablet ? 80 : 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Send a message to start the conversation',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCallOptions(BuildContext context, {bool isVideo = false}) {
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
                  color: AppConfig.primaryColor.withOpacity(0.1),
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
                'Call ${widget.chat.name}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667781),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/call', arguments: {
                  'chat': widget.chat,
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

  void _showChatOptions(BuildContext context) {
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
            
            _buildOptionTile(
              icon: Icons.contact_page,
              title: 'View Contact',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile', arguments: widget.chat.participants.first);
              },
            ),
            _buildOptionTile(
              icon: Icons.search,
              title: 'Search in Chat',
              onTap: () {
                Navigator.pop(context);
                _toggleSearchMode();
              },
            ),
            _buildOptionTile(
              icon: Icons.notifications_off,
              title: 'Mute Notifications',
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon('Mute notifications');
              },
            ),
            _buildOptionTile(
              icon: Icons.wallpaper,
              title: 'Chat Wallpaper',
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon('Chat wallpaper');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppConfig.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111B21),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  void _showFeatureComingSoon(String feature) {
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

  void _sendMediaMessage(MessageType type, String content, String fileName) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      sender: MockDataService.currentUser,
      type: type,
      content: content,
      mediaUrl: content,
      fileName: fileName,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    context.read<MessageBloc>().add(MessageSent(message));
    _scrollToBottom();
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111B21),
            ),
          ),
        ],
      ),
    );
  }
}
