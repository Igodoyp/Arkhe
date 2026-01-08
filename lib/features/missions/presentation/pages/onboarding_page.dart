import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/time/time_provider.dart';
import '../../../../core/audio/audio_service.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../data/datasources/user_profile_datasource.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/usecases/user_profile_usecase.dart';
import 'mission_page.dart';

/// Pantalla de onboarding "El Despertar"
/// 
/// NARRATIVA:
/// El usuario despierta en un mundo donde debe forjar su identidad
/// completando misiones diarias. Morgana (AI) será su guía.
/// 
/// FLUJO:
/// 1. Intro cinemática con la historia
/// 2. Creación de perfil (nombre + motivación)
/// 3. Selección de áreas de enfoque
/// 4. Finalización con ritual de inicio
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Datos del formulario
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();
  final Set<String> _selectedFocusAreas = {};
  
  // Áreas disponibles
  static const List<String> _availableFocusAreas = [
    'Salud Física',
    'Salud Mental',
    'Carrera Profesional',
    'Aprendizaje',
    'Relaciones',
    'Creatividad',
    'Finanzas',
    'Espiritualidad',
  ];

  @override
  void initState() {
    super.initState();
    // Agregar listeners para actualizar el UI cuando el usuario escribe
    _nameController.addListener(() {
      setState(() {});
    });
    _motivationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Validar datos
    if (_nameController.text.trim().isEmpty) {
      _showError('Por favor ingresa tu nombre');
      return;
    }
    
    if (_motivationController.text.trim().isEmpty) {
      _showError('Por favor describe tu motivación');
      return;
    }
    
    if (_selectedFocusAreas.isEmpty) {
      _showError('Selecciona al menos un área de enfoque');
      return;
    }

    // Obtener TimeProvider global para timestamp
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);

    // Crear perfil
    final profile = UserProfile(
      id: 'default',
      name: _nameController.text.trim(),
      idealSelfDescription: _motivationController.text.trim(),
      focusAreas: _selectedFocusAreas.toList(),
      currentGoals: [], // Se pueden agregar más adelante
      challengePreferences: {}, // Valores por defecto
      hasCompletedOnboarding: true,
      lastUpdated: timeProvider.now,
    );

    // Guardar perfil con persistencia real
    final dataSource = await createUserProfileDataSource();
    final repository = UserProfileRepositoryImpl(dataSource: dataSource);
    final saveUseCase = SaveUserProfileUseCase(repository);
    
    try {
      await saveUseCase(profile);
      
      // Navegar a la pantalla principal
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MissionsPage()),
      );
    } catch (e) {
      _showError('Error al guardar perfil: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildNamePage(),
          _buildMotivationPage(),
          _buildFocusAreasPage(),
        ],
      ),
    );
  }

  /// Página 1: Intro cinemática
  Widget _buildIntroPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.red.shade900.withOpacity(0.3),
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título "EL DESPERTAR"
              const Text(
                'EL DESPERTAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Colors.red,
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              
              // Narrativa
              const Text(
                'En un mundo donde cada día es una batalla...\n\n'
                'Donde la rutina amenaza con consumir tu esencia...\n\n'
                'Una fuerza ancestral despierta dentro de ti.\n\n'
                'ARKHE - El Principio Primordial.\n\n'
                'Tu misión: Forjar tu identidad completando desafíos diarios.\n\n'
                'Morgana, guardiana del conocimiento antiguo, será tu guía.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.8,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              
              // Botón "Comenzar"
              ElevatedButton(
                onPressed: () {
                  final audioService = Provider.of<AudioService>(context, listen: false);
                  audioService.playTap();
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black, width: 3),
                  ),
                ),
                child: const Text(
                  'DESPERTAR',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Página 2: Nombre del usuario
  Widget _buildNamePage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.red.shade900.withOpacity(0.2),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿CUÁL ES TU NOMBRE?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: Colors.red, blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Morgana necesita saber cómo dirigirse a ti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 60),
              
              // Input de nombre
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tu nombre...',
                    hintStyle: TextStyle(
                      color: Colors.white30,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      final audioService = Provider.of<AudioService>(context, listen: false);
                      audioService.playTap();
                      _previousPage();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'VOLVER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nameController.text.trim().isEmpty
                        ? null
                        : () {
                            final audioService = Provider.of<AudioService>(context, listen: false);
                            audioService.playTap();
                            _nextPage();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Página 3: Motivación/Ideal Self
  Widget _buildMotivationPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.red.shade900.withOpacity(0.2),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿QUIÉN ASPIRAS SER?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: Colors.red, blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Describe tu versión ideal. Morgana usará esto para crear tus misiones.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // Input de motivación
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: TextField(
                  controller: _motivationController,
                  maxLines: 8,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ej: Quiero ser una persona disciplinada que mantiene balance entre trabajo, salud y aprendizaje continuo...',
                    hintStyle: TextStyle(
                      color: Colors.white30,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      final audioService = Provider.of<AudioService>(context, listen: false);
                      audioService.playTap();
                      _previousPage();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'VOLVER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _motivationController.text.trim().isEmpty
                        ? null
                        : () {
                            final audioService = Provider.of<AudioService>(context, listen: false);
                            audioService.playTap();
                            _nextPage();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Página 4: Áreas de enfoque
  Widget _buildFocusAreasPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.red.shade900.withOpacity(0.2),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿EN QUÉ ÁREAS QUIERES ENFOCARTE?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: Colors.red, blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Selecciona las áreas que son prioritarias para ti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // Grid de áreas
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _availableFocusAreas.length,
                  itemBuilder: (context, index) {
                    final area = _availableFocusAreas[index];
                    final isSelected = _selectedFocusAreas.contains(area);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedFocusAreas.remove(area);
                          } else {
                            _selectedFocusAreas.add(area);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.redAccent : Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.red : Colors.white30,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            area.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      final audioService = Provider.of<AudioService>(context, listen: false);
                      audioService.playTap();
                      _previousPage();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'VOLVER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectedFocusAreas.isEmpty
                        ? null
                        : () {
                            final audioService = Provider.of<AudioService>(context, listen: false);
                            audioService.playTap();
                            _completeOnboarding();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'COMENZAR VIAJE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
