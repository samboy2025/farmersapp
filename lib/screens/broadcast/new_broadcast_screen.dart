import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

class NewBroadcastScreen extends StatefulWidget {
  const NewBroadcastScreen({super.key});

  @override
  State<NewBroadcastScreen> createState() => _NewBroadcastScreenState();
}

class _NewBroadcastScreenState extends State<NewBroadcastScreen>
    with TickerProviderStateMixin {
  final List<User> _selectedContacts = [];
  final List<User> _allContacts = MockDataService.users;
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredContacts = [];
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _filteredContacts = List.from(_allContacts);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_allContacts);
      } else {
        _filteredContacts = _allContacts
            .where((contact) =>
                contact.name.toLowerCase().contains(query.toLowerCase()) ||
                contact.phoneNumber.contains(query))
            .toList();
      }
    });
  }

  void _toggleContactSelection(User contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  void _createBroadcast() {
    if (_selectedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one contact'),
          backgroundColor: AppConfig.errorColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // Navigate back with success message
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Broadcast list created with ${_selectedContacts.length} contacts'),
        backgroundColor: AppConfig.successColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppConfig.lightBackground,
      appBar: _buildAppBar(context, isTablet),
      body: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _slideAnimation,
          child: Column(
            children: [
              // Selected contacts header
              if (_selectedContacts.isNotEmpty) _buildSelectedHeader(isTablet),
              
              // Search bar
              _buildSearchBar(isTablet),
              
              // Info banner
              _buildInfoBanner(isTablet),
              
              // Contacts list
              Expanded(
                child: _buildContactsList(isTablet),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedContacts.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _createBroadcast,
              backgroundColor: AppConfig.primaryColor,
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                'Create (${_selectedContacts.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 4,
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    return AppBar(
      backgroundColor: AppConfig.primaryColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        splashRadius: 20,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New broadcast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_selectedContacts.isNotEmpty)
            Text(
              '${_selectedContacts.length} of ${_allContacts.length} selected',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      actions: [
        if (_isSearching)
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _filterContacts('');
              });
            },
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Close search',
            splashRadius: 20,
          )
        else
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Search contacts',
            splashRadius: 20,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSelectedHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppConfig.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.campaign,
            color: AppConfig.primaryColor,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Broadcast to ${_selectedContacts.length} contacts',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                Text(
                  'Only contacts with your number saved will receive broadcasts',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: AppConfig.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedContacts.clear();
              });
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: AppConfig.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isTablet) {
    if (!_isSearching) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
        autofocus: true,
        onChanged: _filterContacts,
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: Icon(
            Icons.search,
            color: AppConfig.lightTextSecondary,
            size: isTablet ? 24 : 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterContacts('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: AppConfig.lightTextSecondary,
                    size: isTablet ? 20 : 18,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            borderSide: BorderSide(color: AppConfig.primaryColor),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 14 : 12,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: AppConfig.lightText,
        ),
      ),
    );
  }

  Widget _buildInfoBanner(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: isTablet ? 20 : 18,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              'Only contacts who have your number saved will receive your broadcast messages.',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(bool isTablet) {
    if (_filteredContacts.isEmpty) {
      return _buildEmptyState(isTablet);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 8,
      ),
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final isSelected = _selectedContacts.contains(contact);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: isTablet ? 8 : 4),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppConfig.primaryColor.withOpacity(0.1) 
                : Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            border: isSelected
                ? Border.all(color: AppConfig.primaryColor.withOpacity(0.3))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: isTablet ? 8 : 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 8 : 4,
            ),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: isTablet ? 24 : 20,
                  backgroundColor: contact.profilePicture != null
                      ? Colors.transparent
                      : AppConfig.primaryColor.withOpacity(0.1),
                  backgroundImage: contact.profilePicture != null
                      ? NetworkImage(contact.profilePicture!)
                      : null,
                  child: contact.profilePicture == null
                      ? Text(
                          contact.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            color: AppConfig.primaryColor,
                          ),
                        )
                      : null,
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppConfig.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: isTablet ? 14 : 12,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              contact.name,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppConfig.primaryColor : AppConfig.lightText,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.phoneNumber,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: isSelected 
                        ? AppConfig.primaryColor.withOpacity(0.8)
                        : AppConfig.lightTextSecondary,
                  ),
                ),
                if (contact.about?.isNotEmpty == true)
                  Text(
                    contact.about!,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: isSelected 
                          ? AppConfig.primaryColor.withOpacity(0.6)
                          : AppConfig.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isTablet ? 28 : 24,
              height: isTablet ? 28 : 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? AppConfig.primaryColor 
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? AppConfig.primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: isTablet ? 16 : 14,
                    )
                  : null,
            ),
            onTap: () => _toggleContactSelection(contact),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: isTablet ? 80 : 64,
            color: AppConfig.lightTextSecondary,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'No contacts found',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: AppConfig.lightText,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Try adjusting your search terms',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: AppConfig.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
