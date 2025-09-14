import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/call.dart';

class IncomingCallScreen extends StatefulWidget {
  final User caller;
  final CallType callType;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback? onMessageReply;

  const IncomingCallScreen({
    super.key,
    required this.caller,
    required this.callType,
    required this.onAccept,
    required this.onReject,
    this.onMessageReply,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _ringAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startVibration();
  }

  void _initializeAnimations() {
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _ringAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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

    _ringController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _scaleController.forward();
  }

  void _startVibration() {
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      // In a real app, this would trigger device vibration
      // For now, we just show the visual ring animation
    });
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    _vibrationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated ring around profile picture
              AnimatedBuilder(
                animation: _ringAnimation,
                builder: (context, child) {
                  return Container(
                    width: 200 * _ringAnimation.value,
                    height: 200 * _ringAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppConfig.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),

              // Profile picture with pulse animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
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
                            AppConfig.primaryColor.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConfig.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 85,
                        backgroundColor: Colors.transparent,
                        backgroundImage: widget.caller.profilePicture != null
                            ? NetworkImage(widget.caller.profilePicture!)
                            : null,
                        child: widget.caller.profilePicture == null
                            ? Text(
                                widget.caller.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Caller name
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  widget.caller.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Incoming call type
              Text(
                widget.callType == CallType.voice
                    ? 'Incoming voice call'
                    : 'Incoming video call',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject button
                  _buildActionButton(
                    icon: Icons.call_end,
                    label: 'Decline',
                    color: const Color(0xFFFF3B30), // iOS red
                    onPressed: widget.onReject,
                  ),

                  // Accept button
                  _buildActionButton(
                    icon: widget.callType == CallType.voice ? Icons.call : Icons.videocam,
                    label: 'Accept',
                    color: const Color(0xFF34C759), // iOS green
                    onPressed: widget.onAccept,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Optional message reply
              if (widget.onMessageReply != null) ...[
                GestureDetector(
                  onTap: widget.onMessageReply,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.message,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Can\'t talk now',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
