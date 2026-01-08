import 'package:flutter/material.dart';
import '../widgets/ransom_note_text.dart';
import '../widgets/arkhe_flame.dart';

class RansomNoteDemoPage extends StatelessWidget {
  const RansomNoteDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Widgets')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: RansomNoteText(
              text: "TAKE YOUR HEART",
              palette: [
                Color(0xFFD72638), // Rojo P5
                Colors.black,
                Colors.white,
              ],
              fontFamilies: ['Impact', 'Arial Black'], // Fuentes gruesas del sistema
            )
          ),
          const SizedBox(height: 48),
          Center(
            child: GeoFlame(
              width: 150,
              height: 250,
              intensity: 0.8, // Prueba cambiar esto a 0.2 y 1.0
            )
          ),
        ],
      ),
    );
  }
}
