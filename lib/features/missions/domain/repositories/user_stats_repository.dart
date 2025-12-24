// domain/repositories/user_stats_repository.dart
import '../entities/user_stats_entity.dart';

abstract class UserStatsRepository {
  Future<UserStats> getUserStats();
  Future<void> updateUserStats(UserStats stats);
}
