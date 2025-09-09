import 'package:flutter/material.dart';
import '../../models/status.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import '../../config/app_config.dart';
import '../../widgets/common/app_header.dart';
import '../status/status_view_screen.dart';
import '../status/status_creation_screen.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen>
    with TickerProviderStateMixin {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Map<User, List<Status>> _filteredStatuses = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _filteredStatuses = _generateMockStatuses();
    _searchController.addListener(_onSearchChanged);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _filteredStatuses = _generateMockStatuses();
      } else {
        final allStatuses = _generateMockStatuses();
        final Map<User, List<Status>> filtered = {};
        
        allStatuses.forEach((user, statuses) {
          if (user.name.toLowerCase().contains(query)) {
            filtered[user] = statuses;
          }
        });
        
        _filteredStatuses = filtered;
      }
    });
  }

  Map<User, List<Status>> _generateMockStatuses() {
    final users = MockDataService.users;
    final Map<User, List<Status>> statusMap = {};
    
    // Add current user with empty status for demo
    statusMap[MockDataService.currentUser] = [];
    
    // Add some mock statuses for other users
    for (int i = 0; i < users.length && i < 5; i++) {
      final user = users[i];
      if (user.id != MockDataService.currentUser.id) {
        statusMap[user] = [
          Status(
            id: '${user.id}_status_1',
            author: user,
            type: StatusType.text,
            caption: 'Hello everyone! 👋',
            createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
            expiresAt: DateTime.now().add(const Duration(hours: 23)),
            viewed: i % 2 == 0,
          ),
        ];
      }
    }
    
    return statusMap;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              AppHeader(
                title: 'Updates',
                showSearch: true,
                showMoreOptions: true,
                isSearching: _isSearching,
                onSearchToggle: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _onSearchChanged();
                    }
                  });
                },
                searchController: _searchController,
                onSearchChanged: (query) => _onSearchChanged(),
                searchHint: 'Search status updates...',
                onMoreOptions: () => _showStatusPrivacySettings(context),
              ),
              
              // Status List
              Expanded(
                child: _buildStatusList(context, _filteredStatuses, isTablet, isDark),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Pencil FAB for text status
          FloatingActionButton(
            heroTag: "text_status_simple",
            mini: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatusCreationScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF075E54), // Dark WhatsApp green
            child: const Icon(Icons.edit, color: Colors.white, size: 20),
          ),
          
          const SizedBox(height: 16),
          
          // Camera FAB for media status
          FloatingActionButton(
            heroTag: "camera_status_simple",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatusCreationScreen(),
                ),
              );
            },
            backgroundColor: AppConfig.primaryColor,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusList(BuildContext context, Map<User, List<Status>> statusUpdates, bool isTablet, bool isDark) {
    if (statusUpdates.isEmpty) {
      return AppEmptyState(
        icon: _isSearching ? Icons.search_off : Icons.update,
        title: _isSearching ? 'No status updates found' : 'Stay updated',
        subtitle: _isSearching 
            ? 'Try adjusting your search terms'
            : 'Share photos, videos, and text with your contacts through status updates that disappear after 24 hours.',
        isTablet: isTablet,
        action: !_isSearching
            ? ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatusCreationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 24,
                    vertical: isTablet ? 16 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Create status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      );
    }

    // Simple, safe ListView implementation
    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 16 : 12,
        horizontal: isTablet ? 24 : 16,
      ),
      children: [
        // My Status Section
        _buildSimpleStatusTile(
          user: MockDataService.currentUser,
          title: 'My status',
          subtitle: 'Tap to add status update',
          isMyStatus: true,
          isDark: isDark,
          isTablet: isTablet,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StatusCreationScreen(),
              ),
            );
          },
        ),

        SizedBox(height: isTablet ? 24 : 16),

        // Recent Updates
        if (statusUpdates.isNotEmpty) ...[
          Text(
            'Recent updates',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          
          ...statusUpdates.entries.map((entry) {
            final user = entry.key;
            final statuses = entry.value;
            
            if (user.id == MockDataService.currentUser.id || statuses.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return _buildSimpleStatusTile(
              user: user,
              title: user.name,
              subtitle: '${statuses.length} update${statuses.length > 1 ? 's' : ''}',
              isMyStatus: false,
              isDark: isDark,
              isTablet: isTablet,
              onTap: () {
                // Navigate to status view
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Viewing ${user.name}\'s status'),
                    backgroundColor: AppConfig.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
            );
          }).toList(),
        ],
        
        SizedBox(height: isTablet ? 120 : 100),
      ],
    );
  }

  Widget _buildSimpleStatusTile({
    required User user,
    required String title,
    required String subtitle,
    required bool isMyStatus,
    required bool isDark,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: isTablet ? 8 : 4,
            offset: const Offset(0, 2),
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
              backgroundColor: user.profilePicture != null
                  ? Colors.transparent
                  : AppConfig.primaryColor.withOpacity(0.1),
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: user.profilePicture == null
                  ? Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: AppConfig.primaryColor,
                      ),
                    )
                  : null,
            ),
            if (isMyStatus)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 4 : 3),
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppConfig.darkSurface : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: isTablet ? 16 : 12,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showStatusPrivacySettings(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppConfig.darkSurface : Colors.white,
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
                color: isDark ? AppConfig.darkTextSecondary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              child: Column(
                children: [
                  _buildOptionTile(
                    icon: Icons.visibility,
                    title: 'Status privacy',
                    subtitle: 'Control who can see your status',
                    onTap: () {
                      Navigator.pop(context);
                      _showStatusPrivacyOptions(context);
                    },
                    isDark: isDark,
                    isTablet: isTablet,
                  ),
                  
                  _buildOptionTile(
                    icon: Icons.delete_outline,
                    title: 'Clear all statuses',
                    subtitle: 'Delete all your status updates',
                    onTap: () {
                      Navigator.pop(context);
                      _showClearStatusDialog(context);
                    },
                    isDark: isDark,
                    isTablet: isTablet,
                  ),
                ],
              ),
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
    required bool isDark,
    required bool isTablet,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 8 : 4,
        vertical: isTablet ? 8 : 4,
      ),
      leading: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 8),
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
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
          color: isDark ? AppConfig.darkText : AppConfig.lightText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showStatusPrivacyOptions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppConfig.darkSurface : Colors.white,
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
                color: isDark ? AppConfig.darkTextSecondary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.people,
                      color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    ),
                    title: Text(
                      'Everyone',
                      style: TextStyle(
                        color: isDark ? AppConfig.darkText : AppConfig.lightText,
                      ),
                    ),
                    subtitle: Text(
                      'All contacts can see your status',
                      style: TextStyle(
                        color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.contacts,
                      color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    ),
                    title: Text(
                      'My contacts',
                      style: TextStyle(
                        color: isDark ? AppConfig.darkText : AppConfig.lightText,
                      ),
                    ),
                    subtitle: Text(
                      'Only your contacts can see your status',
                      style: TextStyle(
                        color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    ),
                    title: Text(
                      'Selected contacts',
                      style: TextStyle(
                        color: isDark ? AppConfig.darkText : AppConfig.lightText,
                      ),
                    ),
                    subtitle: Text(
                      'Choose who can see your status',
                      style: TextStyle(
                        color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearStatusDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        title: Text(
          'Clear all statuses?',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will delete all your status updates. This action cannot be undone.',
          style: TextStyle(
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All statuses cleared'),
                  backgroundColor: AppConfig.successColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
            ),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

