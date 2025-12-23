import '../repositories/mission_repository.dart';
import '../entities/mission_entity.dart';

class ToggleMissionUseCase {
  final MissionRepository repository;

  ToggleMissionUseCase(this.repository);

  Future<void> call(Mission mission) async {
    // Generamos la versión opuesta de la misión actual
    final updatedMission = mission.copyWith(isCompleted: !mission.isCompleted);
    // Guardamos en el sistema
    return repository.updateMission(updatedMission);
  }
}