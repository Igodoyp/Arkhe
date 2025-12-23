// domain/repositories/mission_repository.dart
import '../entities/mission_entity.dart';

abstract class MissionRepository {
  Future<List<Mission>> getDailyMissions();
  Future<void> updateMission(Mission mission);
}