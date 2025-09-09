import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

class AddMembersScreen extends StatefulWidget {
  final Group group;

  const AddMembersScreen({
    super.key,
    required this.group,
  });

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _availableContacts = [];
  List<User> _selectedContacts = [];
  List<User> _filteredContacts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAvailableContacts() {
    // Get all contacts except those already in the group
    final allContacts = MockDataService.users;
    final existingMemberIds = widget.group.members.map((user) => user.id).toSet();

    _availableContacts = allContacts
        .where((user) => !existingMemberIds.contains(user.id))
        .toList();

    _filteredContacts = List.from(_availableContacts);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_availableContacts);
      } else {
        _filteredContacts = _availableContacts
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

  void _addSelectedMembers() {
    if (_selectedContacts.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedContacts.length} member(s) added to ${widget.group.name}'),
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
        title: Text(
          'Add Members',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedContacts.isNotEmpty)
            TextButton(
              onPressed: _addSelectedMembers,
              child: Text(
                'Add (${_selectedContacts.length})',
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
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppConfig.darkSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
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
          ),

          // Content
          Expanded(
            child: _availableContacts.isEmpty
                ? _buildEmptyState(isDark)
                : _buildContactsList(isDark),
          ),

          // Bottom Action Bar
          if (_selectedContacts.isNotEmpty)
            _buildBottomActionBar(isDark),
        ],
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
                Icons.person_add,
                size: 48,
                color: AppConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No contacts available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All your contacts are already members of this group',
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

  Widget _buildBottomActionBar(bool isDark) {
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${_selectedContacts.length} contact(s) selected',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _addSelectedMembers,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Add Members'),
            ),
          ],
        ),
      ),
    );
  }
}
