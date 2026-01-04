import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/stat_type.dart';

/// Radar Chart personalizado para visualizar las 6 stats del usuario
/// 
/// DISEÑO:
/// - Hexágono (6 lados, uno por stat)
/// - Grilla con niveles: 0, 25, 50, 75, 100
/// - Color degradado desde el centro (rojo intenso → transparente)
/// - Labels con iconos y nombres de stats
/// - Animación de entrada suave
class StatsRadarChart extends StatefulWidget {
  final Map<StatType, double> stats; // valores de 0 a 100

  const StatsRadarChart({
    super.key,
    required this.stats,
  });

  @override
  State<StatsRadarChart> createState() => _StatsRadarChartState();
}

class _StatsRadarChartState extends State<StatsRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: RadarChartPainter(
            stats: widget.stats,
            animationProgress: _animation.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

/// CustomPainter que dibuja el radar chart hexagonal
class RadarChartPainter extends CustomPainter {
  final Map<StatType, double> stats;
  final double animationProgress;

  RadarChartPainter({
    required this.stats,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.5;
    final statList = StatType.values;
    final sides = statList.length; // 6 lados para 6 stats

    // Dibuja grilla de fondo (niveles: 25, 50, 75, 100)
    _drawGrid(canvas, center, radius, sides);

    // Dibuja el polígono de datos (las stats del usuario)
    _drawDataPolygon(canvas, center, radius, sides, statList);

    // Dibuja labels (nombres + valores de stats)
    _drawLabels(canvas, center, radius, sides, statList, size);
  }

  /// Dibuja la grilla hexagonal de fondo con niveles
  void _drawGrid(Canvas canvas, Offset center, double radius, int sides) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final axesPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Dibuja 4 niveles: 25%, 50%, 75%, 100%
    for (int level = 1; level <= 4; level++) {
      final levelRadius = radius * (level / 4);
      final path = _createPolygonPath(center, levelRadius, sides);
      canvas.drawPath(path, gridPaint);
    }

    // Dibuja ejes desde el centro hacia cada vértice
    for (int i = 0; i < sides; i++) {
      final angle = (math.pi * 2 / sides) * i - math.pi / 2;
      final vertex = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, vertex, axesPaint);
    }
  }

  /// Dibuja el polígono de datos (stats del usuario) con gradiente
  void _drawDataPolygon(Canvas canvas, Offset center, double radius, int sides, List<StatType> statList) {
    final path = Path();
    
    for (int i = 0; i < sides; i++) {
      final stat = statList[i];
      final value = (stats[stat] ?? 0.0).clamp(0.0, 100.0);
      final normalizedValue = value / 100.0 * animationProgress; // Animación
      
      final angle = (math.pi * 2 / sides) * i - math.pi / 2;
      final distance = radius * normalizedValue;
      
      final point = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );
      
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Fill con gradiente radial (rojo intenso en el centro)
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.redAccent.withOpacity(0.6),
          Colors.redAccent.withOpacity(0.3),
          Colors.redAccent.withOpacity(0.1),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // Borde del polígono
    final strokePaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // Dibuja puntos en cada vértice
    for (int i = 0; i < sides; i++) {
      final stat = statList[i];
      final value = (stats[stat] ?? 0.0).clamp(0.0, 100.0);
      final normalizedValue = value / 100.0 * animationProgress;
      
      final angle = (math.pi * 2 / sides) * i - math.pi / 2;
      final distance = radius * normalizedValue;
      
      final point = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );
      
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  /// Dibuja labels con nombres y valores de stats
  void _drawLabels(Canvas canvas, Offset center, double radius, int sides, List<StatType> statList, Size size) {
    const labelDistance = 1.3; // Distancia extra para los labels
    
    for (int i = 0; i < sides; i++) {
      final stat = statList[i];
      final value = (stats[stat] ?? 0.0).clamp(0.0, 100.0);
      
      final angle = (math.pi * 2 / sides) * i - math.pi / 2;
      final labelPos = Offset(
        center.dx + radius * labelDistance * math.cos(angle),
        center.dy + radius * labelDistance * math.sin(angle),
      );
      
      // Dibuja nombre de la stat
      final textSpan = TextSpan(
        text: stat.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
          ],
        ),
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      // Centra el texto según su posición angular
      double dx = labelPos.dx - textPainter.width / 2;
      double dy = labelPos.dy - textPainter.height / 2;
      
      // Ajuste fino según cuadrante para mejor legibilidad
      if (angle > -math.pi / 2 && angle < math.pi / 2) {
        // Derecha
        dx = labelPos.dx;
      } else {
        // Izquierda
        dx = labelPos.dx - textPainter.width;
      }
      
      textPainter.paint(canvas, Offset(dx, dy));
      
      // Dibuja valor numérico debajo
      final valueSpan = TextSpan(
        text: '${value.toInt()}',
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      );
      
      final valuePainter = TextPainter(
        text: valueSpan,
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      
      double valueDx = labelPos.dx - valuePainter.width / 2;
      double valueDy = dy + textPainter.height + 2;
      
      // Ajuste fino según cuadrante
      if (angle > -math.pi / 2 && angle < math.pi / 2) {
        valueDx = labelPos.dx;
      } else {
        valueDx = labelPos.dx - valuePainter.width;
      }
      
      valuePainter.paint(canvas, Offset(valueDx, valueDy));
    }
  }

  /// Crea un path para un polígono regular
  Path _createPolygonPath(Offset center, double radius, int sides) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (math.pi * 2 / sides) * i - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.stats != stats || oldDelegate.animationProgress != animationProgress;
  }
}
