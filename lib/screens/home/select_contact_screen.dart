import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_config.dart';
import '../../services/mock_data_service.dart';

class ContactInfo {
  final String name;
  final String phoneNumber;
  final bool hasProfilePicture;

  ContactInfo(this.name, this.phoneNumber, this.hasProfilePicture);
}

class SelectContactScreen extends StatefulWidget {
  const SelectContactScreen({super.key});

  @override
  State<SelectContactScreen> createState() => _SelectContactScreenState();
}

class _SelectContactScreenState extends State<SelectContactScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSyncing = false;
  List<ContactInfo> _contactsOnApp = [];
  List<ContactInfo> _contactsToInvite = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadContacts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading contacts
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generate mock contacts
    final mockContacts = _generateMockContacts();
    final appUsers = MockDataService.users;

    // Separate contacts into those on app and those to invite
    for (final contact in mockContacts) {
      final isOnApp = appUsers.any((user) =>
          user.phoneNumber == contact.phoneNumber);

      if (isOnApp) {
        _contactsOnApp.add(contact);
      } else {
        _contactsToInvite.add(contact);
      }
    }

    setState(() {
      _isLoading = false;
    });

    _animationController.forward();
  }

  Future<void> _syncContacts() async {
    setState(() {
      _isSyncing = true;
    });

    // Simulate syncing
    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() {
      _isSyncing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contacts synced successfully!'),
          backgroundColor: AppConfig.successColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  List<ContactInfo> _generateMockContacts() {
    return [
      ContactInfo('John Doe', '+234 803 123 4567', true),
      ContactInfo('Jane Smith', '+234 805 987 6543', false),
      ContactInfo('Mike Johnson', '+234 807 555 1234', true),
      ContactInfo('Sarah Wilson', '+234 809 444 7890', false),
      ContactInfo('David Brown', '+234 806 333 5678', true),
      ContactInfo('Lisa Davis', '+234 808 222 9012', false),
      ContactInfo('Tom Anderson', '+234 804 111 3456', true),
      ContactInfo('Emily Taylor', '+234 802 666 7894', false),
      ContactInfo('Chris Martin', '+234 801 888 2468', false),
      ContactInfo('Anna White', '+234 803 999 1357', true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppConfig.lightBackground,
      appBar: _buildAppBar(context, isTablet),
      body: _isLoading ? _buildLoadingState(isTablet) : _buildContactsList(isTablet),
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
      title: const Text(
        'Select contact',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _isSyncing ? null : _syncContacts,
          icon: _isSyncing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.sync, color: Colors.white),
          tooltip: 'Sync contacts',
          splashRadius: 20,
        ),
        IconButton(
          onPressed: () => _showSearchBottomSheet(context),
          icon: const Icon(Icons.search, color: Colors.white),
          tooltip: 'Search contacts',
          splashRadius: 20,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
            strokeWidth: 3,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Syncing your contacts...',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: AppConfig.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'This may take a few moments',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: AppConfig.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(bool isTablet) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Sync Status Banner
          if (_isSyncing) _buildSyncBanner(isTablet),

          // Contacts List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 16 : 8,
              ),
              children: [
                // Quick Actions
                _buildQuickActions(isTablet),

                SizedBox(height: isTablet ? 24 : 16),

                // Contacts on App
                if (_contactsOnApp.isNotEmpty) ...[
                  _buildSectionHeader('Contacts on ChatWave', _contactsOnApp.length, isTablet),
                  SizedBox(height: isTablet ? 12 : 8),
                  ..._contactsOnApp.map((contact) => _buildContactTile(contact, true, isTablet)),
                  SizedBox(height: isTablet ? 32 : 24),
                ],

                // Invite to App
                if (_contactsToInvite.isNotEmpty) ...[
                  _buildSectionHeader('Invite to ChatWave', _contactsToInvite.length, isTablet),
                  SizedBox(height: isTablet ? 12 : 8),
                  ..._contactsToInvite.map((contact) => _buildContactTile(contact, false, isTablet)),
                ],

                SizedBox(height: isTablet ? 100 : 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncBanner(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: AppConfig.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isTablet ? 20 : 16,
            height: isTablet ? 20 : 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Text(
              'Syncing contacts...',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppConfig.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: isTablet ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildQuickActionTile(
            icon: Icons.person_add,
            title: 'New contact',
            subtitle: 'Add contact manually',
            onTap: () => _showAddContactDialog(context),
            isTablet: isTablet,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildQuickActionTile(
            icon: Icons.group_add,
            title: 'New group',
            subtitle: 'Create a new group',
            onTap: () => Navigator.pushNamed(context, '/create-group'),
            isTablet: isTablet,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildQuickActionTile(
            icon: Icons.share,
            title: 'Invite friends',
            subtitle: 'Share invitation link',
            onTap: () => _showInviteOptions(context),
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 4,
      ),
      leading: Container(
        width: isTablet ? 48 : 40,
        height: isTablet ? 48 : 40,
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        ),
        child: Icon(
          icon,
          color: AppConfig.primaryColor,
          size: isTablet ? 24 : 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w600,
          color: AppConfig.lightText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: AppConfig.lightTextSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: isTablet ? 18 : 16,
        color: AppConfig.lightTextSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 4 : 0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: AppConfig.lightText,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 8,
              vertical: isTablet ? 6 : 4,
            ),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(ContactInfo contact, bool isOnApp, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 8 : 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
        leading: CircleAvatar(
          radius: isTablet ? 24 : 20,
          backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
          child: Text(
            contact.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: AppConfig.primaryColor,
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: AppConfig.lightText,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.phoneNumber,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppConfig.lightTextSecondary,
              ),
            ),
            if (isOnApp)
              Text(
                'On ChatWave',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: AppConfig.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: isOnApp
            ? IconButton(
                onPressed: () => _startChat(contact),
                icon: Icon(
                  Icons.chat,
                  color: AppConfig.primaryColor,
                  size: isTablet ? 24 : 20,
                ),
                tooltip: 'Start chat',
                splashRadius: isTablet ? 24 : 20,
              )
            : IconButton(
                onPressed: () => _inviteContact(contact),
                icon: Icon(
                  Icons.person_add,
                  color: AppConfig.lightTextSecondary,
                  size: isTablet ? 24 : 20,
                ),
                tooltip: 'Invite',
                splashRadius: isTablet ? 24 : 20,
              ),
        onTap: isOnApp ? () => _startChat(contact) : () => _inviteContact(contact),
      ),
    );
  }

  void _startChat(ContactInfo contact) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting chat with ${contact.name}...'),
        backgroundColor: AppConfig.successColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _inviteContact(ContactInfo contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInviteBottomSheet(contact),
    );
  }

  Widget _buildInviteBottomSheet(ContactInfo contact) {
    final isTablet = MediaQuery.of(context).size.width > 600;

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
                  'Invite ${contact.name}',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.lightText,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Send an invitation to join ChatWave',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppConfig.lightTextSecondary,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildInviteOption(
                        icon: Icons.sms,
                        title: 'SMS',
                        onTap: () => _sendInvite('SMS', contact),
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: _buildInviteOption(
                        icon: Icons.share,
                        title: 'Share',
                        onTap: () => _sendInvite('Share', contact),
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

  Widget _buildInviteOption({
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
          color: AppConfig.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          border: Border.all(
            color: AppConfig.primaryColor.withValues(alpha: 0.2),
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

  void _sendInvite(String method, ContactInfo contact) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to ${contact.name} via $method'),
        backgroundColor: AppConfig.successColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ContactSearchBottomSheet(),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddContactDialog(),
    );
  }

  void _showInviteOptions(BuildContext context) {
    Share.share(
      'Hey! Check out ChatWave - the best messaging app! Download it now: https://play.google.com/store/apps/details?id=com.chatwave.app',
      subject: 'Join me on ChatWave!',
    );
  }

}

class ContactSearchBottomSheet extends StatefulWidget {
  const ContactSearchBottomSheet({super.key});

  @override
  State<ContactSearchBottomSheet> createState() => _ContactSearchBottomSheetState();
}

class _ContactSearchBottomSheetState extends State<ContactSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<ContactInfo> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final allContacts = _generateMockContacts();
      final results = allContacts.where((contact) =>
        contact.name.toLowerCase().contains(query) ||
        contact.phoneNumber.contains(query)
      ).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  List<ContactInfo> _generateMockContacts() {
    return [
      ContactInfo('John Doe', '+234 803 123 4567', true),
      ContactInfo('Jane Smith', '+234 805 987 6543', false),
      ContactInfo('Mike Johnson', '+234 807 555 1234', true),
      ContactInfo('Sarah Wilson', '+234 809 444 7890', false),
      ContactInfo('David Brown', '+234 806 333 5678', true),
      ContactInfo('Lisa Davis', '+234 808 222 9012', false),
      ContactInfo('Tom Anderson', '+234 804 111 3456', true),
      ContactInfo('Emily Taylor', '+234 802 666 7894', false),
      ContactInfo('Chris Martin', '+234 801 888 2468', false),
      ContactInfo('Anna White', '+234 803 999 1357', true),
    ];
  }

  void _selectContact(ContactInfo contact) {
    Navigator.pop(context); // Close search sheet

    // Check if contact is on app
    final appUsers = MockDataService.users;
    final isOnApp = appUsers.any((user) =>
        user.phoneNumber == contact.phoneNumber);

    if (isOnApp) {
      // Start chat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting chat with ${contact.name}...'),
          backgroundColor: AppConfig.successColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      // Show invite
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildInviteBottomSheet(contact),
      );
    }
  }

  Widget _buildInviteBottomSheet(ContactInfo contact) {
    final isTablet = MediaQuery.of(context).size.width > 600;

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
                  'Invite ${contact.name}',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.lightText,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Send an invitation to join ChatWave',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppConfig.lightTextSecondary,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildInviteOption(
                        icon: Icons.sms,
                        title: 'SMS',
                        onTap: () => _sendInvite('SMS', contact),
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: _buildInviteOption(
                        icon: Icons.share,
                        title: 'Share',
                        onTap: () => _sendInvite('Share', contact),
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

  Widget _buildInviteOption({
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
          color: AppConfig.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          border: Border.all(
            color: AppConfig.primaryColor.withValues(alpha: 0.2),
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

  void _sendInvite(String method, ContactInfo contact) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to ${contact.name} via $method'),
        backgroundColor: AppConfig.successColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppConfig.darkSurface
            : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTablet ? 24 : 20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Search field
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Search results
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
                    ),
                  )
                : _searchController.text.isEmpty
                    ? _buildSearchPrompt()
                    : _searchResults.isEmpty
                        ? _buildNoResults()
                        : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for contacts',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No contacts found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final contact = _searchResults[index];
        final appUsers = MockDataService.users;
        final isOnApp = appUsers.any((user) =>
            user.phoneNumber == contact.phoneNumber);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
            child: Text(
              contact.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppConfig.primaryColor,
              ),
            ),
          ),
          title: Text(
            contact.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.phoneNumber,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              if (isOnApp)
                Text(
                  'On ChatWave',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConfig.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          trailing: isOnApp
              ? Icon(
                  Icons.chat,
                  color: AppConfig.primaryColor,
                )
              : Icon(
                  Icons.person_add,
                  color: Colors.grey.shade600,
                ),
          onTap: () => _selectContact(contact),
        );
      },
    );
  }
}

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // In a real app, this would save to phone contacts and app DB
      final newContact = ContactInfo(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        false,
      );

      // Add to mock contacts (in real app, this would be saved to database)
      // For now, we'll just show success message
      await Future.delayed(const Duration(seconds: 1)); // Simulate save delay

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact "${newContact.name}" added successfully'),
            backgroundColor: AppConfig.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save contact: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Contact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF111B21),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter contact name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 (234) 567-8901',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Contact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
