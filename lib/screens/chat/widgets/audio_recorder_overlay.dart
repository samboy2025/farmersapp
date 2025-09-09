import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../config/app_config.dart';

class AudioRecorderOverlay extends StatefulWidget {
  final Function(String? filePath)? onRecordingComplete;
  final VoidCallback? onRecordingCancelled;

  const AudioRecorderOverlay({
    super.key,
    this.onRecordingComplete,
    this.onRecordingCancelled,
  });

  @override
  State<AudioRecorderOverlay> createState() => _AudioRecorderOverlayState();
}

class _AudioRecorderOverlayState extends State<AudioRecorderOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveformController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveformAnimation;

  Duration _recordingDuration = Duration.zero;
  bool _isRecording = true;
  double _recordingVolume = 0.5; // Simulated volume level

  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveformAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveformController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
    _waveformController.repeat();

    // Start recording timer
    _startRecordingTimer();
    // Start audio recording
    _startRecording();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveformController.dispose();
    _stopRecording();
    super.dispose();
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
        _startRecordingTimer();
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      // Check if microphone permission is granted
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        // Handle permission denied
        return;
      }

      // Get temporary directory for recording
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start recording
      await _audioRecorder.start(
        RecordConfig(),
        path: filePath,
      );

      setState(() {
        _recordedFilePath = filePath;
      });
    } catch (e) {
      // Handle recording start error
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final isRecording = await _audioRecorder.isRecording();
      if (isRecording) {
        final path = await _audioRecorder.stop();
        setState(() {
          _recordedFilePath = path;
        });
      }
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppConfig.largePadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recording indicator
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppConfig.errorColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Recording text
              Text(
                'Recording...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Timer
              Text(
                _formatDuration(_recordingDuration),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Waveform visualization
              SizedBox(
                height: 60,
                child: AnimatedBuilder(
                  animation: _waveformController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(200, 60),
                      painter: WaveformPainter(
                        animation: _waveformAnimation.value,
                        volume: _recordingVolume,
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Instructions
              Text(
                'Slide to cancel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cancel button
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _isRecording = false);
                      widget.onRecordingCancelled?.call();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Stop button
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() => _isRecording = false);
                      await _stopRecording();

                      // Call the completion callback with the recorded file path
                      if (widget.onRecordingComplete != null) {
                        widget.onRecordingComplete!(_recordedFilePath);
                      }
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.errorColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class WaveformPainter extends CustomPainter {
  final double animation;
  final double volume;

  WaveformPainter({
    required this.animation,
    required this.volume,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConfig.primaryColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = 4.0;
    final spacing = 6.0;
    final totalBars = (size.width / (barWidth + spacing)).floor();

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + spacing);
      final progress = (i / totalBars + animation) % 1.0;
      
      // Create wave-like pattern
      final height = (sin(progress * 2 * pi) * 0.5 + 0.5) * 40 * volume;
      final startY = centerY - height / 2;
      final endY = centerY + height / 2;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
