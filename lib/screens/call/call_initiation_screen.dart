import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_config.dart';
import '../../utils/animation_utils.dart';
import '../../models/user.dart';
import '../../models/call.dart';

class CallInitiationScreen extends StatefulWidget {
  final User receiver;
  final CallType callType;

  const CallInitiationScreen({
    super.key,
    required this.receiver,
    required this.callType,
  });

  @override
  State<CallInitiationScreen> createState() => _CallInitiationScreenState();
}

class _CallInitiationScreenState extends State<CallInitiationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Simulate connection timeout after 30 seconds
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        Navigator.of(context).pop();
        // Show timeout message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Call timed out. Please try again.'),
            backgroundColor: AppConfig.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
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

    _pulseController.repeat(reverse: true);
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Color(0xFF1a1a1a),
                    ],
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.9,
                      maxHeight: screenHeight * 0.9,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile picture with enhanced pulse animation
                        PulseAnimation(
                          duration: const Duration(seconds: 2),
                          scale: 1.1,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: screenWidth * 0.4, // Responsive size
                                  height: screenWidth * 0.4,
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                    maxHeight: 200,
                                    minWidth: 120,
                                    minHeight: 120,
                                  ),
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
                                        blurRadius: 20 + (_pulseAnimation.value * 10), // Dynamic blur
                                        spreadRadius: 5 + (_pulseAnimation.value * 5), // Dynamic spread
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: widget.receiver.profilePicture != null
                                        ? NetworkImage(widget.receiver.profilePicture!)
                                        : null,
                                    child: widget.receiver.profilePicture == null
                                        ? Text(
                                            widget.receiver.name.substring(0, 1).toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth * 0.12, // Responsive font
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        // User name
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              widget.receiver.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.08, // Responsive font
                                fontWeight: FontWeight.bold,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black38,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Calling status
                        Text(
                          'Calling...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: screenWidth * 0.045, // Responsive font
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.015),

                        // Call type
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.callType == CallType.voice ? 'Voice Call' : 'Video Call',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: screenWidth * 0.035, // Responsive font
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.08),

                        // Cancel button
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleAnimation(
                              beginScale: 0.9,
                              endScale: 1.1,
                              duration: AnimationDurations.quick,
                              curve: AppAnimationCurves.microBounce,
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: screenWidth * 0.18, // Responsive size
                                height: screenWidth * 0.18,
                                constraints: const BoxConstraints(
                                  maxWidth: 70,
                                  maxHeight: 70,
                                  minWidth: 50,
                                  minHeight: 50,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF3B30), // iOS red
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFF3B30),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: screenWidth * 0.08, // Responsive icon
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04, // Responsive font
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
