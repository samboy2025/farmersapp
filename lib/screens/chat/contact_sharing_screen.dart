import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

class ContactSharingScreen extends StatefulWidget {
  final Function(String, String) onContactSelected;

  const ContactSharingScreen({
    super.key,
    required this.onContactSelected,
  });

  @override
  State<ContactSharingScreen> createState() => _ContactSharingScreenState();
}

class _ContactSharingScreenState extends State<ContactSharingScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _contacts = [];
  List<User> _filteredContacts = [];
  List<User> _selectedContacts = [];
  bool _selectMultiple = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadContacts() {
    // Load all contacts except current user
    _contacts = MockDataService.users
        .where((user) => user.id != MockDataService.currentUser.id)
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
      if (_selectMultiple) {
        if (_selectedContacts.contains(user)) {
          _selectedContacts.remove(user);
        } else {
          _selectedContacts.add(user);
        }
      } else {
        _selectedContacts = [user];
        _shareContacts();
      }
    });
  }

  void _shareContacts() {
    if (_selectedContacts.isEmpty) return;

    if (_selectedContacts.length == 1) {
      final contact = _selectedContacts.first;
      widget.onContactSelected(
        '👤 ${contact.name}',
        'Phone: ${contact.phoneNumber}',
      );
    } else {
      widget.onContactSelected(
        '👥 ${_selectedContacts.length} contacts',
        'Shared multiple contacts',
      );
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact${_selectedContacts.length > 1 ? 's' : ''} shared successfully'),
        backgroundColor: AppConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
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
          'Share Contact',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedContacts.isNotEmpty && _selectMultiple)
            TextButton(
              onPressed: _shareContacts,
              child: Text(
                'Share (${_selectedContacts.length})',
                style: TextStyle(
                  color: AppConfig.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              _selectMultiple ? Icons.check_box : Icons.check_box_outline_blank,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
            onPressed: () {
              setState(() {
                _selectMultiple = !_selectMultiple;
                if (!_selectMultiple) {
                  _selectedContacts.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(isDark),

          // Contacts List
          Expanded(
            child: _filteredContacts.isEmpty
                ? _buildEmptyState(isDark)
                : _buildContactsList(isDark),
          ),

          // Share Button (for multiple selection)
          if (_selectedContacts.isNotEmpty && _selectMultiple)
            _buildShareButton(isDark),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search,
                size: 48,
                color: AppConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No contacts found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different name or number',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            trailing: _selectMultiple
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleContactSelection(user),
                    activeColor: AppConfig.primaryColor,
                  )
                : IconButton(
                    icon: Icon(
                      Icons.share,
                      color: AppConfig.primaryColor,
                    ),
                    onPressed: () => _toggleContactSelection(user),
                  ),
            onTap: () => _toggleContactSelection(user),
          ),
        );
      },
    );
  }

  Widget _buildShareButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _shareContacts,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            'Share ${_selectedContacts.length} Contact${_selectedContacts.length > 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
