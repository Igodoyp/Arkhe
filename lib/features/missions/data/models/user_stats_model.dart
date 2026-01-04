// data/models/user_stats_model.dart
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/entities/stat_type.dart';

class UserStatsModel extends UserStats {
  UserStatsModel({
    required super.stats,
  });

  // Factory para convertir JSON a UserStatsModel
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      stats: {
        StatType.strength: (json['strength'] as num?)?.toDouble() ?? 0.0,
        StatType.intelligence: (json['intelligence'] as num?)?.toDouble() ?? 0.0,
        StatType.charisma: (json['charisma'] as num?)?.toDouble() ?? 0.0,
        StatType.vitality: (json['vitality'] as num?)?.toDouble() ?? 0.0,
        StatType.dexterity: (json['dexterity'] as num?)?.toDouble() ?? 0.0,
        StatType.wisdom: (json['wisdom'] as num?)?.toDouble() ?? 0.0,
      },
    );
  }

  // Método para convertir UserStatsModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'strength': stats[StatType.strength],
      'intelligence': stats[StatType.intelligence],
      'charisma': stats[StatType.charisma],
      'vitality': stats[StatType.vitality],
      'dexterity': stats[StatType.dexterity],
      'wisdom': stats[StatType.wisdom],
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
