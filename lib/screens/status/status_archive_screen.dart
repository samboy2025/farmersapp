import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/status/status_bloc.dart';
import '../../config/app_config.dart';
import '../../models/status.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import '../../services/status_service.dart';
import 'status_view_screen.dart';
import 'status_analytics_screen.dart';

class StatusArchiveScreen extends StatefulWidget {
  const StatusArchiveScreen({super.key});

  @override
  State<StatusArchiveScreen> createState() => _StatusArchiveScreenState();
}

class _StatusArchiveScreenState extends State<StatusArchiveScreen> {
  final StatusService _statusService = StatusService();
  List<Status> _archivedStatuses = [];
  String _selectedFilter = 'all';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadArchivedStatuses();
  }

  Future<void> _loadArchivedStatuses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allStatuses = MockDataService.statuses;
      _archivedStatuses = _statusService.getStatusArchive(allStatuses);
      _applyFilter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load archived statuses: $e'),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    final allStatuses = MockDataService.statuses;
    List<Status> filteredStatuses = _statusService.getStatusArchive(allStatuses);

    switch (_selectedFilter) {
      case 'images':
        filteredStatuses = filteredStatuses.where((s) => s.isImage).toList();
        break;
      case 'videos':
        filteredStatuses = filteredStatuses.where((s) => s.isVideo).toList();
        break;
      case 'text':
        filteredStatuses = filteredStatuses.where((s) => s.isText).toList();
        break;
      case 'recent':
        filteredStatuses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        filteredStatuses = filteredStatuses.take(10).toList();
        break;
      case 'oldest':
        filteredStatuses.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        filteredStatuses = filteredStatuses.take(10).toList();
        break;
    }

    setState(() {
      _archivedStatuses = filteredStatuses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Status Archive',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatusAnalyticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _archivedStatuses.isEmpty
                    ? _buildEmptyState()
                    : _buildArchiveList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Statuses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All', Icons.all_inclusive),
                const SizedBox(width: 8),
                _buildFilterChip('images', 'Images', Icons.image),
                const SizedBox(width: 8),
                _buildFilterChip('videos', 'Videos', Icons.videocam),
                const SizedBox(width: 8),
                _buildFilterChip('text', 'Text', Icons.text_fields),
                const SizedBox(width: 8),
                _buildFilterChip('recent', 'Recent', Icons.access_time),
                const SizedBox(width: 8),
                _buildFilterChip('oldest', 'Oldest', Icons.history),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _applyFilter();
      },
      backgroundColor: Colors.grey[100],
      selectedColor: AppConfig.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No archived statuses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Expired statuses will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveList() {
    return RefreshIndicator(
      onRefresh: _loadArchivedStatuses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _archivedStatuses.length,
        itemBuilder: (context, index) {
          final status = _archivedStatuses[index];
          return _buildArchiveItem(status);
        },
      ),
    );
  }

  Widget _buildArchiveItem(Status status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _viewStatus(status),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status thumbnail
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: status.thumbnailUrl != null
                        ? Image.network(
                            status.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildStatusIcon(status);
                            },
                          )
                        : _buildStatusIcon(status),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Status info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              status.author.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusTypeColor(status.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusTypeText(status.type),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getStatusTypeColor(status.type),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      if (status.caption != null) ...[
                        Text(
                          status.caption!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expired ${status.timeAgo}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${status.viewCount} views',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Action button
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showStatusOptions(status),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(Status status) {
    IconData icon;
    Color color;
    
    switch (status.type) {
      case StatusType.image:
        icon = Icons.image;
        color = Colors.blue;
        break;
      case StatusType.video:
        icon = Icons.videocam;
        color = Colors.red;
        break;
      case StatusType.text:
        icon = Icons.text_fields;
        color = Colors.green;
        break;
    }
    
    return Icon(
      icon,
      color: color,
      size: 24,
    );
  }

  String _getStatusTypeText(StatusType type) {
    switch (type) {
      case StatusType.image:
        return 'PHOTO';
      case StatusType.video:
        return 'VIDEO';
      case StatusType.text:
        return 'TEXT';
    }
  }

  Color _getStatusTypeColor(StatusType type) {
    switch (type) {
      case StatusType.image:
        return Colors.blue;
      case StatusType.video:
        return Colors.red;
      case StatusType.text:
        return Colors.green;
    }
  }

  void _viewStatus(Status status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusViewScreen(
          statuses: [status],
          initialIndex: 0,
        ),
      ),
    );
  }

  void _showStatusOptions(Status status) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Status'),
              onTap: () {
                Navigator.pop(context);
                _viewStatus(status);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('View Analytics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatusAnalyticsScreen(status: status),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Status'),
              onTap: () {
                Navigator.pop(context);
                _shareStatus(status);
              },
            ),
            if (status.author.id == MockDataService.currentUser.id)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteStatus(status);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _shareStatus(Status status) {
    // In a real app, this would share the status
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status shared successfully!'),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }

  void _deleteStatus(Status status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Status'),
        content: const Text(
          'This status will be permanently deleted and cannot be recovered. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _statusService.deleteStatus(status);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Status deleted permanently!'),
                    backgroundColor: AppConfig.successColor,
                  ),
                );
                _loadArchivedStatuses();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
