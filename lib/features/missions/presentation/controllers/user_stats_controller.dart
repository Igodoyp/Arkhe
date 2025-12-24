// presentation/controllers/user_stats_controller.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/entities/stat_type.dart';
import '../../domain/usecases/user_stats_usecase.dart';

class UserStatsController extends ChangeNotifier {
  final GetUserStatsUseCase getUserStatsUseCase;
  final UpdateUserStatsUseCase updateUserStatsUseCase;
  final IncrementStatUseCase incrementStatUseCase;

  UserStatsController({
    required this.getUserStatsUseCase,
    required this.updateUserStatsUseCase,
    required this.incrementStatUseCase,
  });

  UserStats? _userStats;
  bool _isLoading = false;

  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;

  // Obtener las stats como Map para pasarlas al radar chart
  Map<StatType, double> get statsMap => _userStats?.stats ?? {};

  // Cargar las stats del usuario
  Future<void> loadUserStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userStats = await getUserStatsUseCase();
      print('Stats cargadas: $_userStats');
    } catch (e) {
      print('Error al cargar stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Incrementar una stat específica (útil cuando completas una misión)
  Future<void> incrementStat(StatType type, double amount) async {
    if (_userStats == null) {
      print('No se pueden incrementar stats: userStats es null');
      return;
    }

    try {
      _userStats = await incrementStatUseCase(type, amount);
      notifyListeners();
      print('Stat $type incrementada en $amount. Nuevas stats: $_userStats');
    } catch (e) {
      print('Error al incrementar stat: $e');
    }
  }

  // Actualizar todas las stats
  Future<void> updateStats(UserStats newStats) async {
    try {
      await updateUserStatsUseCase(newStats);
      _userStats = newStats;
      notifyListeners();
      print('Stats actualizadas: $_userStats');
    } catch (e) {
      print('Error al actualizar stats: $e');
    }
  }
}
