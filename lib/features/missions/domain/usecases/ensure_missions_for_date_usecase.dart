// domain/usecases/ensure_missions_for_date_usecase.dart
import '../services/mission_orchestration_service.dart';
import '../../../../core/time/date_time_extensions.dart';

/// UseCase formal que garantiza que existan misiones para una fecha específica
/// 
/// RESPONSABILIDAD ÚNICA:
/// - Si ya hay misiones → No hace nada (LAZY)
/// - Si NO hay misiones → Genera nuevas misiones vía AI (orchestration)
/// 
/// MODO DE OPERACIÓN (LAZY):
/// 1. Verifica si existen misiones en Drift para la fecha
/// 2. Si NO existen → llama a orchestration.lazyLoadMissions()
/// 3. Si SÍ existen → retorna sin hacer nada (idempotente)
/// 
/// DIFERENCIA CON EAGER:
/// - EAGER: Genera misiones al iniciar la app (en startup)
/// - LAZY: Genera misiones solo cuando el usuario abre la pantalla
/// 
/// USO:
/// ```dart
/// // En MissionController:
/// await ensureMissionsUseCase.call(timeProvider.todayStripped);
/// ```
class EnsureMissionsForDateUseCase {
  final MissionOrchestrationService orchestrationService;

  EnsureMissionsForDateUseCase({
    required this.orchestrationService,
  });

  /// Garantiza que existan misiones para una fecha específica
  /// 
  /// @param dateStripped: Fecha normalizada a medianoche
  /// @returns: Future<void> que completa cuando las misiones están garantizadas
  /// 
  /// IMPORTANTE: Esta operación es idempotente (puede llamarse múltiples veces)
  Future<void> call(DateTime dateStripped) async {
    assert(dateStripped == dateStripped.stripped, 'Date must be stripped');
    
    // La orchestration service usa LAZY loading (verifica si existen antes de generar)
    await orchestrationService.lazyLoadMissions(forceRegenerate: false);
  }
}
