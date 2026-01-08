// data/datasources/local/drift/user_stats_local_datasource_drift.dart

import 'dart:convert';
import 'package:drift/drift.dart';
import 'database.dart';
import '../../../../domain/entities/stat_type.dart';

/// DataSource local para UserStats usando Drift
/// 
/// RESPONSABILIDADES:
/// - Persistir stats del usuario en SQLite
/// - Cargar stats al iniciar la app
/// - Actualizar stats cuando se completan misiones
/// 
/// FORMATO DE PERSISTENCIA:
/// - statsJson: JSON string con stats Y totalXp
/// - Ejemplo: {"stats":{"strength":25.5,"intelligence":30.0},"totalXp":1500}
class UserStatsLocalDataSourceDrift {
  final AppDatabase database;
  static const String defaultUserId = 'default_user';

  UserStatsLocalDataSourceDrift({required this.database});

  // ==========================================================================
  // READ
  // ==========================================================================

  /// Obtiene las stats del usuario desde Drift
  /// 
  /// Si no existen, retorna stats iniciales (todas en 0, totalXp = 0)
  Future<({Map<StatType, double> stats, int totalXp})> getUserStats() async {
    final query = database.select(database.userStats)
      ..where((tbl) => tbl.id.equals(defaultUserId));

    final results = await query.get();

    if (results.isEmpty) {
      print('[UserStatsDrift] 📊 No hay stats guardadas, retornando iniciales');
      return (stats: _getInitialStats(), totalXp: 0);
    }

    final data = results.first;
    final parsed = _parseStatsJson(data.statsJson);
    
    print('[UserStatsDrift] 📊 Stats cargadas: ${parsed.stats}, XP: ${parsed.totalXp}');
    return parsed;
  }

  // ==========================================================================
  // WRITE
  // ==========================================================================

  /// Guarda las stats del usuario en Drift
  /// 
  /// Usa InsertMode.replace para actualizar si ya existe
  /// @param lastUpdated: Timestamp de actualización (inyectado desde repo)
  Future<void> saveUserStats(Map<StatType, double> stats, int totalXp, DateTime lastUpdated) async {
    final statsJson = _statsToJson(stats, totalXp);
    
    await database.into(database.userStats).insert(
      UserStatsCompanion(
        id: const Value(defaultUserId),
        statsJson: Value(statsJson),
        lastUpdated: Value(lastUpdated),
      ),
      mode: InsertMode.replace,
    );

    print('[UserStatsDrift] ✅ Stats guardadas: $stats, XP: $totalXp');
  }

  /// Actualiza una stat específica (incremento)
  /// 
  /// Útil para aplicar rewards de misiones
  /// @param lastUpdated: Timestamp de actualización (inyectado desde repo)
  Future<void> incrementStat(StatType type, double amount, DateTime lastUpdated) async {
    final current = await getUserStats();
    final newStats = Map<StatType, double>.from(current.stats);
    newStats[type] = (newStats[type] ?? 0.0) + amount;
    
    // Limitar a 100
    if (newStats[type]! > 100) {
      newStats[type] = 100;
    }
    
    await saveUserStats(newStats, current.totalXp, lastUpdated);
  }

  // ==========================================================================
  // DELETE
  // ==========================================================================

  /// Resetea las stats del usuario (útil para testing)
  Future<void> resetStats() async {
    await (database.delete(database.userStats)
      ..where((tbl) => tbl.id.equals(defaultUserId))).go();
    
    print('[UserStatsDrift] 🔄 Stats reseteadas');
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  /// Stats iniciales (todas en 0)
  Map<StatType, double> _getInitialStats() {
    return {
      for (var type in StatType.values) type: 0.0,
    };
  }

  /// Convierte Map<StatType, double> y totalXp a JSON string
  String _statsToJson(Map<StatType, double> stats, int totalXp) {
    final statsMap = <String, double>{};
    for (var entry in stats.entries) {
      statsMap[entry.key.name] = entry.value;
    }
    
    final fullJson = {
      'stats': statsMap,
      'totalXp': totalXp,
    };
    
    return json.encode(fullJson);
  }

  /// Parsea JSON string a Map<StatType, double> y totalXp
  ({Map<StatType, double> stats, int totalXp}) _parseStatsJson(String statsJson) {
    try {
      final fullJson = json.decode(statsJson) as Map<String, dynamic>;
      
      // Manejar formato antiguo (solo stats) y nuevo (stats + totalXp)
      Map<String, dynamic> statsData;
      int totalXp = 0;
      
      if (fullJson.containsKey('stats')) {
        // Formato nuevo
        statsData = fullJson['stats'] as Map<String, dynamic>;
        totalXp = (fullJson['totalXp'] as num?)?.toInt() ?? 0;
      } else {
        // Formato antiguo (retrocompatibilidad)
        statsData = fullJson;
        totalXp = 0;
      }
      
      final stats = <StatType, double>{};
      for (var entry in statsData.entries) {
        final type = StatType.values.firstWhere(
          (t) => t.name == entry.key,
          orElse: () => StatType.strength,
        );
        stats[type] = (entry.value as num).toDouble();
      }
      
      // Asegurar que todas las stats existan
      for (var type in StatType.values) {
        stats.putIfAbsent(type, () => 0.0);
      }
      
      return (stats: stats, totalXp: totalXp);
    } catch (e) {
      print('[UserStatsDrift] ⚠️ Error parseando stats JSON: $e');
      return (stats: _getInitialStats(), totalXp: 0);
    }
  }
}
