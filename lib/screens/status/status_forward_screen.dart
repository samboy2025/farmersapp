import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/status.dart';
import '../../services/mock_data_service.dart';

class StatusForwardScreen extends StatefulWidget {
  final Status status;
  final User author;

  const StatusForwardScreen({
    super.key,
    required this.status,
    required this.author,
  });

  @override
  State<StatusForwardScreen> createState() => _StatusForwardScreenState();
}

class _StatusForwardScreenState extends State<StatusForwardScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _contacts = [];
  List<User> _filteredContacts = [];
  List<User> _selectedContacts = [];
  bool _includeCaption = false;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _loadContacts() {
    // Load all contacts except the status author
    _contacts = MockDataService.users
        .where((user) => user.id != widget.author.id)
        .toList();
    _filteredContacts = List.from(_contacts);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_contacts);
      } else {
        _filteredContacts = _contacts
            .where((user) =>
                user.name.toLowerCase().contains(query) ||
                user.phoneNumber.contains(query))
            .toList();
      }
    });
  }

  void _toggleContactSelection(User user) {
    setState(() {
      if (_selectedContacts.contains(user)) {
        _selectedContacts.remove(user);
      } else {
        _selectedContacts.add(user);
      }
    });
  }

  void _forwardStatus() {
    if (_selectedContacts.isEmpty) return;

    // Simulate forwarding
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status forwarded to ${_selectedContacts.length} contact(s)'),
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
          'Forward Status',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedContacts.isNotEmpty)
            TextButton(
              onPressed: _forwardStatus,
              child: Text(
                'Send (${_selectedContacts.length})',
                style: TextStyle(
                  color: AppConfig.primaryColor,
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

          // Search Bar
          _buildSearchBar(isDark),

          // Options
          _buildOptions(isDark),

          // Contacts List
          Expanded(
            child: _buildContactsList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPreview(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        border: Border.all(
          color: AppConfig.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Status Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forwarding ${widget.author.name}\'s status',
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

          // Status Icon
          Icon(
            _getStatusTypeIcon(),
            color: AppConfig.primaryColor,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppConfig.darkCard : AppConfig.lightCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildOptions(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        children: [
          // Include Caption Option
          SwitchListTile(
            title: Text(
              'Include caption',
              style: TextStyle(
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Add your own message with the forwarded status',
              style: TextStyle(
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                fontSize: 12,
              ),
            ),
            value: _includeCaption,
            onChanged: (value) {
              setState(() {
                _includeCaption = value;
              });
            },
            activeColor: AppConfig.primaryColor,
          ),

          // Caption Input
          if (_includeCaption) ...[
            Divider(
              height: 1,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _captionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a caption...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final user = _filteredContacts[index];
        final isSelected = _selectedContacts.contains(user);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            border: Border.all(
              color: isSelected ? AppConfig.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppConfig.primaryColor,
                  backgroundImage: user.profilePicture != null
                      ? NetworkImage(user.profilePicture!)
                      : null,
                  child: user.profilePicture == null
                      ? Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                if (isSelected)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppConfig.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppConfig.darkSurface : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              user.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            subtitle: Text(
              user.phoneNumber,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
            onTap: () => _toggleContactSelection(user),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleContactSelection(user),
              activeColor: AppConfig.primaryColor,
            ),
          ),
        );
      },
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
}
