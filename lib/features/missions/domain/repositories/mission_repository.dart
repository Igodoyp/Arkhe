// domain/repositories/mission_repository.dart
import '../entities/mission_entity.dart';

abstract class MissionRepository {
  /// Obtiene misiones del día actual (pull, una sola vez)
  Future<List<Mission>> getDailyMissions();
  
  /// Observa cambios en las misiones de una fecha específica (stream, reactivo)
  /// 
  /// Emite una nueva lista cada vez que hay cambios en Drift:
  /// - Nuevas misiones insertadas
  /// - Misiones actualizadas (completadas/descompletadas)
  /// - Misiones eliminadas
  /// 
  /// @param dateStripped: Fecha normalizada a medianoche
  /// @returns: Stream que emite List<Mission> en cada cambio
  Stream<List<Mission>> watchMissionsForDate(DateTime dateStripped);
  
  /// Actualiza el estado de una misión (principalmente isCompleted)
  Future<void> updateMission(Mission mission);
}