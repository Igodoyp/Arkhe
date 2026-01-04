// domain/services/mission_orchestration_service.dart

import '../entities/mission_entity.dart';
import '../usecases/get_daily_missions_usecase.dart';
import '../usecases/generate_daily_missions_usecase.dart';
import '../../data/repositories/mission_repository_impl.dart';
import '../../../../core/time/date_time_extensions.dart';
import '../../../../core/time/time_provider.dart';

/// Servicio de orquestación para misiones diarias
/// 
/// RESPONSABILIDADES:
/// - Coordinar generación EAGER (automática al inicio)
/// - Coordinar generación LAZY (on-demand cuando usuario pide)
/// - Decidir si usar misiones existentes vs generar nuevas
/// 
/// REGLAS DE DECISIÓN:
/// - Si hay misiones en Drift para HOY → retornar existentes
/// - Si NO hay misiones para HOY → generar nuevas
/// - Opción de forzar regeneración (reemplazar existentes)
class MissionOrchestrationService {
  final GetDailyMissionsUseCase getDailyMissionsUseCase;
  final GenerateDailyMissionsUseCase generateDailyMissionsUseCase;
  final MissionRepositoryImpl missionRepository;
  final TimeProvider timeProvider;

  MissionOrchestrationService({
    required this.getDailyMissionsUseCase,
    required this.generateDailyMissionsUseCase,
    required this.missionRepository,
    required this.timeProvider,
  });

  // ==========================================================================
  // EAGER LOADING: Generación automática al inicio de la app
  // ==========================================================================

  /// Carga misiones al inicio de la app (EAGER)
  /// 
  /// ESTRATEGIA:
  /// 1. Verifica si ya existen misiones para HOY en Drift
  /// 2. Si existen → retorna las existentes (no regenera)
  /// 3. Si NO existen → genera nuevas automáticamente
  /// 
  /// @returns: Lista de misiones (existentes o recién generadas)
  Future<List<Mission>> eagerLoadTodayMissions() async {
    final today = timeProvider.todayStripped;
    
    print('[Orchestration] 🚀 EAGER LOAD: Iniciando carga de misiones...');
    
    // 1. Verificar si ya existen misiones para HOY
    final existingMissions = await _getMissionsForDate(today);
    
    if (existingMissions.isNotEmpty) {
      print('[Orchestration] ✅ EAGER: Usando ${existingMissions.length} misiones existentes');
      return existingMissions;
    }
    
    // 2. No hay misiones, generar automáticamente
    print('[Orchestration] 🔄 EAGER: No hay misiones, generando...');
    
    try {
      final newMissions = await generateDailyMissionsUseCase(today, persistMissions: true);
      print('[Orchestration] ✅ EAGER: ${newMissions.length} misiones generadas y guardadas');
      return newMissions;
    } catch (e) {
      print('[Orchestration] ❌ EAGER: Error generando misiones: $e');
      // Retornar lista vacía en caso de error (UI mostrará estado vacío)
      return [];
    }
  }

  // ==========================================================================
  // LAZY LOADING: Generación on-demand cuando usuario pide
  // ==========================================================================

  /// Obtiene misiones del día (LAZY)
  /// 
  /// ESTRATEGIA:
  /// 1. Intenta obtener misiones existentes de Drift
  /// 2. Si no existen → genera nuevas
  /// 3. Si forzarRegenerar=true → elimina y regenera
  /// 
  /// @param targetDate: Fecha para la cual obtener/generar misiones
  /// @param forceRegenerate: Si true, elimina y regenera misiones existentes
  /// @returns: Lista de misiones
  Future<List<Mission>> lazyLoadMissions({
    DateTime? targetDate,
    bool forceRegenerate = false,
  }) async {
    final date = (targetDate ?? timeProvider.todayStripped).stripped;
    
    print('[Orchestration] 🔍 LAZY LOAD: Obteniendo misiones para $date');
    
    // Si se fuerza regeneración, eliminar misiones existentes primero
    if (forceRegenerate) {
      print('[Orchestration] 🔄 LAZY: Forzando regeneración...');
      await missionRepository.deleteMissionsForDate(date);
    }
    
    // 1. Intentar obtener misiones existentes
    final existingMissions = await _getMissionsForDate(date);
    
    if (existingMissions.isNotEmpty && !forceRegenerate) {
      print('[Orchestration] ✅ LAZY: Usando ${existingMissions.length} misiones existentes');
      return existingMissions;
    }
    
    // 2. No hay misiones (o se eliminaron), generar nuevas
    print('[Orchestration] 🔄 LAZY: Generando nuevas misiones...');
    
    try {
      final newMissions = await generateDailyMissionsUseCase(date, persistMissions: true);
      print('[Orchestration] ✅ LAZY: ${newMissions.length} misiones generadas');
      return newMissions;
    } catch (e) {
      print('[Orchestration] ❌ LAZY: Error generando misiones: $e');
      return [];
    }
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  /// Obtiene misiones de Drift para una fecha específica
  Future<List<Mission>> _getMissionsForDate(DateTime dateStripped) async {
    assert(dateStripped == dateStripped.stripped);
    
    try {
      // Obtener todas las misiones del repositorio
      final allMissions = await getDailyMissionsUseCase(dateStripped);
      
      // Filtrar por fecha (el repository ya debería hacerlo, pero por si acaso)
      return allMissions;
    } catch (e) {
      print('[Orchestration] ⚠️ Error obteniendo misiones: $e');
      return [];
    }
  }

  /// Verifica si hay misiones para una fecha específica
  Future<bool> hasMissionsForDate(DateTime date) async {
    final missions = await _getMissionsForDate(date.stripped);
    return missions.isNotEmpty;
  }

  /// Cuenta cuántas misiones completadas hay para una fecha
  Future<int> countCompletedMissions(DateTime date) async {
    final missions = await _getMissionsForDate(date.stripped);
    return missions.where((m) => m.isCompleted).length;
  }

  /// Regenera misiones para una fecha (útil para debugging o ajustes)
  Future<List<Mission>> regenerateMissions(DateTime date) async {
    return await lazyLoadMissions(
      targetDate: date,
      forceRegenerate: true,
    );
  }
}
