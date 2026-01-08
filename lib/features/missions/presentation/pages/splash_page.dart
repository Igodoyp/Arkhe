import 'package:flutter/material.dart';
import '../../data/datasources/user_profile_datasource.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/usecases/user_profile_usecase.dart';
import '../../../../presentation/screens/onboarding_screen.dart';
import 'mission_page.dart';

/// Splash screen que verifica si el usuario ha completado el onboarding
/// 
/// FLUJO:
/// 1. Muestra logo/loading
/// 2. Verifica si existe perfil de usuario
/// 3. Si existe Y hasCompletedOnboarding == true → MissionsPage
/// 4. Si NO existe O hasCompletedOnboarding == false → OnboardingScreen (MVP)
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animación de fade-in del logo
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
    
    // Verificar onboarding después de un delay
    _checkOnboarding();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkOnboarding() async {
    // Esperar al menos 2 segundos para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));
    
    // Crear dependencias con persistencia real
    final dataSource = await createUserProfileDataSource();
    final repository = UserProfileRepositoryImpl(dataSource: dataSource);
    final getUserProfileUseCase = GetUserProfileUseCase(repository);
    
    try {
      // Intentar obtener el perfil
      final profile = await getUserProfileUseCase();
      
      if (!mounted) return;
      
      // Decidir a dónde navegar
      if (profile != null && profile.hasCompletedOnboarding) {
        // Usuario ya completó onboarding → ir a misiones
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MissionsPage()),
        );
      } else {
        // Usuario nuevo o no completó onboarding → ir a onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      // Si hay error, ir a onboarding por seguridad
      print('[SplashPage] Error al verificar perfil: $e');
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Título ARKHE
              const Text(
                'ARKHE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: Colors.red,
                      blurRadius: 30,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'EL PRINCIPIO PRIMORDIAL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 60),
              
              // Loading indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.redAccent,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
