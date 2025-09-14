import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../config/app_config.dart';
import 'voice_note_preview.dart';

class VoiceNoteRecorder extends StatefulWidget {
  final Function(String filePath, Duration duration)? onRecordingComplete;
  final VoidCallback? onRecordingCancelled;

  const VoiceNoteRecorder({
    super.key,
    this.onRecordingComplete,
    this.onRecordingCancelled,
  });

  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _slideAnimation;

  // Recording state
  bool _isRecording = false;
  bool _isLocked = false;
  bool _isDragging = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  double _dragOffset = 0.0;
  double _lockThreshold = 100.0; // Distance to swipe up for lock
  double _cancelThreshold = -80.0; // Distance to swipe left for cancel

  // Audio recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordedFilePath;
  double _currentVolume = 0.0;

  // Waveform data (simulated)
  List<double> _waveformData = [];

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${directory.path}/$fileName';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _recordedFilePath = filePath;
      });

      // Start timer
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration = Duration(
              milliseconds: _recordingDuration.inMilliseconds + 100,
            );

            // Simulate volume changes for waveform
            _currentVolume = Random().nextDouble() * 0.8 + 0.2;

            // Add waveform data point
            _waveformData.add(_currentVolume);
            if (_waveformData.length > 50) {
              _waveformData.removeAt(0);
            }
          });
        }
      });

      _pulseController.repeat(reverse: true);
    } catch (e) {
      print('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();
      _pulseController.stop();

      if (path != null && mounted) {
        setState(() {
          _isRecording = false;
        });

        // Show preview
        _showPreview();
      }
    } catch (e) {
      print('Failed to stop recording: $e');
    }
  }

  void _cancelRecording() {
    _audioRecorder.stop();
    _timer?.cancel();
    _pulseController.stop();

    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    widget.onRecordingCancelled?.call();
    Navigator.of(context).pop();
  }

  void _lockRecording() {
    setState(() {
      _isLocked = true;
    });
    _slideController.forward();
  }

  void _showPreview() {
    Navigator.of(context).pop(); // Close recorder overlay

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => VoiceNotePreview(
        filePath: _recordedFilePath!,
        duration: _recordingDuration,
        onSend: (filePath, duration) {
          widget.onRecordingComplete?.call(filePath, duration);
        },
        onDelete: () {
          final file = File(_recordedFilePath!);
          if (file.existsSync()) {
            file.deleteSync();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background blur effect
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Main recorder UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppConfig.darkSurface
                    : Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(isTablet ? 24 : 20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Slide up to lock',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _cancelRecording,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Recording indicator and waveform
                  Row(
                    children: [
                      // Recording dot
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 16),

                      // Waveform
                      Expanded(
                        child: Container(
                          height: 40,
                          child: CustomPaint(
                            painter: WaveformPainter(
                              waveformData: _waveformData,
                              color: AppConfig.primaryColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Timer
                      Text(
                        _formatDuration(_recordingDuration),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Slide to cancel hint
                  Row(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Slide left to cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Recording button with drag gesture
                  GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _isDragging = true;
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _dragOffset = details.delta.dx;

                        // Check for lock gesture (swipe up)
                        if (details.delta.dy < -_lockThreshold && !_isLocked) {
                          _lockRecording();
                        }

                        // Check for cancel gesture (swipe left)
                        if (_dragOffset < _cancelThreshold) {
                          _cancelRecording();
                        }
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _isDragging = false;
                        _dragOffset = 0.0;
                      });

                      // If not cancelled and not locked, stop recording
                      if (!_isLocked && _dragOffset > _cancelThreshold) {
                        _stopRecording();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_dragOffset, 0),
                          child: Transform.scale(
                            scale: _isDragging ? 1.1 : 1.0,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _dragOffset < _cancelThreshold
                                    ? AppConfig.errorColor
                                    : AppConfig.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_dragOffset < _cancelThreshold
                                            ? AppConfig.errorColor
                                            : AppConfig.primaryColor)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _dragOffset < _cancelThreshold
                                    ? Icons.delete
                                    : Icons.mic,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lock indicator
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _slideAnimation.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock,
                              color: AppConfig.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recording locked - tap to stop',
                              style: TextStyle(
                                color: AppConfig.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Locked recording stop button
                  if (_isLocked) ...[
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;

  WaveformPainter({
    required this.waveformData,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth;
      final barHeight = waveformData[i] * size.height * 0.8;
      final topY = centerY - barHeight / 2;
      final bottomY = centerY + barHeight / 2;

      canvas.drawLine(
        Offset(x, topY),
        Offset(x, bottomY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
