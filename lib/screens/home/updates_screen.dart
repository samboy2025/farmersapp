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
    _filteredStatuses = _getMockStatusUpdates();
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
        _filteredStatuses = _getMockStatusUpdates();
      } else {
        final allStatuses = _getMockStatusUpdates();
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
            heroTag: "text_status",
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
          
          // Camera FAB for photo/video status  
          FloatingActionButton(
            heroTag: "camera_status",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatusCreationScreen(),
                ),
              );
            },
            backgroundColor: AppConfig.primaryColor,
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
          ),
        ],
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

  void _showClearStatusDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear all statuses?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
          ),
        ),
        content: Text(
          'This will delete all your status updates. This action cannot be undone.',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFeatureComingSoon(context, 'Clear statuses');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusList(BuildContext context, Map<User, List<Status>> statusUpdates, bool isTablet, bool isDark) {
    // Separate statuses by category
    final myStatuses = statusUpdates[MockDataService.currentUser] ?? [];
    final recentUpdates = <User, List<Status>>{};
    final viewedUpdates = <User, List<Status>>{};

    statusUpdates.forEach((user, statuses) {
      if (user.id != MockDataService.currentUser.id) {
        final hasUnviewed = statuses.any((s) => !s.viewed && s.isActive);
        if (hasUnviewed) {
          recentUpdates[user] = statuses.where((s) => s.isActive).toList();
        } else {
          viewedUpdates[user] = statuses.where((s) => s.isActive).toList();
        }
      }
    });

    if (recentUpdates.isEmpty && viewedUpdates.isEmpty && myStatuses.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 40 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isTablet ? 120 : 80,
                height: isTablet ? 120 : 80,
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.update,
                  size: isTablet ? 60 : 40,
                  color: AppConfig.primaryColor,
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),
              Text(
                'Stay updated',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Text(
                'Share photos, videos, and text with your contacts through status updates that disappear after 24 hours.',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 32 : 24),
              ElevatedButton.icon(
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
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  'Add status',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // For mock data, just rebuild the UI
        // In real app, this would refresh from API
      },
      color: AppConfig.primaryColor,
      child: ListView(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 12,
          horizontal: 0,
        ),
        children: [
          // My Status Section
          _WhatsAppMyStatusTile(
            statuses: myStatuses,
            isTablet: isTablet,
            onTap: () {
              if (myStatuses.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatusViewScreen(
                      statuses: myStatuses,
                      initialIndex: 0,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatusCreationScreen(),
                  ),
                );
              }
            },
          ),

          // Recent Updates Section
          if (recentUpdates.isNotEmpty) ...[
            SizedBox(height: isTablet ? 24 : 16),
            _buildSectionHeader('Recent updates', isTablet),
            SizedBox(height: isTablet ? 12 : 8),
            ...recentUpdates.entries.map((entry) => _WhatsAppStatusTile(
              user: entry.key,
              statuses: entry.value,
              isTablet: isTablet,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatusViewScreen(
                      statuses: entry.value,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
            )),
          ],

          // Viewed Updates Section
          if (viewedUpdates.isNotEmpty) ...[
            SizedBox(height: isTablet ? 24 : 16),
            _buildSectionHeader('Viewed updates', isTablet),
            SizedBox(height: isTablet ? 12 : 8),
            ...viewedUpdates.entries.map((entry) => _WhatsAppStatusTile(
              user: entry.key,
              statuses: entry.value,
              isViewed: true,
              isTablet: isTablet,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatusViewScreen(
                      statuses: entry.value,
                      initialIndex: 0,
                    ),
                  ),
                );
              },
            )),
          ],
          
          // Bottom padding for FAB
          SizedBox(height: isTablet ? 120 : 100),
        ],
      ),
    );
  }

  Map<User, List<Status>> _getMockStatusUpdates() {
    final statuses = MockDataService.statuses;
    final Map<User, List<Status>> groupedStatuses = {};
    
    for (final status in statuses) {
      if (!groupedStatuses.containsKey(status.author)) {
        groupedStatuses[status.author] = [];
      }
      groupedStatuses[status.author]!.add(status);
    }
    
    return groupedStatuses;
  }

  Widget _buildSectionHeader(String title, bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _WhatsAppMyStatusTile extends StatelessWidget {
  final List<Status> statuses;
  final VoidCallback onTap;
  final bool isTablet;

  const _WhatsAppMyStatusTile({
    required this.statuses,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final hasStatus = statuses.isNotEmpty;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              // My Status Avatar with ring
              Stack(
                children: [
                  Container(
                    width: isTablet ? 64 : 56,
                    height: isTablet ? 64 : 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasStatus
                          ? LinearGradient(
                              colors: [
                                AppConfig.primaryColor,
                                AppConfig.primaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: hasStatus ? null : const Color(0xFFE5E5E5),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        radius: isTablet ? 28 : 24,
                        backgroundColor: const Color(0xFFE5E5E5),
                        backgroundImage: hasStatus && statuses.first.thumbnailUrl != null
                            ? NetworkImage(statuses.first.thumbnailUrl!)
                            : null,
                        child: !hasStatus || statuses.first.thumbnailUrl == null
                            ? Icon(
                                Icons.person, 
                                color: const Color(0xFF667781), 
                                size: isTablet ? 28 : 24,
                              )
                            : null,
                      ),
                    ),
                  ),
                  
                  // Add icon for new status
                  if (!hasStatus)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: isTablet ? 24 : 20,
                        height: isTablet ? 24 : 20,
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add,
                          size: isTablet ? 14 : 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              
              SizedBox(width: isTablet ? 20 : 16),
              
              // Status info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My status',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      hasStatus
                          ? 'Tap to view your status'
                          : 'Tap to add status update',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Camera icon
              Icon(
                Icons.camera_alt_outlined,
                color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                size: isTablet ? 28 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhatsAppStatusTile extends StatelessWidget {
  final User user;
  final List<Status> statuses;
  final VoidCallback onTap;
  final bool isViewed;
  final bool isTablet;

  const _WhatsAppStatusTile({
    required this.user,
    required this.statuses,
    required this.onTap,
    required this.isTablet,
    this.isViewed = false,
  });

  @override
  Widget build(BuildContext context) {
    final latestStatus = statuses.first;
    final hasUnviewed = !isViewed && statuses.any((s) => !s.viewed);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 16,
          vertical: isTablet ? 12 : 8,
        ),
        child: Row(
          children: [
            // User Avatar with Status Ring
            _buildStatusAvatar(latestStatus, hasUnviewed),
            
            SizedBox(width: isTablet ? 20 : 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: hasUnviewed ? FontWeight.w600 : FontWeight.w500,
                      color: hasUnviewed
                          ? (isDark ? AppConfig.darkText : const Color(0xFF111B21))
                          : (isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 4 : 2),
                  Text(
                    latestStatus.timeAgo,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusAvatar(Status latestStatus, bool hasUnviewed) {
    final avatarSize = isTablet ? 64.0 : 56.0;
    final avatarRadius = isTablet ? 28.0 : 24.0;
    
    // Create multiple rings for multiple statuses
    return Stack(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasUnviewed
                ? LinearGradient(
                    colors: [
                      AppConfig.primaryColor,
                      AppConfig.primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: hasUnviewed ? null : const Color(0xFFE5E5E5),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: AppConfig.primaryColor,
              backgroundImage: latestStatus.thumbnailUrl != null
                  ? NetworkImage(latestStatus.thumbnailUrl!)
                  : null,
              child: latestStatus.thumbnailUrl == null
                  ? Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        
        // Multiple status indicator segments
        if (statuses.length > 1)
          ...List.generate(
            statuses.length.clamp(0, 4), // Max 4 segments
            (index) => _buildStatusSegment(index, statuses.length, hasUnviewed),
          ),
      ],
    );
  }

  Widget _buildStatusSegment(int index, int total, bool hasUnviewed) {
    final angle = (2 * 3.14159) / total; // 360 degrees divided by total statuses
    final startAngle = angle * index - 3.14159 / 2; // Start from top
    
    return Positioned.fill(
      child: CustomPaint(
        painter: _StatusRingPainter(
          startAngle: startAngle,
          sweepAngle: angle - 0.1, // Small gap between segments
          color: hasUnviewed ? AppConfig.primaryColor : Colors.grey.shade400,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _StatusRingPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final double strokeWidth;

  _StatusRingPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
