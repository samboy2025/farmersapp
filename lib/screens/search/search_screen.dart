import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../models/group.dart';
import '../../services/mock_data_service.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? searchType; // 'all', 'chats', 'contacts', 'messages', 'groups'

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.searchType = 'all',
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';
  String _selectedFilter = 'all'; // all, chats, contacts, messages, groups
  bool _isSearching = false;

  List<Map<String, dynamic>> _searchResults = [];
  List<String> _recentSearches = [
    'John',
    'Meeting notes',
    'Project team',
    'Photos',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _currentQuery = widget.initialQuery!;
      _selectedFilter = widget.searchType ?? 'all';
      _performSearch(_currentQuery);
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _currentQuery) {
      setState(() {
        _currentQuery = query;
      });

      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
        });
      }
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final results = <Map<String, dynamic>>[];

        // Search chats
        if (_selectedFilter == 'all' || _selectedFilter == 'chats') {
          final chatResults = MockDataService.chats.where((chat) =>
            chat.name.toLowerCase().contains(query.toLowerCase()) ||
            chat.lastMessage?.content.toLowerCase().contains(query.toLowerCase()) == true
          ).map((chat) => {
            'type': 'chat',
            'item': chat,
            'title': chat.name,
            'subtitle': chat.lastMessage?.content ?? 'No messages yet',
          }).toList();
          results.addAll(chatResults);
        }

        // Search contacts
        if (_selectedFilter == 'all' || _selectedFilter == 'contacts') {
          final contactResults = MockDataService.users.where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.phoneNumber.contains(query)
          ).map((user) => {
            'type': 'contact',
            'item': user,
            'title': user.name,
            'subtitle': user.phoneNumber,
          }).toList();
          results.addAll(contactResults);
        }

        // Search messages
        if (_selectedFilter == 'all' || _selectedFilter == 'messages') {
          final messageResults = MockDataService.messages.where((message) =>
            message.content.toLowerCase().contains(query.toLowerCase())
          ).map((message) => {
            'type': 'message',
            'item': message,
            'title': message.content,
            'subtitle': 'From ${message.sender.name}',
          }).toList();
          results.addAll(messageResults);
        }

        // Search groups
        if (_selectedFilter == 'all' || _selectedFilter == 'groups') {
          final groupResults = MockDataService.groups.where((group) =>
            group.name.toLowerCase().contains(query.toLowerCase()) ||
            (group.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
          ).map((group) => {
            'type': 'group',
            'item': group,
            'title': group.name,
            'subtitle': '${group.members.length} members',
          }).toList();
          results.addAll(groupResults);
        }

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });

        // Add to recent searches if not already there
        if (!_recentSearches.contains(query)) {
          setState(() {
            _recentSearches.insert(0, query);
            if (_recentSearches.length > 10) {
              _recentSearches = _recentSearches.sublist(0, 10);
            }
          });
        }
      }
    });
  }

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    if (_currentQuery.isNotEmpty) {
      _performSearch(_currentQuery);
    }
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
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
            Icons.arrow_back,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkCard : AppConfig.lightCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: _currentQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
            style: TextStyle(
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
              fontSize: 16,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(isDark),

          // Content
          Expanded(
            child: _currentQuery.isEmpty
                ? _buildRecentSearches(isDark)
                : _buildSearchResults(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'chats', 'label': 'Chats'},
      {'key': 'contacts', 'label': 'Contacts'},
      {'key': 'messages', 'label': 'Messages'},
      {'key': 'groups', 'label': 'Groups'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter['key'] == _selectedFilter;
          return Expanded(
            child: InkWell(
              onTap: () => _selectFilter(filter['key']!),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppConfig.primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  filter['label']!,
                  style: TextStyle(
                    color: isSelected
                        ? AppConfig.primaryColor
                        : (isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentSearches(bool isDark) {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Start typing to search',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: AppConfig.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppConfig.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                ),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(
                    search,
                    style: TextStyle(
                      color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _removeRecentSearch(search),
                  ),
                  onTap: () {
                    _searchController.text = search;
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(bool isDark) {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppConfig.primaryColor,
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Group results by type
    final groupedResults = <String, List<Map<String, dynamic>>>{};
    for (final result in _searchResults) {
      final type = result['type'] as String;
      if (!groupedResults.containsKey(type)) {
        groupedResults[type] = [];
      }
      groupedResults[type]!.add(result);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedResults.entries.map((entry) {
        final type = entry.key;
        final results = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_capitalizeFirst(type)} (${results.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
            ),
            ...results.map((result) => _buildResultItem(result, isDark)),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildResultItem(Map<String, dynamic> result, bool isDark) {
    final type = result['type'] as String;
    final item = result['item'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: ListTile(
        leading: _getResultIcon(type),
        title: Text(
          result['title'],
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          result['subtitle'],
          style: TextStyle(
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
            fontSize: 14,
          ),
        ),
        onTap: () => _onResultTap(type, item),
      ),
    );
  }

  Widget _getResultIcon(String type) {
    switch (type) {
      case 'chat':
        return const Icon(Icons.chat, color: Colors.blue);
      case 'contact':
        return const Icon(Icons.person, color: Colors.green);
      case 'message':
        return const Icon(Icons.message, color: Colors.orange);
      case 'group':
        return const Icon(Icons.group, color: Colors.purple);
      default:
        return const Icon(Icons.search, color: Colors.grey);
    }
  }

  void _onResultTap(String type, dynamic item) {
    // Just visual feedback - no action for now
    // Users can see search suggestions but clicking doesn't do anything
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
