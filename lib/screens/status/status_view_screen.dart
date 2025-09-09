import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/status.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import 'status_reply_screen.dart';
import 'status_forward_screen.dart';

class StatusViewScreen extends StatefulWidget {
  final List<Status> statuses;
  final int initialIndex;

  const StatusViewScreen({
    super.key,
    required this.statuses,
    this.initialIndex = 0,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late List<Status> _statuses;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _statuses = widget.statuses;
    _pageController = PageController(initialPage: _currentIndex);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (_statuses.isNotEmpty) {
      _autoPlayNext();
    }
  }

  void _autoPlayNext() {
    if (!_isPaused && _currentIndex < _statuses.length - 1) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_isPaused) {
          _nextStatus();
        }
      });
    }
  }

  void _nextStatus() {
    if (_currentIndex < _statuses.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _autoPlayNext();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStatus() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _togglePause(),
        onTapUp: (_) => _togglePause(),
        onPanEnd: (details) => _handleSwipeGesture(details),
        child: Stack(
          children: [
            // Status content
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _autoPlayNext();
              },
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                return _buildStatusView(_statuses[index], isTablet);
              },
            ),
            
            // Top bar with all controls
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(isTablet),
            ),
            
            // Progress indicators
            Positioned(
              top: isTablet ? 100 : 80, // Position below the top bar
              left: isTablet ? 24 : 16,
              right: isTablet ? 24 : 16,
              child: _buildProgressIndicators(isTablet),
            ),
            
            // Navigation hints for tablets
            if (isTablet) ...[
              _buildNavigationArea(context, isLeft: true),
              _buildNavigationArea(context, isLeft: false),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationArea(BuildContext context, {required bool isLeft}) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      width: 80,
      child: GestureDetector(
        onTap: isLeft ? _previousStatus : _nextStatus,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLeft ? Icons.chevron_left : Icons.chevron_right,
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusView(Status status, bool isTablet) {
    if (status.mediaUrl != null) {
      return _buildImageStatus(status, isTablet);
    } else {
      return _buildTextStatus(status, isTablet);
    }
  }

  Widget _buildImageStatus(Status status, bool isTablet) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              status.mediaUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade900,
                  child: Icon(
                    Icons.broken_image,
                    size: isTablet ? 120 : 80,
                    color: Colors.white54,
                  ),
                );
              },
            ),
          ),
          
          // Text overlay if any
          if (status.caption != null && status.caption!.isNotEmpty)
            Positioned(
              bottom: isTablet ? 140 : 100,
              left: isTablet ? 40 : 20,
              right: isTablet ? 40 : 20,
              child: Container(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  status.caption!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextStatus(Status status, bool isTablet) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConfig.primaryColor,
            AppConfig.primaryColor.withOpacity(0.8),
            AppConfig.secondaryColor,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 60 : 40),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              status.caption ?? 'No text content',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 36 : 28,
                fontWeight: FontWeight.w600,
                height: 1.4,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isTablet) {
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (isTablet ? 20 : 16),
        left: isTablet ? 24 : 16,
        right: isTablet ? 24 : 16,
        bottom: isTablet ? 20 : 16,
      ),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back, 
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
              onPressed: () => Navigator.pop(context),
              constraints: BoxConstraints(
                minWidth: isTablet ? 48 : 44,
                minHeight: isTablet ? 48 : 44,
              ),
              splashRadius: isTablet ? 24 : 20,
            ),
          ),
          
          SizedBox(width: isTablet ? 20 : 16),
          
          // User info
          Expanded(
            child: _buildUserInfo(isTablet),
          ),
          
          // Play/Pause button
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
                size: isTablet ? 36 : 32,
              ),
              onPressed: _togglePause,
              constraints: BoxConstraints(
                minWidth: isTablet ? 52 : 48,
                minHeight: isTablet ? 52 : 48,
              ),
              splashRadius: isTablet ? 26 : 24,
            ),
          ),
          
          SizedBox(width: isTablet ? 16 : 12),
          
          // More options
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert, 
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
              onPressed: _showMoreOptions,
              constraints: BoxConstraints(
                minWidth: isTablet ? 48 : 44,
                minHeight: isTablet ? 48 : 44,
              ),
              splashRadius: isTablet ? 24 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(bool isTablet) {
    final status = _statuses[_currentIndex];
    final user = status.author;
    
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: isTablet ? 24 : 20,
            backgroundColor: AppConfig.primaryColor,
            backgroundImage: user.profilePicture != null
                ? NetworkImage(user.profilePicture!)
                : null,
            child: user.profilePicture == null
                ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isTablet ? 4 : 2),
              Text(
                _formatTime(status.createdAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicators(bool isTablet) {
    return Row(
      children: List.generate(_statuses.length, (index) {
        return Expanded(
          child: Container(
            height: isTablet ? 4 : 3,
            margin: EdgeInsets.only(
              right: index < _statuses.length - 1 ? (isTablet ? 6 : 4) : 0,
            ),
            decoration: BoxDecoration(
              color: index <= _currentIndex
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }



  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (!_isPaused) {
      _autoPlayNext();
    }
  }

  void _handleSwipeGesture(DragEndDetails details) {
    final velocityX = details.velocity.pixelsPerSecond.dx;

    if (velocityX > 500) {
      _nextStatus();
    } else if (velocityX < -500) {
      _previousStatus();
    }
  }

  void _showMoreOptions() {
    final status = _statuses[_currentIndex];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                _replyToStatus(status);
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Forward'),
              onTap: () {
                Navigator.pop(context);
                _forwardStatus(status);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                _copyStatus(status);
              },
            ),
            if (status.author.id == MockDataService.currentUser.id)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
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

  void _replyToStatus(Status status) {
    Navigator.pop(context);

    // Get the author of the status
    final author = MockDataService.users.firstWhere(
      (user) => user.id == status.userId,
      orElse: () => MockDataService.users[0],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusReplyScreen(
          status: status,
          author: author,
        ),
      ),
    );
  }

  void _forwardStatus(Status status) {
    Navigator.pop(context);

    // Get the author of the status
    final author = MockDataService.users.firstWhere(
      (user) => user.id == status.userId,
      orElse: () => MockDataService.users[0],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusForwardScreen(
          status: status,
          author: author,
        ),
      ),
    );
  }

  void _copyStatus(Status status) {
    Navigator.pop(context);
    if (status.caption != null) {
      // Copy text to clipboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status copied to clipboard!')),
      );
    }
  }

  void _deleteStatus(Status status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Status'),
        content: const Text('Are you sure you want to delete this status?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would delete the status
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status deleted!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}
