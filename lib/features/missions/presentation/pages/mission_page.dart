import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/mission_controller.dart';
import '../controllers/day_session_controller.dart';
import '../controllers/bonfire_controller.dart';
import '../../data/datasources/user_stats_datasource.dart';
import '../../data/datasources/day_feedback_datasource.dart';
import '../../data/datasources/user_profile_datasource.dart';
import '../../data/datasources/local/drift/database.dart';
import '../../data/datasources/local/drift/mission_local_datasource_drift.dart';
import '../../data/datasources/local/drift/day_session_local_datasource_drift.dart';
import '../../data/repositories/mission_repository_impl.dart';
import '../../data/repositories/day_session_repository_impl.dart';
import '../../data/repositories/user_stats_repository_impl.dart';
import '../../data/repositories/day_feedback_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/usecases/day_session_usecase.dart';
import '../../domain/usecases/day_feedback_usecase.dart';
import '../../domain/usecases/get_daily_missions_usecase.dart';
import '../../domain/usecases/generate_daily_missions_usecase.dart';
import '../../domain/usecases/ensure_missions_for_date_usecase.dart';
import '../../domain/usecases/watch_missions_for_date_usecase.dart';
import '../../domain/services/mission_orchestration_service.dart';
import '../../data/services/gemini_service.dart';
import '../../../../core/time/real_time_provider.dart';
import '../../../../core/haptic/haptic_service.dart';
import '../../domain/entities/stat_type.dart';
import 'user_stats_page.dart';
import 'bonfire_page.dart';
import '../widgets/bonfire_page_route.dart';
import '../widgets/celebration_effects.dart';
import '../widgets/shimmer_loading.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  // Controllers
  late MissionController _missionController;
  late DaySessionController _daySessionController;

  @override
  void initState() {
    super.initState();
    
    // === Inyección de Dependencias Manual ===
    
    // 1. Database (Drift)
    final database = AppDatabase();
    
    // 1.1. Time Provider (para inyección de tiempo)
    final timeProvider = RealTimeProvider();
    
    // 2. Local DataSources (Drift)
    final missionLocalDataSource = MissionLocalDataSourceDrift(database: database);
    final daySessionLocalDataSource = DaySessionLocalDataSourceDrift(database: database);
    final userStatsDataSource = StatsDummyDataSourceImpl(); // TODO: Migrar a Drift
    final dayFeedbackDataSource = DayFeedbackDataSourceDummy();
    final userProfileDataSource = UserProfileDummyDataSourceImpl();
    
    // 3. Repositories
    final missionRepository = MissionRepositoryImpl(
      localDataSource: missionLocalDataSource,
      timeProvider: timeProvider,
    );
    final daySessionRepository = DaySessionRepositoryImpl(
      localDataSource: daySessionLocalDataSource,
      timeProvider: timeProvider,
    );
    final userStatsRepository = UserStatsRepositoryImpl(remoteDataSource: userStatsDataSource);
    final dayFeedbackRepository = DayFeedbackRepositoryImpl(dataSource: dayFeedbackDataSource);
    final userProfileRepository = UserProfileRepositoryImpl(dataSource: userProfileDataSource);
    
    // 4. Use Cases
    final getCurrentDaySessionUseCase = GetCurrentDaySessionUseCase(daySessionRepository);
    final addCompletedMissionUseCase = AddCompletedMissionUseCase(daySessionRepository);
    final removeCompletedMissionUseCase = RemoveCompletedMissionUseCase(daySessionRepository);
    final endDayUseCase = EndDayUseCase(
      daySessionRepository: daySessionRepository,
      userStatsRepository: userStatsRepository,
    );
    
    // 4.1. AI Services
    final geminiService = GeminiService(apiKey: ''); // TODO: Add real API key from env
    
    // 4.2. Mission Generation UseCase
    final generateDailyMissionsUseCase = GenerateDailyMissionsUseCase(
      userProfileRepository: userProfileRepository,
      daySessionRepository: daySessionRepository,
      dayFeedbackRepository: dayFeedbackRepository,
      userStatsRepository: userStatsRepository,
      geminiService: geminiService,
      missionRepository: missionRepository,
    );
    
    // 4.3. Mission Orchestration Service
    final orchestrationService = MissionOrchestrationService(
      getDailyMissionsUseCase: GetDailyMissionsUseCase(missionRepository: missionRepository),
      generateDailyMissionsUseCase: generateDailyMissionsUseCase,
      missionRepository: missionRepository,
      timeProvider: timeProvider,
    );
    
    // 4.4. Mission UseCases (Formales para Controller)
    final ensureMissionsUseCase = EnsureMissionsForDateUseCase(
      orchestrationService: orchestrationService,
    );
    final watchMissionsUseCase = WatchMissionsForDateUseCase(
      repository: missionRepository,
    );
    
    // 5. Controllers
    _daySessionController = DaySessionController(
      getCurrentDaySessionUseCase: getCurrentDaySessionUseCase,
      addCompletedMissionUseCase: addCompletedMissionUseCase,
      removeCompletedMissionUseCase: removeCompletedMissionUseCase,
      endDayUseCase: endDayUseCase,
    );
    
    _missionController = MissionController(
      ensureMissionsUseCase: ensureMissionsUseCase,
      watchMissionsUseCase: watchMissionsUseCase,
      missionRepository: missionRepository,
      timeProvider: timeProvider,
      daySessionController: _daySessionController,
    );
    
    // 5. Cargar datos
    _missionController.loadMissions();
    _daySessionController.loadCurrentSession();
    
    // 6. Escuchar cambios
    _missionController.addListener(() {
      if (mounted) setState(() {});
    });
    _daySessionController.addListener(() {
      if (mounted) setState(() {});
    });
  }
  
  // Método para navegar a la pantalla de Bonfire después de finalizar el día
  void _showEndDaySummary(BuildContext context) async {
    // Haptic feedback épico para end of day
    await HapticService.endOfDay();
    
    // Finalizar el día (calcula y aplica stats)
    final result = await _daySessionController.endDay();
    
    if (result == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El día ya fue finalizado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Obtener datos para el Bonfire
    final bonfireData = _daySessionController.getBonfireData();
    if (bonfireData == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al preparar datos para Bonfire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crear controller de Bonfire (con todas las dependencias)
    final feedbackDataSource = DayFeedbackDataSourceDummy();
    final feedbackRepository = DayFeedbackRepositoryImpl(
      dataSource: feedbackDataSource,
    );
    final bonfireController = BonfireController(
      saveFeedbackUseCase: SaveFeedbackUseCase(feedbackRepository),
      getFeedbackHistoryUseCase: GetFeedbackHistoryUseCase(feedbackRepository),
      analyzeFeedbackTrendsUseCase: AnalyzeFeedbackTrendsUseCase(feedbackRepository),
      generateAIPromptUseCase: GenerateAIPromptUseCase(feedbackRepository),
    );

    // Navegar a la pantalla de Bonfire con transición épica
    if (!mounted) return;
    Navigator.of(context).push(
      BonfirePageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: bonfireController,
          child: BonfirePage(
            sessionId: bonfireData.sessionId,
            completedMissions: bonfireData.completedMissions,
            totalStatsGained: bonfireData.totalStatsGained,
            daySessionController: _daySessionController,
          ),
        ),
      ),
    );
  }

//TODO: meter cosas dopaminicas al completar misiones

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        title: const Text(
          'MISIONES DIARIAS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.5,
            shadows: [Shadow(color: Colors.red, blurRadius: 4, offset: Offset(1, 2))],
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.redAccent.withOpacity(0.5),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            tooltip: 'Ver Stats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _missionController.refreshMissions();
        },
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh, size: 28),
        label: const Text(
          'REGENERAR',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  /// Construye el cuerpo de la pantalla según el estado del controller
  /// 
  /// ESTADOS:
  /// 1. isLoading = true → Skeleton loader (shimmer)
  /// 2. errorMessage != null → Vista de error con botón "Reintentar"
  /// 3. missions.isEmpty && isGenerating → "Generando misiones..."
  /// 4. missions.isNotEmpty → Lista de misiones
  Widget _buildBody() {
    // ESTADO 1: Loading (primera carga) con shimmer
    if (_missionController.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...List.generate(5, (index) => const MissionCardSkeleton()),
          ],
        ),
      );
    }
    
    // ESTADO 2: Error
    if (_missionController.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            Text(
              'ERROR AL CARGAR MISIONES',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _missionController.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _missionController.loadMissions();
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'REINTENTAR',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      );
    }
    
    // ESTADO 3: Generando misiones (lista vacía)
    if (_missionController.missions.isEmpty && _missionController.isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 16),
            Text(
              'GENERANDO MISIONES...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Morgana está preparando tus desafíos...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    // ESTADO 4: Lista de misiones
    return Column(
        children: [
          // Barra de información con contador y botón "Finalizar Día"
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MISIONES COMPLETADAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_daySessionController.completedMissionsCount} / ${_missionController.missions.length}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Colors.red, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: !(_daySessionController.currentSession?.isClosed ?? true)
                      ? () => _showEndDaySummary(context)
                      : null,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'FINALIZAR DÍA',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade700,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de misiones
          Expanded(
            child: ListView.builder(
              itemCount: _missionController.missions.length,
                    itemBuilder: (context, index) {
                      final mission = _missionController.missions[index];
                      return ConfettiCelebration(
                        isCompleted: mission.isCompleted,
                        primaryColor: Colors.orange,
                        child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(4, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                left: BorderSide(color: Colors.red.shade700, width: 7),
                                bottom: const BorderSide(color: Colors.black, width: 3),
                                right: const BorderSide(color: Colors.black, width: 3),
                                top: const BorderSide(color: Colors.black, width: 3),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              onTap: () async {
                                // Haptic feedback ANTES de cambiar estado
                                await HapticService.celebration();
                                _missionController.toggleMission(index);
                              },
                              leading: CircleAvatar(
                                backgroundColor: mission.isCompleted ? Colors.redAccent : Colors.black,
                                radius: 26,
                                child: Icon(
                                  mission.isCompleted ? Icons.check : Icons.flash_on,
                                  color: Colors.white,
                                  size: 28,
                                  shadows: const [Shadow(color: Colors.red, blurRadius: 6)],
                                ),
                              ),
                              title: Text(
                                mission.title.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Colors.black,
                                  letterSpacing: 1.2,
                                  shadows: [Shadow(color: Colors.red, blurRadius: 2, offset: Offset(1, 1))],
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mission.description,
                                      style: const TextStyle(
                                        color: Color(0xFF232323),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade700,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.black, width: 2),
                                      ),
                                      child: Text(
                                        mission.type.name.toUpperCase(),
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Transform.rotate(
                                angle: -0.1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade700,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(2, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '+${mission.xpReward} XP',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                      letterSpacing: 1.2,
                                      shadows: [Shadow(color: Colors.white, blurRadius: 2)],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      );
                    },
                  ),
                ),
              ],
            );
  }
}

// Widget de diálogo para mostrar el resumen del día
class _EndDaySummaryDialog extends StatelessWidget {
  final EndDayResult result;

  const _EndDaySummaryDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF232323),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow.shade700,
                    size: 32,
                    shadows: const [Shadow(color: Colors.yellow, blurRadius: 10)],
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '¡DÍA COMPLETADO!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: Colors.redAccent, blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.star,
                    color: Colors.yellow.shade700,
                    size: 32,
                    shadows: const [Shadow(color: Colors.yellow, blurRadius: 10)],
                  ),
                ],
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // XP Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow.shade700, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'XP TOTAL GANADO',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '+${result.totalXpGained} XP',
                          style: TextStyle(
                            color: Colors.yellow.shade700,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            shadows: const [
                              Shadow(color: Colors.yellow, blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.missionsCompleted} misiones completadas',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats incrementadas
                  if (result.statsGained.isNotEmpty) ...[
                    const Text(
                      'STATS INCREMENTADAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...result.statsGained.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getStatColor(entry.key),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key.name.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatColor(entry.key),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Text(
                                '+${entry.value.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: _getStatColor(entry.key),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: _getStatColor(entry.key),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            // Botón de cerrar
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 3),
                    ),
                  ),
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Colores para cada tipo de stat
  Color _getStatColor(StatType type) {
    switch (type) {
      case StatType.strength:
        return Colors.red.shade400;
      case StatType.intelligence:
        return Colors.blue.shade400;
      case StatType.charisma:
        return Colors.yellow.shade600;
      case StatType.vitality:
        return Colors.green.shade400;
      case StatType.dexterity:
        return Colors.orange.shade400;
      case StatType.wisdom:
        return Colors.purple.shade300;
    }
  }
}