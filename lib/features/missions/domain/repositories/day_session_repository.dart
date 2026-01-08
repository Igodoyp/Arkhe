// domain/repositories/day_session_repository.dart
import '../entities/day_session_entity.dart';
import '../entities/mission_entity.dart';

abstract class DaySessionRepository {
  Future<DaySession> getCurrentDaySession();
  Future<void> saveDaySession(DaySession session);
  Future<void> addCompletedMission(Mission mission);
  Future<void> removeCompletedMission(String missionId);
  Future<void> finalizeDaySession();
  Future<void> clearCurrentSession();
  
  /// Obtiene sesión de una fecha específica (o null si no existe)
  /// La fecha debe estar stripped a medianoche
  Future<DaySession?> getSessionByDate(DateTime dateStripped);
}
