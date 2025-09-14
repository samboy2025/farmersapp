import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/call.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCalls = [];

  final List<Map<String, dynamic>> _callHistory = [
    {
      'id': '1',
      'contact': MockDataService.getUserById('2')!,
      'type': CallType.voice,
      'status': CallStatus.ended,
      'duration': const Duration(minutes: 5, seconds: 32),
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isIncoming': true,
    },
    {
      'id': '2',
      'contact': MockDataService.getUserById('3')!,
      'type': CallType.video,
      'status': CallStatus.ended,
      'duration': const Duration(minutes: 12, seconds: 45),
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isIncoming': false,
    },
    {
      'id': '3',
      'contact': MockDataService.getUserById('4')!,
      'type': CallType.voice,
      'status': CallStatus.missed,
      'duration': Duration.zero,
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isIncoming': true,
    },
    {
      'id': '4',
      'contact': MockDataService.getUserById('5')!,
      'type': CallType.voice,
      'status': CallStatus.rejected,
      'duration': Duration.zero,
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isIncoming': false,
    },
    {
      'id': '5',
      'contact': MockDataService.getUserById('1')!,
      'type': CallType.video,
      'status': CallStatus.ended,
      'duration': const Duration(minutes: 8, seconds: 12),
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      'isIncoming': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredCalls = List.from(_callHistory);
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
        _filteredCalls = List.from(_callHistory);
      } else {
        _filteredCalls = _callHistory
            .where((call) =>
                call['contact'].name.toLowerCase().contains(query) ||
                call['contact'].phoneNumber.contains(query))
            .toList();
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
        child: Column(
          children: [
            // Custom Header
            _buildHeader(context, isTablet),
            
            // Search Bar (when searching)
            if (_isSearching) _buildSearchBar(isTablet),
            
            // Calls List
            Expanded(
              child: _buildCallsList(isTablet, isDark),
            ),
          ],
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
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Calls',
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
                onPressed: () => _showCallOptions(context),
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

  Widget _buildSearchBar(bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search calls...',
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
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
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    size: isTablet ? 20 : 18,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            borderSide: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
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
          fillColor: isDark ? AppConfig.darkCard : Colors.grey.shade50,
        ),
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: isDark ? AppConfig.darkText : AppConfig.lightText,
        ),
      ),
    );
  }

  Widget _buildCallsList(bool isTablet, bool isDark) {
    if (_filteredCalls.isEmpty) {
      return _buildEmptyState(isTablet);
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 8,
      ),
      children: _filteredCalls.asMap().entries.map((entry) {
        final index = entry.key;
        final call = entry.value;
        return Column(
          children: [
            _buildCallTile(call, isTablet, isDark),
            if (index < _filteredCalls.length - 1)
              Divider(
                height: 1,
                color: (isDark ? AppConfig.darkTextSecondary : Colors.grey).withOpacity(0.1),
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
            _isSearching ? Icons.search_off : Icons.call_end,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching ? 'No calls found' : 'No calls yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching 
                ? 'Try adjusting your search terms'
                : 'Your call history will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isSearching) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showNewCallOptions(context),
              icon: const Icon(Icons.add_call, color: Colors.white),
              label: const Text(
                'Start call',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCallTile(Map<String, dynamic> call, bool isTablet, bool isDark) {
    final User contact = call['contact'];
    final CallType type = call['type'];
    final CallStatus status = call['status'];
    final Duration duration = call['duration'];
    final DateTime timestamp = call['timestamp'];
    final bool isIncoming = call['isIncoming'];

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 4 : 2),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
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
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(isTablet ? 4 : 3),
                decoration: BoxDecoration(
                  color: isDark ? AppConfig.darkSurface : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppConfig.darkCard : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Icon(
                  type == CallType.video ? Icons.videocam : Icons.call,
                  color: _getCallStatusColor(status),
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
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              _getCallDirectionIcon(status, isIncoming),
              color: _getCallStatusColor(status),
              size: isTablet ? 16 : 14,
            ),
            SizedBox(width: isTablet ? 6 : 4),
            Text(
              _getCallSubtitle(status, duration, timestamp),
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(timestamp),
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleCallAction(value, call),
              icon: Icon(
                Icons.more_vert,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                size: isTablet ? 20 : 18,
              ),
              tooltip: 'Call options',
              itemBuilder: (context) => [
                _buildMenuItem('call_back', 'Call back', Icons.call),
                _buildMenuItem('video_call', 'Video call', Icons.videocam),
                _buildMenuItem('message', 'Send message', Icons.message),
                _buildMenuItem('delete', 'Delete', Icons.delete, isDestructive: true),
              ],
            ),
          ],
        ),
        onTap: () => _callContact(contact, type),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    String text,
    IconData icon, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive
                ? AppConfig.errorColor
                : (isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781)),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isDestructive
                  ? AppConfig.errorColor
                  : (isDark ? AppConfig.darkText : const Color(0xFF111B21)),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCallDirectionIcon(CallStatus status, bool isIncoming) {
    switch (status) {
      case CallStatus.missed:
        return isIncoming ? Icons.call_received : Icons.call_made;
      case CallStatus.rejected:
        return Icons.call_received;
      case CallStatus.ended:
      case CallStatus.connected:
        return isIncoming ? Icons.call_received : Icons.call_made;
      case CallStatus.initial:
      case CallStatus.dialing:
      case CallStatus.incoming:
      case CallStatus.connecting:
      case CallStatus.failed:
        return isIncoming ? Icons.call_received : Icons.call_made;
    }
  }

  Color _getCallStatusColor(CallStatus status) {
    switch (status) {
      case CallStatus.missed:
      case CallStatus.rejected:
      case CallStatus.failed:
        return AppConfig.errorColor;
      case CallStatus.ended:
      case CallStatus.connected:
        return AppConfig.successColor;
      case CallStatus.initial:
      case CallStatus.dialing:
      case CallStatus.incoming:
      case CallStatus.connecting:
        return AppConfig.primaryColor;
    }
  }

  String _getCallSubtitle(CallStatus status, Duration duration, DateTime timestamp) {
    switch (status) {
      case CallStatus.missed:
        return 'Missed';
      case CallStatus.rejected:
        return 'Declined';
      case CallStatus.failed:
        return 'Failed';
      case CallStatus.ended:
      case CallStatus.connected:
        if (duration.inSeconds > 0) {
          return _formatDuration(duration);
        } else {
          return 'Call ended';
        }
      case CallStatus.initial:
        return 'Preparing...';
      case CallStatus.dialing:
        return 'Dialing...';
      case CallStatus.incoming:
        return 'Incoming call';
      case CallStatus.connecting:
        return 'Connecting...';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _callContact(User contact, CallType type) {
    Navigator.pushNamed(
      context,
      '/call',
      arguments: {
        'contact': contact,
        'isIncoming': false,
        'callType': type,
      },
    );
  }

  void _handleCallAction(String action, Map<String, dynamic> call) {
    final User contact = call['contact'];
    
    switch (action) {
      case 'call_back':
        _callContact(contact, CallType.voice);
        break;
      case 'video_call':
        _callContact(contact, CallType.video);
        break;
      case 'message':
        // Assuming Chat model is available or needs to be imported
        // For now, we'll just navigate to a placeholder
        Navigator.pushNamed(context, '/chat', arguments: {'contact': contact});
        break;
      case 'delete':
        _showDeleteCallDialog(call);
        break;
    }
  }

  void _showDeleteCallDialog(Map<String, dynamic> call) {
    final User contact = call['contact'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete call'),
        content: Text('Delete call with ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _callHistory.remove(call);
                _filteredCalls.remove(call);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Call with ${contact.name} deleted'),
                  backgroundColor: AppConfig.successColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewCallOptions(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNewCallBottomSheet(isTablet),
    );
  }

  Widget _buildNewCallBottomSheet(bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
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
                Text(
                  'Start a call',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),
                
                _buildCallOptionTile(
                  icon: Icons.call,
                  title: 'Voice call',
                  subtitle: 'Start a voice call with a contact',
                  onTap: () => _selectContactForCall(CallType.voice),
                  isTablet: isTablet,
                  isDark: isDark,
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
                
                _buildCallOptionTile(
                  icon: Icons.videocam,
                  title: 'Video call',
                  subtitle: 'Start a video call with a contact',
                  onTap: () => _selectContactForCall(CallType.video),
                  isTablet: isTablet,
                  isDark: isDark,
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          border: Border.all(
            color: AppConfig.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
              ),
              child: Icon(
                icon,
                color: AppConfig.primaryColor,
                size: isTablet ? 24 : 20,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                  SizedBox(height: isTablet ? 4 : 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: AppConfig.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppConfig.primaryColor,
              size: isTablet ? 18 : 16,
            ),
          ],
        ),
      ),
    );
  }

  void _selectContactForCall(CallType callType) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/contacts');
    // TODO: Pass call type to contacts screen and allow contact selection for calling
  }

  void _showCallOptions(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCallOptionsBottomSheet(isTablet),
    );
  }

  Widget _buildCallOptionsBottomSheet(bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
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
                    Icons.clear_all,
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  ),
                  title: Text(
                    'Clear call log',
                    style: TextStyle(
                      color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    ),
                  ),
                  onTap: () => _showClearCallLogDialog(),
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  ),
                  title: Text(
                    'Call settings',
                    style: TextStyle(
                      color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    ),
                  ),
                  onTap: () => _showFeatureComingSoon('Call Settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCallLogDialog() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear call log'),
        content: const Text(
          'This will delete your entire call history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _callHistory.clear();
                _filteredCalls.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Call log cleared'),
                  backgroundColor: AppConfig.successColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(color: AppConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureComingSoon(String feature) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature functionality will be available soon!'),
        backgroundColor: AppConfig.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}