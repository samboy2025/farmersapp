import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class VoiceMessageRecorder extends StatefulWidget {
  final Function(String, String) onRecordingComplete;

  const VoiceMessageRecorder({
    super.key,
    required this.onRecordingComplete,
  });

  @override
  State<VoiceMessageRecorder> createState() => _VoiceMessageRecorderState();
}

class _VoiceMessageRecorderState extends State<VoiceMessageRecorder>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isPaused) {
        setState(() {
          _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1);
        });
      }
    });
  }

  void _pauseRecording() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeRecording() {
    setState(() {
      _isPaused = false;
    });
  }

  void _stopRecording() {
    _timer?.cancel();

    if (_recordingDuration.inSeconds >= 1) {
      // Recording is long enough, send it
      widget.onRecordingComplete(
        '🎤 Voice message',
        'Voice message (${_formatDuration(_recordingDuration)})',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Voice message sent'),
          backgroundColor: AppConfig.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      // Recording too short
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Voice message too short'),
          backgroundColor: AppConfig.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  void _cancelRecording() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: SafeArea(
        child: Column(
          children: [
            // Header with timer and cancel
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _cancelRecording,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDuration(_recordingDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the layout
                ],
              ),
            ),

            // Main recording interface
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated recording indicator
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isRecording && !_isPaused ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: _isPaused ? Colors.grey : Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPaused ? Icons.pause : Icons.mic,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Recording status
                    Text(
                      _isPaused
                          ? 'Recording Paused'
                          : 'Recording...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Instructions
                    Text(
                      _isPaused
                          ? 'Tap play to resume'
                          : 'Slide up to cancel • Tap to pause',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Control buttons
            Container(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Delete button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _cancelRecording,
                    ),
                  ),

                  // Pause/Resume button
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isPaused ? Colors.green : Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                    ),
                  ),

                  // Send button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _stopRecording,
                    ),
                  ),
                ],
              ),
            ),

            // Swipe to cancel indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Slide up to cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
