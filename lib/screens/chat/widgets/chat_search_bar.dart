import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/chat/message_bloc.dart';
import '../../../config/app_config.dart';

class ChatSearchBar extends StatefulWidget {
  final String chatId;
  final VoidCallback? onClose;

  const ChatSearchBar({
    super.key,
    required this.chatId,
    this.onClose,
  });

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      setState(() => _isSearching = true);
      context.read<MessageBloc>().add(
        MessageSearchStarted(
          chatId: widget.chatId,
          query: _searchController.text.trim(),
        ),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _isSearching = false);
    context.read<MessageBloc>().add(const MessageSearchCleared());
  }

  void _searchNext() {
    context.read<MessageBloc>().add(const MessageSearchNext());
  }

  void _searchPrevious() {
    context.read<MessageBloc>().add(const MessageSearchPrevious());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: 56,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppConfig.lightBackground,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onClose,
            color: AppConfig.primaryColor,
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search in chat...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              onSubmitted: (_) => _startSearch(),
              onChanged: (value) {
                if (value.isEmpty && _isSearching) {
                  _clearSearch();
                }
              },
            ),
          ),
          if (_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up),
              onPressed: _searchPrevious,
              color: AppConfig.primaryColor,
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: _searchNext,
              color: AppConfig.primaryColor,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
            color: AppConfig.primaryColor,
          ),
        ],
      ),
    );
  }
}

class SearchResultsCounter extends StatelessWidget {
  const SearchResultsCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        if (state is MessageSearchSuccess) {
          return Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              minHeight: 40,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppConfig.primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '${state.currentResultIndex + 1} of ${state.searchResults.length} results for "${state.query}"',
                    style: TextStyle(
                      color: AppConfig.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<MessageBloc>().add(const MessageSearchCleared());
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          );
        } else if (state is MessageSearchNoResults) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No results found for "${state.query}"',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<MessageBloc>().add(const MessageSearchCleared());
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
