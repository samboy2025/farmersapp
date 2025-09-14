import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../config/app_config.dart';

class VoiceNotePreview extends StatefulWidget {
  final String filePath;
  final Duration duration;
  final Function(String filePath, Duration duration) onSend;
  final VoidCallback onDelete;

  const VoiceNotePreview({
    super.key,
    required this.filePath,
    required this.duration,
    required this.onSend,
    required this.onDelete,
  });

  @override
  State<VoiceNotePreview> createState() => _VoiceNotePreviewState();
}

class _VoiceNotePreviewState extends State<VoiceNotePreview>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;
  List<double> _waveformData = [];
  Timer? _waveformTimer;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _generateWaveformData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveformTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    try {
      await _audioPlayer.setSource(DeviceFileSource(widget.filePath));
      _totalDuration = widget.duration;

      _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentPosition = Duration.zero;
          });
        }
      });
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  void _generateWaveformData() {
    // Generate simulated waveform data based on duration
    final dataPoints = (widget.duration.inMilliseconds / 100).toInt();
    _waveformData = List.generate(dataPoints, (index) {
      return 0.3 + (index % 10) * 0.05 + (index % 3) * 0.1;
    });
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _audioPlayer.setPlaybackRate(_playbackSpeed);
        await _audioPlayer.resume();
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      print('Error toggling playback: $e');
    }
  }

  void _seekToPosition(double value) {
    final position = Duration(milliseconds: (value * _totalDuration.inMilliseconds).toInt());
    _audioPlayer.seek(position);
  }

  void _changePlaybackSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }
    });

    if (_isPlaying) {
      _audioPlayer.setPlaybackRate(_playbackSpeed);
    }
  }

  void _sendVoiceNote() {
    widget.onSend(widget.filePath, widget.duration);
    Navigator.of(context).pop();
  }

  void _deleteVoiceNote() {
    widget.onDelete();
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
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
              Text(
                'Voice Note Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF111B21),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                color: Colors.grey,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Voice note card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConfig.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Play/Pause and waveform
                Row(
                  children: [
                    // Play/Pause button
                    IconButton(
                      onPressed: _togglePlayback,
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                      ),
                      color: AppConfig.primaryColor,
                    ),

                    const SizedBox(width: 12),

                    // Waveform
                    Expanded(
                      child: Container(
                        height: 40,
                        child: Stack(
                          children: [
                            // Background waveform
                            CustomPaint(
                              size: Size.infinite,
                              painter: WaveformPainter(
                                waveformData: _waveformData,
                                color: AppConfig.primaryColor.withOpacity(0.3),
                                playedColor: AppConfig.primaryColor,
                                progress: _totalDuration.inMilliseconds > 0
                                    ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                                    : 0.0,
                              ),
                            ),

                            // Progress scrubber
                            Positioned.fill(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 40,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                    disabledThumbRadius: 6,
                                  ),
                                  overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                  activeTrackColor: Colors.transparent,
                                  inactiveTrackColor: Colors.transparent,
                                  thumbColor: AppConfig.primaryColor,
                                  overlayColor: AppConfig.primaryColor.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: _totalDuration.inMilliseconds > 0
                                      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                                      : 0.0,
                                  onChanged: (value) => _seekToPosition(value),
                                  min: 0.0,
                                  max: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Duration
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConfig.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDuration(_totalDuration),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Playback speed
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Speed:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _changePlaybackSpeed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppConfig.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Delete button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _deleteVoiceNote,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConfig.errorColor,
                    side: BorderSide(color: AppConfig.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Send button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sendVoiceNote,
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final Color playedColor;
  final double progress;

  WaveformPainter({
    required this.waveformData,
    required this.color,
    required this.playedColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;
    final playedBars = (progress * waveformData.length).toInt();

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth;
      final barHeight = waveformData[i] * size.height * 0.8;
      final topY = centerY - barHeight / 2;
      final bottomY = centerY + barHeight / 2;

      final paint = Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = i <= playedBars ? playedColor : color;

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
