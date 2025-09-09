import 'package:flutter/material.dart';
import '../../models/status.dart';


class MyStatusCard extends StatelessWidget {
  final List<Status> statuses;
  final VoidCallback onTap;
  final VoidCallback onAddTap;

  const MyStatusCard({
    super.key,
    required this.statuses,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveStatus = statuses.any((s) => s.isActive);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Avatar with status indicator
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasActiveStatus ? Colors.blue : Colors.grey[300]!,
                      width: hasActiveStatus ? 3 : 1,
                    ),
                  ),
                  child: ClipOval(
                    child: hasActiveStatus && statuses.first.thumbnailUrl != null
                        ? Image.network(
                            statuses.first.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
                
                // Add button overlay
                if (!hasActiveStatus)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onAddTap,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Status info
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        hasActiveStatus ? 'My Status' : 'Add to my story',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: hasActiveStatus ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                      if (hasActiveStatus) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statuses.length.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  if (hasActiveStatus) ...[
                    const SizedBox(height: 4),
                    Text(
                      statuses.first.timeAgo,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tap to add a photo or video',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Action buttons
          if (hasActiveStatus) ...[
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showStatusOptions(context);
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: onAddTap,
              color: Colors.blue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 30,
        color: Colors.grey,
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
              leading: const Icon(Icons.edit),
              title: const Text('Edit Status'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to status editing
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Status'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Status'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share status
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Status'),
        content: const Text('Are you sure you want to delete this status? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete status
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
