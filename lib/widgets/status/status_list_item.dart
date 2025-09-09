import 'package:flutter/material.dart';
import '../../models/status.dart';
import '../../models/user.dart';

class StatusListItem extends StatelessWidget {
  final User user;
  final List<Status> statuses;
  final VoidCallback onTap;
  final bool isViewed;

  const StatusListItem({
    super.key,
    required this.user,
    required this.statuses,
    required this.onTap,
    this.isViewed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) return const SizedBox.shrink();
    
    final latestStatus = statuses.first;
    final hasUnviewed = statuses.any((s) => !s.viewed);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar with status indicator
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasUnviewed ? Colors.blue : Colors.grey[300]!,
                          width: hasUnviewed ? 3 : 1,
                        ),
                      ),
                      child: ClipOval(
                        child: latestStatus.thumbnailUrl != null
                            ? Image.network(
                                latestStatus.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar();
                                },
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                    
                    // Status type indicator
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                        child: Icon(
                          latestStatus.isVideo ? Icons.play_arrow : Icons.image,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 12),
                
                // Status info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: hasUnviewed ? FontWeight.w600 : FontWeight.w500,
                                color: hasUnviewed ? Colors.black87 : Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (statuses.length > 1) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statuses.length.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          Text(
                            latestStatus.timeAgo,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (latestStatus.caption != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                latestStatus.caption!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // View indicator
                if (hasUnviewed)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 25,
        color: Colors.grey,
      ),
    );
  }
}
