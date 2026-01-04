import 'package:flutter/material.dart';

/// Widget de shimmer loading effect
/// 
/// Crea un efecto de "brillo" que se mueve de izquierda a derecha,
/// simulando que el contenido se está cargando.
/// 
/// Uso:
/// ```dart
/// Shimmer(
///   child: Container(
///     width: 200,
///     height: 20,
///     color: Colors.white,
///   ),
/// )
/// ```
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration period;
  final Color baseColor;
  final Color highlightColor;
  final ShimmerDirection direction;

  const Shimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.direction = ShimmerDirection.leftToRight,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: _getBeginAlignment(),
              end: _getEndAlignment(),
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                0.35 + (_controller.value * 0.3),
                0.5 + (_controller.value * 0.3),
                0.65 + (_controller.value * 0.3),
                1.0,
              ],
            ).createShader(bounds);
          },
          child: child!,
        );
      },
      child: widget.child,
    );
  }

  Alignment _getBeginAlignment() {
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return Alignment.centerLeft;
      case ShimmerDirection.rightToLeft:
        return Alignment.centerRight;
      case ShimmerDirection.topToBottom:
        return Alignment.topCenter;
      case ShimmerDirection.bottomToTop:
        return Alignment.bottomCenter;
    }
  }

  Alignment _getEndAlignment() {
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return Alignment.centerRight;
      case ShimmerDirection.rightToLeft:
        return Alignment.centerLeft;
      case ShimmerDirection.topToBottom:
        return Alignment.bottomCenter;
      case ShimmerDirection.bottomToTop:
        return Alignment.topCenter;
    }
  }
}

enum ShimmerDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// Skeleton loader para mission cards
class MissionCardSkeleton extends StatelessWidget {
  const MissionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Checkbox skeleton
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title skeleton
                Expanded(
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Icon skeleton
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Description skeleton
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 14,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            
            // Stats skeleton
            Row(
              children: [
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
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

/// Skeleton loader para stats page
class StatsPageSkeleton extends StatelessWidget {
  const StatsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Radar chart skeleton
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 40),
            
            // Stats bars skeleton
            ...List.generate(6, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 30,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Pulse loading indicator - Mejor que CircularProgressIndicator
class PulseLoader extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const PulseLoader({
    super.key,
    this.color = Colors.orange,
    this.size = 60,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse
            Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            
            // Center circle
            Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
              child: const Center(
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Dots loader - Tres puntos animados
class DotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const DotsLoader({
    super.key,
    this.color = Colors.orange,
    this.size = 12,
  });

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 1.0 + (0.5 * (1.0 - (value - 0.5).abs() * 2));
            
            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
