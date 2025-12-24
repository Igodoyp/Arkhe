// presentation/controllers/day_session_controller.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/day_session_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/usecases/day_session_usecase.dart';

class DaySessionController extends ChangeNotifier {
  final GetCurrentDaySessionUseCase getCurrentDaySessionUseCase;
  final AddCompletedMissionUseCase addCompletedMissionUseCase;
  final RemoveCompletedMissionUseCase removeCompletedMissionUseCase;
  final EndDayUseCase endDayUseCase;

  DaySessionController({
    required this.getCurrentDaySessionUseCase,
    required this.addCompletedMissionUseCase,
    required this.removeCompletedMissionUseCase,
    required this.endDayUseCase,
  });

  DaySession? _currentSession;
  bool _isLoading = false;
  bool _isEndingDay = false;
  EndDayResult? _lastEndDayResult;

  DaySession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  bool get isEndingDay => _isEndingDay;
  EndDayResult? get lastEndDayResult => _lastEndDayResult;

  // Obtener cuántas misiones están completadas
  int get completedMissionsCount => _currentSession?.completedMissions.length ?? 0;

  // Verificar si una misión está en la sesión actual
  bool isMissionInSession(String missionId) {
    return _currentSession?.completedMissions.any((m) => m.id == missionId) ?? false;
  }

  // Cargar la sesión del día actual
  Future<void> loadCurrentSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentSession = await getCurrentDaySessionUseCase();
      print('Sesión del día cargada: $_currentSession');
    } catch (e) {
      print('Error al cargar sesión: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar una misión completada a la sesión
  Future<void> addCompletedMission(Mission mission) async {
    try {
      await addCompletedMissionUseCase(mission);
      // Recargar sesión para reflejar cambios
      _currentSession = _currentSession?.addCompletedMission(mission);
      notifyListeners();
      print('Misión ${mission.title} agregada a la sesión');
    } catch (e) {
      print('Error al agregar misión a sesión: $e');
    }
  }

  // Remover una misión de la sesión (si se desmarca)
  Future<void> removeCompletedMission(String missionId) async {
    try {
      await removeCompletedMissionUseCase(missionId);
      // Recargar sesión para reflejar cambios
      _currentSession = _currentSession?.removeCompletedMission(missionId);
      notifyListeners();
      print('Misión $missionId removida de la sesión');
    } catch (e) {
      print('Error al remover misión de sesión: $e');
    }
  }

  // Finalizar el día y actualizar stats
  Future<EndDayResult?> endDay() async {
    if (_currentSession == null || _currentSession!.isFinalized) {
      print('No se puede finalizar: sesión no disponible o ya finalizada');
      return null;
    }

    _isEndingDay = true;
    notifyListeners();

    try {
      final result = await endDayUseCase();
      _lastEndDayResult = result;
      _currentSession = _currentSession?.finalize();
      
      print('Día finalizado: $result');
      return result;
    } catch (e) {
      print('Error al finalizar día: $e');
      return null;
    } finally {
      _isEndingDay = false;
      notifyListeners();
    }
  }

  // Limpiar el resultado del último día (útil para resetear la UI)
  void clearLastResult() {
    _lastEndDayResult = null;
    notifyListeners();
  }
}
