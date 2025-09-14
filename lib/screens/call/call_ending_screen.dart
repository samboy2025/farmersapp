import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/call.dart';

class CallEndingScreen extends StatefulWidget {
  final Call? call;
  final Duration duration;
  final VoidCallback onComplete;

  const CallEndingScreen({
    super.key,
    this.call,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<CallEndingScreen> createState() => _CallEndingScreenState();
}

class _CallEndingScreenState extends State<CallEndingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Auto-close after 2 seconds
    _autoCloseTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        _handleComplete();
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
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
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.9,
                        maxHeight: screenHeight * 0.8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Call ended icon
                          Container(
                            width: screenWidth * 0.25, // Responsive size
                            height: screenWidth * 0.25,
                            constraints: const BoxConstraints(
                              maxWidth: 120,
                              maxHeight: 120,
                              minWidth: 80,
                              minHeight: 80,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.call_end,
                              color: Colors.white.withOpacity(0.8),
                              size: screenWidth * 0.12, // Responsive icon
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.04),

                          // Call ended text
                          Text(
                            'Call Ended',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.07, // Responsive font
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Duration summary
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _formatDuration(widget.duration),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: screenWidth * 0.05, // Responsive font
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),

                          // Manual close button
                          GestureDetector(
                            onTap: () {
                              if (mounted) {
                                _handleComplete();
                              }
                            },
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
                              child: Text(
                                'Back to Chat',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: screenWidth * 0.04, // Responsive font
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _handleComplete() {
    // Cancel auto-close timer to prevent conflicts
    _autoCloseTimer?.cancel();

    // Simple navigation - just call the onComplete callback
    // The CallScreen handles the actual navigation
    if (mounted) {
      widget.onComplete();
    }
  }
}
