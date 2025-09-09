import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/group.dart';
import '../../models/message.dart';
import '../../services/mock_data_service.dart';
import '../chat/group_chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Group> _filteredGroups = [];
  final List<Group> _groups = [
    Group(
      id: '1',
      name: 'Project Team',
      description: 'Team collaboration for the main project',
      members: MockDataService.users.take(8).toList(),
      admins: [MockDataService.users[0], MockDataService.users[1]],
      createdBy: MockDataService.users[0],
      lastMessage: Message(
        id: '1',
        chatId: '1',
        sender: MockDataService.users[0],
        type: MessageType.text,
        content: 'Meeting at 3 PM today',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      unreadCount: 3,
      lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Group(
      id: '2',
      name: 'Family Group',
      description: 'Family updates and coordination',
      members: MockDataService.users.take(12).toList(),
      admins: [MockDataService.users[0]],
      createdBy: MockDataService.users[0],
      lastMessage: Message(
        id: '2',
        chatId: '2',
        sender: MockDataService.users[1],
        type: MessageType.text,
        content: 'Dinner at 7 PM tonight',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      unreadCount: 0,
      lastActivity: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Group(
      id: '3',
      name: 'College Friends',
      description: 'Stay connected with college buddies',
      members: MockDataService.users.take(25).toList(),
      admins: [MockDataService.users[0], MockDataService.users[2]],
      createdBy: MockDataService.users[0],
      lastMessage: Message(
        id: '3',
        chatId: '3',
        sender: MockDataService.users[2],
        type: MessageType.text,
        content: 'Reunion next month!',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      unreadCount: 1,
      lastActivity: DateTime.now().subtract(const Duration(hours: 6)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredGroups = List.from(_groups);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    
    setState(() {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _filteredGroups = List.from(_groups);
      } else {
        _filteredGroups = _groups
            .where((group) =>
                group.name.toLowerCase().contains(query) ||
                (group.description?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context, isTablet),
            
            // Search Bar (when searching)
            if (_isSearching) _buildSearchBar(isTablet),
            
            // Groups List
            Expanded(
              child: _buildGroupsList(isTablet),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-group'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New community'),
      ),
    );
  }

  Widget _buildSearchBar(bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search communities...',
          prefixIcon: Icon(
            Icons.search,
            color: AppConfig.lightTextSecondary,
            size: isTablet ? 24 : 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
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

  Widget _buildHeader(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Communities',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
            ),
          ),
          
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _onSearchChanged();
                    }
                  });
                },
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                splashRadius: 20,
              ),
              IconButton(
                onPressed: () {
                  _showCommunityOptions(context);
                },
                icon: const Icon(Icons.more_vert),
                color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }



  void _showCommunityOptions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildOptionTile(
              icon: Icons.add,
              title: 'New community',
              subtitle: 'Create a new community',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/create-group');
              },
            ),
            
            _buildOptionTile(
              icon: Icons.public,
              title: 'Join community',
              subtitle: 'Join an existing community',
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon(context, 'Join community');
              },
            ),
            
            _buildOptionTile(
              icon: Icons.settings,
              title: 'Community settings',
              subtitle: 'Manage community preferences',
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon(context, 'Community settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withValues(alpha: 0.1),
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  void _showFeatureComingSoon(BuildContext context, String feature) {
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



  Widget _buildGroupsList(bool isTablet) {
    if (_filteredGroups.isEmpty) {
      return _buildEmptyState(isTablet);
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 12 : 8,
        horizontal: 0,
      ),
      children: _filteredGroups.asMap().entries.map((entry) {
        final index = entry.key;
        final group = entry.value;
        return Column(
          children: [
            _buildWhatsAppGroupTile(group, isTablet),
            if (index < _filteredGroups.length - 1)
              Divider(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.1),
                indent: isTablet ? 88 : 72,
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No groups yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first group to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showCreateGroupDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppGroupTile(Group group, bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
        onTap: () => _openGroup(context, group),
      onLongPress: () => _showGroupOptions(context, group),
        child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 16, 
          vertical: isTablet ? 16 : 12,
        ),
          child: Row(
            children: [
            // Group Avatar
            SizedBox(
              width: isTablet ? 56 : 48,
              height: isTablet ? 56 : 48,
              child: CircleAvatar(
                radius: isTablet ? 28 : 24,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/icons/Group placeholder.png',
                    width: isTablet ? 56 : 48,
                    height: isTablet ? 56 : 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => CircleAvatar(
                      radius: isTablet ? 28 : 24,
                      backgroundColor: AppConfig.primaryColor,
                      child: Icon(Icons.group, color: Colors.white, size: isTablet ? 28 : 24),
                    ),
                  ),
                ),
              ),
            ),
              
              SizedBox(width: isTablet ? 20 : 16),
              
            // Group Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        _formatLastActivity(group.lastActivity),
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                          color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                  Row(
                    children: [
                      if (group.lastMessage != null) ...[
                    Text(
                          '${group.lastMessage!.sender.name}: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppConfig.darkTextSecondary : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            group.lastMessage!.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: group.unreadCount > 0
                                  ? (isDark ? AppConfig.darkText : Colors.black87)
                                  : (isDark ? AppConfig.darkTextSecondary : Colors.grey.shade600),
                              fontWeight: group.unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Text(
                          '${group.members.length} members',
                          style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppConfig.darkTextSecondary : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                      ],
                    ),
                  ],
                ),
              ),
              
            // Unread count
            if (group.unreadCount > 0) ...[
              const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: AppConfig.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Text(
                  group.unreadCount > 99 ? '99+' : group.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ],
            ],
        ),
      ),
    );
  }

  String _formatLastActivity(DateTime lastActivity) {
    final now = DateTime.now();
    final diff = now.difference(lastActivity);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter group description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                _createGroup(
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createGroup(String name, String description) {
    if (!mounted) return;
    
    final newGroup = Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      members: [MockDataService.currentUser],
      admins: [MockDataService.currentUser],
      createdBy: MockDataService.currentUser,
      lastActivity: DateTime.now(),
      createdAt: DateTime.now(),
    );
    
    setState(() {
      _groups.insert(0, newGroup);
      _filteredGroups = List.from(_groups);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group "$name" created successfully!'),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }

  void _openGroup(BuildContext context, Group group) {
    // Navigate to group chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatScreen(group: group),
      ),
    );
  }

  void _showGroupOptions(BuildContext context, Group group) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Group'),
              onTap: () {
                Navigator.pop(context);
                _editGroup(context, group);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Members'),
              onTap: () {
                Navigator.pop(context);
                _addMembers(context, group);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Group Settings'),
              onTap: () {
                Navigator.pop(context);
                _showGroupSettings(context, group);
              },
            ),
            if (group.admins.any((admin) => admin.id == MockDataService.currentUser.id))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Group', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteGroup(context, group);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _editGroup(BuildContext context, Group group) {
    final nameController = TextEditingController(text: group.name);
    final descriptionController = TextEditingController(text: group.description);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter group description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Note: In a real app, you would update the group object properly
                // For now, we'll just show a success message
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addMembers(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Members'),
        content: const Text('Member management functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGroupSettings(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Community Settings'),
        content: const Text('Settings functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteGroup(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete "${group.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _groups.remove(group);
                _filteredGroups = List.from(_groups);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Group "${group.name}" deleted!'),
                  backgroundColor: AppConfig.errorColor,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }




}
