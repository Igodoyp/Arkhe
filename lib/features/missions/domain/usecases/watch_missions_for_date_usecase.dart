// domain/usecases/watch_missions_for_date_usecase.dart
import '../entities/mission_entity.dart';
import '../repositories/mission_repository.dart';
import '../../../../core/time/date_time_extensions.dart';

/// UseCase formal para observar cambios en misiones de una fecha específica
/// 
/// RESPONSABILIDAD ÚNICA:
/// - Exponer el stream reactivo de misiones desde el repository
/// - Encapsular la lógica de suscripción para Clean Architecture
/// 
/// MODO DE OPERACIÓN (REACTIVE):
/// 1. Retorna un Stream<List<Mission>> que emite cada vez que:
///    - Se insertan nuevas misiones en Drift
///    - Se actualiza una misión (completada/descompletada)
///    - Se elimina una misión
/// 2. El stream se mantiene abierto mientras haya suscriptores
/// 3. Drift maneja automáticamente los cambios de la base de datos
/// 
/// VENTAJAS:
/// - UI se actualiza automáticamente sin refresh manual
/// - Single source of truth: Drift es la fuente de verdad
/// - Evita problemas de sincronización entre memoria y DB
/// 
/// USO:
/// ```dart
/// // En MissionController:
/// watchMissionsUseCase.call(timeProvider.todayStripped).listen((missions) {
///   state = state.copyWith(missions: missions, isLoading: false);
/// });
/// ```
class WatchMissionsForDateUseCase {
  final MissionRepository repository;

  WatchMissionsForDateUseCase({
    required this.repository,
  });

  /// Observa cambios en las misiones de una fecha específica
  /// 
  /// @param dateStripped: Fecha normalizada a medianoche
  /// @returns: Stream<List<Mission>> que emite en cada cambio
  Stream<List<Mission>> call(DateTime dateStripped) {
    assert(dateStripped == dateStripped.stripped, 'Date must be stripped');
    
    return repository.watchMissionsForDate(dateStripped);
  }
}
