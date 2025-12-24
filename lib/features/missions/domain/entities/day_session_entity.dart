// domain/entities/day_session_entity.dart
import 'mission_entity.dart';

class DaySession {
  final String id;
  final DateTime date;
  final List<Mission> completedMissions;
  final bool isFinalized;

  DaySession({
    required this.id,
    required this.date,
    required this.completedMissions,
    this.isFinalized = false,
  });

  // Método copyWith para inmutabilidad
  DaySession copyWith({
    String? id,
    DateTime? date,
    List<Mission>? completedMissions,
    bool? isFinalized,
  }) {
    return DaySession(
      id: id ?? this.id,
      date: date ?? this.date,
      completedMissions: completedMissions ?? List.from(this.completedMissions),
      isFinalized: isFinalized ?? this.isFinalized,
    );
  }

  // Agregar una misión completada
  DaySession addCompletedMission(Mission mission) {
    final newCompleted = List<Mission>.from(completedMissions);
    // Solo agregar si no está ya en la lista
    if (!newCompleted.any((m) => m.id == mission.id)) {
      newCompleted.add(mission);
    }
    return copyWith(completedMissions: newCompleted);
  }

  // Remover una misión (si se desmarca como completada)
  DaySession removeCompletedMission(String missionId) {
    final newCompleted = completedMissions.where((m) => m.id != missionId).toList();
    return copyWith(completedMissions: newCompleted);
  }

  // Finalizar el día
  DaySession finalize() {
    return copyWith(isFinalized: true);
  }

  @override
  String toString() {
    return 'DaySession(id: $id, date: $date, completedMissions: ${completedMissions.length}, isFinalized: $isFinalized)';
  }
}
