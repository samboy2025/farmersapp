import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../utils/animation_utils.dart';

class VoiceNoteRecorder extends StatefulWidget {
  final VoidCallback onRecordingComplete;
  final VoidCallback onCancel;

  const VoiceNoteRecorder({
    super.key,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveformController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveformAnimation;

  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  late DateTime _recordingStartTime;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveformAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _waveformController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _recordingDuration = Duration.zero;
    });

    _pulseController.repeat(reverse: true);

    // Update recording duration
    Future.doWhile(() async {
      if (!mounted || !_isRecording) return false;

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration = DateTime.now().difference(_recordingStartTime);
        });
      }
      return _isRecording;
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
    _pulseController.stop();
    _pulseController.reset();

    widget.onRecordingComplete();
  }

  void _cancelRecording() {
    setState(() {
      _isRecording = false;
    });
    _pulseController.stop();
    _pulseController.reset();

    widget.onCancel();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Cancel button
          ScaleAnimation(
            beginScale: 0.9,
            endScale: 1.1,
            duration: AnimationDurations.micro,
            onTap: _cancelRecording,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Waveform visualization
          Expanded(
            child: AnimatedBuilder(
              animation: _waveformAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    20,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 3,
                      height: (index % 4 + 1) * 8.0 * _waveformAnimation.value,
                      decoration: BoxDecoration(
                        color: AppConfig.primaryColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          // Recording duration
          Text(
            _formatDuration(_recordingDuration),
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(width: 16),

          // Record button with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: ScaleAnimation(
                  beginScale: 0.9,
                  endScale: 1.1,
                  duration: AnimationDurations.micro,
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    width: isTablet ? 48 : 44,
                    height: isTablet ? 48 : 44,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : AppConfig.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.red : AppConfig.primaryColor).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: isTablet ? 24 : 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
