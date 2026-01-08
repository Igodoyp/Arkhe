import 'dart:math' as math;
import 'package:flutter/material.dart';

class GeoFlame extends StatefulWidget {
  final double width;
  final double height;
  final double intensity; // 0.0 a 1.0
  final Color? colorOutline;
  final Color? colorBody;
  final Color? colorCore;

  const GeoFlame({
    super.key,
    this.width = 120,
    this.height = 180,
    this.intensity = 0.6,
    this.colorOutline,
    this.colorBody,
    this.colorCore,
  });

  @override
  State<GeoFlame> createState() => _GeoFlameState();
}

class _GeoFlameState extends State<GeoFlame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Ligeramente más rápido
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Paleta Promare / Arkhe (defaults)
    final colorOutline = widget.colorOutline ?? const Color(0xFF1A0515); // Negro/Violeta oscuro
    final colorBody = widget.colorBody ?? const Color(0xFFD72638);    // Rojo Intenso
    final colorCore = widget.colorCore ?? const Color(0xFF4AF2F5);    // Cian Neón

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _LowPolyFlamePainter(
            time: _controller.value,
            intensity: widget.intensity,
            colorOutline: colorOutline,
            colorBody: colorBody,
            colorCore: colorCore,
          ),
        );
      },
    );
  }
}

class _LowPolyFlamePainter extends CustomPainter {
  final double time;
  final double intensity;
  final Color colorOutline;
  final Color colorBody;
  final Color colorCore;

  _LowPolyFlamePainter({
    required this.time,
    required this.intensity,
    required this.colorOutline,
    required this.colorBody,
    required this.colorCore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Shards (Chispas geométricas)
    _drawShard(canvas, w * 0.2, h * 0.8, 0.0, 1.2);
    _drawShard(canvas, w * 0.8, h * 0.9, 0.5, 0.9);
    _drawShard(canvas, w * 0.5, h * 0.7, 0.2, 1.5);
    
    // 2. Capa Base (Sombra/Outline) 
    // Ahora le damos más "cuerpo" abajo para que se note la redondez
    _drawJaggedPoly(
      canvas, size,
      color: colorOutline,
      heightMulti: 0.95, 
      widthMulti: 1.0, 
      roundBaseFactor: 1.0, // Base ancha
      seed: 1, 
    );

    // 3. Capa Cuerpo (Rojo)
    _drawJaggedPoly(
      canvas, size,
      color: colorBody,
      heightMulti: 0.85,
      widthMulti: 0.85,
      roundBaseFactor: 0.8,
      seed: 2,
    );

    // 4. Capa Núcleo (Cian)
    _drawJaggedPoly(
      canvas, size,
      color: colorCore,
      heightMulti: 0.5,
      widthMulti: 0.45,
      roundBaseFactor: 0.5,
      seed: 3,
    );
  }

  void _drawJaggedPoly(
    Canvas canvas, 
    Size size, {
    required Color color,
    required double heightMulti, // Qué tan alto llega
    required double widthMulti,  // Qué tan ancho es
    required double roundBaseFactor, // Qué tanto se curva la base
    required int seed,
  }) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    // Altura efectiva de la llama
    final flameTop = h * (1.0 - heightMulti); 
    // Ancho efectivo
    final flameW = w * widthMulti;
    final margin = (w - flameW) / 2;

    // Función de ruido
    double noise(double offset, double speed, double amp) {
      return math.sin((time * math.pi * 2 * speed) + offset + seed) * amp;
    }

    // --- COMIENZO DEL TRAZADO ---
    
    // 1. BASE IZQUIERDA (El inicio de la curva)
    // No empezamos en h (el piso absoluto), sino un poco más arriba
    // para dar espacio a la panza de la base.
    final baseCurveHeight = h * 0.15 * roundBaseFactor; // Altura de la curvatura
    
    // Punto inicial: Abajo-Izquierda (pero levantado)
    path.moveTo(margin, h - baseCurveHeight);

    // 2. LADO IZQUIERDO (Subiendo en Zig Zag)
    path.lineTo(
      margin - (noise(1, 2, 5)), 
      h - (h * 0.4) // Cintura
    );
    path.lineTo(
      margin + (w * 0.15) + noise(2, 3, 10 * intensity), 
      flameTop + (h * 0.3) // Hombro
    );

    // 3. LA PUNTA (Peak)
    final tipX = (w / 2) + noise(0, 4, 25 * intensity);
    final tipY = flameTop + noise(5, 6, 15 * intensity);
    path.lineTo(tipX, tipY);

    // 4. LADO DERECHO (Bajando en Zig Zag)
    path.lineTo(
      w - margin - (w * 0.15) + noise(3, 3, 10 * intensity), 
      flameTop + (h * 0.35)
    );
    path.lineTo(
      w - margin + noise(4, 2, 5), 
      h - (h * 0.45)
    );

    // --- AQUI ESTA EL CAMBIO: LA BASE REDONDEADA GEOMETRICA ---
    // En lugar de cerrar recto, dibujamos segmentos que forman una "U" poligonal.
    
    // Punto 5: Abajo-Derecha (Simétrico al inicio)
    path.lineTo(w - margin, h - baseCurveHeight);

    // Punto 6: Corte inferior derecho (Intermedio)
    path.lineTo(
      w - margin - (flameW * 0.25), 
      h - (baseCurveHeight * 0.3) + noise(10, 2, 3) // Pequeño movimiento en la base
    );

    // Punto 7: EL FONDO (El punto más bajo, centro)
    path.lineTo(
      w / 2 + noise(11, 1, 5), 
      h // Toca el suelo
    );

    // Punto 8: Corte inferior izquierdo (Intermedio)
    path.lineTo(
      margin + (flameW * 0.25), 
      h - (baseCurveHeight * 0.3) - noise(12, 2, 3)
    );

    // Cerramos volviendo al inicio
    path.close();

    // Dibujado
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, paint);
  }

  void _drawShard(Canvas canvas, double xBase, double hBase, double offset, double speed) {
    final loop = ((time * speed) + offset) % 1.0;
    if (loop < 0.05 || loop > 0.95) return; // Fade in/out

    final yPos = hBase - (hBase * loop * 0.8); 
    // Movimiento lateral errático para los fragmentos
    final xPos = xBase + (math.sin(loop * 25) * 5); 
    
    final size = 10.0 * (1.0 - loop); 

    // Fragmentos triangulares (Shards)
    final path = Path();
    path.moveTo(xPos, yPos);
    path.lineTo(xPos - size/2, yPos + size);
    path.lineTo(xPos + size/2, yPos + size + (math.sin(time*10)*2)); // Base deforme
    path.close();

    canvas.drawPath(path, Paint()..color = colorBody.withOpacity(0.7));
  }

  @override
  bool shouldRepaint(covariant _LowPolyFlamePainter oldDelegate) => true;
}