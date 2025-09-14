import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../config/app_config.dart';

class VoiceNotePlayer extends StatefulWidget {
  final String filePath;
  final Duration duration;
  final bool isFromMe;

  const VoiceNotePlayer({
    super.key,
    required this.filePath,
    required this.duration,
    required this.isFromMe,
  });

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;
  List<double> _waveformData = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _generateWaveformData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    try {
      // Check if file exists
      final file = File(widget.filePath);
      if (!file.existsSync()) {
        print('Voice note file does not exist: ${widget.filePath}');
        return;
      }

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

      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing voice note audio: $e');
    }
  }

  void _generateWaveformData() {
    // Generate simulated waveform data based on duration
    final dataPoints = (widget.duration.inMilliseconds / 100).toInt();
    _waveformData = List.generate(dataPoints, (index) {
      return 0.2 + (index % 8) * 0.05 + (index % 5) * 0.08;
    });
  }

  Future<void> _togglePlayback() async {
    if (!_isInitialized) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setPlaybackRate(_playbackSpeed);
        await _audioPlayer.resume();
      }
    } catch (e) {
      print('Error toggling voice note playback: $e');
    }
  }

  void _seekToPosition(double value) {
    if (!_isInitialized) return;

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

  void _showPlaybackControls() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceNotePlaybackControls(
        filePath: widget.filePath,
        duration: widget.duration,
        currentPosition: _currentPosition,
        isPlaying: _isPlaying,
        playbackSpeed: _playbackSpeed,
        waveformData: _waveformData,
        onTogglePlayback: _togglePlayback,
        onSeek: _seekToPosition,
        onSpeedChange: _changePlaybackSpeed,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: _showPlaybackControls,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: isTablet ? 300 : 200,
        ),
        decoration: BoxDecoration(
          color: widget.isFromMe
              ? AppConfig.primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play/Pause button
            IconButton(
              onPressed: _togglePlayback,
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 24,
              ),
              color: widget.isFromMe ? Colors.white : AppConfig.primaryColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),

            const SizedBox(width: 8),

            // Waveform visualization
            Expanded(
              child: Container(
                height: 24,
                child: CustomPaint(
                  painter: MiniWaveformPainter(
                    waveformData: _waveformData,
                    color: widget.isFromMe ? Colors.white.withOpacity(0.7) : Colors.grey.shade500,
                    playedColor: widget.isFromMe ? Colors.white : AppConfig.primaryColor,
                    progress: _totalDuration.inMilliseconds > 0
                        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                        : 0.0,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Duration and speed
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDuration(_totalDuration),
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.isFromMe ? Colors.white.withOpacity(0.8) : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_playbackSpeed != 1.0)
                  Text(
                    '${_playbackSpeed}x',
                    style: TextStyle(
                      fontSize: 8,
                      color: widget.isFromMe ? Colors.white.withOpacity(0.6) : Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MiniWaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final Color playedColor;
  final double progress;

  MiniWaveformPainter({
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
        ..strokeWidth = 1.5
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

class VoiceNotePlaybackControls extends StatefulWidget {
  final String filePath;
  final Duration duration;
  final Duration currentPosition;
  final bool isPlaying;
  final double playbackSpeed;
  final List<double> waveformData;
  final VoidCallback onTogglePlayback;
  final Function(double) onSeek;
  final VoidCallback onSpeedChange;

  const VoiceNotePlaybackControls({
    super.key,
    required this.filePath,
    required this.duration,
    required this.currentPosition,
    required this.isPlaying,
    required this.playbackSpeed,
    required this.waveformData,
    required this.onTogglePlayback,
    required this.onSeek,
    required this.onSpeedChange,
  });

  @override
  State<VoiceNotePlaybackControls> createState() => _VoiceNotePlaybackControlsState();
}

class _VoiceNotePlaybackControlsState extends State<VoiceNotePlaybackControls> {
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
            ? const Color(0xFF1F2937)
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
              const Icon(
                Icons.audiotrack,
                color: AppConfig.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Voice Note',
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

          // Large waveform and controls
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Play/Pause button
                IconButton(
                  onPressed: widget.onTogglePlayback,
                  icon: Icon(
                    widget.isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 64,
                  ),
                  color: AppConfig.primaryColor,
                ),

                const SizedBox(height: 16),

                // Waveform with scrubber
                Container(
                  height: 60,
                  child: Stack(
                    children: [
                      // Background waveform
                      CustomPaint(
                        size: Size.infinite,
                        painter: WaveformPainter(
                          waveformData: widget.waveformData,
                          color: AppConfig.primaryColor.withOpacity(0.3),
                          playedColor: AppConfig.primaryColor,
                          progress: widget.duration.inMilliseconds > 0
                              ? widget.currentPosition.inMilliseconds / widget.duration.inMilliseconds
                              : 0.0,
                        ),
                      ),

                      // Progress scrubber
                      Positioned.fill(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 60,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                              disabledThumbRadius: 8,
                            ),
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 16,
                            ),
                            activeTrackColor: Colors.transparent,
                            inactiveTrackColor: Colors.transparent,
                            thumbColor: AppConfig.primaryColor,
                            overlayColor: AppConfig.primaryColor.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: widget.duration.inMilliseconds > 0
                                ? widget.currentPosition.inMilliseconds / widget.duration.inMilliseconds
                                : 0.0,
                            onChanged: widget.onSeek,
                            min: 0.0,
                            max: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Time display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(widget.currentPosition),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConfig.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDuration(widget.duration),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Playback speed
                GestureDetector(
                  onTap: widget.onSpeedChange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Speed: ${widget.playbackSpeed}x',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppConfig.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
        ..strokeWidth = 2.5
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
