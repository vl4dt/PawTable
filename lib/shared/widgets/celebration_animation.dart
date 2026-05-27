import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// =========================================================================
// CELEBRATION MANAGER
// =========================================================================

/// Centralized service for triggering celebrations throughout the app
///
/// Usage:
/// ```dart
/// CelebrationManager.triggerMilestone(context, 'Streak 30');
/// CelebrationManager.triggerConfetti(context);
/// ```
class CelebrationManager {
  CelebrationManager._();

  /// Trigger confetti burst across the screen
  static Future<void> triggerConfetti(BuildContext context, {Duration? duration}) async {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (ctx) => Positioned.fill(
        child: ConfettiAnimation(
          duration: duration ?? const Duration(milliseconds: 1500),
          particleCount: 60,
          autoRemove: true,
        ),
      ),
    );
    overlay.insert(entry);
  }

  /// Trigger fireworks for diamond-tier milestones
  static Future<void> triggerFireworks(BuildContext context) async {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (ctx) => Positioned.fill(
        child: FireworksAnimation(
          duration: const Duration(seconds: 2),
          burstCount: 5,
          autoRemove: true,
        ),
      ),
    );
    overlay.insert(entry);
  }

  /// Trigger a badge reveal animation with achievement name
  static void triggerBadgeReveal(BuildContext context, {required String badgeName}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Achievement Unlocked!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    badgeName,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Trigger a milestone celebration (confetti + badge reveal)
  static Future<void> triggerMilestone(
    BuildContext context, {
    required String milestoneName,
    String? tier,
  }) async {
    await triggerConfetti(context, duration: const Duration(milliseconds: 1500));
    await Future.delayed(const Duration(milliseconds: 800));
    triggerBadgeReveal(context, badgeName: milestoneName);
  }

  /// Trigger a major milestone (diamond tier — fireworks)
  static Future<void> triggerMajorMilestone(
    BuildContext context, {
    required String milestoneName,
  }) async {
    await triggerConfetti(context, duration: const Duration(milliseconds: 2000));
    await Future.delayed(const Duration(milliseconds: 500));
    await triggerFireworks(context);
    await Future.delayed(const Duration(milliseconds: 500));
    triggerBadgeReveal(context, badgeName: '🏆 $milestoneName');
  }
}

// =========================================================================
// CONFETTI
// =========================================================================

/// Screen-covering confetti burst from multiple points
class ConfettiAnimation extends StatefulWidget {
  final Duration duration;
  final int particleCount;
  final List<Color> colors;
  final bool autoRemove;
  final VoidCallback? onComplete;

  const ConfettiAnimation({
    super.key,
    this.duration = const Duration(milliseconds: 1500),
    this.particleCount = 60,
    this.colors = const [
      Color(0xFFF4A261),
      Color(0xFFA8D5BA),
      Color(0xFFB5C9D9),
      Color(0xFFF8E167),
      Color(0xFFF2B8B8),
      Color(0xFFD4C5E2),
      Color(0xFFFFD700),
      Color(0xFFFF69B4),
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
  bool _done = false;

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
      if (widget.autoRemove && mounted && !_done) {
        _done = true;
        widget.onComplete?.call();
      }
    });

    _particles = List.generate(
      widget.particleCount,
      (index) => _ConfettiParticle.random(
        colors: widget.colors,
        controller: _controller,
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
      children: _particles.map((p) => _buildParticle(p)).toList(),
    );
  }

  Widget _buildParticle(_ConfettiParticle p) {
    final t = p.animation.value;
    final x = p.startX + (p.endX - p.startX) * t;
    final y = p.startY + (p.endY - p.startY) * t;
    final rotation = p.rotation * t;
    final opacity = t < 0.8 ? 1.0 : (1.0 - (t - 0.8) / 0.2);

    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Container(
            width: p.size,
            height: p.size,
            color: p.color,
            decoration: BoxDecoration(
              borderRadius: p.isCircle
                  ? null
                  : BorderRadius.circular(p.size / 2),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double size;
  final bool isCircle;
  final double startX, startY;
  final double endX, endY;
  final double rotation;
  final Animation<double> animation;

  _ConfettiParticle({
    required this.color,
    required this.size,
    required this.isCircle,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.rotation,
    required this.animation,
  });

  factory _ConfettiParticle.random({
    required List<Color> colors,
    required AnimationController controller,
  }) {
    final random = Random();
    final angle = random.nextDouble() * pi * 2;
    final distance = 100 + random.nextDouble() * 200;

    return _ConfettiParticle(
      color: colors[random.nextInt(colors.length)],
      size: 6 + random.nextDouble() * 12,
      isCircle: random.nextBool(),
      startX: 0,
      startY: 0,
      endX: cos(angle) * distance,
      endY: sin(angle) * distance + 100,
      rotation: (random.nextDouble() - 0.5) * pi * 6,
      animation: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}

// =========================================================================
// BADGE REVEAL
// =========================================================================

/// Badge reveal animation — dramatic scale bounce with glow and shine
class BadgeRevealAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool repeat;
  final VoidCallback? onComplete;

  const BadgeRevealAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
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
      _controller.forward().whenComplete(() {
        if (mounted) widget.onComplete?.call();
      });
    } else {
      _controller.repeat(reverse: true);
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
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Scale bounce: overshoot 1.3 then settle to 1.0
        final scale = value < 0.5
            ? Tween(begin: 0.0, end: 1.3).transform(value * 2)
            : Tween(begin: 1.3, end: 1.0).transform((value - 0.5) * 2);

        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              if (value < 0.5)
                Container(
                  width: 80 + value * 40,
                  height: 80 + value * 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withValues(alpha: (1 - value) * 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              // Shine sweep effect
              if (value > 0.3 && value < 0.7)
                Positioned.fill(
                  child: ClipRect(
                    child: Transform.translate(
                      offset: Offset(-50 + value * 200, 0),
                      child: Container(
                        width: 50,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }

  /// Show a badge reveal toast
  static void trigger(BuildContext context, {Duration? duration}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
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

// =========================================================================
// FIREWORKS
// =========================================================================

/// Fireworks animation — multiple bursts across the screen
class FireworksAnimation extends StatefulWidget {
  final Duration duration;
  final int burstCount;
  final bool autoRemove;
  final VoidCallback? onComplete;

  const FireworksAnimation({
    super.key,
    this.duration = const Duration(seconds: 2),
    this.burstCount = 5,
    this.autoRemove = true,
    this.onComplete,
  });

  @override
  State<FireworksAnimation> createState() => _FireworksAnimationState();
}

class _FireworksAnimationState extends State<FireworksAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_FireworkBurst> _bursts;
  bool _done = false;

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
      if (widget.autoRemove && mounted && !_done) {
        _done = true;
        widget.onComplete?.call();
      }
    });

    _bursts = List.generate(
      widget.burstCount,
      (index) => _FireworkBurst(
        position: Offset(
          Random().nextDouble() * 300 - 150,
          Random().nextDouble() * 200 - 100,
        ),
        index: index,
        totalBursts: widget.burstCount,
        controller: _controller,
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
      children: _bursts.map((burst) => _buildBurst(burst)).toList(),
    );
  }

  Widget _buildBurst(_FireworkBurst burst) {
    return Positioned.fill(
      child: Center(
        child: Transform.translate(
          offset: burst.offsetAt(burst.animation.value),
          child: Stack(
            children: burst.particles.map((p) => _buildParticle(p)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildParticle(_FireworkParticle p) {
    final t = p.animation.value;
    return Transform.translate(
      offset: Offset(p.vx * t, p.vy * t + 50 * t * t),
      child: Opacity(
        opacity: (1 - t).clamp(0.0, 1.0),
        child: Container(
          width: p.size,
          height: p.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: p.color,
            boxShadow: [
              BoxShadow(
                color: p.color,
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FireworkBurst {
  final Offset position;
  final int index;
  final int totalBursts;
  final AnimationController controller;
  late Animation<double> animation;
  late List<_FireworkParticle> particles;

  _FireworkBurst({
    required this.position,
    required this.index,
    required this.totalBursts,
    required this.controller,
  }) {
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          index / totalBursts,
          (index + 1) / totalBursts,
          curve: Curves.easeIn,
        ),
      ),
    );

    final random = Random(index);
    final colors = [
      const Color(0xFFF4A261),
      const Color(0xFFA8D5BA),
      const Color(0xFFF8E167),
      const Color(0xFFF2B8B8),
      const Color(0xFFD4C5E2),
      const Color(0xFFFF69B4),
      const Color(0xFF00CED1),
    ];

    particles = List.generate(20, (i) {
      final angle = (i / 20) * pi * 2;
      final speed = 40 + random.nextDouble() * 60;
      return _FireworkParticle(
        color: colors[random.nextInt(colors.length)],
        size: 3 + random.nextDouble() * 4,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        animation: animation,
      );
    });
  }

  Offset offsetAt(double t) {
    return Offset(
      position.dx + cos(index) * 50 * t,
      position.dy + sin(index) * 30 * t,
    );
  }
}

class _FireworkParticle {
  final Color color;
  final double size;
  final double vx, vy;
  final Animation<double> animation;

  _FireworkParticle({
    required this.color,
    required this.size,
    required this.vx,
    required this.vy,
    required this.animation,
  });
}

// =========================================================================
// STREAK FIRE
// =========================================================================

/// Pulsing flame glow animation for streak achievements
class StreakFireAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback? onComplete;

  const StreakFireAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
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

// =========================================================================
// ACHIEVEMENT POPUP OVERLAY
// =========================================================================

/// Full celebration overlay — shows when an achievement is unlocked
class AchievementPopupOverlay extends StatelessWidget {
  final String badgeName;
  final String description;
  final IconData icon;
  final Color tierColor;
  final Duration showDuration;
  final VoidCallback? onDismiss;

  const AchievementPopupOverlay({
    super.key,
    required this.badgeName,
    required this.description,
    required this.icon,
    required this.tierColor,
    this.showDuration = const Duration(seconds: 3),
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: _AchievementCard(
                    badgeName: badgeName,
                    description: description,
                    icon: icon,
                    tierColor: tierColor,
                    showDuration: showDuration,
                    onDismiss: onDismiss,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatefulWidget {
  final String badgeName;
  final String description;
  final IconData icon;
  final Color tierColor;
  final Duration showDuration;
  final VoidCallback? onDismiss;

  const _AchievementCard({
    required this.badgeName,
    required this.description,
    required this.icon,
    required this.tierColor,
    required this.showDuration,
    this.onDismiss,
  });

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _dismissiveController;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _dismissiveController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dismissTimer = Timer(widget.showDuration, () {
      if (mounted) {
        _dismissiveController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _dismissiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.tierColor.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.tierColor.withValues(alpha: 0.15),
                    widget.tierColor.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: widget.tierColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.tierColor,
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Badge name
                  Text(
                    widget.badgeName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.tierColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
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
