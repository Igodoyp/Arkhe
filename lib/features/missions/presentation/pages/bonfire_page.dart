// presentation/pages/bonfire_page.dart

// ============================================================================
// BONFIRE PAGE (HOGUERA)
// ============================================================================
// Pantalla inspirada en Dark Souls donde el usuario descansa tras completar
// el día y proporciona feedback sobre sus misiones.
//
// FLUJO:
// 1. Usuario llega después de "End Day"
// 2. Se muestra resumen de misiones completadas
// 3. Usuario proporciona feedback: dificultad, energía, misiones problemáticas
// 4. Se guarda el feedback para adaptar misiones futuras
// 5. Navegación de vuelta al inicio

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/day_feedback_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/usecases/day_feedback_usecase.dart';
import '../controllers/bonfire_controller.dart';
import '../controllers/day_session_controller.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Animación de entrada
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Inicializar el controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<BonfireController>();
      controller.initialize(
        sessionId: widget.sessionId,
        completedMissionIds: widget.completedMissions.map((m) => m.id).toList(),
      );
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a), // Fondo oscuro tipo Dark Souls
      body: Consumer<BonfireController>(
        builder: (context, controller, child) {
          if (!controller.isReady && !controller.isSaved) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (controller.isSaved) {
            return _buildSuccessScreen(context, controller);
          }

          return _buildFeedbackForm(context, controller);
        },
      ),
    );
  }

  Widget _buildFeedbackForm(BuildContext context, BonfireController controller) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ========== Header (Bonfire Icon + Título) ==========
              _buildHeader(),
              const SizedBox(height: 32),

              // ========== Resumen del Día ==========
              _buildDaySummary(),
              const SizedBox(height: 32),

              // ========== Selector de Dificultad ==========
              _buildDifficultySelector(controller),
              const SizedBox(height: 24),

              // ========== Selector de Energía ==========
              _buildEnergySelector(controller),
              const SizedBox(height: 24),

              // ========== Misiones Difíciles/Fáciles ==========
              _buildMissionFeedback(controller),
              const SizedBox(height: 24),

              // ========== Notas del Usuario ==========
              _buildNotesField(controller),
              const SizedBox(height: 32),

              // ========== Análisis de Tendencias (si existe) ==========
              if (controller.analysis != null) ...[
                _buildAnalysisCard(controller.analysis!),
                const SizedBox(height: 24),
              ],

              // ========== Botón de Guardar ==========
              _buildSaveButton(controller),
              const SizedBox(height: 16),

              // ========== Botón de Cancelar ==========
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icono de fuego (hoguera)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.orange.shade300,
                Colors.deepOrange.shade700,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_fire_department,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'BONFIRE',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Descansa y reflexiona sobre tu día',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade400,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDaySummary() {
    final hasCompletedMissions = widget.completedMissions.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Día',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.check_circle,
            'Misiones Completadas',
            '${widget.completedMissions.length}',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            Icons.trending_up,
            'Stats Ganados',
            hasCompletedMissions ? '+${widget.totalStatsGained}' : '0',
          ),
          if (!hasCompletedMissions) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue.shade300),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No completaste misiones hoy. Tu feedback es igual de valioso.',
                      style: TextStyle(
                        color: Colors.blue.shade200,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.orange),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector(BonfireController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cómo fue la dificultad?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...DifficultyLevel.values.map((level) {
          final isSelected = controller.selectedDifficulty == level;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => controller.setDifficulty(level),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey.shade700,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? Colors.orange : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.orange : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEnergySelector(BonfireController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cómo estuvo tu energía?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final level = index + 1;
            final isSelected = controller.selectedEnergy == level;
            return GestureDetector(
              onTap: () => controller.setEnergy(level),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.orange
                      : Colors.black.withOpacity(0.3),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey.shade700,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Agotado', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            Text('Lleno de energía', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ],
    );
  }

  Widget _buildMissionFeedback(BonfireController controller) {
    if (widget.completedMissions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marca las misiones según tu experiencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.completedMissions.map((mission) {
          final isStruggled = controller.struggledMissions.contains(mission.id);
          final isEasy = controller.easyMissions.contains(mission.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      mission.title,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.sentiment_dissatisfied,
                      color: isStruggled ? Colors.red : Colors.grey.shade600,
                    ),
                    onPressed: () => controller.toggleStruggledMission(mission.id),
                    tooltip: 'Fue difícil',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.sentiment_satisfied,
                      color: isEasy ? Colors.green : Colors.grey.shade600,
                    ),
                    onPressed: () => controller.toggleEasyMission(mission.id),
                    tooltip: 'Fue fácil',
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotesField(BonfireController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas adicionales (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          onChanged: controller.setNotes,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ej: Tuve mucho trabajo hoy, me sentí motivado...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(FeedbackAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Análisis de Tendencias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Últimos ${analysis.daysAnalyzed} días analizados',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...analysis.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.blue)),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(color: Colors.grey.shade300, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BonfireController controller) {
    return ElevatedButton(
      onPressed: controller.isSaving ? null : () async {
        final success = await controller.saveFeedback();
        if (success && mounted) {
          // El estado cambiará a "saved" y se mostrará _buildSuccessScreen
        } else if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(controller.errorMessage ?? 'Error al guardar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: controller.isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'GUARDAR Y CONTINUAR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(
        'Saltar feedback',
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context, BonfireController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'Feedback Guardado',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tus misiones se adaptarán según tu experiencia',
            style: TextStyle(color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              // 1. Resetear el controller de Bonfire
              controller.reset();
              
              // 2. Limpiar el resultado anterior del día
              widget.daySessionController.clearLastResult();
              
              // 3. Crear una nueva sesión del día (para testing de múltiples días)
              print('[BonfirePage] 🔄 Creando nueva sesión del día...');
              await widget.daySessionController.loadCurrentSession();
              
              // 4. Volver al inicio
              if (!mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
              
              print('[BonfirePage] ✅ Nueva sesión creada - Listo para el próximo día!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('COMENZAR NUEVO DÍA'),
          ),
          const SizedBox(height: 16),
          Text(
            '(Se creará una nueva sesión para testing)',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
