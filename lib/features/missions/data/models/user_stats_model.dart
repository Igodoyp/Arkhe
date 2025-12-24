// data/models/user_stats_model.dart
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/entities/stat_type.dart';

class UserStatsModel extends UserStats {
  UserStatsModel({
    required Map<StatType, double> stats,
  }) : super(stats: stats);

  // Factory para convertir JSON a UserStatsModel
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      stats: {
        StatType.strength: (json['strength'] as num?)?.toDouble() ?? 0.0,
        StatType.intelligence: (json['intelligence'] as num?)?.toDouble() ?? 0.0,
        StatType.creativity: (json['creativity'] as num?)?.toDouble() ?? 0.0,
        StatType.discipline: (json['discipline'] as num?)?.toDouble() ?? 0.0,
      },
    );
  }

  // Método para convertir UserStatsModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'strength': stats[StatType.strength],
      'intelligence': stats[StatType.intelligence],
      'creativity': stats[StatType.creativity],
      'discipline': stats[StatType.discipline],
    };
  }

  // copyWith que retorna UserStatsModel
  @override
  UserStatsModel copyWith({
    Map<StatType, double>? stats,
  }) {
    return UserStatsModel(
      stats: stats ?? Map.from(this.stats),
    );
  }

  // Override de incrementStat para retornar UserStatsModel
  @override
  UserStatsModel incrementStat(StatType type, double amount) {
    final newStats = Map<StatType, double>.from(stats);
    newStats[type] = (newStats[type] ?? 0.0) + amount;
    // Limitar a 100 como máximo
    if (newStats[type]! > 100) {
      newStats[type] = 100;
    }
    return UserStatsModel(stats: newStats);
  }
}
