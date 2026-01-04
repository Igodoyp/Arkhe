// domain/entities/day_session_entity.dart
import 'mission_entity.dart';
import '../../../../core/time/date_time_extensions.dart';

class DaySession {
  final String id;
  final DateTime date;
  final List<Mission> completedMissions;
  final bool isClosed;

  DaySession({
    required this.id,
    required DateTime date,
    required this.completedMissions,
    this.isClosed = false,
  }) : date = date.stripped;

  // Método copyWith para inmutabilidad
  DaySession copyWith({
    String? id,
    DateTime? date,
    List<Mission>? completedMissions,
    bool? isClosed,
  }) {
    return DaySession(
      id: id ?? this.id,
      date: (date ?? this.date).stripped,
      completedMissions: completedMissions ?? List.from(this.completedMissions),
      isClosed: isClosed ?? this.isClosed,
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
    return copyWith(isClosed: true);
  }

  @override
  String toString() {
    return 'DaySession(id: $id, date: $date, completedMissions: ${completedMissions.length}, isClosed: $isClosed)';
  }
}
