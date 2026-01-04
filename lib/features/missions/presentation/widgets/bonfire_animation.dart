import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget de animación de hoguera con partículas
/// 
/// Simula una hoguera ardiendo con:
/// - Llamas animadas con movimiento oscilatorio
/// - Partículas de brasas flotando hacia arriba
/// - Gradiente de colores cálidos (rojo → naranja → amarillo)
/// - Efecto de resplandor (glow)
class BonfireAnimation extends StatefulWidget {
  final double size;
  final bool isActive;

  const BonfireAnimation({
    super.key,
    this.size = 200,
    this.isActive = true,
  });

  @override
  State<BonfireAnimation> createState() => _BonfireAnimationState();
}

class _BonfireAnimationState extends State<BonfireAnimation>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late AnimationController _particlesController;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Controlador para las llamas (oscilación continua)
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Controlador para las partículas (generación continua)
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_generateParticles);

    if (widget.isActive) {
      _particlesController.repeat();
    }

    // Generar partículas iniciales
    for (int i = 0; i < 20; i++) {
      _particles.add(_createParticle());
    }
  }

  @override
  void dispose() {
    _flameController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  void _generateParticles() {
    setState(() {
      // Actualizar partículas existentes
      _particles.removeWhere((p) => p.isDead);
      for (var particle in _particles) {
        particle.update();
      }

      // Generar nuevas partículas ocasionalmente
      if (_random.nextDouble() < 0.3) {
        _particles.add(_createParticle());
      }
    });
  }

  Particle _createParticle() {
    return Particle(
      x: widget.size / 2 + (_random.nextDouble() - 0.5) * widget.size * 0.3,
      y: widget.size * 0.7,
      size: _random.nextDouble() * 4 + 2,
      velocity: _random.nextDouble() * 2 + 1,
      lifetime: _random.nextInt(100) + 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flameController, _particlesController]),
        builder: (context, child) {
          return CustomPaint(
            painter: BonfirePainter(
              flameProgress: _flameController.value,
              particles: _particles,
            ),
          );
        },
      ),
    );
  }
}

/// Partícula de brasa que flota hacia arriba
class Particle {
  double x;
  double y;
  final double size;
  final double velocity;
  int age;
  final int lifetime;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
    required this.lifetime,
  }) : age = 0;

  void update() {
    y -= velocity;
    x += (math.Random().nextDouble() - 0.5) * 0.5; // Deriva lateral
    age++;
  }

  bool get isDead => age >= lifetime;

  double get opacity => 1.0 - (age / lifetime);
}

/// Painter personalizado que dibuja la hoguera
class BonfirePainter extends CustomPainter {
  final double flameProgress;
  final List<Particle> particles;

  BonfirePainter({
    required this.flameProgress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar base de leña (troncos oscuros)
    _drawLogs(canvas, size);

    // Dibujar llamas centrales
    _drawFlames(canvas, size);

    // Dibujar resplandor
    _drawGlow(canvas, size);

    // Dibujar partículas
    _drawParticles(canvas, size);
  }

  void _drawLogs(Canvas canvas, Size size) {
    final logPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.fill;

    final logShadow = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Tronco 1 (horizontal)
    final log1 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.8),
        width: size.width * 0.6,
        height: size.height * 0.12,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(log1, logShadow);
    canvas.drawRRect(log1, logPaint);

    // Tronco 2 (inclinado)
    canvas.save();
    canvas.translate(size.width * 0.3, size.height * 0.75);
    canvas.rotate(-0.3);
    final log2 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.5,
        height: size.height * 0.1,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(log2, logShadow);
    canvas.drawRRect(log2, logPaint);
    canvas.restore();
  }

  void _drawFlames(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.75;

    // Llama grande central
    _drawFlame(
      canvas,
      centerX,
      baseY,
      size.height * 0.5,
      size.width * 0.25,
      flameProgress,
      [
        const Color(0xFFFF6F00), // Naranja oscuro base
        const Color(0xFFFF8F00),
        const Color(0xFFFFA000),
        const Color(0xFFFFD54F), // Amarillo en la punta
      ],
    );

    // Llama izquierda
    _drawFlame(
      canvas,
      centerX - size.width * 0.15,
      baseY,
      size.height * 0.35,
      size.width * 0.18,
      1 - flameProgress,
      [
        const Color(0xFFE65100),
        const Color(0xFFFF6F00),
        const Color(0xFFFF8F00),
        const Color(0xFFFFA726),
      ],
    );

    // Llama derecha
    _drawFlame(
      canvas,
      centerX + size.width * 0.15,
      baseY,
      size.height * 0.38,
      size.width * 0.2,
      flameProgress * 0.7,
      [
        const Color(0xFFD84315),
        const Color(0xFFE65100),
        const Color(0xFFFF6F00),
        const Color(0xFFFF9800),
      ],
    );
  }

  void _drawFlame(
    Canvas canvas,
    double x,
    double y,
    double height,
    double width,
    double oscillation,
    List<Color> colors,
  ) {
    // Oscilación sinusoidal
    final wave = math.sin(oscillation * math.pi * 2) * width * 0.2;

    final path = Path();
    path.moveTo(x, y);

    // Curva izquierda
    path.quadraticBezierTo(
      x - width / 2 + wave,
      y - height * 0.3,
      x - width * 0.2 + wave * 0.5,
      y - height * 0.7,
    );

    // Punta de la llama
    path.quadraticBezierTo(
      x + wave * 0.3,
      y - height - wave * 0.5,
      x + width * 0.2 - wave * 0.5,
      y - height * 0.7,
    );

    // Curva derecha
    path.quadraticBezierTo(
      x + width / 2 - wave,
      y - height * 0.3,
      x,
      y,
    );

    path.close();

    // Gradiente de colores
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: colors,
    );

    final paint = Paint()
      ..shader = gradient.createShader(path.getBounds())
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  void _drawGlow(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.6),
      size.width * 0.4,
      glowPaint,
    );
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = Color.lerp(
          Colors.orange,
          Colors.yellow,
          particle.opacity,
        )!
            .withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BonfirePainter oldDelegate) {
    return oldDelegate.flameProgress != flameProgress ||
        oldDelegate.particles.length != particles.length;
  }
}
