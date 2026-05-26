import 'dart:math';
import 'package:flutter/material.dart';

/// Confetti burst animation for celebrations
///
/// Displays a burst of confetti particles from a specified point.
/// Uses animated particles with varying colors, sizes, and trajectories.
class ConfettiAnimation extends StatefulWidget {
  /// Duration of the animation
  final Duration duration;

  /// Number of confetti particles
  final int particleCount;

  /// Color palette for confetti
  final List<Color> colors;

  /// Whether to auto-remove after animation completes
  final bool autoRemove;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  const ConfettiAnimation({
    super.key,
    this.duration = const Duration(milliseconds: 1200),
    this.particleCount = 30,
    this.colors = const [
      Color(0xFFF4A261), // Primary
      Color(0xFFA8D5BA), // Success
      Color(0xFFB5C9D9), // Info
      Color(0xFFF8E167), // Warning
      Color(0xFFF2B8B8), // Error
      Color(0xFFD4C5E2), // Premium
    ],
    this.autoRemove = true,
    this.onComplete,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _controller.forward().whenComplete(() {
      if (widget.autoRemove) {
        widget.onComplete?.call();
      }
    });

    _particles = List.generate(
      widget.particleCount,
      (index) => _ConfettiParticle.random(
        colors: widget.colors,
        animation: _controller,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _particles.map((particle) {
        return _particleWidget(particle);
      }).toList(),
    );
  }

  Widget _particleWidget(_ConfettiParticle p) {
    final progress = p.animation.value;
    final x = p.startX + (p.endX - p.startX) * progress;
    final y = p.startY + (p.endY - p.startY) * progress;
    final rotation = p.rotation * progress;
    final opacity = progress < 0.7
        ? 1.0
        : 1.0 - ((progress - 0.7) / 0.3);

    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: p.size,
          height: p.size,
          color: p.color.withValues(alpha: opacity.clamp(0.0, 1.0)),
          decoration: BoxDecoration(
            borderRadius: p.isCircle
                ? null
                : BorderRadius.circular(p.size / 2),
          ),
        ),
      ),
    );
  }

  /// Trigger confetti at a specific point
  static Future<void> trigger(
    BuildContext context, {
    Duration duration = const Duration(milliseconds: 1200),
    int particleCount = 30,
    List<Color>? colors,
    VoidCallback? onComplete,
  }) async {
    final overlay = Overlay.of(context);
    final displayColors = colors ?? [
      Color(0xFFF4A261),
      Color(0xFFA8D5BA),
      Color(0xFFB5C9D9),
      Color(0xFFF8E167),
      Color(0xFFF2B8B8),
      Color(0xFFD4C5E2),
    ];

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned.fill(
        child: ConfettiAnimation(
          duration: duration,
          particleCount: particleCount,
          colors: displayColors,
          autoRemove: true,
          onComplete: () {
            entry?.remove();
            onComplete?.call();
          },
        ),
      ),
    );

    overlay.insert(entry);
  }
}

/// Confetti particle data
class _ConfettiParticle {
  final Color color;
  final double size;
  final bool isCircle;
  final double startX;
  final double endX;
  final double startY;
  final double endY;
  final double rotation;
  final Animation<double> animation;

  _ConfettiParticle({
    required this.color,
    required this.size,
    required this.isCircle,
    required this.startX,
    required this.endX,
    required this.startY,
    required this.endY,
    required this.rotation,
    required this.animation,
  });

  factory _ConfettiParticle.random({
    required List<Color> colors,
    required Animation<double> animation,
  }) {
    final random = Random();
    final angle = random.nextDouble() * pi * 2;
    final distance = 80 + random.nextDouble() * 120;

    return _ConfettiParticle(
      color: colors[random.nextInt(colors.length)],
      size: 6 + random.nextDouble() * 10,
      isCircle: random.nextBool(),
      startX: 0,
      endX: cos(angle) * distance,
      startY: 0,
      endY: sin(angle) * distance - 50,
      rotation: (random.nextDouble() - 0.5) * pi * 4,
      animation: animation,
    );
  }
}

/// Badge reveal animation — scales up and pulses when a new badge is earned
class BadgeRevealAnimation extends StatefulWidget {
  /// Widget to animate (typically a badge icon or icon button)
  final Widget child;

  /// Duration of the reveal animation
  final Duration duration;

  /// Whether to repeat the animation
  final bool repeat;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  const BadgeRevealAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.repeat = false,
    this.onComplete,
  });

  @override
  State<BadgeRevealAnimation> createState() => _BadgeRevealAnimationState();
}

class _BadgeRevealAnimationState extends State<BadgeRevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    if (!widget.repeat) {
      _controller.forward();
    } else {
      _controller.forward().then((_) {
        if (widget.onComplete != null) widget.onComplete!();
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
    return TweenAnimationBuilder<double>(
      duration: widget.duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        // Scale bounce effect: overshoot slightly then settle
        final scale = value < 0.5
            ? Tween(begin: 0.0, end: 1.4).transform(value * 2)
            : Tween(begin: 1.4, end: 1.0).transform((value - 0.5) * 2);

        return Transform.scale(
          scale: scale,
          child: child!,
        );
      },
      child: widget.child,
    );
  }

  /// Trigger badge reveal animation programmatically
  static void trigger(BuildContext context, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('🎉 Achievement Unlocked!'),
          ],
        ),
        backgroundColor: Colors.amber,
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
}

/// Streak fire animation — pulsing flame effect for streak milestones
class StreakFireAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback? onComplete;

  const StreakFireAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.onComplete,
  });

  @override
  State<StreakFireAnimation> createState() => _StreakFireAnimationState();
}

class _StreakFireAnimationState extends State<StreakFireAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _controller.forward().whenComplete(() {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: widget.duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final glow = 0.3 + (value * 0.7);
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.orange.withValues(alpha: glow),
              Colors.red.withValues(alpha: glow),
            ],
          ).createShader(bounds),
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}
