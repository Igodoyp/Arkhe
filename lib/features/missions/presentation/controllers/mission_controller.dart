import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/usecases/ensure_missions_for_date_usecase.dart';
import '../../domain/usecases/watch_missions_for_date_usecase.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../../../core/time/time_provider.dart';
import 'day_session_controller.dart';

// ============================================================================
// CONTROLADOR DE MISIONES (Refactorizado con UseCases + Streams)
// ============================================================================
// Este controller gestiona el ESTADO y las ACCIONES relacionadas con
// la lista de misiones diarias usando el patrón UseCase formal.
//
// ARQUITECTURA:
// - EnsureMissionsForDateUseCase: Garantiza que existan misiones (LAZY)
// - WatchMissionsForDateUseCase: Stream reactivo de cambios en Drift
// - MissionRepository: Para operaciones de actualización
// - TimeProvider: Para obtener fechas stripped (abstracción testeable)
//
// FLUJO REACTIVO:
// 1. loadMissions() garantiza que existan misiones (LAZY ensure)
// 2. Suscribe al stream de Drift que observa cambios en la tabla missions
// 3. Cuando hay cambios (insert/update/delete) → stream emite nueva lista
// 4. UI se actualiza automáticamente sin refresh manual
//
// ESTADOS:
// - isLoading: true hasta que el stream emite la primera vez
// - isGenerating: true cuando se está generando nuevas misiones
// - errorMessage: null si todo ok, String con error si falla
class MissionController extends ChangeNotifier {
  // ========== Estado (Variables que la UI observa) ==========
  List<Mission> missions = [];       // La lista de misiones del día
  bool isLoading = false;            // true hasta que el stream emite la primera vez
  bool isGenerating = false;         // true mientras genera nuevas misiones
  String? errorMessage;              // null si ok, String si hay error
  
  StreamSubscription<List<Mission>>? _missionsSubscription;

  // ========== Dependencias ==========
  final EnsureMissionsForDateUseCase ensureMissionsUseCase;
  final WatchMissionsForDateUseCase watchMissionsUseCase;
  final MissionRepository missionRepository;
  final TimeProvider timeProvider;
  final DaySessionController? daySessionController;

  MissionController({
    required this.ensureMissionsUseCase,
    required this.watchMissionsUseCase,
    required this.missionRepository,
    required this.timeProvider,
    this.daySessionController,
  });

  // ========== ACCIÓN 1: Cargar Misiones del Día (LAZY + Stream) ==========
  // Se llama al iniciar la app (en initState de MissionsPage).
  // 
  // FLUJO:
  // 1. Garantiza que existan misiones (LAZY ensure)
  // 2. Suscribe al stream de Drift para observar cambios
  // 3. El stream emite automáticamente cuando hay cambios en Drift
  Future<void> loadMissions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); 

    try {
      print('[MissionController] 📖 Garantizando misiones (LAZY)...');
      
      final today = timeProvider.todayStripped;
      
      // PASO 1: Garantizar que existan misiones (LAZY)
      // Si no existen → genera nuevas misiones
      // Si ya existen → no hace nada
      await ensureMissionsUseCase.call(today);
      
      // PASO 2: Suscribirse al stream reactivo de Drift
      // El stream emite cada vez que hay cambios en la tabla missions
      _missionsSubscription?.cancel(); // Cancelar suscripción previa si existe
      
      _missionsSubscription = watchMissionsUseCase.call(today).listen(
        (missionsList) {
          print('[MissionController] 🔄 Stream emitió: ${missionsList.length} misiones');
          missions = missionsList;
          isLoading = false;
          errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          print('[MissionController] ❌ Error en stream: $error');
          errorMessage = 'Error al cargar misiones: $error';
          isLoading = false;
          notifyListeners();
        },
      );
      
      print('[MissionController] ✅ Suscrito al stream de misiones');
      
    } catch (e) {
      print('[MissionController] ❌ Error al cargar misiones: $e');
      errorMessage = 'Error al cargar misiones: $e';
      missions = [];
      isLoading = false;
      notifyListeners();
    }
  }

  // ========== ACCIÓN 2: Regenerar Misiones (LAZY con force) ==========
  // Permite al usuario forzar la regeneración de misiones.
  // Útil si las misiones actuales no son adecuadas o para testing.
  Future<void> refreshMissions() async {
    isGenerating = true;
    notifyListeners();

    try {
      print('[MissionController] 🔄 Regenerando misiones...');
      
      // TODO: Implementar forceRegenerate en EnsureMissionsForDateUseCase
      // Por ahora, simplemente re-garantizamos
      final today = timeProvider.todayStripped;
      await ensureMissionsUseCase.call(today);
      
      print('[MissionController] ✅ Misiones regeneradas (stream las cargará)');
      
    } catch (e) {
      print('[MissionController] ❌ Error al regenerar misiones: $e');
      errorMessage = 'Error al regenerar misiones: $e';
      
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  // ========== ACCIÓN 3: Toggle Misión (Marcar/Desmarcar) - OPTIMISTIC UI ==========
  // Se llama cuando el usuario toca una misión en la lista.
  // 
  // FLUJO OPTIMISTIC UI:
  // 1. Actualiza la UI INMEDIATAMENTE (optimistic)
  // 2. Guarda en background (sesión + repositorio)
  // 3. Si falla → REVIERTE la UI + muestra error
  // 
  // Ventajas:
  // - La app se siente instantánea (0ms de latencia percibida)
  // - El usuario ve feedback inmediato
  // - Si falla, revertimos y mostramos error
  Future<void> toggleMission(int index) async {
    final mission = missions[index];
    final oldMission = mission; // Guardar estado anterior para revertir
    
    // PASO 1: OPTIMISTIC UI - Actualizar INMEDIATAMENTE
    final updatedMission = mission.copyWith(isCompleted: !mission.isCompleted);
    missions[index] = updatedMission;
    notifyListeners(); // ⚡ UI se actualiza INSTANTÁNEAMENTE
    
    try {
      // PASO 2: Guardar en background (sesión del día)
      if (daySessionController != null) {
        if (updatedMission.isCompleted) {
          await daySessionController!.addCompletedMission(updatedMission);
        } else {
          await daySessionController!.removeCompletedMission(updatedMission.id);
        }
      }
      
      // PASO 3: Persistir en repositorio
      await missionRepository.updateMission(updatedMission);
      
      print('[MissionController] ✅ Misión ${updatedMission.isCompleted ? "completada" : "desmarcada"}: ${updatedMission.title}');
      
    } catch (e) {
      print('[MissionController] ❌ Error al toggle misión, REVIRTIENDO: $e');
      
      // PASO 4: REVERTIR si falla (rollback optimistic)
      missions[index] = oldMission;
      notifyListeners(); // UI vuelve al estado anterior
      
      // TODO: Mostrar SnackBar con error
      errorMessage = 'Error al marcar misión: $e';
      
      // Limpiar error después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        errorMessage = null;
        notifyListeners();
      });
    }
  }
  
  // ========== CLEANUP: Cancelar Suscripción al Stream ==========
  @override
  void dispose() {
    _missionsSubscription?.cancel();
    super.dispose();
  }
}

// ============================================================================
// COORDINACIÓN CON DAY SESSION CONTROLLER
// ============================================================================
//
// Este controller trabaja en EQUIPO con DaySessionController:
//
// MissionController se encarga de:
//   - Mostrar la lista de misiones
//   - Gestionar el estado visual (completada/pendiente)
//   - Persistir el estado de cada misión
//
// DaySessionController se encarga de:
//   - Mantener la lista de CUÁLES misiones se completaron HOY
//   - Finalizar el día y aplicar las stats
//
// Ejemplo de flujo:
//   Usuario marca "Estudiar" ✅
//     → MissionController.toggleMission()
//     → daySessionController.addCompletedMission("Estudiar")
//     → DaySession.completedMissions = ["Estudiar"]
//     ⚠️ Las stats NO se tocan todavía
//
//   Usuario presiona "Finalizar Día"
//     → daySessionController.endDay()
//     → EndDayUseCase lee DaySession.completedMissions
//     → Calcula: "Estudiar" = +5 Intelligence
//     → Aplica a UserStats
//     ✅ AHORA sí se actualizan las stats
//
