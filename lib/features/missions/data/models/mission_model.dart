// data/models/mission_model.dart
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/stat_type.dart';
class MissionModel extends Mission {
  MissionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.xpReward,
    super.isCompleted,
  });

  // Factory para convertir el JSON (o Map) en objeto
  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      xpReward: json['xpReward'] as int,
      type: StatType.values.byName(json['type']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // copyWith que retorna MissionModel
  @override
  MissionModel copyWith({
    String? id,
    String? title,
    String? description,
    StatType? type,
    int? xpReward,
    bool? isCompleted,
  }) {
    return MissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}