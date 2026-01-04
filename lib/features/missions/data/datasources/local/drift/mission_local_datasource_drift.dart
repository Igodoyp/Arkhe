// data/datasources/local/drift/mission_local_datasource_drift.dart

import 'package:drift/drift.dart';
import 'package:d0/core/time/date_time_extensions.dart';
import 'database.dart';

/// DataSource local para Missions usando Drift
/// 
/// RESPONSABILIDADES:
/// - Persistir y recuperar misiones de SQLite
/// - Queries por fecha (scheduledFor stripped)
/// - Marcar misiones como completadas
/// - Contar misiones completadas por fecha
/// 
/// REGLAS DE NEGOCIO:
/// - TODAS las fechas DEBEN estar stripped antes de guardar/buscar
/// - scheduledFor es la fecha clave para agrupación
class MissionLocalDataSourceDrift {
  final AppDatabase database;

  MissionLocalDataSourceDrift({required this.database});

  // ==========================================================================
  // CREATE
  // ==========================================================================

  /// Inserta una misión en la base de datos
  /// 
  /// IMPORTANTE: scheduledFor DEBE estar stripped
  Future<void> insertMission(MissionsCompanion mission) async {
    await database.into(database.missions).insert(
      mission,
      mode: InsertMode.replace,
    );
    
    print('[MissionDrift] ✅ Misión insertada: ${mission.id.value}');
  }

  /// Inserta múltiples misiones en una transacción
  /// 
  /// IMPORTANTE: Todas las scheduledFor DEBEN estar stripped
  Future<void> insertMissions(List<MissionsCompanion> missions) async {
    await database.transaction(() async {
      for (final mission in missions) {
        await database.into(database.missions).insert(
          mission,
          mode: InsertMode.replace,
        );
      }
    });
    
    print('[MissionDrift] ✅ ${missions.length} misiones insertadas');
  }

  // ==========================================================================
  // READ - QUERIES POR FECHA (STRIPPED)
  // ==========================================================================

  /// Obtiene todas las misiones para una fecha específica (stripped)
  /// 
  /// Esta es la query PRINCIPAL para cargar misiones del día.
  /// 
  /// @param dateStripped: Fecha normalizada (00:00:00)
  /// @returns: Lista de misiones ordenadas por createdAt
  Future<List<MissionData>> getMissionsByDate(DateTime dateStripped) async {
    // Validar que la fecha esté stripped
    assert(
      dateStripped == dateStripped.stripped,
      'ERROR: getMissionsByDate requiere fecha stripped. '
      'Recibido: $dateStripped, Esperado: ${dateStripped.stripped}'
    );

    final query = database.select(database.missions)
      ..where((tbl) => tbl.scheduledFor.equals(dateStripped))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.createdAt),
      ]);

    final results = await query.get();
    
    print('[MissionDrift] 📖 ${results.length} misiones encontradas para ${dateStripped.toIso8601String()}');
    
    return results;
  }

  /// Observa cambios en las misiones de un día específico (STREAM)
  /// 
  /// Este método retorna un Stream que emite la lista de misiones cada vez
  /// que hay cambios en Drift (inserts, updates, deletes).
  /// 
  /// USO PRINCIPAL: UI reactiva que se actualiza automáticamente cuando:
  /// - Se genera una nueva misión
  /// - Se marca/desmarca una misión como completada
  /// - Se elimina una misión
  /// 
  /// @param dateStripped: Fecha normalizada (00:00:00)
  /// @returns: Stream de lista de misiones que se actualiza en tiempo real
  Stream<List<MissionData>> watchMissionsByDate(DateTime dateStripped) {
    // Validar que la fecha esté stripped
    assert(
      dateStripped == dateStripped.stripped,
      'ERROR: watchMissionsByDate requiere fecha stripped. '
      'Recibido: $dateStripped, Esperado: ${dateStripped.stripped}'
    );

    final query = database.select(database.missions)
      ..where((tbl) => tbl.scheduledFor.equals(dateStripped))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.createdAt),
      ]);

    // .watch() es la magia de Drift: convierte la query en un Stream
    // que emite cada vez que la tabla cambia
    return query.watch();
  }

  /// Obtiene misiones por sessionId (para agrupar)
  Future<List<MissionData>> getMissionsBySessionId(String sessionId) async {
    final query = database.select(database.missions)
      ..where((tbl) => tbl.sessionId.equals(sessionId))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.createdAt),
      ]);

    return await query.get();
  }

  /// Obtiene una misión por ID
  Future<MissionData?> getMissionById(String id) async {
    final query = database.select(database.missions)
      ..where((tbl) => tbl.id.equals(id));

    final results = await query.get();
    return results.isNotEmpty ? results.first : null;
  }

  // ==========================================================================
  // UPDATE
  // ==========================================================================

  /// Marca una misión como completada/no completada
  /// 
  /// @param missionId: ID de la misión
  /// @param isCompleted: true para marcar como completada, false para desmarcar
  Future<void> setCompleted(String missionId, bool isCompleted) async {
    final now = DateTime.now();
    
    final rowsAffected = await (database.update(database.missions)
      ..where((tbl) => tbl.id.equals(missionId))).write(
      MissionsCompanion(
        isCompleted: Value(isCompleted),
        updatedAt: Value(now),
      ),
    );

    if (rowsAffected > 0) {
      print('[MissionDrift] ✅ Misión $missionId marcada como ${isCompleted ? "completada" : "pendiente"}');
    } else {
      print('[MissionDrift] ⚠️ WARNING: Misión $missionId no encontrada');
    }
  }

  /// Actualiza una misión completa
  Future<void> updateMission(MissionsCompanion mission) async {
    await (database.update(database.missions)
      ..where((tbl) => tbl.id.equals(mission.id.value))).write(mission);
    
    print('[MissionDrift] ✅ Misión actualizada: ${mission.id.value}');
  }

  // ==========================================================================
  // ANALYTICS & COUNTS
  // ==========================================================================

  /// Cuenta cuántas misiones están completadas para una fecha específica
  /// 
  /// Útil para:
  /// - Mostrar progreso del día: "3/5 misiones completadas"
  /// - Calcular XP ganado del día
  /// - Determinar si se completó el día
  /// 
  /// @param dateStripped: Fecha normalizada (00:00:00)
  /// @returns: Número de misiones completadas
  Future<int> countCompletedByDate(DateTime dateStripped) async {
    // Validar que la fecha esté stripped
    assert(
      dateStripped == dateStripped.stripped,
      'ERROR: countCompletedByDate requiere fecha stripped'
    );

    final query = database.selectOnly(database.missions)
      ..addColumns([database.missions.id.count()])
      ..where(database.missions.scheduledFor.equals(dateStripped))
      ..where(database.missions.isCompleted.equals(true));

    final result = await query.getSingle();
    final count = result.read(database.missions.id.count()) ?? 0;
    
    print('[MissionDrift] 📊 $count misiones completadas en ${dateStripped.toIso8601String()}');
    
    return count;
  }

  /// Cuenta el total de misiones para una fecha
  Future<int> countTotalByDate(DateTime dateStripped) async {
    assert(
      dateStripped == dateStripped.stripped,
      'ERROR: countTotalByDate requiere fecha stripped'
    );

    final query = database.selectOnly(database.missions)
      ..addColumns([database.missions.id.count()])
      ..where(database.missions.scheduledFor.equals(dateStripped));

    final result = await query.getSingle();
    return result.read(database.missions.id.count()) ?? 0;
  }

  /// Obtiene el XP total ganado en una fecha
  Future<int> getTotalXpByDate(DateTime dateStripped) async {
    assert(
      dateStripped == dateStripped.stripped,
      'ERROR: getTotalXpByDate requiere fecha stripped'
    );

    final query = database.select(database.missions)
      ..where((tbl) => tbl.scheduledFor.equals(dateStripped))
      ..where((tbl) => tbl.isCompleted.equals(true));

    final completedMissions = await query.get();
    
    final totalXp = completedMissions.fold<int>(
      0,
      (sum, mission) => sum + mission.xpReward,
    );
    
    print('[MissionDrift] 💎 $totalXp XP ganado en ${dateStripped.toIso8601String()}');
    
    return totalXp;
  }

  // ==========================================================================
  // DELETE
  // ==========================================================================

  /// Elimina una misión por ID
  Future<void> deleteMission(String id) async {
    final rowsDeleted = await (database.delete(database.missions)
      ..where((tbl) => tbl.id.equals(id))).go();

    if (rowsDeleted > 0) {
      print('[MissionDrift] 🗑️ Misión eliminada: $id');
    }
  }

  /// Elimina todas las misiones de una fecha específica
  /// 
  /// Útil para:
  /// - Regenerar misiones del día
  /// - Limpiar misiones antiguas
  Future<void> deleteMissionsByDate(DateTime dateStripped) async {
    assert(
      dateStripped == dateStripped.stripped,
      'ERROR: deleteMissionsByDate requiere fecha stripped'
    );

    final rowsDeleted = await (database.delete(database.missions)
      ..where((tbl) => tbl.scheduledFor.equals(dateStripped))).go();

    print('[MissionDrift] 🗑️ $rowsDeleted misiones eliminadas de ${dateStripped.toIso8601String()}');
  }

  /// Elimina todas las misiones (para testing)
  Future<void> deleteAllMissions() async {
    await database.delete(database.missions).go();
    print('[MissionDrift] 🗑️ Todas las misiones eliminadas');
  }
}
