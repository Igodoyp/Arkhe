// presentation/controllers/day_session_controller.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/day_session_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/usecases/day_session_usecase.dart';

// ============================================================================
// CONTROLADOR DE SESIÓN DEL DÍA
// ============================================================================
// Este controller gestiona el ESTADO y las ACCIONES relacionadas con
// la sesión del día actual. Es el intermediario entre la UI y los Use Cases.
//
// Responsabilidades:
// - Mantener el estado de la sesión actual en memoria
// - Proveer getters para que la UI pueda leer el estado
// - Ejecutar acciones (agregar misión, finalizar día) vía Use Cases
// - Notificar a la UI cuando el estado cambia (via ChangeNotifier)
class DaySessionController extends ChangeNotifier {
  // ========== Dependencias (inyectadas por constructor) ==========
  // Los Use Cases encapsulan la lógica de negocio.
  // El controller solo orquesta CUÁNDO ejecutarlos y gestiona el estado.
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

  // ========== Estado Privado (solo este controller puede modificar) ==========
  DaySession? _currentSession;     // La sesión del día actual (null si no se ha cargado)
  bool _isLoading = false;         // true cuando está cargando la sesión inicial
  bool _isEndingDay = false;       // true mientras ejecuta endDay() (para mostrar loading)
  EndDayResult? _lastEndDayResult; // Resultado del último día finalizado (para mostrar resumen)

  // ========== Getters Públicos (la UI lee estos valores) ==========
  DaySession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  bool get isEndingDay => _isEndingDay;
  EndDayResult? get lastEndDayResult => _lastEndDayResult;

  // Getter de conveniencia: cuenta cuántas misiones están completadas
  // Útil para mostrar "3 / 5 misiones completadas" en la UI
  int get completedMissionsCount => _currentSession?.completedMissions.length ?? 0;

  // Verifica si una misión específica ya está en la sesión
  // Útil para sincronizar el estado de checkboxes en la UI
  bool isMissionInSession(String missionId) {
    return _currentSession?.completedMissions.any((m) => m.id == missionId) ?? false;
  }

  // ========== ACCIÓN 1: Cargar Sesión del Día ==========
  // Se llama al iniciar la app (en initState de MissionsPage).
  // Obtiene la sesión actual o crea una nueva si no existe.
  Future<void> loadCurrentSession() async {
    _isLoading = true;
    notifyListeners(); // Avisa a la UI: "Muestra un loading spinner"

    try {
      // Delega la lógica al Use Case (capa de dominio)
      _currentSession = await getCurrentDaySessionUseCase();
      print('Sesión del día cargada: $_currentSession');
    } catch (e) {
      print('Error al cargar sesión: $e');
      // TODO: Manejar error con Either<Failure, DaySession>
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisa a la UI: "Ya terminé, esconde el loading"
    }
  }

  // ========== ACCIÓN 2: Agregar Misión Completada ==========
  // Se llama cuando el usuario marca una misión como completada.
  // IMPORTANTE: Solo actualiza la SESIÓN, NO las stats del usuario.
  // Las stats se actualizan al finalizar el día.
  Future<void> addCompletedMission(Mission mission) async {
    try {
      // 1. Persiste en el repositorio (vía Use Case)
      await addCompletedMissionUseCase(mission);
      
      // 2. Actualiza el estado local (inmutable, crea nueva instancia)
      _currentSession = _currentSession?.addCompletedMission(mission);
      
      // 3. Notifica a la UI para que se re-renderice
      notifyListeners();
      
      print('Misión ${mission.title} agregada a la sesión');
    } catch (e) {
      print('Error al agregar misión a sesión: $e');
      // TODO: Manejar error y mostrar mensaje al usuario
    }
  }

  // ========== ACCIÓN 3: Remover Misión Completada ==========
  // Se llama cuando el usuario DESMARCA una misión.
  // Útil si el usuario se equivocó o cambió de opinión antes de finalizar el día.
  Future<void> removeCompletedMission(String missionId) async {
    try {
      // 1. Remueve de la persistencia (vía Use Case)
      await removeCompletedMissionUseCase(missionId);
      
      // 2. Actualiza el estado local (inmutable)
      _currentSession = _currentSession?.removeCompletedMission(missionId);
      
      // 3. Notifica a la UI
      notifyListeners();
      
      print('Misión $missionId removida de la sesión');
    } catch (e) {
      print('Error al remover misión de sesión: $e');
    }
  }

  // ========== ACCIÓN 4: Finalizar el Día (LA MÁS IMPORTANTE) ==========
  // Se llama cuando el usuario presiona el botón "FINALIZAR DÍA".
  // Este es el momento crítico donde:
  // 1. Se calculan las stats ganadas basadas en las misiones completadas (puede ser 0)
  // 2. Se APLICAN esas stats al perfil del usuario
  // 3. Se marca la sesión como finalizada (no se pueden agregar más misiones)
  // 4. Se retorna un resultado para mostrar en el Bonfire
  // 
  // NOTA: Se permite finalizar el día sin misiones completadas.
  // Esto es útil para registrar días difíciles donde no se completó nada.
  Future<EndDayResult?> endDay() async {
    // Validaciones previas
    if (_currentSession == null || _currentSession!.isClosed) {
      print('[DaySessionController] ❌ No se puede finalizar: sesión no disponible o ya finalizada');
      return null; // La UI mostrará un SnackBar de error
    }

    // Marca que está en proceso (para mostrar loading en el botón)
    _isEndingDay = true;
    notifyListeners();

    print('[DaySessionController] 📊 Finalizando día con ${_currentSession!.completedMissions.length} misiones completadas...');

    try {
      // Ejecuta el Use Case que hace la MAGIA:
      // - Lee las misiones completadas de la sesión (puede ser lista vacía)
      // - Calcula stats ganadas (xpReward / 10 por cada misión, 0 si no hay misiones)
      // - Obtiene las stats actuales del usuario
      // - Aplica los incrementos
      // - Guarda las stats actualizadas
      // - Finaliza la sesión
      final result = await endDayUseCase();
      
      // Guarda el resultado para mostrarlo en el diálogo
      _lastEndDayResult = result;
      
      // Marca la sesión como finalizada (inmutable, crea nueva instancia)
      _currentSession = _currentSession?.finalize();
      
      print('Día finalizado: $result');
      return result; // La UI usará esto para el diálogo de resumen
    } catch (e) {
      print('Error al finalizar día: $e');
      // TODO: Manejar con Either y mostrar error específico
      return null;
    } finally {
      // Quita el loading sin importar si hubo éxito o error
      _isEndingDay = false;
      notifyListeners();
    }
  }

  // ========== ACCIÓN 5: Limpiar Resultado Anterior ==========
  // Limpia el resultado del último día finalizado.
  // Útil para resetear el estado después de mostrar el diálogo de resumen,
  // o cuando se inicia un nuevo día.
  void clearLastResult() {
    _lastEndDayResult = null;
    notifyListeners();
  }

  // ========== ACCIÓN 6: Preparar Datos para Bonfire ==========
  // Retorna los datos necesarios para navegar a la pantalla de Bonfire.
  // Se llama después de endDay() para obtener la información del resumen.
  BonfireData? getBonfireData() {
    if (_lastEndDayResult == null || _currentSession == null) {
      print('[DaySessionController] No hay datos disponibles para Bonfire');
      return null;
    }

    // Calcular el total de stats ganadas (suma de todos los valores del mapa)
    final totalStatsGained = _lastEndDayResult!.statsGained.values
        .fold<double>(0.0, (sum, value) => sum + value)
        .round();

    return BonfireData(
      sessionId: _currentSession!.id,
      completedMissions: _currentSession!.completedMissions,
      totalStatsGained: totalStatsGained,
    );
  }
}

// ============================================================================
// CLASE AUXILIAR: BONFIRE DATA
// ============================================================================
/// Encapsula los datos necesarios para la pantalla de Bonfire
class BonfireData {
  final String sessionId;
  final List<Mission> completedMissions;
  final int totalStatsGained;

  BonfireData({
    required this.sessionId,
    required this.completedMissions,
    required this.totalStatsGained,
  });
}

// ============================================================================
// FLUJO COMPLETO DE USO
// ============================================================================
//
// 1. INICIALIZACIÓN (App se abre):
//    MissionsPage.initState()
//      → daySessionController.loadCurrentSession()
//      → Carga o crea sesión del día
//
// 2. DURANTE EL DÍA (Usuario marca misiones):
//    Usuario toca misión
//      → missionController.toggleMission()
//      → daySessionController.addCompletedMission()
//      → Solo actualiza la SESIÓN, stats sin tocar
//
// 3. FINALIZAR DÍA (Usuario presiona botón):
//    Usuario presiona "FINALIZAR DÍA"
//      → _showEndDaySummary()
//      → daySessionController.endDay()
//      → EndDayUseCase:
//           - Calcula stats ganadas
//           - Actualiza UserStats (AQUÍ se aplican las stats)
//           - Finaliza sesión
//      → Muestra diálogo con resultado
//
// 4. PRÓXIMO DÍA (Opcional, cuando implementes lógica de días):
//    App detecta que es un nuevo día
//      → daySessionController.clearCurrentSession()
//      → daySessionController.loadCurrentSession()
//      → Crea nueva sesión vacía para HOY
//
