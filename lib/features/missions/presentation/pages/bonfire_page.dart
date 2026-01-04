// presentation/pages/bonfire_page.dart

// ============================================================================
// BONFIRE PAGE (HOGUERA) - RITUAL VERSION
// ============================================================================
// Experiencia cinemática inspirada en Dark Souls donde el usuario descansa
// tras completar el día y reflexiona sobre su jornada.
//
// FASES DEL RITUAL:
// 1. Intro Cinemática - Fade in con título "DÍA COMPLETADO"
// 2. Resumen Épico - Misiones completadas con animaciones
// 3. Hoguera Animada - Fuego ardiendo con partículas
// 4. Reflexión - Usuario escribe sus pensamientos
// 5. Palabras de Morgana - AI analiza y ofrece sabiduría

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/day_feedback_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/stat_type.dart';
import '../controllers/bonfire_controller.dart';
import '../controllers/day_session_controller.dart';
import '../widgets/bonfire_animation.dart';

class BonfirePage extends StatefulWidget {
  final String sessionId;
  final List<Mission> completedMissions;
  final int totalStatsGained;
  final DaySessionController daySessionController;

  const BonfirePage({
    super.key,
    required this.sessionId,
    required this.completedMissions,
    required this.totalStatsGained,
    required this.daySessionController,
  });

  @override
  State<BonfirePage> createState() => _BonfirePageState();
}

class _BonfirePageState extends State<BonfirePage>
    with TickerProviderStateMixin {
  // Fase del ritual (0 = intro cinemática, 1 = ritual principal)
  int _phase = 0;

  // Controladores de animación
  late AnimationController _cinematicController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _statsAnimation;

  final TextEditingController _reflectionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Animación cinemática inicial (3 segundos)
    _cinematicController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Animación de fade general
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Animaciones escalonadas para intro cinemática
    _titleAnimation = CurvedAnimation(
      parent: _cinematicController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _statsAnimation = CurvedAnimation(
      parent: _cinematicController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    // Inicializar controller y comenzar intro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<BonfireController>();
      controller.initialize(
        sessionId: widget.sessionId,
        completedMissionIds: widget.completedMissions.map((m) => m.id).toList(),
      );

      // Comenzar animación cinemática
      _cinematicController.forward().then((_) {
        // Esperar 1 segundo y transicionar a fase principal
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() => _phase = 1);
            _fadeController.forward();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _cinematicController.dispose();
    _fadeController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<BonfireController>(
        builder: (context, controller, child) {
          if (controller.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${controller.errorMessage ?? "Unknown error"}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          if (!controller.isReady && !controller.isSaved) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (controller.isSaved) {
            return _buildSuccessScreen(context, controller);
          }

          // Fase 0: Intro cinemática
          if (_phase == 0) {
            return _buildCinematicIntro(context);
          }

          // Fase 1: Ritual principal
          return _buildRitualScreen(context, controller);
        },
      ),
    );
  }

  // ========================================================================
  // FASE 0: INTRO CINEMÁTICA
  // ========================================================================

  Widget _buildCinematicIntro(BuildContext context) {
    return AnimatedBuilder(
      animation: _cinematicController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Color(0xFF2a1a0a), // Marrón oscuro centro
                Colors.black, // Negro bordes
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título "DÍA COMPLETADO"
                FadeTransition(
                  opacity: _titleAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      _titleAnimation,
                    ),
                    child: Column(
                      children: [
                        // Ornamento superior
                        _buildOrnament(),
                        const SizedBox(height: 24),

                        // Título principal
                        Text(
                          'DÍA COMPLETADO',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade300,
                            letterSpacing: 4,
                            shadows: const [
                              Shadow(
                                color: Colors.orange,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Ornamento inferior
                        _buildOrnament(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Estadísticas del día
                FadeTransition(
                  opacity: _statsAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_statsAnimation),
                    child: Column(
                      children: [
                        // Misiones completadas
                        _buildCinematicStat(
                          'Misiones Completadas',
                          '${widget.completedMissions.length}',
                          Icons.check_circle,
                        ),
                        const SizedBox(height: 20),

                        // Stats ganadas
                        _buildCinematicStat(
                          'Stats Ganadas',
                          '+${widget.totalStatsGained}',
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrnament() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.orange.shade300,
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.local_fire_department,
          color: Colors.orange.shade300,
          size: 24,
        ),
        const SizedBox(width: 12),
        Container(
          width: 60,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade300,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCinematicStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange.shade900.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.orange.shade300,
            size: 28,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.orange.shade200,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // FASE 1: RITUAL PRINCIPAL (HOGUERA + REFLEXIÓN)
  // ========================================================================

  Widget _buildRitualScreen(BuildContext context, BonfireController controller) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFF3a1a0a), // Centro cálido
              Color(0xFF1a1a1a), // Bordes oscuros
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // ========== HOGUERA ANIMADA ==========
                const BonfireAnimation(
                  size: 200,
                  isActive: true,
                ),
                const SizedBox(height: 40),

                // ========== TÍTULO DEL RITUAL ==========
                Text(
                  '⚔️ LA HOGUERA ⚔️',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade300,
                    letterSpacing: 3,
                    shadows: const [
                      Shadow(
                        color: Colors.orange,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Subtítulo épico
                Text(
                  'Descansa, viajero. Reflexiona sobre tu jornada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade200.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 40),

                // ========== RESUMEN ÉPICO DE MISIONES ==========
                _buildEpicMissionSummary(),
                const SizedBox(height: 40),

                // ========== SECCIÓN DE REFLEXIÓN ==========
                _buildReflectionSection(controller),
                const SizedBox(height: 32),

                // ========== BOTONES DE ACCIÓN ==========
                _buildActionButtons(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEpicMissionSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade900.withOpacity(0.1),
            Colors.orange.shade900.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.orange.shade900.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de sección
          Row(
            children: [
              Icon(
                Icons.military_tech,
                color: Colors.orange.shade300,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'LOGROS DEL DÍA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade300,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lista de misiones completadas
          if (widget.completedMissions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No se completaron misiones hoy',
                  style: TextStyle(
                    color: Colors.orange.shade200.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...widget.completedMissions.asMap().entries.map((entry) {
              final index = entry.key;
              final mission = entry.value;
              return _buildMissionCard(mission, index);
            }),

          const SizedBox(height: 16),

          // Resumen de stats ganadas
          Divider(color: Colors.orange.shade900.withOpacity(0.3)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total de Stats Ganadas',
                style: TextStyle(
                  color: Colors.orange.shade200,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${widget.totalStatsGained}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Mission mission, int index) {
    // Determinar stat principal (la de mayor valor)
    final statEntries = mission.statsReward.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final primaryStatName = statEntries.first.key;
    final primaryStat = StatType.values.firstWhere(
      (s) => s.name == primaryStatName,
      orElse: () => StatType.strength,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(
          color: primaryStat.color.withOpacity(0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Número de misión
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primaryStat.color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryStat.color,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: primaryStat.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Título de misión
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      primaryStat.icon,
                      color: primaryStat.color,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${mission.statsReward.values.reduce((a, b) => a + b)} stats',
                      style: TextStyle(
                        color: Colors.orange.shade200.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Icono de completado
          Icon(
            Icons.check_circle,
            color: Colors.green.shade400,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSection(BonfireController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade900.withOpacity(0.1),
            Colors.purple.shade900.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.purple.shade900.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de sección
          Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: Colors.purple.shade300,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'REFLEXIÓN DEL GUERRERO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade300,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Prompt de Morgana
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '"Dime, viajero... ¿Cómo ha sido tu batalla hoy? '
              '¿Qué desafíos enfrentaste? ¿Qué aprendiste de tu jornada?"',
              style: TextStyle(
                color: Colors.purple.shade200,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Campo de reflexión
          TextField(
            controller: _reflectionController,
            maxLines: 6,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe tus reflexiones aquí...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontStyle: FontStyle.italic,
              ),
              filled: true,
              fillColor: Colors.black.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.purple.shade900.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.purple.shade900.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.purple.shade300,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              controller.updateNotes(value);
            },
          ),

          const SizedBox(height: 16),

          // Selector de dificultad
          Text(
            '¿Cómo fue la dificultad?',
            style: TextStyle(
              color: Colors.purple.shade200,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _buildDifficultySelector(controller),

          const SizedBox(height: 20),

          // Selector de energía
          Text(
            '¿Cómo está tu energía?',
            style: TextStyle(
              color: Colors.purple.shade200,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _buildEnergySelector(controller),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(BonfireController controller) {
    final difficulties = [
      (DifficultyLevel.tooEasy, Icons.sentiment_very_satisfied, Colors.green),
      (DifficultyLevel.justRight, Icons.sentiment_neutral, Colors.orange),
      (DifficultyLevel.challenging, Icons.sentiment_dissatisfied, Colors.deepOrange),
      (DifficultyLevel.tooHard, Icons.sentiment_very_dissatisfied, Colors.red),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: difficulties.map((diff) {
        final (level, icon, color) = diff;
        final isSelected = controller.overallDifficulty == level;

        return InkWell(
          onTap: () => controller.updateOverallDifficulty(level),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              border: Border.all(
                color: isSelected ? color : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? color : Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  level.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnergySelector(BonfireController controller) {
    const energies = [
      (1, 'Agotado', Icons.battery_0_bar, Colors.red),
      (2, 'Bajo', Icons.battery_2_bar, Colors.orange),
      (3, 'Normal', Icons.battery_4_bar, Colors.yellow),
      (4, 'Bien', Icons.battery_6_bar, Colors.lightGreen),
      (5, 'Lleno', Icons.battery_full, Colors.green),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: energies.map((energy) {
        final (value, label, icon, color) = energy;
        final isSelected = controller.energyLevel == value;

        return InkWell(
          onTap: () => controller.updateEnergyLevel(value),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              border: Border.all(
                color: isSelected ? color : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? color : Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BonfireController controller) {
    return Column(
      children: [
        // Botón principal: Guardar reflexión
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isSaving
                ? null
                : () async {
                    await controller.saveFeedback();
                    if (!mounted) return;

                    if (controller.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(controller.errorMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              shadowColor: Colors.orange.withOpacity(0.5),
            ),
            child: controller.isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.save, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'GUARDAR REFLEXIÓN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Botón secundario: Saltar (sin guardar)
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF2a2a2a),
                title: const Text(
                  '¿Salir sin reflexionar?',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Si sales ahora, no se guardará tu reflexión y Morgana no podrá ayudarte a mejorar.',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar diálogo
                      Navigator.pop(context); // Volver a missions
                    },
                    child: const Text(
                      'Salir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Text(
            'Salir sin guardar',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================================
  // PANTALLA DE ÉXITO (PALABRAS DE MORGANA)
  // ========================================================================

  Widget _buildSuccessScreen(
      BuildContext context, BonfireController controller) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Color(0xFF3a1a3a), // Púrpura oscuro centro
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de Morgana
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.shade300.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.psychology,
                  size: 80,
                  color: Colors.purple.shade300,
                ),
              ),
              const SizedBox(height: 40),

              // Título
              Text(
                'PALABRAS DE MORGANA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade300,
                  letterSpacing: 3,
                  shadows: const [
                    Shadow(
                      color: Colors.purple,
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Mensaje de Morgana (análisis de AI)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade900.withOpacity(0.2),
                      Colors.purple.shade900.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.purple.shade900.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (controller.analysis != null) ...[
                      Text(
                        controller.analysis!.summary,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.purple.shade100,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tendencias
                      if (controller.analysis!.trends.isNotEmpty) ...[
                        Divider(
                          color: Colors.purple.shade900.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        ...controller.analysis!.trends.map((trend) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_right,
                                  color: Colors.purple.shade300,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    trend,
                                    style: TextStyle(
                                      color: Colors.purple.shade200,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ] else
                      Text(
                        '"Tu reflexión ha sido guardada, viajero. '
                        'Que el fuego te guíe en tu próxima jornada."',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.purple.shade100,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Botón para volver
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Volver a la pantalla de misiones
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    shadowColor: Colors.purple.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.home, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'VOLVER AL VIAJE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
