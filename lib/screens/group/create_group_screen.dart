import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  List<User> _selectedParticipants = [];
  List<User> _allContacts = [];
  List<User> _filteredContacts = [];
  String _searchQuery = '';
  int _currentStep = 0; // 0: Select participants, 1: Group details
  bool _isLoading = false;
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
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
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    _searchController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadContacts() {
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

  void _nextStep() {
    if (_selectedParticipants.isEmpty) {
      _showErrorSnackbar('Please select at least one participant');
      return;
    }
    
    setState(() {
      _currentStep = 1;
    });
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
    
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate group creation
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group "${_groupNameController.text}" created successfully!'),
          backgroundColor: AppConfig.successColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConfig.errorColor,
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
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildParticipantSelection(isTablet),
            _buildGroupDetails(isTablet),
          ],
        ),
      ),
      floatingActionButton: _currentStep == 0
          ? (_selectedParticipants.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _nextStep,
                  backgroundColor: AppConfig.primaryColor,
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text(
                    'Next (${_selectedParticipants.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  elevation: 4,
                )
              : null)
          : FloatingActionButton.extended(
              onPressed: _isLoading ? null : _createGroup,
              backgroundColor: _isLoading ? Colors.grey : AppConfig.primaryColor,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label: Text(
                _isLoading ? 'Creating...' : 'Create Group',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 4,
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    return AppBar(
      backgroundColor: AppConfig.primaryColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          if (_currentStep == 1) {
            _previousStep();
          } else {
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        splashRadius: 20,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentStep == 0 ? 'Add participants' : 'New group',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_currentStep == 0 && _selectedParticipants.isNotEmpty)
            Text(
              '${_selectedParticipants.length} selected',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      actions: _currentStep == 0 ? [
        if (_isSearching)
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _filterContacts();
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
            tooltip: 'Search participants',
            splashRadius: 20,
          ),
        const SizedBox(width: 8),
      ] : null,
    );
  }

  Widget _buildParticipantSelection(bool isTablet) {
    return Column(
      children: [
        // Selected participants header
        if (_selectedParticipants.isNotEmpty) _buildSelectedHeader(isTablet),
        
        // Search bar
        if (_isSearching) _buildSearchBar(isTablet),
        
        // Info banner
        _buildInfoBanner(isTablet),
        
        // Participants list
        Expanded(
          child: _buildParticipantsList(isTablet),
        ),
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
            Icons.group,
            color: AppConfig.primaryColor,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedParticipants.length} participants selected',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                Text(
                  'Tap to remove participants',
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
                _selectedParticipants.clear();
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
        decoration: InputDecoration(
          hintText: 'Search participants...',
          prefixIcon: Icon(
            Icons.search,
            color: AppConfig.lightTextSecondary,
            size: isTablet ? 24 : 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterContacts();
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
              'Select contacts to add to your group. You can add more members later.',
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

  Widget _buildParticipantsList(bool isTablet) {
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
        final isSelected = _selectedParticipants.contains(contact);

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
            onTap: () => _toggleParticipant(contact),
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

  Widget _buildGroupDetails(bool isTablet) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Group preview header
          _buildGroupPreviewHeader(isTablet),
          
          // Group details form
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 24 : 16,
              ),
              children: [
                // Group avatar section
                _buildGroupAvatarSection(isTablet),
                
                SizedBox(height: isTablet ? 32 : 24),
                
                // Group name field
                _buildGroupNameField(isTablet),
                
                SizedBox(height: isTablet ? 24 : 16),
                
                // Group description field
                _buildGroupDescriptionField(isTablet),
                
                SizedBox(height: isTablet ? 32 : 24),
                
                // Group settings section
                _buildGroupSettingsSection(isTablet),
                
                SizedBox(height: isTablet ? 100 : 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupPreviewHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 20 : 16,
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
            Icons.group,
            color: AppConfig.primaryColor,
            size: isTablet ? 28 : 24,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create group with ${_selectedParticipants.length} participants',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                Text(
                  'Set group name and description',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppConfig.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAvatarSection(bool isTablet) {
    return Center(
      child: GestureDetector(
        onTap: () => _showAvatarOptions(isTablet),
        child: Container(
          width: isTablet ? 120 : 100,
          height: isTablet ? 120 : 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppConfig.primaryColor.withOpacity(0.1),
            border: Border.all(
              color: AppConfig.primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.group,
                size: isTablet ? 48 : 40,
                color: AppConfig.primaryColor,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 8 : 6),
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: isTablet ? 16 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupNameField(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isTablet ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _groupNameController,
        decoration: InputDecoration(
          labelText: 'Group name',
          hintText: 'Enter group name',
          prefixIcon: Icon(
            Icons.group,
            color: AppConfig.primaryColor,
            size: isTablet ? 24 : 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 20 : 16,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          color: AppConfig.lightText,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a group name';
          }
          if (value.trim().length < 2) {
            return 'Group name must be at least 2 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGroupDescriptionField(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isTablet ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _groupDescriptionController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Group description (optional)',
          hintText: 'What is this group about?',
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: isTablet ? 40 : 32),
            child: Icon(
              Icons.description,
              color: AppConfig.primaryColor,
              size: isTablet ? 24 : 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 20 : 16,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: AppConfig.lightText,
        ),
      ),
    );
  }

  Widget _buildGroupSettingsSection(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isTablet ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Text(
              'Group settings',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: AppConfig.lightText,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          SwitchListTile(
            title: Text(
              'Send messages to admins only',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppConfig.lightText,
              ),
            ),
            subtitle: Text(
              'Only group admins can send messages',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: AppConfig.lightTextSecondary,
              ),
            ),
            value: false,
            onChanged: (value) {
              // Handle toggle
            },
            activeColor: AppConfig.primaryColor,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          SwitchListTile(
            title: Text(
              'Hide participant list',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppConfig.lightText,
              ),
            ),
            subtitle: Text(
              'Only admins can see all participants',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: AppConfig.lightTextSecondary,
              ),
            ),
            value: false,
            onChanged: (value) {
              // Handle toggle
            },
            activeColor: AppConfig.primaryColor,
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions(bool isTablet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAvatarOptionsBottomSheet(isTablet),
    );
  }

  Widget _buildAvatarOptionsBottomSheet(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTablet ? 24 : 20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: isTablet ? 50 : 40,
            height: 4,
            margin: EdgeInsets.only(top: isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              children: [
                Text(
                  'Set group photo',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.lightText,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildAvatarOption(
                        icon: Icons.camera_alt,
                        title: 'Camera',
                        onTap: () => _handleAvatarOption('Camera'),
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: _buildAvatarOption(
                        icon: Icons.photo_library,
                        title: 'Gallery',
                        onTap: () => _handleAvatarOption('Gallery'),
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 12,
          horizontal: isTablet ? 20 : 16,
        ),
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          border: Border.all(
            color: AppConfig.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppConfig.primaryColor,
              size: isTablet ? 32 : 28,
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAvatarOption(String option) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$option option coming soon!'),
        backgroundColor: AppConfig.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}