import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget de celebración con confetti
/// 
/// Muestra una explosión de confetti cuando se completa una misión.
/// Inspirado en apps como Duolingo, Habitica, etc.
/// 
/// Uso:
/// ```dart
/// ConfettiCelebration(
///   child: MissionCard(...),
///   isCompleted: mission.isCompleted,
/// )
/// ```
class ConfettiCelebration extends StatefulWidget {
  final Widget child;
  final bool isCompleted;
  final Color primaryColor;
  final Duration duration;

  const ConfettiCelebration({
    super.key,
    required this.child,
    required this.isCompleted,
    this.primaryColor = Colors.orange,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  bool _hasShownConfetti = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si cambió de no-completado a completado → mostrar confetti
    if (!oldWidget.isCompleted && widget.isCompleted && !_hasShownConfetti) {
      _triggerConfetti();
    }
    
    // Si se desmarcó → resetear flag
    if (oldWidget.isCompleted && !widget.isCompleted) {
      _hasShownConfetti = false;
    }
  }

  void _triggerConfetti() {
    _hasShownConfetti = true;
    _particles.clear();
    
    // Generar partículas de confetti
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(ConfettiParticle(
        color: _randomColor(random),
        angle: random.nextDouble() * 2 * math.pi,
        velocity: 100 + random.nextDouble() * 100,
        angularVelocity: -2 + random.nextDouble() * 4,
        size: 4 + random.nextDouble() * 6,
        shape: random.nextBool() ? ConfettiShape.circle : ConfettiShape.square,
      ));
    }
    
    _controller.forward(from: 0.0);
  }

  Color _randomColor(math.Random random) {
    final colors = [
      widget.primaryColor,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        
        // Confetti overlay
        if (_particles.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(
                      particles: _particles,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Forma del confetti
enum ConfettiShape {
  circle,
  square,
}

/// Partícula de confetti
class ConfettiParticle {
  final Color color;
  final double angle;
  final double velocity;
  final double angularVelocity;
  final double size;
  final ConfettiShape shape;
  
  ConfettiParticle({
    required this.color,
    required this.angle,
    required this.velocity,
    required this.angularVelocity,
    required this.size,
    required this.shape,
  });
  
  double rotation = 0.0;
}

/// Painter personalizado para dibujar confetti
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  
  ConfettiPainter({
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (final particle in particles) {
      // Calcular posición con física simple
      final t = progress;
      final distance = particle.velocity * t;
      final gravity = 300 * t * t; // Gravedad
      
      final x = centerX + math.cos(particle.angle) * distance;
      final y = centerY + math.sin(particle.angle) * distance + gravity;
      
      // Actualizar rotación
      particle.rotation = particle.angularVelocity * progress * 2 * math.pi;
      
      // Fade out al final
      final opacity = 1.0 - progress;
      
      // Dibujar partícula
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation);
      
      if (particle.shape == ConfettiShape.circle) {
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );
      }
      
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Widget de pulso para stats
/// 
/// Muestra un efecto de pulso cuando el valor aumenta.
/// Útil para mostrar stats ganadas al completar misiones.
class StatPulse extends StatefulWidget {
  final Widget child;
  final bool shouldPulse;
  final Color color;

  const StatPulse({
    super.key,
    required this.child,
    required this.shouldPulse,
    this.color = Colors.orange,
  });

  @override
  State<StatPulse> createState() => _StatPulseState();
}

class _StatPulseState extends State<StatPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
    
    _opacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(StatPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.shouldPulse && widget.shouldPulse) {
      _controller.forward(from: 0.0);
    }
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
            // Anillo de pulso
            if (_controller.isAnimating)
              Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Widget hijo
            widget.child,
          ],
        );
      },
    );
  }
}
