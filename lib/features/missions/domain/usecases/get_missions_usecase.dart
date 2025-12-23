import '../entities/mission_entity.dart';
import '../repositories/mission_repository.dart';

class GetMissionsUseCase {

  final MissionRepository repository; 

  GetMissionsUseCase(this.repository);

  Future<List<Mission>> call() {
    return repository.getDailyMissions();
  }
}