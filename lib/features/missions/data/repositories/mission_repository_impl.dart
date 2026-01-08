// data/repositories/mission_repository_impl.dart
import 'package:drift/drift.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/stat_type.dart';
import '../datasources/local/drift/mission_local_datasource_drift.dart';
import '../datasources/local/drift/database.dart';
import '../../../../core/time/date_time_extensions.dart';
import '../../../../core/time/time_provider.dart';

/// Implementación del repositorio de misiones usando Drift como single source of truth
/// 
/// RESPONSABILIDADES:
/// - Guardar misiones generadas por AI
/// - Recuperar misiones del día (fecha stripped)
/// - Actualizar estado de completion
/// 
/// REGLAS DE NEGOCIO:
/// - Todas las fechas DEBEN estar stripped antes de guardar/buscar
/// - El estado de completion se guarda en Drift, no en memoria
/// - scheduledFor = fecha stripped del día de las misiones
class MissionRepositoryImpl implements MissionRepository {
  final MissionLocalDataSourceDrift localDataSource;
  final TimeProvider timeProvider;

  MissionRepositoryImpl({
    required this.localDataSource,
    required this.timeProvider,
  });

  @override
  Future<List<Mission>> getDailyMissions() async {
    try {
      // Obtenemos misiones del día actual (stripped)
      final today = timeProvider.todayStripped;
      final missionDataList = await localDataSource.getMissionsByDate(today);

      // Convertimos de Drift Data a Domain Entities
      return missionDataList.map((data) => _missionDataToEntity(data)).toList();
    } catch (e) {
      throw Exception('Error al obtener misiones del día: $e');
    }
  }

  @override
  Stream<List<Mission>> watchMissionsForDate(DateTime dateStripped) {
    assert(dateStripped == dateStripped.stripped, 'Date must be stripped');
    
    // Drift .watch() emite cada vez que hay cambios en la tabla missions
    // Mapeamos List<MissionData> -> List<Mission>
    return localDataSource
        .watchMissionsByDate(dateStripped)
        .map((dataList) => dataList.map(_missionDataToEntity).toList());
  }

  @override
  Future<void> updateMission(Mission mission) async {
    try {
      // Actualizamos el estado de completion con timestamp desde TimeProvider
      await localDataSource.setCompleted(mission.id, mission.isCompleted, timeProvider.now);
    } catch (e) {
      throw Exception('Error al actualizar misión: $e');
    }
  }

  /// Guarda una lista de misiones para un día específico
  /// 
  /// IMPORTANTE: date DEBE estar stripped
  Future<void> saveMissionsForDate(List<Mission> missions, DateTime dateStripped) async {
    assert(dateStripped == dateStripped.stripped, 'Date must be stripped');

    final companions = missions.map((m) => _entityToCompanion(m, dateStripped)).toList();
    await localDataSource.insertMissions(companions);
  }

  /// Obtiene misiones de una sesión específica
  Future<List<Mission>> getMissionsBySessionId(String sessionId) async {
    try {
      final missionDataList = await localDataSource.getMissionsBySessionId(sessionId);
      return missionDataList.map((data) => _missionDataToEntity(data)).toList();
    } catch (e) {
      throw Exception('Error al obtener misiones de sesión: $e');
    }
  }

  /// Cuenta cuántas misiones fueron completadas en un día
  Future<int> getCompletedCountForDate(DateTime dateStripped) async {
    assert(dateStripped == dateStripped.stripped);
    return await localDataSource.countCompletedByDate(dateStripped);
  }

  /// Obtiene el XP total ganado en un día
  Future<int> getTotalXpForDate(DateTime dateStripped) async {
    assert(dateStripped == dateStripped.stripped);
    return await localDataSource.getTotalXpByDate(dateStripped);
  }

  @override
  Future<int> getTotalXpAllTime() async {
    try {
      return await localDataSource.getTotalXpAllTime();
    } catch (e) {
      throw Exception('Error al obtener XP total histórico: $e');
    }
  }

  /// Elimina todas las misiones de un día (útil para regenerar)
  Future<void> deleteMissionsForDate(DateTime dateStripped) async {
    assert(dateStripped == dateStripped.stripped);
    await localDataSource.deleteMissionsByDate(dateStripped);
  }

  // ==========================================================================
  // HELPERS: Conversión entre Domain Entities y Drift Data
  // ==========================================================================

  Mission _missionDataToEntity(MissionData data) {
    return Mission(
      id: data.id,
      title: data.title,
      description: data.description,
      xpReward: data.xpReward,
      isCompleted: data.isCompleted,
      type: StatType.values.firstWhere(
        (t) => t.name.toLowerCase() == data.type.toLowerCase(),
        orElse: () => StatType.strength,
      ),
    );
  }

  MissionsCompanion _entityToCompanion(Mission entity, DateTime dateStripped) {
    return MissionsCompanion(
      id: Value(entity.id),
      title: Value(entity.title),
      description: Value(entity.description),
      xpReward: Value(entity.xpReward),
      isCompleted: Value(entity.isCompleted),
      type: Value(entity.type.name),
      scheduledFor: Value(dateStripped),
      sessionId: const Value.absent(), // Opcional, se puede asignar después
    );
  }
}