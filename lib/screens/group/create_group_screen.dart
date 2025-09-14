import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../utils/animation_utils.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import 'group_details_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<User> _selectedParticipants = [];
  List<User> _allContacts = [];
  List<User> _filteredContacts = [];
  String _searchQuery = '';
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadContacts() {
    // Load contacts (in WhatsApp, this would be actual contacts)
    _allContacts = MockDataService.users
        .where((user) => user.id != MockDataService.currentUser.id)
        .toList();
    _filteredContacts = List.from(_allContacts);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterContacts();
    });
  }

  void _filterContacts() {
    if (_searchQuery.isEmpty) {
      _filteredContacts = List.from(_allContacts);
    } else {
      _filteredContacts = _allContacts
          .where((contact) =>
              contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              contact.phoneNumber.contains(_searchQuery))
          .toList();
    }
  }

  void _toggleParticipant(User user) {
    setState(() {
      if (_selectedParticipants.contains(user)) {
        _selectedParticipants.remove(user);
      } else {
        _selectedParticipants.add(user);
      }
    });
  }

  void _removeParticipant(User user) {
    setState(() {
      _selectedParticipants.remove(user);
    });
  }

  void _navigateToGroupDetails() {
    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one participant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsScreen(
          selectedParticipants: _selectedParticipants,
          onGroupCreated: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppConfig.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New group',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Add participants',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filterContacts();
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar (sticky)
            if (_isSearching)
              SlideInAnimation(
                beginOffset: const Offset(0, -0.5), // Slide down from top
                duration: AnimationDurations.quick,
                curve: AppAnimationCurves.slideIn,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ScaleAnimation(
                    beginScale: 0.95,
                    endScale: 1.0,
                    duration: AnimationDurations.quick,
                    curve: AppAnimationCurves.microBounce,
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search contacts...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterContacts();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: AppConfig.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),

            // Selected participants row
            if (_selectedParticipants.isNotEmpty)
              Container(
                height: 90, // Adjusted height to fit content better
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedParticipants.length,
                      itemBuilder: (context, index) {
                        final user = _selectedParticipants[index];
                        return SlideInAnimation(
                          beginOffset: const Offset(1, 0), // Slide from right
                          duration: AnimationDurations.quick,
                          curve: AppAnimationCurves.slideIn,
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
                                      backgroundImage: user.profilePicture != null
                                          ? NetworkImage(user.profilePicture!)
                                          : null,
                                      child: user.profilePicture == null
                                          ? Text(
                                              user.name.substring(0, 1).toUpperCase(),
                                              style: const TextStyle(
                                                color: AppConfig.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      top: -1,
                                      right: -1,
                                      child: GestureDetector(
                                        onTap: () => _removeParticipant(user),
                                        child: ScaleAnimation(
                                          beginScale: 0.8,
                                          endScale: 1.2,
                                          duration: AnimationDurations.micro,
                                          child: Container(
                                            padding: const EdgeInsets.all(1.5),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Flexible(
                                  child: Text(
                                    user.name.split(' ').first,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Contacts list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 80), // Add bottom padding for FAB
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  final isSelected = _selectedParticipants.contains(contact);

                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: contact.profilePicture != null
                              ? NetworkImage(contact.profilePicture!)
                              : null,
                          child: contact.profilePicture == null
                              ? Text(
                                  contact.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: AppConfig.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
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
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                size: 18,
                                color: AppConfig.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      contact.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  trailing: AnimatedContainer(
                    duration: AnimationDurations.micro,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppConfig.primaryColor : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isSelected ? AppConfig.primaryColor : Colors.transparent,
                    ),
                    child: isSelected
                        ? ScaleAnimation(
                            beginScale: 0.5,
                            endScale: 1.0,
                            duration: AnimationDurations.micro,
                            curve: AppAnimationCurves.bounceIn,
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                    onTap: () => _toggleParticipant(contact),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedParticipants.isNotEmpty
          ? FloatingActionButton(
              onPressed: _navigateToGroupDetails,
              backgroundColor: AppConfig.primaryColor,
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            )
          : null,
    );
  }

}