// data/models/day_session_model.dart
import '../../domain/entities/day_session_entity.dart';
import '../../domain/entities/mission_entity.dart';
import 'mission_model.dart';
import '../../../../core/time/date_time_extensions.dart';

class DaySessionModel extends DaySession {
  DaySessionModel({
    required super.id,
    required super.date,
    required super.completedMissions,
    super.isClosed,
  });

  // Factory para convertir JSON a DaySessionModel
  factory DaySessionModel.fromJson(Map<String, dynamic> json) {
    final missionsJson = json['completedMissions'] as List<dynamic>? ?? [];
    final missions = missionsJson
        .map((missionJson) => MissionModel.fromJson(missionJson as Map<String, dynamic>))
        .toList();

    return DaySessionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String).stripped,
      completedMissions: missions,
      isClosed: json['isClosed'] as bool? ?? false,
    );
  }

  // Método para convertir DaySessionModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'completedMissions': completedMissions
          .map((mission) => _missionToJson(mission))
          .toList(),
      'isClosed': isClosed,
    };
  }

  // Helper para convertir Mission a JSON
  Map<String, dynamic> _missionToJson(Mission mission) {
    return {
      'id': mission.id,
      'title': mission.title,
      'description': mission.description,
      'xpReward': mission.xpReward,
      'isCompleted': mission.isCompleted,
      'type': mission.type.name,
    };
  }

  // copyWith que retorna DaySessionModel
  @override
  DaySessionModel copyWith({
    String? id,
    DateTime? date,
    List<Mission>? completedMissions,
    bool? isClosed,
  }) {
    return DaySessionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      completedMissions: completedMissions ?? List.from(this.completedMissions),
      isClosed: isClosed ?? this.isClosed,
    );
  }

  // Override de métodos para retornar DaySessionModel
  @override
  DaySessionModel addCompletedMission(Mission mission) {
    final newCompleted = List<Mission>.from(completedMissions);
    if (!newCompleted.any((m) => m.id == mission.id)) {
      newCompleted.add(mission);
    }
    return copyWith(completedMissions: newCompleted);
  }

  @override
  DaySessionModel removeCompletedMission(String missionId) {
    final newCompleted = completedMissions.where((m) => m.id != missionId).toList();
    return copyWith(completedMissions: newCompleted);
  }

  @override
  DaySessionModel finalize() {
    return copyWith(isClosed: true);
  }
}
