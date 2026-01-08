import '../widgets/ransom_note_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/mission_controller.dart';
import '../controllers/day_session_controller.dart';
import '../controllers/bonfire_controller.dart';
import '../../data/datasources/day_feedback_datasource.dart';
import '../../data/datasources/user_profile_datasource.dart';
import '../../data/datasources/local/drift/database.dart';
import '../../data/datasources/local/drift/mission_local_datasource_drift.dart';
import '../../data/datasources/local/drift/day_session_local_datasource_drift.dart';
import '../../data/datasources/local/drift/user_stats_local_datasource_drift.dart';
import '../../data/repositories/mission_repository_impl.dart';
import '../../data/repositories/day_session_repository_impl.dart';
import '../../data/repositories/user_stats_repository_drift_impl.dart';
import '../../data/repositories/day_feedback_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../../domain/usecases/day_session_usecase.dart';
import '../../domain/usecases/day_feedback_usecase.dart';
import '../../domain/usecases/get_daily_missions_usecase.dart';
import '../../domain/usecases/generate_daily_missions_usecase.dart';
import '../../domain/usecases/ensure_missions_for_date_usecase.dart';
import '../../domain/usecases/watch_missions_for_date_usecase.dart';
import '../../domain/services/mission_orchestration_service.dart';
import '../../data/services/gemini_service.dart';
import '../../../../core/time/time_provider.dart';
import '../../../../core/time/virtual_time_provider.dart';
import '../../../../core/haptic/haptic_service.dart';
import '../../../../core/audio/audio_service.dart';
import '../../domain/entities/stat_type.dart';
import 'profile_page.dart';
import 'bonfire_page.dart';
import '../widgets/bonfire_page_route.dart';
import '../widgets/celebration_effects.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/arkhe_flame.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  // Controllers
  late MissionController _missionController;
  late DaySessionController _daySessionController;
  
  // Repositories (para pasar a otras páginas)
  late MissionRepository _missionRepository;
  late UserProfileRepository _userProfileRepository;
  late UserStatsRepository _userStatsRepository;
  
  // Tiempo virtual compartido (para testing ciclo diario)
  late VirtualTimeProvider _timeProvider;
  
  // Feedback repository compartido (para que bonfire guarde en el mismo storage)
  late DayFeedbackRepositoryImpl _dayFeedbackRepository;
  
  // Estado de inicialización
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Inicializar async después de que el frame se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAsync();
    });
  }
  
  Future<void> _initializeAsync() async {
    // === Inyección de Dependencias Manual (Async) ===
    
    // 1. Database (Drift)
    final database = AppDatabase();
    
    // 1.1. Time Provider (COMPARTIDO desde Provider global)
    _timeProvider = Provider.of<TimeProvider>(context, listen: false) as VirtualTimeProvider;
    print('[MissionsPage] 🕐 Tiempo compartido iniciado: ${_timeProvider.todayStripped}');
    
    // 2. Local DataSources (Drift)
    final missionLocalDataSource = MissionLocalDataSourceDrift(database: database);
    final daySessionLocalDataSource = DaySessionLocalDataSourceDrift(database: database);
    final userStatsLocalDataSource = UserStatsLocalDataSourceDrift(database: database);
    final dayFeedbackDataSource = DayFeedbackDataSourceDummy();
    
    // 2.1. User Profile con persistencia real (async)
    final userProfileDataSource = await createUserProfileDataSource();
    
    // 3. Repositories
    final missionRepository = MissionRepositoryImpl(
      localDataSource: missionLocalDataSource,
      timeProvider: _timeProvider,
    );
    final daySessionRepository = DaySessionRepositoryImpl(
      localDataSource: daySessionLocalDataSource,
      timeProvider: _timeProvider,
    );
    final userStatsRepository = UserStatsRepositoryDriftImpl(
      localDataSource: userStatsLocalDataSource,
      timeProvider: _timeProvider,
    );
    _dayFeedbackRepository = DayFeedbackRepositoryImpl(dataSource: dayFeedbackDataSource);
    final userProfileRepository = UserProfileRepositoryImpl(dataSource: userProfileDataSource);
    
    // Guardar referencias para otras páginas
    _missionRepository = missionRepository;
    _userProfileRepository = userProfileRepository;
    _userStatsRepository = userStatsRepository;
    
    // 4. Use Cases
    final getCurrentDaySessionUseCase = GetCurrentDaySessionUseCase(daySessionRepository);
    final addCompletedMissionUseCase = AddCompletedMissionUseCase(daySessionRepository);
    final removeCompletedMissionUseCase = RemoveCompletedMissionUseCase(daySessionRepository);
    final endDayUseCase = EndDayUseCase(
      daySessionRepository: daySessionRepository,
      missionRepository: missionRepository,
      userStatsRepository: userStatsRepository,
    );
    
    // 4.1. AI Services
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('⚠️ GEMINI_API_KEY no encontrada en .env');
    }
    final geminiService = GeminiService(apiKey: apiKey);
    
    // 4.2. Mission Generation UseCase
    final generateDailyMissionsUseCase = GenerateDailyMissionsUseCase(
      userProfileRepository: userProfileRepository,
      daySessionRepository: daySessionRepository,
      dayFeedbackRepository: _dayFeedbackRepository,
      userStatsRepository: userStatsRepository,
      geminiService: geminiService,
      missionRepository: missionRepository,
    );
    
    // 4.3. Mission Orchestration Service
    final orchestrationService = MissionOrchestrationService(
      getDailyMissionsUseCase: GetDailyMissionsUseCase(missionRepository: missionRepository),
      generateDailyMissionsUseCase: generateDailyMissionsUseCase,
      missionRepository: missionRepository,
      timeProvider: _timeProvider,
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
      timeProvider: _timeProvider,
      daySessionController: _daySessionController,
    );
    
    // 6. Cargar datos
    _missionController.loadMissions();
    _daySessionController.loadCurrentSession();
    
    // 7. Escuchar cambios
    _missionController.addListener(() {
      if (mounted) setState(() {});
    });
    _daySessionController.addListener(() {
      if (mounted) setState(() {});
    });
    
    // 8. Marcar como inicializado
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
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

    // Crear controller de Bonfire (COMPARTIR repositorio y timeProvider)
    final bonfireController = BonfireController(
      saveFeedbackUseCase: SaveFeedbackUseCase(_dayFeedbackRepository),
      getFeedbackHistoryUseCase: GetFeedbackHistoryUseCase(_dayFeedbackRepository),
      analyzeFeedbackTrendsUseCase: AnalyzeFeedbackTrendsUseCase(_dayFeedbackRepository),
      generateAIPromptUseCase: GenerateAIPromptUseCase(_dayFeedbackRepository),
      timeProvider: _timeProvider,
    );

    // Navegar a la pantalla de Bonfire con transición épica
    if (!mounted) return;
    await Navigator.of(context).push(
      BonfirePageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: bonfireController,
          child: BonfirePage(
            sessionId: bonfireData.sessionId,
            completedMissions: bonfireData.completedMissions,
            totalStatsGained: bonfireData.totalStatsGained,
            totalXpGained: bonfireData.totalXpGained,
            daySessionController: _daySessionController,
          ),
        ),
      ),
    );
    
    // Al volver de bonfire: avanzar día virtual y recargar misiones + sesión
    if (!mounted) return;
    print('[MissionsPage] 🔄 Volviendo de Bonfire, avanzando tiempo virtual...');
    _timeProvider.advanceDays(1);
    
    // CRÍTICO: Recargar tanto misiones como sesión del nuevo día
    await _missionController.loadMissions();
    await _daySessionController.loadCurrentSession();
    
    print('[MissionsPage] ✅ Día avanzado → ${_timeProvider.todayStripped}');
  }

//TODO: meter cosas dopaminicas al completar misiones

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras se inicializa
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFD700),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        title: RansomNoteText(
          text: 'MISIONES DIARIAS',
          palette: [
            Colors.redAccent,
            Colors.black,
            Colors.white,
          ],
          minFontSize: 20,
          maxFontSize: 28,
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.redAccent.withOpacity(0.5),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Perfil',
            onPressed: () {
              final audioService = Provider.of<AudioService>(context, listen: false);
              audioService.playTap();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userProfileRepository: _userProfileRepository,
                    userStatsRepository: _userStatsRepository,
                    missionRepository: _missionRepository,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final audioService = Provider.of<AudioService>(context, listen: false);
          audioService.playTap();
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
                final audioService = Provider.of<AudioService>(context, listen: false);
                audioService.playTap();
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

    // ESTADO 3: Generando misiones (cuando la lista aún está vacía)
    if (_missionController.missions.isEmpty && _missionController.isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
                      ? () {
                          final audioService = Provider.of<AudioService>(context, listen: false);
                          audioService.playTap();
                          _showEndDaySummary(context);
                        }
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
                                // Audio + Haptic feedback ANTES de cambiar estado
                                final audioService = Provider.of<AudioService>(context, listen: false);
                                
                                // Reproducir sonido según acción (completar vs desmarcar)
                                if (!mission.isCompleted) {
                                  // Al COMPLETAR → ui_success.wav
                                  audioService.playSuccess();
                                } else {
                                  // Al DESMARCAR → ui_tap.wav (más sutil)
                                  audioService.playTap();
                                }
                                
                                await HapticService.celebration();
                                _missionController.toggleMission(index);
                              },
                              leading: SizedBox(
                                width: 52,
                                height: 52,
                                child: mission.isCompleted
                                    ? GeoFlame(
                                        width: 52,
                                        height: 52,
                                        intensity: 0.8,
                                        // Colores vivos cuando está completada
                                        colorOutline: const Color(0xFF1A0515), // Negro/Violeta oscuro
                                        colorBody: const Color(0xFFD72638),    // Rojo Intenso
                                        colorCore: const Color(0xFF4AF2F5),    // Cian Neón
                                      )
                                    : GeoFlame(
                                        width: 52,
                                        height: 52,
                                        intensity: 0.3,
                                        // Colores grises cuando no está completada
                                        colorOutline: const Color(0xFF2A2A2A), // Gris oscuro
                                        colorBody: const Color(0xFF5A5A5A),    // Gris medio
                                        colorCore: const Color(0xFF808080),    // Gris claro
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