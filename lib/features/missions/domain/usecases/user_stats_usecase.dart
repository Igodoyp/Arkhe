// domain/usecases/user_stats_usecase.dart
import '../entities/user_stats_entity.dart';
import '../entities/stat_type.dart';
import '../repositories/user_stats_repository.dart';

// UseCase para obtener las stats del usuario
class GetUserStatsUseCase {
  final UserStatsRepository repository;

  GetUserStatsUseCase(this.repository);

  Future<UserStats> call() async {
    return await repository.getUserStats();
  }
}

// UseCase para actualizar las stats del usuario
class UpdateUserStatsUseCase {
  final UserStatsRepository repository;

  UpdateUserStatsUseCase(this.repository);

  Future<void> call(UserStats stats) async {
    await repository.updateUserStats(stats);
  }
}

// UseCase para incrementar una stat específica (cuando completas una misión)
class IncrementStatUseCase {
  final UserStatsRepository repository;

  IncrementStatUseCase(this.repository);

  Future<UserStats> call(StatType type, double amount) async {
    // 1. Obtener stats actuales
    final currentStats = await repository.getUserStats();
    
    // 2. Incrementar la stat
    final updatedStats = currentStats.incrementStat(type, amount);
    
    // 3. Guardar las stats actualizadas
    await repository.updateUserStats(updatedStats);
    
    // 4. Retornar las stats actualizadas
    return updatedStats;
  }
}
