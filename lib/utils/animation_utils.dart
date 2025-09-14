import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom animation curves for smooth, natural-feeling animations
class AppAnimationCurves {
  // Spring-like bounce for playful interactions
  static const Curve bounceIn = Curves.elasticOut;
  static const Curve bounceOut = Curves.elasticIn;

  // Smooth slide transitions
  static const Curve slideIn = Curves.easeOutCubic;
  static const Curve slideOut = Curves.easeInCubic;

  // Subtle micro-interactions
  static const Curve microBounce = Curves.elasticOut;
  static const Curve fadeSmooth = Curves.easeInOut;

  // Page transitions
  static const Curve pageEnter = Curves.easeOutQuart;
  static const Curve pageExit = Curves.easeInQuart;
}

/// Spring physics configuration for natural animations
class SpringPhysics {
  static const SpringDescription gentleBounce = SpringDescription(
    mass: 1.0,
    stiffness: 100.0,
    damping: 10.0,
  );

  static const SpringDescription quickSnap = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 15.0,
  );

  static const SpringDescription smoothSlide = SpringDescription(
    mass: 1.0,
    stiffness: 150.0,
    damping: 12.0,
  );
}

/// Animation durations for consistency
class AnimationDurations {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 350);
}

/// Staggered animation helper for sequential animations
class StaggeredAnimation {
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const StaggeredAnimation({
    this.delay = Duration.zero,
    this.duration = AnimationDurations.normal,
    this.curve = Curves.easeOut,
  });

  Animation<T> createAnimation<T>(
    AnimationController controller,
    Tween<T> tween,
  ) {
    return TweenSequence<T>([
      TweenSequenceItem(
        tween: Tween(begin: tween.begin, end: tween.begin),
        weight: delay.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: tween,
        weight: duration.inMilliseconds.toDouble(),
      ),
    ]).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
}

/// Pulse animation for attention-grabbing elements
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scale;
  final VoidCallback? onTap;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.scale = 1.1,
    this.onTap,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Bounce animation for playful interactions
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double bounceHeight;
  final VoidCallback? onTap;

  const BounceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.bounceHeight = 8.0,
    this.onTap,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -widget.bounceHeight), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -widget.bounceHeight, end: widget.bounceHeight * 0.5), weight: 25),
      TweenSequenceItem(tween: Tween(begin: widget.bounceHeight * 0.5, end: -widget.bounceHeight * 0.25), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -widget.bounceHeight * 0.25, end: 0), weight: 25),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startBounce() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _startBounce();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Slide-in animation from any direction
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final Curve curve;
  final Duration delay;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.beginOffset = const Offset(0, 1),
    this.duration = AnimationDurations.normal,
    this.curve = AppAnimationCurves.slideIn,
    this.delay = Duration.zero,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

/// Fade-in animation
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration delay;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.curve = AppAnimationCurves.fadeSmooth,
    this.delay = Duration.zero,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Scale animation for micro-interactions
class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final double beginScale;
  final double endScale;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTap;
  final bool autoStart;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.beginScale = 1.0,
    this.endScale = 1.05,
    this.duration = AnimationDurations.quick,
    this.curve = AppAnimationCurves.microBounce,
    this.onTap,
    this.autoStart = true,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.reverse().then((_) => _controller.forward());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Typing indicator animation
class TypingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const TypingIndicator({
    super.key,
    this.color = Colors.grey,
    this.size = 4.0,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) =>
      AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      )..repeat(reverse: true)
    );

    _animations = _controllers.map((controller) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      )
    ).toList();

    // Stagger the animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controllers[1].forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controllers[2].forward();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size / 2),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(_animations[index].value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// Custom page route with smooth transitions
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset beginOffset;
  final Curve curve;

  SmoothPageRoute({
    required this.page,
    this.beginOffset = const Offset(1.0, 0.0),
    this.curve = AppAnimationCurves.pageEnter,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const endOffset = Offset.zero;
      const beginOffset = Offset(1.0, 0.0);

      var slideAnimation = Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      ).animate(
        CurvedAnimation(parent: animation, curve: curve),
      );

      var fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: AnimationDurations.pageTransition,
  );
}
