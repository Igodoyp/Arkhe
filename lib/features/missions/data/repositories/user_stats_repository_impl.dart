// data/repositories/user_stats_repository_impl.dart
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../datasources/user_stats_datasource.dart';
import '../models/user_stats_model.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final StatsRemoteDataSource remoteDataSource;

  UserStatsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserStats> getUserStats() async {
    // 1. Obtener JSON del datasource
    final json = await remoteDataSource.fetchUserStatsFromServer();
    
    // 2. Convertir JSON a modelo
    final model = UserStatsModel.fromJson(json);
    
    // 3. Retornar como entidad (el modelo extiende la entidad)
    return model;
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    // 1. Convertir entidad a modelo si no lo es
    final model = stats is UserStatsModel 
        ? stats 
        : UserStatsModel(stats: stats.stats);
    
    // 2. Convertir a JSON
    final json = model.toJson();
    
    // 3. Enviar al datasource
    await remoteDataSource.updateUserStats(json);
  }
}
