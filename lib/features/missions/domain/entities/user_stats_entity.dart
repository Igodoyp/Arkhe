// domain/entities/user_stats_entity.dart
import 'stat_type.dart';

class UserStats {
  final Map<StatType, double> stats;

  UserStats({
    required this.stats,
  });

  // Método para obtener el valor de una stat específica
  double getStat(StatType type) {
    return stats[type] ?? 0.0;
  }

  // Método copyWith para crear una copia con stats modificadas
  UserStats copyWith({
    Map<StatType, double>? stats,
  }) {
    return UserStats(
      stats: stats ?? Map.from(this.stats),
    );
  }

  // Método para incrementar una stat (útil cuando completas misiones)
  UserStats incrementStat(StatType type, double amount) {
    final newStats = Map<StatType, double>.from(stats);
    newStats[type] = (newStats[type] ?? 0.0) + amount;
    // Limitar a 100 como máximo
    if (newStats[type]! > 100) {
      newStats[type] = 100;
    }
    return UserStats(stats: newStats);
  }

  @override
  String toString() {
    return 'UserStats(stats: $stats)';
  }
}
