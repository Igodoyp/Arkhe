// domain/usecases/get_daily_missions_usecase.dart

import '../entities/mission_entity.dart';
import '../repositories/mission_repository.dart';
import '../../../../core/time/date_time_extensions.dart';

/// Use Case para obtener misiones del día desde Drift
/// 
/// RESPONSABILIDADES:
/// - Recuperar misiones ya generadas y guardadas en Drift
/// - Aplicar filtros por fecha
/// - Retornar lista vacía si no hay misiones (caller decidirá si genera)
/// 
/// DIFERENCIA CON GenerateDailyMissionsUseCase:
/// - Este SOLO lee de Drift (no genera)
/// - GenerateDailyMissionsUseCase genera Y guarda en Drift
class GetDailyMissionsUseCase {
  final MissionRepository missionRepository;

  GetDailyMissionsUseCase({required this.missionRepository});

  /// Obtiene misiones del día desde la base de datos local
  /// 
  /// @param targetDate: Fecha para la cual obtener misiones (será stripped internamente)
  /// @returns: Lista de misiones del día (vacía si no hay misiones guardadas)
  Future<List<Mission>> call(DateTime targetDate) async {
    final dateStripped = targetDate.stripped;
    
    print('[GetDailyMissions] 📖 Obteniendo misiones para: $dateStripped');
    
    final missions = await missionRepository.getDailyMissions();
    
    print('[GetDailyMissions] ✅ ${missions.length} misiones encontradas');
    
    return missions;
  }
}
