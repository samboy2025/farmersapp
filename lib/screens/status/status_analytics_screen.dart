import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/status.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import '../../services/status_service.dart';

class StatusAnalyticsScreen extends StatefulWidget {
  final Status? status; // If null, show overall analytics

  const StatusAnalyticsScreen({
    super.key,
    this.status,
  });

  @override
  State<StatusAnalyticsScreen> createState() => _StatusAnalyticsScreenState();
}

class _StatusAnalyticsScreenState extends State<StatusAnalyticsScreen> {
  final StatusService _statusService = StatusService();
  Map<String, dynamic>? _analytics;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (widget.status != null) {
      _analytics = _statusService.getStatusAnalytics(widget.status!);
    } else {
      _analytics = _getOverallAnalytics();
    }
    setState(() {});
  }

  Map<String, dynamic> _getOverallAnalytics() {
    final allStatuses = MockDataService.statuses;
    final activeStatuses = _statusService.getActiveStatuses(allStatuses);
    final expiredStatuses = _statusService.getStatusArchive(allStatuses);
    
    int totalViews = 0;
    int totalReactions = 0;
    int totalActive = activeStatuses.length;
    int totalExpired = expiredStatuses.length;
    
    for (final status in allStatuses) {
      totalViews += status.viewCount;
      totalReactions += status.reactions.length;
    }

    return {
      'totalStatuses': allStatuses.length,
      'activeStatuses': totalActive,
      'expiredStatuses': totalExpired,
      'totalViews': totalViews,
      'totalReactions': totalReactions,
      'averageViews': allStatuses.isNotEmpty ? totalViews / allStatuses.length : 0,
      'averageReactions': allStatuses.isNotEmpty ? totalReactions / allStatuses.length : 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.status != null ? 'Status Analytics' : 'Overall Analytics',
          style: const TextStyle(
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
            icon: const Icon(Icons.share),
            onPressed: _shareAnalytics,
          ),
        ],
      ),
      body: _analytics == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 20),
                    _buildMetricsGrid(),
                    const SizedBox(height: 20),
                    _buildDetailedMetrics(),
                    const SizedBox(height: 20),
                    _buildStatusBreakdown(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    final isOverall = widget.status == null;
    final title = isOverall ? 'Overall Performance' : 'Status Performance';
    final subtitle = isOverall 
        ? 'Analytics for all your statuses'
        : 'Detailed insights for this status';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConfig.primaryColor,
            AppConfig.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          if (widget.status != null) ...[
            const SizedBox(height: 16),
            _buildStatusPreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusPreview() {
    final status = widget.status!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.3),
            ),
            child: status.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      status.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          status.isVideo ? Icons.videocam : Icons.image,
                          color: Colors.white,
                          size: 24,
                        );
                      },
                    ),
                  )
                : Icon(
                    status.isVideo ? Icons.videocam : Icons.image,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.caption ?? 'No caption',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  status.timeAgo,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = _analytics!;
    final isOverall = widget.status == null;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          title: 'Views',
          value: metrics['totalViews']?.toString() ?? '0',
          icon: Icons.visibility,
          color: Colors.blue,
          subtitle: isOverall ? 'Total views' : 'Status views',
        ),
        _buildMetricCard(
          title: 'Reactions',
          value: metrics['totalReactions']?.toString() ?? '0',
          icon: Icons.favorite,
          color: Colors.red,
          subtitle: isOverall ? 'Total reactions' : 'Status reactions',
        ),
        _buildMetricCard(
          title: isOverall ? 'Active' : 'Duration',
          value: isOverall 
              ? (metrics['activeStatuses']?.toString() ?? '0')
              : _formatDuration(),
          icon: isOverall ? Icons.trending_up : Icons.timer,
          color: Colors.green,
          subtitle: isOverall ? 'Active statuses' : 'Time active',
        ),
        _buildMetricCard(
          title: 'Engagement',
          value: _calculateEngagementRate(),
          icon: Icons.analytics,
          color: Colors.orange,
          subtitle: 'Engagement rate',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    final metrics = _analytics!;
    final isOverall = widget.status == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          _buildMetricRow(
            label: 'Status Type',
            value: isOverall ? 'Mixed' : _getStatusTypeText(),
            icon: Icons.category,
          ),
          _buildMetricRow(
            label: 'Privacy',
            value: isOverall ? 'Mixed' : _getPrivacyText(),
            icon: Icons.visibility,
          ),
          _buildMetricRow(
            label: 'Created',
            value: isOverall ? 'Various' : _formatDate(),
            icon: Icons.schedule,
          ),
          if (isOverall) ...[
            _buildMetricRow(
              label: 'Average Views',
              value: metrics['averageViews']?.toStringAsFixed(1) ?? '0',
              icon: Icons.trending_up,
            ),
            _buildMetricRow(
              label: 'Average Reactions',
              value: metrics['averageReactions']?.toStringAsFixed(1) ?? '0',
              icon: Icons.favorite_border,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    if (widget.status != null) return const SizedBox.shrink();

    final allStatuses = MockDataService.statuses;
    final statusTypes = <StatusType, int>{};
    final privacyLevels = <StatusPrivacy, int>{};

    for (final status in allStatuses) {
      statusTypes[status.type] = (statusTypes[status.type] ?? 0) + 1;
      privacyLevels[status.privacy] = (privacyLevels[status.privacy] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildBreakdownCard(
                title: 'By Type',
                data: statusTypes.map((key, value) => MapEntry(_getStatusTypeText(key), value)),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBreakdownCard(
                title: 'By Privacy',
                data: privacyLevels.map((key, value) => MapEntry(_getPrivacyText(key), value)),
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownCard({
    required String title,
    required Map<String, int> data,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...data.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _getStatusTypeText([StatusType? type]) {
    if (type == null && widget.status != null) {
      type = widget.status!.type;
    }
    
    switch (type) {
      case StatusType.image:
        return 'Image';
      case StatusType.video:
        return 'Video';
      case StatusType.text:
        return 'Text';
      default:
        return 'Unknown';
    }
  }

  String _getPrivacyText([StatusPrivacy? privacy]) {
    if (privacy == null && widget.status != null) {
      privacy = widget.status!.privacy;
    }
    
    switch (privacy) {
      case StatusPrivacy.public:
        return 'Public';
      case StatusPrivacy.contactsOnly:
        return 'Contacts Only';
      case StatusPrivacy.custom:
        return 'Custom';
      default:
        return 'Unknown';
    }
  }

  String _formatDate() {
    if (widget.status == null) return '';
    return '${widget.status!.createdAt.day}/${widget.status!.createdAt.month}/${widget.status!.createdAt.year}';
  }

  String _formatDuration() {
    if (widget.status == null) return '';
    final now = DateTime.now();
    final diff = now.difference(widget.status!.createdAt);
    
    if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  String _calculateEngagementRate() {
    final metrics = _analytics!;
    final views = metrics['totalViews'] ?? 0;
    final reactions = metrics['totalReactions'] ?? 0;
    
    if (views == 0) return '0%';
    
    final rate = (reactions / views) * 100;
    return '${rate.toStringAsFixed(1)}%';
  }

  void _shareAnalytics() {
    // In a real app, this would share the analytics
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics shared successfully!'),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }
}
