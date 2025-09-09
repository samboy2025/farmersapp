import 'package:flutter/material.dart';
import 'dart:async';

class StatusProgressIndicator extends StatefulWidget {
  final int totalStatuses;
  final int currentIndex;
  final Duration duration;
  final bool isPlaying;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onTapCenter;

  const StatusProgressIndicator({
    super.key,
    required this.totalStatuses,
    required this.currentIndex,
    required this.duration,
    this.isPlaying = true,
    this.onTapLeft,
    this.onTapRight,
    this.onTapCenter,
  });

  @override
  State<StatusProgressIndicator> createState() => _StatusProgressIndicatorState();
}

class _StatusProgressIndicatorState extends State<StatusProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Timer? _progressTimer;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_progressController);
    
    _progressAnimation.addListener(() {
      setState(() {
        _currentProgress = _progressAnimation.value;
      });
    });
    
    if (widget.isPlaying) {
      _startProgress();
    }
  }

  @override
  void didUpdateWidget(StatusProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentIndex != widget.currentIndex) {
      _resetProgress();
    }
    
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _startProgress();
      } else {
        _pauseProgress();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _progressController.forward();
  }

  void _pauseProgress() {
    _progressController.stop();
  }

  void _resetProgress() {
    _progressController.reset();
    _currentProgress = 0.0;
    if (widget.isPlaying) {
      _startProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Progress bars
          Row(
            children: List.generate(widget.totalStatuses, (index) {
              final isActive = index == widget.currentIndex;
              final progress = isActive ? _currentProgress : 
                             index < widget.currentIndex ? 1.0 : 0.0;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < widget.totalStatuses - 1 ? 4 : 0,
                  ),
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Navigation area
          Expanded(
            child: Row(
              children: [
                // Left tap area (previous status)
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onTapLeft,
                    child: Container(
                      color: Colors.transparent,
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                // Center tap area (pause/play)
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onTapCenter,
                    child: Container(
                      color: Colors.transparent,
                      child: Icon(
                        widget.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                // Right tap area (next status)
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onTapRight,
                    child: Container(
                      color: Colors.transparent,
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                        size: 20,
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
