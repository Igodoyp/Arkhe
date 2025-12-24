// data/repositories/day_session_repository_impl.dart
import '../../domain/entities/day_session_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/day_session_repository.dart';
import '../datasources/day_session_datasource.dart';
import '../models/day_session_model.dart';

class DaySessionRepositoryImpl implements DaySessionRepository {
  final DaySessionDataSource dataSource;

  DaySessionRepositoryImpl({required this.dataSource});

  @override
  Future<DaySession> getCurrentDaySession() async {
    // 1. Obtener JSON del datasource
    final json = await dataSource.getCurrentDaySession();
    
    // 2. Si no hay sesión, crear una nueva
    if (json == null) {
      final now = DateTime.now();
      return DaySessionModel(
        id: 'session_${now.year}_${now.month}_${now.day}',
        date: now,
        completedMissions: [],
        isFinalized: false,
      );
    }
    
    // 3. Convertir JSON a modelo
    final model = DaySessionModel.fromJson(json);
    
    // 4. Retornar como entidad
    return model;
  }

  @override
  Future<void> saveDaySession(DaySession session) async {
    // 1. Convertir entidad a modelo si no lo es
    final model = session is DaySessionModel
        ? session
        : DaySessionModel(
            id: session.id,
            date: session.date,
            completedMissions: session.completedMissions,
            isFinalized: session.isFinalized,
          );
    
    // 2. Convertir a JSON
    final json = model.toJson();
    
    // 3. Guardar en datasource
    await dataSource.saveDaySession(json);
  }

  @override
  Future<void> addCompletedMission(Mission mission) async {
    // 1. Obtener sesión actual
    final currentSession = await getCurrentDaySession();
    
    // 2. Agregar misión completada
    final updatedSession = currentSession.addCompletedMission(mission);
    
    // 3. Guardar sesión actualizada
    await saveDaySession(updatedSession);
  }

  @override
  Future<void> removeCompletedMission(String missionId) async {
    // 1. Obtener sesión actual
    final currentSession = await getCurrentDaySession();
    
    // 2. Remover misión
    final updatedSession = currentSession.removeCompletedMission(missionId);
    
    // 3. Guardar sesión actualizada
    await saveDaySession(updatedSession);
  }

  @override
  Future<void> finalizeDaySession() async {
    // 1. Obtener sesión actual
    final currentSession = await getCurrentDaySession();
    
    // 2. Finalizar sesión
    final finalizedSession = currentSession.finalize();
    
    // 3. Guardar y marcar como finalizada en datasource
    await saveDaySession(finalizedSession);
    await dataSource.finalizeDaySession(currentSession.id);
  }

  @override
  Future<void> clearCurrentSession() async {
    await dataSource.clearCurrentSession();
  }
}
