// domain/usecases/day_session_usecase.dart
import '../entities/day_session_entity.dart';
import '../entities/mission_entity.dart';
import '../entities/stat_type.dart';
import '../entities/user_stats_entity.dart';
import '../repositories/day_session_repository.dart';
import '../repositories/user_stats_repository.dart';

// UseCase para obtener la sesión del día actual
class GetCurrentDaySessionUseCase {
  final DaySessionRepository repository;

  GetCurrentDaySessionUseCase(this.repository);

  Future<DaySession> call() async {
    return await repository.getCurrentDaySession();
  }
}

// UseCase para agregar una misión completada a la sesión
class AddCompletedMissionUseCase {
  final DaySessionRepository repository;

  AddCompletedMissionUseCase(this.repository);

  Future<void> call(Mission mission) async {
    await repository.addCompletedMission(mission);
  }
}

// UseCase para remover una misión completada de la sesión
class RemoveCompletedMissionUseCase {
  final DaySessionRepository repository;

  RemoveCompletedMissionUseCase(this.repository);

  Future<void> call(String missionId) async {
    await repository.removeCompletedMission(missionId);
  }
}

// UseCase principal: Finalizar el día y actualizar stats
class EndDayUseCase {
  final DaySessionRepository daySessionRepository;
  final UserStatsRepository userStatsRepository;

  EndDayUseCase({
    required this.daySessionRepository,
    required this.userStatsRepository,
  });

  Future<EndDayResult> call() async {
    // 1. Obtener la sesión del día actual
    final currentSession = await daySessionRepository.getCurrentDaySession();

    // 2. Verificar que haya misiones completadas
    if (currentSession.completedMissions.isEmpty) {
      return EndDayResult(
        statsGained: {},
        totalXpGained: 0,
        missionsCompleted: 0,
      );
    }

    // 3. Calcular stats ganadas por tipo
    final statsGained = <StatType, double>{};
    int totalXp = 0;

    for (final mission in currentSession.completedMissions) {
      // Cada misión incrementa su stat correspondiente
      // Puedes ajustar la fórmula: por ejemplo, xpReward / 10 para las stats
      final statIncrement = mission.xpReward / 10.0;
      statsGained[mission.type] = (statsGained[mission.type] ?? 0.0) + statIncrement;
      totalXp += mission.xpReward;
    }

    // 4. Obtener stats actuales del usuario
    final currentStats = await userStatsRepository.getUserStats();

    // 5. Aplicar los incrementos a las stats
    UserStats updatedStats = currentStats;
    for (final entry in statsGained.entries) {
      updatedStats = updatedStats.incrementStat(entry.key, entry.value);
    }

    // 6. Guardar las stats actualizadas
    await userStatsRepository.updateUserStats(updatedStats);

    // 7. Finalizar la sesión del día
    await daySessionRepository.finalizeDaySession();

    // 8. Retornar el resultado
    return EndDayResult(
      statsGained: statsGained,
      totalXpGained: totalXp,
      missionsCompleted: currentSession.completedMissions.length,
    );
  }
}

// Clase para el resultado de finalizar el día
class EndDayResult {
  final Map<StatType, double> statsGained;
  final int totalXpGained;
  final int missionsCompleted;

  EndDayResult({
    required this.statsGained,
    required this.totalXpGained,
    required this.missionsCompleted,
  });

  @override
  String toString() {
    return 'EndDayResult(statsGained: $statsGained, totalXpGained: $totalXpGained, missionsCompleted: $missionsCompleted)';
  }
}
