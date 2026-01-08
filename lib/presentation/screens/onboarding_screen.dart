import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../features/missions/presentation/widgets/ransom_note_text.dart';
import '../../features/missions/presentation/widgets/arkhe_flame.dart';
import '../../features/missions/presentation/pages/onboarding_page.dart';
import '../../core/audio/audio_service.dart';

/// MVP Onboarding Screen con estética Cyberpunk/Rebellion
/// 
/// 3 slides con PageView swipeable:
/// 1. THE SYSTEM - El problema
/// 2. THE GLITCH - La solución (con GeoFlame)
/// 3. TRUE SELF - La transformación
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    
    // Reproducir sonido de slide al cambiar de página
    final audioService = Provider.of<AudioService>(context, listen: false);
    audioService.playSlide();
  }

  void _startRebellion() {
    // Reproducir sonido de confirmación
    final audioService = Provider.of<AudioService>(context, listen: false);
    audioService.playConfirm();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // PageView swipeable
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  // Slide 1: THE SYSTEM
                  _buildOnboardingPage(
                    icon: Icons.visibility_off_outlined,
                    title: 'THE SYSTEM',
                    body:
                        'El algoritmo está diseñado para mantenerte dócil, distraído y consumiendo. Eres combustible para ellos.',
                  ),

                  // Slide 2: THE GLITCH
                  _buildOnboardingPage(
                    customWidget: const GeoFlame(
                      width: 180,
                      height: 180,
                      intensity: 0.8,
                    ),
                    title: 'THE GLITCH',
                    body:
                        'Tu ambición es un error en su código. Arkhe es tu kit de sabotaje para recuperar tu atención.',
                  ),

                  // Slide 3: TRUE SELF
                  _buildOnboardingPage(
                    icon: Icons.fingerprint,
                    title: 'TRUE SELF',
                    body:
                        'Usa el fuego para quemar la niebla. Completa misiones. Escapa del promedio.',
                  ),
                ],
              ),
            ),

            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFD72638) // Punk Red
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Button (solo en última página)
            if (_currentPage == 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startRebellion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD72638), // Punk Red
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // Square corners
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'INICIAR REBELIÓN',
                      style: GoogleFonts.spaceMono(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 104), // Spacer para mantener altura consistente
          ],
        ),
      ),
    );
  }

  /// Método reutilizable para construir cada página del onboarding
  /// 
  /// Puede recibir un [icon] (IconData) O un [customWidget] (como GeoFlame).
  /// Ambos son opcionales pero al menos uno debe estar presente.
  Widget _buildOnboardingPage({
    IconData? icon,
    Widget? customWidget,
    required String title,
    required String body,
  }) {
    assert(
      icon != null || customWidget != null,
      'Debe proporcionar un icon o customWidget',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon o Custom Widget
          if (customWidget != null)
            customWidget
          else if (icon != null)
            Icon(
              icon,
              color: Colors.white,
              size: 120,
            ),

          const SizedBox(height: 60),

          // Title con RansomNoteText
          RansomNoteText(
            text: title,
            palette: const [
              Color(0xFFD72638), // Punk Red
              Colors.white,
              Color(0xFF4AF2F5), // Cian
            ],
            minFontSize: 28,
            maxFontSize: 42,
          ),

          const SizedBox(height: 40),

          // Body text (estilo terminal/monospace)
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              color: Colors.white70,
              height: 1.6,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
