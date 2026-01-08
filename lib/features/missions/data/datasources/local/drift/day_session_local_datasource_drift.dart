// data/datasources/local/drift/day_session_local_datasource_drift.dart

import 'package:drift/drift.dart';
import 'package:d0/core/time/date_time_extensions.dart';
import 'database.dart';

/// DataSource local para DaySessions usando Drift
/// 
/// RESPONSABILIDADES:
/// - Persistir y recuperar sesiones del día
/// - Queries por fecha (date stripped)
/// - Marcar sesiones como cerradas (isClosed)
/// - Auditoría y feedback
/// 
/// REGLAS DE NEGOCIO:
/// - TODAS las fechas DEBEN estar stripped antes de guardar/buscar
/// - El campo `isClosed` es el flag definitivo para el branching binario
/// - Una vez isClosed=true, no se puede reabrir (inmutable)
class DaySessionLocalDataSourceDrift {
  final AppDatabase database;

  DaySessionLocalDataSourceDrift({required this.database});

  // ==========================================================================
  // CREATE
  // ==========================================================================

  /// Crea una nueva sesión del día
  /// 
  /// IMPORTANTE: date DEBE estar stripped
  Future<void> insertSession(DaySessionsCompanion session) async {
    await database.into(database.daySessions).insert(
      session,
      mode: InsertMode.replace,
    );
    
    print('[DaySessionDrift] ✅ Sesión insertada: ${session.id.value}');
  }

  // ==========================================================================
  // READ - QUERIES POR FECHA (STRIPPED)
  // ==========================================================================

  /// Obtiene la sesión para una fecha específica (stripped)
  /// 
  /// Esta es la query PRINCIPAL para obtener sesiones.
  /// 
  /// @param dateStripped: Fecha normalizada (00:00:00)
  /// @returns: Sesión del día o null si no existe
  Future<DaySessionData?> getSessionByDate(DateTime dateStripped) async {
    // Validar que la fecha esté stripped
    assert(
      dateStripped == dateStripped.stripped,
      'ERROR: getSessionByDate requiere fecha stripped. '
      'Recibido: $dateStripped, Esperado: ${dateStripped.stripped}'
    );

    final query = database.select(database.daySessions)
      ..where((tbl) => tbl.date.equals(dateStripped));

    final results = await query.get();
    
    if (results.isEmpty) {
      print('[DaySessionDrift] ❌ No existe sesión para ${dateStripped.toIso8601String()}');
      return null;
    }
    
    print('[DaySessionDrift] 📖 Sesión encontrada: ${results.first.id} (isClosed=${results.first.isClosed})');
    return results.first;
  }

  /// Obtiene una sesión por ID
  Future<DaySessionData?> getSessionById(String id) async {
    final query = database.select(database.daySessions)
      ..where((tbl) => tbl.id.equals(id));

    final results = await query.get();
    return results.isNotEmpty ? results.first : null;
  }

  /// Verifica si existe una sesión cerrada para una fecha
  /// 
  /// Esta es la query CRÍTICA para el branching binario en GenerateDailyMissionsUseCase.
  /// 
  /// @param dateStripped: Fecha normalizada (00:00:00)
  /// @returns: true si existe sesión con isClosed=true
  Future<bool> hasClosedSessionForDate(DateTime dateStripped) async {
    assert(
      dateStripped == dateStripped.stripped,
      'ERROR: hasClosedSessionForDate requiere fecha stripped'
    );

    final query = database.select(database.daySessions)
      ..where((tbl) => tbl.date.equals(dateStripped))
      ..where((tbl) => tbl.isClosed.equals(true));

    final results = await query.get();
    final hasClosed = results.isNotEmpty;
    
    print('[DaySessionDrift] 🔍 ¿Sesión cerrada para ${dateStripped.toIso8601String()}? $hasClosed');
    
    return hasClosed;
  }

  /// Obtiene todas las sesiones cerradas (para historial/analytics)
  Future<List<DaySessionData>> getClosedSessions({int? limit}) async {
    final query = database.select(database.daySessions)
      ..where((tbl) => tbl.isClosed.equals(true))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ]);

    if (limit != null) {
      query.limit(limit);
    }

    final results = await query.get();
    print('[DaySessionDrift] 📊 ${results.length} sesiones cerradas encontradas');
    
    return results;
  }

  // ==========================================================================
  // UPDATE
  // ==========================================================================

  /// Marca una sesión como cerrada (isClosed=true)
  /// 
  /// CRÍTICO: Una vez cerrada, no se puede reabrir.
  /// Este flag es definitivo para el branching binario.
  /// 
  /// @param sessionId: ID de la sesión a cerrar
  /// @param finalizedAt: Timestamp de cierre (inyectado desde repo)
  Future<void> closeSession(String sessionId, DateTime finalizedAt) async {
    
    final rowsAffected = await (database.update(database.daySessions)
      ..where((tbl) => tbl.id.equals(sessionId))).write(
      DaySessionsCompanion(
        isClosed: const Value(true),
        finalizedAt: Value(finalizedAt),
      ),
    );

    if (rowsAffected > 0) {
      print('[DaySessionDrift] 🔒 Sesión cerrada: $sessionId');
    } else {
      print('[DaySessionDrift] ⚠️ WARNING: Sesión $sessionId no encontrada');
    }
  }

  /// Actualiza los IDs de misiones completadas en la sesión
  /// 
  /// NOTA: En Drift, guardamos como JSON string array
  Future<void> updateCompletedMissionIds(
    String sessionId,
    List<String> missionIds,
  ) async {
    // Convertir lista a JSON string
    final jsonString = missionIds.toString(); // Dart convierte List<String> a formato JSON

    final rowsAffected = await (database.update(database.daySessions)
      ..where((tbl) => tbl.id.equals(sessionId))).write(
      DaySessionsCompanion(
        completedMissionIds: Value(jsonString),
      ),
    );

    if (rowsAffected > 0) {
      print('[DaySessionDrift] ✅ Misiones completadas actualizadas: ${missionIds.length}');
    }
  }

  /// Actualiza una sesión completa
  Future<void> updateSession(DaySessionsCompanion session) async {
    await (database.update(database.daySessions)
      ..where((tbl) => tbl.id.equals(session.id.value))).write(session);
    
    print('[DaySessionDrift] ✅ Sesión actualizada: ${session.id.value}');
  }

  // ==========================================================================
  // DELETE
  // ==========================================================================

  /// Elimina una sesión por ID
  /// 
  /// WARNING: Esto también eliminará el feedback asociado (FK constraint)
  Future<void> deleteSession(String id) async {
    final rowsDeleted = await (database.delete(database.daySessions)
      ..where((tbl) => tbl.id.equals(id))).go();

    if (rowsDeleted > 0) {
      print('[DaySessionDrift] 🗑️ Sesión eliminada: $id');
    }
  }

  /// Elimina todas las sesiones (para testing)
  Future<void> deleteAllSessions() async {
    await database.delete(database.daySessions).go();
    print('[DaySessionDrift] 🗑️ Todas las sesiones eliminadas');
  }

  // ==========================================================================
  // ANALYTICS
  // ==========================================================================

  /// Cuenta cuántas sesiones hay para un rango de fechas
  Future<int> countSessionsInRange(DateTime startStripped, DateTime endStripped) async {
    assert(startStripped == startStripped.stripped);
    assert(endStripped == endStripped.stripped);

    final query = database.selectOnly(database.daySessions)
      ..addColumns([database.daySessions.id.count()])
      ..where(database.daySessions.date.isBiggerOrEqualValue(startStripped))
      ..where(database.daySessions.date.isSmallerOrEqualValue(endStripped));

    final result = await query.getSingle();
    return result.read(database.daySessions.id.count()) ?? 0;
  }

  /// Obtiene la racha actual de días cerrados (streak)
  /// 
  /// Comienza desde ayer hacia atrás, contando sesiones cerradas consecutivas
  Future<int> getCurrentStreak() async {
    final yesterday = DateTime.now().stripped.subtract(const Duration(days: 1));
    
    // Obtener sesiones cerradas ordenadas por fecha descendente
    final closedSessions = await (database.select(database.daySessions)
      ..where((tbl) => tbl.isClosed.equals(true))
      ..where((tbl) => tbl.date.isSmallerOrEqualValue(yesterday))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
      ])).get();

    if (closedSessions.isEmpty) {
      print('[DaySessionDrift] 📊 Racha actual: 0 días');
      return 0;
    }

    // Contar días consecutivos
    var streak = 0;
    var expectedDate = yesterday;

    for (final session in closedSessions) {
      if (session.date == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break; // Se rompió la racha
      }
    }

    print('[DaySessionDrift] 📊 Racha actual: $streak días');
    return streak;
  }
}
