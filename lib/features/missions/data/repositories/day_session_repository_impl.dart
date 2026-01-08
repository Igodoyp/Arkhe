// data/repositories/day_session_repository_impl.dart
import 'package:drift/drift.dart';
import '../../domain/entities/day_session_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/day_session_repository.dart';
import '../datasources/local/drift/day_session_local_datasource_drift.dart';
import '../datasources/local/drift/database.dart';
import '../../../../core/time/date_time_extensions.dart';
import '../../../../core/time/time_provider.dart';

/// Implementación del repositorio de sesiones usando Drift como single source of truth
/// 
/// RESPONSABILIDADES:
/// - Guardar/recuperar sesiones del día
/// - Actualizar estado de misiones completadas
/// - Cerrar sesiones (isClosed flag)
/// 
/// REGLAS DE NEGOCIO:
/// - Todas las fechas DEBEN estar stripped
/// - isClosed=true es DEFINITIVO (no se puede reabrir)
/// - Las misiones completadas se guardan como IDs (JSON array)
class DaySessionRepositoryImpl implements DaySessionRepository {
  final DaySessionLocalDataSourceDrift localDataSource;
  final TimeProvider timeProvider;

  DaySessionRepositoryImpl({
    required this.localDataSource,
    required this.timeProvider,
  });

  @override
  Future<DaySession> getCurrentDaySession() async {
    final today = timeProvider.todayStripped;
    final sessionData = await localDataSource.getSessionByDate(today);
    
    if (sessionData == null) {
      // Si no hay sesión, crear una nueva
      return DaySession(
        id: 'session_${today.year}_${today.month}_${today.day}',
        date: today,
        completedMissions: [],
        isClosed: false,
      );
    }
    
    return _sessionDataToEntity(sessionData);
  }

  @override
  Future<void> saveDaySession(DaySession session) async {
    assert(session.date == session.date.stripped, 
      'DaySession.date must be stripped to midnight (got ${session.date})');
    
    final companion = _entityToCompanion(session);
    await localDataSource.insertSession(companion);
  }

  @override
  Future<void> addCompletedMission(Mission mission) async {
    final currentSession = await getCurrentDaySession();
    final updatedSession = currentSession.addCompletedMission(mission);
    
    // Actualizar IDs de misiones completadas
    await localDataSource.updateCompletedMissionIds(
      updatedSession.id,
      updatedSession.completedMissions.map((m) => m.id).toList(),
    );
  }

  @override
  Future<void> removeCompletedMission(String missionId) async {
    final currentSession = await getCurrentDaySession();
    final updatedSession = currentSession.removeCompletedMission(missionId);
    
    await localDataSource.updateCompletedMissionIds(
      updatedSession.id,
      updatedSession.completedMissions.map((m) => m.id).toList(),
    );
  }

  @override
  Future<void> finalizeDaySession() async {
    final currentSession = await getCurrentDaySession();
    
    // Marcar sesión como cerrada (definitivo) con timestamp desde TimeProvider
    await localDataSource.closeSession(currentSession.id, timeProvider.now);
  }

  @override
  Future<void> clearCurrentSession() async {
    final today = timeProvider.todayStripped;
    final sessionData = await localDataSource.getSessionByDate(today);
    
    if (sessionData != null) {
      await localDataSource.deleteSession(sessionData.id);
    }
  }

  @override
  Future<DaySession?> getSessionByDate(DateTime dateStripped) async {
    assert(dateStripped == dateStripped.stripped, 
      'Date must be stripped to midnight (got $dateStripped)');
    
    final sessionData = await localDataSource.getSessionByDate(dateStripped);
    return sessionData != null ? _sessionDataToEntity(sessionData) : null;
  }

  /// Obtiene sesión de ayer para el branching binario
  Future<DaySession?> getYesterdaySession() async {
    final yesterday = timeProvider.yesterdayStripped;
    return await getSessionByDate(yesterday);
  }

  /// Verifica si hay sesión cerrada para una fecha
  Future<bool> hasClosedSessionForDate(DateTime dateStripped) async {
    assert(dateStripped == dateStripped.stripped);
    return await localDataSource.hasClosedSessionForDate(dateStripped);
  }

  // ==========================================================================
  // HELPERS: Conversión entre Domain Entities y Drift Data
  // ==========================================================================

  DaySession _sessionDataToEntity(DaySessionData data) {
    // Parse completedMissionIds de JSON string a lista (NO USADO actualmente)
    // En el futuro podrías hacer join con Missions table para hidratar completedMissions
    
    return DaySession(
      id: data.id,
      date: data.date,
      completedMissions: [], // Por ahora vacío, podrías hacer join con Missions
      isClosed: data.isClosed,
    );
  }

  DaySessionsCompanion _entityToCompanion(DaySession entity) {
    // Convertir lista de misiones completadas a string JSON
    final missionIds = entity.completedMissions.map((m) => m.id).toList();
    final jsonString = missionIds.toString();

    return DaySessionsCompanion(
      id: Value(entity.id),
      date: Value(entity.date),
      completedMissionIds: Value(jsonString),
      isClosed: Value(entity.isClosed),
      finalizedAt: entity.isClosed 
          ? Value(timeProvider.now) 
          : const Value.absent(),
    );
  }
}
