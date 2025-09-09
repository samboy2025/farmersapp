import 'package:flutter/material.dart';
import '../../models/status.dart';


class StatusViewerControls extends StatelessWidget {
  final Status status;
  final VoidCallback? onMenuTap;
  final VoidCallback? onReplyTap;
  final VoidCallback? onForwardTap;
  final VoidCallback? onMuteTap;
  final VoidCallback? onDeleteTap;
  final bool showReplyInput;
  final TextEditingController? replyController;
  final VoidCallback? onSendReply;

  const StatusViewerControls({
    super.key,
    required this.status,
    this.onMenuTap,
    this.onReplyTap,
    this.onForwardTap,
    this.onMuteTap,
    this.onDeleteTap,
    this.showReplyInput = false,
    this.replyController,
    this.onSendReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top controls
            _buildTopControls(),
            
            const Spacer(),
            
            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Profile info
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: status.author.profilePicture != null
                        ? Image.network(
                            status.author.profilePicture!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.author.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        status.timeAgo,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Menu button
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: onMenuTap ?? () => _showMenuOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Reply input (if enabled)
          if (showReplyInput) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      decoration: const InputDecoration(
                        hintText: 'Reply to status...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: onSendReply,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reply button
              _buildActionButton(
                icon: Icons.reply,
                label: 'Reply',
                onTap: onReplyTap,
              ),
              
              // Forward button
              _buildActionButton(
                icon: Icons.forward,
                label: 'Forward',
                onTap: onForwardTap,
              ),
              
              // Reaction button
              _buildActionButton(
                icon: Icons.favorite_border,
                label: 'React',
                onTap: () => _showReactionOptions(),
              ),
              
              // More options
              _buildActionButton(
                icon: Icons.more_horiz,
                label: 'More',
                onTap: onMenuTap ?? () => _showMenuOptions(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 20,
        color: Colors.grey,
      ),
    );
  }

  void _showMenuOptions() {
    // This will be handled by the parent widget
  }

  void _showReactionOptions() {
    // TODO: Show reaction picker
  }
}
