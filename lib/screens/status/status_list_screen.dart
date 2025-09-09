import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/status/status_bloc.dart';
import '../../models/status.dart';
import '../../models/user.dart';
import '../../widgets/status/my_status_card.dart';
import '../../widgets/status/status_list_item.dart';
import '../../services/status_service.dart';

import 'status_view_screen.dart';
import 'status_creation_screen.dart';
import 'status_analytics_screen.dart';
import 'status_archive_screen.dart';
import 'status_privacy_settings_screen.dart';
import '../../config/app_config.dart';

class StatusListScreen extends StatefulWidget {
  const StatusListScreen({super.key});

  @override
  State<StatusListScreen> createState() => _StatusListScreenState();
}

class _StatusListScreenState extends State<StatusListScreen> {
  final StatusService _statusService = StatusService();

  @override
  void initState() {
    super.initState();
    // Fetch statuses when screen loads
    context.read<StatusBloc>().add(const StatusFetched());
    _statusService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.lightBackground,
      body: BlocBuilder<StatusBloc, StatusState>(
        builder: (context, state) {
          if (state is StatusLoadInProgress) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppConfig.primaryColor,
              ),
            );
          }
          
          if (state is StatusOperationFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppConfig.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load statuses',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppConfig.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConfig.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StatusBloc>().add(const StatusFetched());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is StatusLoadSuccess) {
            return _buildStatusList(state);
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 64,
                  color: AppConfig.lightTextSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No statuses available',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConfig.lightText,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _createNewStatus,
                  icon: const Icon(Icons.add),
                  label: const Text('Create First Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewStatus,
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt, size: 28),
      ),
    );
  }

  Widget _buildStatusList(StatusLoadSuccess state) {
    final myStatuses = state.myStatuses;
    final otherStatuses = state.statusUpdates;
    
    // Separate statuses into recent (unviewed) and viewed
    final recentStatuses = <User, List<Status>>{};
    final viewedStatuses = <User, List<Status>>{};
    
    for (final entry in otherStatuses.entries) {
      final user = entry.key;
      final statuses = entry.value.where((s) => s.isActive).toList();
      
      if (statuses.isNotEmpty) {
        final hasUnviewed = statuses.any((s) => !s.viewed);
        if (hasUnviewed) {
          recentStatuses[user] = statuses;
        } else {
          viewedStatuses[user] = statuses;
        }
      }
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<StatusBloc>().add(const StatusFetched());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // My Status Section
          if (myStatuses.isNotEmpty || true) // Always show for now
            MyStatusCard(
              statuses: myStatuses,
              onTap: () {
                if (myStatuses.isNotEmpty) {
                  _viewMyStatuses(myStatuses);
                } else {
                  _createNewStatus();
                }
              },
              onAddTap: _createNewStatus,
            ),
          
          const SizedBox(height: 24),
          
          // Recent Updates Section
          if (recentStatuses.isNotEmpty) ...[
            _buildSectionHeader('Recent Updates', recentStatuses.length),
            const SizedBox(height: 12),
            ...recentStatuses.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StatusListItem(
                  user: entry.key,
                  statuses: entry.value,
                  onTap: () => _viewUserStatuses(entry.value),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
          ],
          
          // Viewed Updates Section
          if (viewedStatuses.isNotEmpty) ...[
            _buildSectionHeader('Viewed Updates', viewedStatuses.length),
            const SizedBox(height: 12),
            ...viewedStatuses.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StatusListItem(
                  user: entry.key,
                  statuses: entry.value,
                  onTap: () => _viewUserStatuses(entry.value),
                  isViewed: true,
                ),
              );
            }).toList(),
          ],
          
          // Empty state if no statuses
          if (recentStatuses.isEmpty && viewedStatuses.isEmpty) ...[
            const SizedBox(height: 48),
            _buildEmptyState(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConfig.darkText,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppConfig.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppConfig.accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.photo_camera_outlined,
          size: 64,
          color: AppConfig.lightTextSecondary,
        ),
        const SizedBox(height: 16),
        Text(
          'No status updates yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Be the first to share a moment!',
          style: TextStyle(
            fontSize: 14,
            color: AppConfig.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _createNewStatus,
          icon: const Icon(Icons.add),
          label: const Text('Create Status'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _viewMyStatuses(List<Status> statuses) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusViewScreen(
          statuses: statuses,
          initialIndex: 0,
        ),
      ),
    );
  }

  void _viewUserStatuses(List<Status> statuses) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusViewScreen(
          statuses: statuses,
          initialIndex: 0,
        ),
      ),
    );
  }

  void _createNewStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StatusCreationScreen(),
      ),
    );
  }

  void _showStatusOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Status Archive'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatusArchiveScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Status Analytics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatusAnalyticsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Status Privacy'),
              onTap: () {
                Navigator.pop(context);
                _showPrivacySettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Status Help'),
              onTap: () {
                Navigator.pop(context);
                _showStatusHelp();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status Privacy Settings'),
        content: const Text(
          'Configure who can see your status updates. You can set default privacy for new statuses and manage existing ones.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to privacy settings screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatusPrivacySettingsScreen(),
                ),
              );
            },
            child: const Text('Configure'),
          ),
        ],
      ),
    );
  }

  void _showStatusHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status Help'),
        content: const Text(
          'Status updates are temporary posts that disappear after 24 hours. You can share photos, videos, or text with your contacts.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
