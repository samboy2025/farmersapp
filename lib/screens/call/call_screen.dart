import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';
import '../../blocs/call/call_bloc.dart';
import '../../config/app_config.dart';
import '../../models/call.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

// Call Ended Screen
class CallEndedScreen extends StatefulWidget {
  final Call call;
  final Duration duration;
  final CallEndReason reason;
  final VoidCallback onClose;

  const CallEndedScreen({
    super.key,
    required this.call,
    required this.duration,
    required this.reason,
    required this.onClose,
  });

  @override
  State<CallEndedScreen> createState() => _CallEndedScreenState();
}

class _CallEndedScreenState extends State<CallEndedScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  int _rating = 0;
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _getReasonText(CallEndReason reason) {
    switch (reason) {
      case CallEndReason.hungUp:
        return 'Call ended';
      case CallEndReason.rejected:
        return 'Call declined';
      case CallEndReason.networkError:
        return 'Network error';
      case CallEndReason.userBusy:
        return 'User busy';
      case CallEndReason.noAnswer:
        return 'No answer';
      case CallEndReason.callEnded:
        return 'Call ended';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = MockDataService.getUserById(widget.call.callerId == MockDataService.currentUser.id
        ? widget.call.receiverId
        : widget.call.callerId);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Call Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Call result icon and text
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: widget.reason == CallEndReason.hungUp
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.reason == CallEndReason.hungUp
                                  ? Icons.call_end
                                  : Icons.call_missed,
                              color: widget.reason == CallEndReason.hungUp
                                  ? Colors.green
                                  : Colors.orange,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getReasonText(widget.reason),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // User info
                    if (user != null) ...[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppConfig.primaryColor,
                        backgroundImage: user.profilePicture != null
                            ? NetworkImage(user.profilePicture!)
                            : null,
                        child: user.profilePicture == null
                            ? Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.call.type == CallType.voice ? 'Voice Call' : 'Video Call',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Call duration and stats
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Duration
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: isDark ? Colors.white70 : Colors.grey.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatDuration(widget.duration),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                  fontFeatures: [const FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Call stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(
                                icon: Icons.network_cell,
                                label: 'Connection',
                                value: 'Excellent',
                                color: Colors.green,
                              ),
                              _buildStatItem(
                                icon: Icons.data_usage,
                                label: 'Data Used',
                                value: '${(widget.duration.inSeconds * 0.5).toStringAsFixed(1)} MB',
                                color: AppConfig.primaryColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Call time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.today,
                                color: isDark ? Colors.white70 : Colors.grey.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.call.startTime.day}/${widget.call.startTime.month}/${widget.call.startTime.year} at ${_formatTime(widget.call.startTime)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Rating section
                    if (!_showFeedback) ...[
                      Text(
                        'How was the call quality?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = index + 1;
                                _showFeedback = true;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                index < _rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 32,
                              ),
                            ),
                          );
                        }),
                      ),
                    ] else ...[
                      // Feedback section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Thanks for your feedback! We\'re glad you had a good experience.',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Call again
                              widget.onClose();
                              // Navigate back to call screen
                            },
                            icon: const Icon(Icons.call),
                            label: const Text('Call Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Send message
                              widget.onClose();
                              // Navigate to chat
                            },
                            icon: const Icon(Icons.message),
                            label: const Text('Message'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppConfig.primaryColor,
                              ),
                              foregroundColor: AppConfig.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: widget.onClose,
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  }
}

class CallScreen extends StatefulWidget {
  final Call? call;
  final User? receiver;
  final bool isIncoming;
  final CallType callType;

  const CallScreen({
    super.key,
    this.call,
    this.receiver,
    this.isIncoming = false,
    this.callType = CallType.voice,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _ringController;
  late AnimationController _fadeController;
  late AnimationController _bounceController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _ringAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  // WebRTC renderers
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // Call state
  Duration _callDuration = Duration.zero;
  late DateTime _callStartTime;
  Timer? _callTimer;

  // Call statistics
  double _callQuality = 0.95;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _initializeAnimations();
    
    if (widget.isIncoming) {
      _playIncomingCallSound();
    }
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _initializeAnimations() {
    // Pulse animation for incoming calls
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Slide animation for controls
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Scale animation for call connection
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Ring animation for incoming calls
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Fade animation for transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Bounce animation for call buttons
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Initialize animations
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _ringAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    // Start initial animations
    _slideController.forward();
    _fadeController.forward();

    if (widget.isIncoming) {
      _pulseController.repeat(reverse: true);
      _ringController.repeat(reverse: true);
    } else {
      _scaleController.forward();
    }
  }

  void _startCallTimer() {
    _callStartTime = DateTime.now();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime);
        });
      }
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  void _playIncomingCallSound() {
    // In a real app, this would play an actual ringtone
    // For now, we'll just show a visual indicator
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _ringController.dispose();
    _fadeController.dispose();
    _bounceController.dispose();
    _stopCallTimer();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Keep call screen dark for better UX
      body: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallEnded) {
            _stopCallTimer();
            _showCallEndedDialog(state);
          } else if (state is CallFailed) {
            _stopCallTimer();
            _showCallFailedDialog(state);
          } else if (state is CallConnected) {
            _startCallTimer();
          }
        },
        child: BlocBuilder<CallBloc, CallState>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  // Top section with call info
                  _buildCallHeader(state),
                  
                  const Spacer(),
                  
                  // Call controls
                  _buildCallControls(state),
                  
                  // Bottom section
                  _buildBottomSection(state),
                  
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCallHeader(CallState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    User? user;
    String statusText = '';
    IconData statusIcon = Icons.hourglass_empty;

    if (state is CallDialing) {
      user = state.receiver;
      statusText = 'Calling...';
      statusIcon = Icons.call_made;
    } else if (state is CallIncoming) {
      user = state.caller;
      statusText = 'Incoming call...';
      statusIcon = Icons.call_received;
    } else if (state is CallConnecting) {
      user = state.otherUser;
      statusText = 'Connecting...';
      statusIcon = Icons.sync;
    } else if (state is CallConnected) {
      user = state.otherUser;
      statusText = 'Connected';
      statusIcon = Icons.call;
    } else if (state is CallEnded) {
      user = widget.receiver ?? MockDataService.getUserById('2');
      statusText = 'Call ended';
      statusIcon = Icons.call_end;
    } else {
      user = widget.receiver ?? MockDataService.getUserById('2');
      statusText = 'Initializing...';
      statusIcon = Icons.hourglass_empty;
    }

    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Call status with icon
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (statusIcon != Icons.hourglass_empty) ...[
                  Icon(
                    statusIcon,
                    color: isDark ? Colors.white70 : Colors.white60,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  statusText,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.white60,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Profile picture or video with enhanced animations
          if (state is CallConnected && widget.callType == CallType.video)
            _buildVideoLayout(state)
          else
            _buildProfilePicture(user, state),

          const SizedBox(height: 30),

          // User name with animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              user.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          // Call duration or status with animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state is CallConnected)
                    Text(
                      _formatDuration(_callDuration),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    )
                  else
                    Text(
                      widget.callType == CallType.voice ? 'Voice Call' : 'Video Call',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (state is CallConnected) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getConnectionColor(),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getConnectionColor().withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Call quality indicator
          if (state is CallConnected) ...[
            const SizedBox(height: 16),
            _buildCallQualityIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildProfilePicture(User user, CallState state) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring animation for incoming calls
            if (state is CallIncoming)
              AnimatedBuilder(
                animation: _ringAnimation,
                builder: (context, child) {
                  return Container(
                    width: 200 * _ringAnimation.value,
                    height: 200 * _ringAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppConfig.primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),

            // Main avatar with pulse animation
            Transform.scale(
              scale: state is CallIncoming ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConfig.primaryColor,
                      AppConfig.primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConfig.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 85,
                  backgroundColor: Colors.transparent,
                  backgroundImage: user.profilePicture != null
                      ? NetworkImage(user.profilePicture!)
                      : null,
                  child: user.profilePicture == null
                      ? Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // Online indicator for connected calls
            if (state is CallConnected)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVideoLayout(CallState state) {
    if (state is! CallConnected) return const SizedBox.shrink();

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Stack(
          children: [
            RTCVideoView(
              _localRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
            // Picture-in-picture remote video
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConnectionColor() {
    if (_callQuality >= 0.8) return Colors.green;
    if (_callQuality >= 0.6) return Colors.yellow;
    if (_callQuality >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCallQualityIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _callQuality >= 0.8 ? Icons.signal_cellular_alt :
            _callQuality >= 0.6 ? Icons.signal_cellular_alt_2_bar :
            _callQuality >= 0.4 ? Icons.signal_cellular_alt_1_bar :
            Icons.signal_cellular_connected_no_internet_0_bar,
            color: _getConnectionColor(),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _callQuality >= 0.8 ? 'Excellent' :
            _callQuality >= 0.6 ? 'Good' :
            _callQuality >= 0.4 ? 'Fair' : 'Poor',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(CallState state) {
    if (state is CallIncoming) {
      return _buildIncomingCallControls();
    } else if (state is CallConnected) {
      return _buildActiveCallControls(state);
    } else {
      return _buildCallingControls();
    }
  }

  Widget _buildIncomingCallControls() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          children: [
            // Reminder text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                widget.callType == CallType.voice
                    ? 'Swipe up to answer voice call'
                    : 'Swipe up to answer video call',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // Call control buttons with enhanced animations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject call button with bounce animation
                ScaleTransition(
                  scale: _bounceAnimation,
                  child: _buildCallButton(
                    icon: Icons.call_end,
                    color: AppConfig.errorColor,
                    label: 'Decline',
                    onPressed: () {
                      _bounceController.forward(from: 0.0);
                      Future.delayed(const Duration(milliseconds: 150), () {
                        context.read<CallBloc>().add(CallRejected(widget.call?.id ?? ''));
                      });
                    },
                  ),
                ),

                // Accept call button with enhanced styling
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildCallButton(
                    icon: widget.callType == CallType.voice ? Icons.call : Icons.videocam,
                    color: AppConfig.successColor,
                    label: 'Accept',
                    onPressed: () {
                      _scaleController.forward(from: 0.0);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        context.read<CallBloc>().add(CallAnswered(widget.call?.id ?? ''));
                      });
                    },
                    isLarge: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Additional options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSmallButton(
                  icon: Icons.message,
                  label: 'Message',
                  onPressed: () {
                    // Navigate to chat
                  },
                ),
                const SizedBox(width: 40),
                _buildSmallButton(
                  icon: Icons.alarm,
                  label: 'Remind me',
                  onPressed: () {
                    // Set reminder
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCallControls(CallState state) {
    if (state is! CallConnected) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            // Call duration display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_callDuration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Primary call controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallButton(
                  icon: state.isMuted ? Icons.mic_off : Icons.mic,
                  color: state.isMuted ? Colors.red : Colors.white.withValues(alpha: 0.9),
                  label: state.isMuted ? 'Unmute' : 'Mute',
                  onPressed: () {
                    _bounceController.forward(from: 0.0);
                    context.read<CallBloc>().add(const CallToggleMute());
                  },
                ),

                // End call button - larger and more prominent
                _buildCallButton(
                  icon: Icons.call_end,
                  color: AppConfig.errorColor,
                  label: 'End',
                  onPressed: () {
                    _bounceController.forward(from: 0.0);
                    Future.delayed(const Duration(milliseconds: 150), () {
                      context.read<CallBloc>().add(CallHungUp(widget.call?.id ?? ''));
                    });
                  },
                  isLarge: true,
                ),

                _buildCallButton(
                  icon: state.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                  color: state.isSpeakerOn ? AppConfig.primaryColor : Colors.white.withValues(alpha: 0.9),
                  label: state.isSpeakerOn ? 'Speaker' : 'Speaker',
                  onPressed: () {
                    _bounceController.forward(from: 0.0);
                    context.read<CallBloc>().add(const CallToggleSpeaker());
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Secondary controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSecondaryButton(
                  icon: Icons.dialpad,
                  label: 'Keypad',
                  onPressed: () => _showDialpad(),
                ),

                if (widget.callType == CallType.video) ...[
                  _buildSecondaryButton(
                    icon: state.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    label: state.isVideoEnabled ? 'Video' : 'Video',
                    onPressed: () {
                      context.read<CallBloc>().add(const CallToggleVideo());
                    },
                  ),

                  _buildSecondaryButton(
                    icon: Icons.flip_camera_ios,
                    label: 'Switch',
                    onPressed: () {
                      context.read<CallBloc>().add(const CallSwitchCamera());
                    },
                  ),
                ] else ...[
                  _buildSecondaryButton(
                    icon: Icons.bluetooth,
                    label: 'Bluetooth',
                    onPressed: () => _toggleBluetooth(),
                  ),
                ],

                _buildSecondaryButton(
                  icon: Icons.more_vert,
                  label: 'More',
                  onPressed: () => _showMoreOptions(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickAction(
                  icon: Icons.message,
                  label: 'Message',
                  onPressed: () => _sendMessage(),
                ),
                const SizedBox(width: 30),
                _buildQuickAction(
                  icon: Icons.person_add,
                  label: 'Add person',
                  onPressed: () => _addPerson(),
                ),
                const SizedBox(width: 30),
                _buildQuickAction(
                  icon: Icons.record_voice_over,
                  label: 'Record',
                  onPressed: () => _toggleRecording(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.9),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallingControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCallButton(
            icon: Icons.call_end,
            color: AppConfig.errorColor,
            onPressed: () {
              context.read<CallBloc>().add(CallHungUp(widget.call?.id ?? ''));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    String? label,
    bool isLarge = false,
  }) {
    final size = isLarge ? 80.0 : 70.0;
    final iconSize = isLarge ? 36.0 : 32.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(size / 2),
              splashColor: Colors.white.withValues(alpha: 0.3),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Icon(
                icon,
                size: iconSize,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.8),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(CallState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Call quality indicator
            if (state is CallConnected)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.signal_cellular_4_bar,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Good connection',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 20),
            
            // Additional info
            Text(
              'Swipe up for more options',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.white.withValues(alpha: 0.48),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  void _showCallEndedDialog(CallEnded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => CallEndedScreen(
        call: state.call,
        duration: state.duration,
        reason: state.reason,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showCallFailedDialog(CallFailed state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Call Failed'),
        content: Text(state.message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDialpad() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dialpad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Dialpad would be implemented here
            Expanded(
              child: Center(
                child: Text(
                  'Dialpad UI would be implemented here',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBluetooth() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bluetooth toggle - would connect/disconnect Bluetooth device')),
    );
  }

  void _sendMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send message - would open quick message composer')),
    );
  }

  void _addPerson() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add person - would show contacts to add to call')),
    );
  }

  void _toggleRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Call recording - would start/stop recording')),
    );
  }

  void _showMoreOptions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
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
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: const Text('Bluetooth'),
              onTap: () => _toggleBluetooth(),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Call Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call settings - would open settings screen')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help - would show call help')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report issue - would open issue reporter')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
