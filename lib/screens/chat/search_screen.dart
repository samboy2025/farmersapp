import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../config/app_config.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Chat> _filteredChats = [];
  List<Chat> _allChats = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterChats();
    });
  }

  void _filterChats() {
    if (_searchQuery.isEmpty) {
      _filteredChats = [];
    } else {
      _filteredChats = _allChats.where((chat) {
        // Search in chat name
        final nameMatch = chat.name.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Search in last message content
        final messageMatch = chat.lastMessage?.content
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ?? false;
        
        // Search in participant names (for group chats)
        final participantMatch = chat.participants.any((participant) =>
            participant.name.toLowerCase().contains(_searchQuery.toLowerCase()));
            
        return nameMatch || messageMatch || participantMatch;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatsLoadSuccess) {
                    _allChats = state.chats;
                    _filterChats();
                    return _buildSearchResults();
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppConfig.primaryColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isTablet ? 18 : 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_filteredChats.isEmpty) {
      return _buildNoResults();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: _filteredChats.asMap().entries.map((entry) {
        final index = entry.key;
        final chat = entry.value;
        return Column(
          children: [
            _SearchResultTile(
              chat: chat,
              searchQuery: _searchQuery,
            ),
            if (index < _filteredChats.length - 1)
              const Divider(
                height: 1,
                thickness: 0,
                indent: 74,
                color: Color(0xFFE8E8E8),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search suggestions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111B21),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSuggestionTile(
            icon: Icons.search,
            title: 'Search messages',
            subtitle: 'Find specific messages',
            onTap: () => _showFeatureComingSoon('Message search'),
          ),
          
          _buildSuggestionTile(
            icon: Icons.photo,
            title: 'Search photos',
            subtitle: 'Find shared photos',
            onTap: () => _showFeatureComingSoon('Photo search'),
          ),
          
          _buildSuggestionTile(
            icon: Icons.videocam,
            title: 'Search videos',
            subtitle: 'Find shared videos',
            onTap: () => _showFeatureComingSoon('Video search'),
          ),
          
          _buildSuggestionTile(
            icon: Icons.description,
            title: 'Search documents',
            subtitle: 'Find shared documents',
            onTap: () => _showFeatureComingSoon('Document search'),
          ),
          
          _buildSuggestionTile(
            icon: Icons.link,
            title: 'Search links',
            subtitle: 'Find shared links',
            onTap: () => _showFeatureComingSoon('Link search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
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
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF667781),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
}

class _SearchResultTile extends StatelessWidget {
  final Chat chat;
  final String searchQuery;

  const _SearchResultTile({
    required this.chat,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(
                    chat.name,
                    searchQuery,
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111B21),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (chat.lastMessage != null)
                    _buildHighlightedText(
                      _getLastMessagePreview(chat.lastMessage!),
                      searchQuery,
                      const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF667781),
                      ),
                      maxLines: 2,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (chat.isGroup) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppConfig.primaryColor,
        child: const Icon(
          Icons.group,
          color: Colors.white,
          size: 24,
        ),
      );
    } else {
      final participant = chat.participants.first;
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppConfig.primaryColor,
        child: Text(
          participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }

  Widget _buildHighlightedText(
    String text,
    String searchQuery,
    TextStyle style, {
    int maxLines = 1,
  }) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + searchQuery.length),
            style: style.copyWith(
              backgroundColor: AppConfig.primaryColor.withOpacity(0.3),
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: text.substring(index + searchQuery.length)),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _getLastMessagePreview(Message message) {
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
      case MessageType.voiceMessage:
        return '🎤 Voice message';
    }
  }
}
