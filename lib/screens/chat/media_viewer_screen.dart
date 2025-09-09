import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/app_config.dart';
import '../../../models/message.dart';

class MediaViewerScreen extends StatefulWidget {
  final Message message;
  final List<Message> mediaMessages;
  final int initialIndex;

  const MediaViewerScreen({
    super.key,
    required this.message,
    required this.mediaMessages,
    this.initialIndex = 0,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.mediaMessages.length,
            itemBuilder: (context, index) {
              final message = widget.mediaMessages[index];
              return _buildMediaContent(message);
            },
          ),
          
          // Top app bar
          if (!_isFullScreen) _buildTopAppBar(),
          
          // Bottom controls
          if (!_isFullScreen) _buildBottomControls(),
          
          // Media counter
          if (!_isFullScreen) _buildMediaCounter(),
        ],
      ),
    );
  }

  Widget _buildMediaContent(Message message) {
    switch (message.type) {
      case MessageType.image:
        return _buildImageViewer(message);
      case MessageType.video:
        return _buildVideoViewer(message);
      default:
        return const Center(
          child: Text(
            'Unsupported media type',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }

  Widget _buildImageViewer(Message message) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFullScreen = !_isFullScreen;
        });
      },
      onDoubleTap: () {
        // TODO: Implement zoom functionality
      },
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: Center(
          child: message.mediaUrl != null
              ? CachedNetworkImage(
                  imageUrl: message.mediaUrl!,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                )
              : const Icon(
                  Icons.image_not_supported,
                  color: Colors.white,
                  size: 64,
                ),
        ),
      ),
    );
  }

  Widget _buildVideoViewer(Message message) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFullScreen = !_isFullScreen;
        });
      },
      child: Center(
        child: message.mediaUrl != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  // Video thumbnail or video player
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: message.mediaUrl!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                  
                  // Play button overlay
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ],
              )
            : const Icon(
                Icons.videocam_off,
                color: Colors.white,
                size: 64,
              ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _shareMedia(),
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => _downloadMedia(),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () => _showMoreOptions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message content if any
            if (widget.mediaMessages[_currentIndex].content.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.mediaMessages[_currentIndex].content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Media info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getMediaInfo(widget.mediaMessages[_currentIndex]),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${_currentIndex + 1} of ${widget.mediaMessages.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCounter() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '${_currentIndex + 1} / ${widget.mediaMessages.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getMediaInfo(Message message) {
    switch (message.type) {
      case MessageType.image:
        return 'Image • ${_formatFileSize(message.fileSize ?? 0)}';
      case MessageType.video:
        return 'Video • ${_formatFileSize(message.fileSize ?? 0)}';
      default:
        return 'Media';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _shareMedia() {
    final currentMessage = widget.mediaMessages[_currentIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text(
                'Share Media',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _performShare();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.message,
                  color: Colors.blue,
                ),
              ),
              title: const Text(
                'Send to Chat',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _sendToChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadMedia() {
    final currentMessage = widget.mediaMessages[_currentIndex];

    // Simulate download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Downloading media...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Simulate download completion
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Media downloaded successfully'),
            backgroundColor: AppConfig.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  void _performShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing media...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _sendToChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Select a chat to send the media'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Media info'),
              onTap: () {
                Navigator.pop(context);
                _showMediaInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaInfo() {
    final message = widget.mediaMessages[_currentIndex];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Media Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${message.type.name.toUpperCase()}'),
            if (message.fileName != null) Text('Name: ${message.fileName}'),
            if (message.fileSize != null) Text('Size: ${_formatFileSize(message.fileSize!)}'),
            Text('Sent: ${_formatTimestamp(message.timestamp)}'),
            if (message.sender != null) Text('From: ${message.sender.name}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
