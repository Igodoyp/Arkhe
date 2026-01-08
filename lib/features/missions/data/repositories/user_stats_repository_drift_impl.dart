// data/repositories/user_stats_repository_drift_impl.dart
import '../../../../core/time/time_provider.dart';
import '../../domain/entities/stat_type.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../datasources/local/drift/user_stats_local_datasource_drift.dart';

/// Implementación del repositorio de UserStats usando Drift como persistencia
/// 
/// RESPONSABILIDADES:
/// - Cargar stats persistidas en SQLite
/// - Guardar stats cuando se actualizan (por EndDayUseCase)
/// - Proveer stats iniciales si no existen
class UserStatsRepositoryDriftImpl implements UserStatsRepository {
  final UserStatsLocalDataSourceDrift localDataSource;
  final TimeProvider timeProvider;

  UserStatsRepositoryDriftImpl({
    required this.localDataSource,
    required this.timeProvider,
  });

  @override
  Future<UserStats> getUserStats() async {
    try {
      final data = await localDataSource.getUserStats();
      return UserStats(stats: data.stats, totalXp: data.totalXp);
    } catch (e) {
      print('[UserStatsRepo] ⚠️ Error cargando stats: $e');
      // En caso de error, retornar stats iniciales
      return UserStats(
        stats: {for (var type in StatType.values) type: 0.0},
        totalXp: 0,
      );
    }
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    try {
      await localDataSource.saveUserStats(stats.stats, stats.totalXp, timeProvider.now);
    } catch (e) {
      throw Exception('Error al actualizar stats: $e');
    }
  }

  /// Incrementa una stat específica (helper)
  Future<void> incrementStat(StatType type, double amount) async {
    await localDataSource.incrementStat(type, amount, timeProvider.now);
  }

  /// Resetea stats a 0 (útil para testing)
  Future<void> resetStats() async {
    await localDataSource.resetStats();
  }
}
