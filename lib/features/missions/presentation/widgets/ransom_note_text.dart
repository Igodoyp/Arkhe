import 'dart:math';
import 'package:flutter/material.dart';

class RansomNoteText extends StatefulWidget {
  final String text;
  final List<Color> palette;
  final List<String>? fontFamilies; // Opcional: Lista de fuentes a usar
  final double minFontSize;
  final double maxFontSize;
  final double spacing;
  final WrapAlignment wrapAlignment;
  final WrapCrossAlignment wrapCrossAlignment;

  const RansomNoteText({
    super.key,
    required this.text,
    this.palette = const [
      Color(0xFFD72638), // Rojo Persona
      Colors.black,
      Colors.white,
      Color(0xFF333333), // Gris oscuro
      Color(0xFFF5F5F5), // Blanco papel
    ],
    this.fontFamilies, // Si es null, usa la default
    this.minFontSize = 24.0,
    this.maxFontSize = 34.0,
    this.spacing = 4.0,
    this.wrapAlignment = WrapAlignment.center,
    this.wrapCrossAlignment = WrapCrossAlignment.center,
  });

  @override
  State<RansomNoteText> createState() => _RansomNoteTextState();
}

class _RansomNoteTextState extends State<RansomNoteText> {
  late List<_LetterConfig> _letterConfigs;

  @override
  void initState() {
    super.initState();
    _generateConfigs();
  }

  @override
  void didUpdateWidget(covariant RansomNoteText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Regeneramos si cambia el texto o la paleta para mantener consistencia
    if (oldWidget.text != widget.text || oldWidget.palette != widget.palette) {
      _generateConfigs();
    }
  }

  void _generateConfigs() {
    int? lastColorIndex;
    _letterConfigs = [];

    for (int i = 0; i < widget.text.length; i++) {
      // Random determinista: basado en el índice y el carácter
      final seed = widget.text.codeUnitAt(i) + (i * 1000);
      final random = Random(seed);
      
      // 1. Lógica de Color: Nunca repetir el anterior
      int colorIndex;
      if (widget.palette.length > 1) {
        do {
          colorIndex = random.nextInt(widget.palette.length);
        } while (colorIndex == lastColorIndex);
      } else {
        colorIndex = 0;
      }
      lastColorIndex = colorIndex;

      // 2. Lógica de Fuente y Tamaño (Determinista por letra)
      final fontSize = widget.minFontSize +
          random.nextDouble() * (widget.maxFontSize - widget.minFontSize);
      
      String? fontFamily;
      if (widget.fontFamilies != null && widget.fontFamilies!.isNotEmpty) {
        fontFamily = widget.fontFamilies![random.nextInt(widget.fontFamilies!.length)];
      }

      // 3. Rotación (-10 a 10 grados aprox)
      final rotation = (random.nextDouble() * 0.35) - 0.17; 

      // 4. Semilla para el recorte irregular (determinista por letra)
      final clipSeed = seed;

      _letterConfigs.add(_LetterConfig(
        color: widget.palette[colorIndex],
        fontSize: fontSize,
        rotation: rotation,
        fontFamily: fontFamily,
        clipSeed: clipSeed,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Wrap para que el texto fluya si es muy largo
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.spacing * 1.5,
      alignment: widget.wrapAlignment,
      crossAxisAlignment: widget.wrapCrossAlignment,
      children: List.generate(widget.text.length, (index) {
        final char = widget.text[index];
        final config = _letterConfigs[index];

        // Manejo de espacios (no dibujamos caja)
        if (char.trim().isEmpty) {
          return SizedBox(width: config.fontSize / 2);
        }

        // Color de texto: Si el fondo es oscuro, letra blanca, si no, negra.
        // Calculamos la luminancia para decidir.
        final isBackgroundDark = config.color.computeLuminance() < 0.5;
        final textColor = isBackgroundDark ? Colors.white : Colors.black;

        return Transform.rotate(
          angle: config.rotation,
          child: ClipPath(
            clipper: IrregularCutClipper(seed: config.clipSeed),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
              color: config.color,
              child: Text(
                char,
                style: TextStyle(
                  fontFamily: config.fontFamily,
                  fontSize: config.fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor, 
                  height: 1.0, // Compactar altura de línea
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Configuración inmutable para cada letra
class _LetterConfig {
  final Color color;
  final double fontSize;
  final double rotation;
  final String? fontFamily;
  final int clipSeed;

  _LetterConfig({
    required this.color,
    required this.fontSize,
    required this.rotation,
    this.fontFamily,
    required this.clipSeed,
  });
}

/// El Clipper Mágico: Crea un cuadrilátero irregular
class IrregularCutClipper extends CustomClipper<Path> {
  final int seed;
  IrregularCutClipper({required this.seed});

  @override
  Path getClip(Size size) {
    final random = Random(seed);
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Factor de irregularidad (qué tan "chueco" es el corte)
    // 15% del tamaño total aprox
    final deltaW = w * 0.15; 
    final deltaH = h * 0.15;

    // Generamos 4 puntos moviendo ligeramente las esquinas originales
    
    // Esquina Superior Izquierda (0,0) -> movemos un poco hacia adentro/afuera
    path.moveTo(
      random.nextDouble() * deltaW, 
      random.nextDouble() * deltaH
    );

    // Esquina Superior Derecha (w,0)
    path.lineTo(
      w - (random.nextDouble() * deltaW), 
      random.nextDouble() * deltaH
    );

    // Esquina Inferior Derecha (w,h)
    path.lineTo(
      w - (random.nextDouble() * deltaW), 
      h - (random.nextDouble() * deltaH)
    );

    // Esquina Inferior Izquierda (0,h)
    path.lineTo(
      random.nextDouble() * deltaW, 
      h - (random.nextDouble() * deltaH)
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant IrregularCutClipper oldClipper) {
    return oldClipper.seed != seed;
  }
}