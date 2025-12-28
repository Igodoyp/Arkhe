import 'package:flutter/material.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/mission_repository.dart';
import 'day_session_controller.dart';

// ============================================================================
// CONTROLADOR DE MISIONES
// ============================================================================
// Este controller gestiona el ESTADO y las ACCIONES relacionadas con
// la lista de misiones diarias.
//
// Responsabilidades:
// - Cargar la lista de misiones del día
// - Gestionar el estado de cada misión (completada/pendiente)
// - Coordinar con DaySessionController para actualizar la sesión
//
// IMPORTANTE: Este controller NO actualiza las stats del usuario directamente.
// Solo marca las misiones y las agrega a la sesión del día.
class MissionController extends ChangeNotifier {
  // ========== Estado (Variables que la UI observa) ==========
  List<Mission> missions = [];  // La lista de misiones del día
  bool isLoading = false;       // true mientras carga las misiones

  // ========== Dependencias ==========
  final MissionRepository repository;               // Para obtener/actualizar misiones
  final DaySessionController? daySessionController; // Para actualizar la sesión del día

  MissionController({
    required this.repository,
    this.daySessionController,
  });

  // ========== ACCIÓN 1: Cargar Misiones del Día ==========
  // Se llama al iniciar la app (en initState de MissionsPage).
  // Obtiene la lista de misiones diarias del repositorio.
  Future<void> loadMissions() async {
    // Paso 1: Marcar como "cargando" y notificar a la UI
    // La UI mostrará un CircularProgressIndicator
    isLoading = true;
    notifyListeners(); 

    try {
      // Paso 2: Obtener misiones del repositorio
      // El repositorio puede obtenerlas de:
      // - API (Gemini en el futuro)
      // - Base de datos local (SQLite/Hive)
      // - Datasource dummy (actual)
      missions = await repository.getDailyMissions();
      
    } catch (e) {
      print("Error al cargar misiones: $e");
      // TODO: Manejar con Either<Failure, List<Mission>>
      // y mostrar mensaje de error al usuario
      
    } finally {
      // Paso 3: Marcar como "no cargando" sin importar si hubo éxito o error
      // La UI ocultará el loading y mostrará la lista (o vacío si falló)
      isLoading = false;
      notifyListeners();
    }
  }

  // ========== ACCIÓN 2: Toggle Misión (Marcar/Desmarcar) ==========
  // Se llama cuando el usuario toca una misión en la lista.
  // 
  // FLUJO CORREGIDO (versión robusta):
  // 1. Intenta actualizar la sesión del día PRIMERO
  // 2. Si tiene éxito, persiste en el repositorio
  // 3. Solo entonces actualiza la UI
  // 
  // ¿Por qué en ese orden? Para evitar estados inconsistentes:
  // - Si falla al agregar a la sesión → UI no se actualiza
  // - Si la UI se actualizara primero → podría mostrar completada pero no estar en la sesión
  Future<void> toggleMission(int index) async {
    final mission = missions[index];
    // Crear nueva instancia con estado invertido (inmutable)
    final updatedMission = mission.copyWith(isCompleted: !mission.isCompleted);
    
    try {
      // PASO 1: Actualizar la sesión del día PRIMERO (puede fallar)
      // Solo si hay un DaySessionController inyectado
      if (daySessionController != null) {
        if (updatedMission.isCompleted) {
          // Agregar a la lista de completadas del día
          await daySessionController!.addCompletedMission(updatedMission);
        } else {
          // Remover de la lista (usuario se arrepintió)
          await daySessionController!.removeCompletedMission(updatedMission.id);
        }
      }
      
      // PASO 2: Si todo salió bien con la sesión, persistir en el repositorio
      // Esto guarda el estado de isCompleted para que persista en reinicios
      await repository.updateMission(updatedMission);
      
      // PASO 3: Solo AHORA actualizar la UI (después de confirmar persistencia)
      // Si llegamos aquí, significa que todo salió bien
      missions[index] = updatedMission;
      notifyListeners(); // Avisa a la UI: "Re-renderízate con el nuevo estado"
      
    } catch (e) {
      print("Error al toggle misión: $e");
      // Si algo falló, la UI NO se actualiza
      // El usuario verá que la misión sigue en su estado anterior
      // TODO: Mostrar SnackBar "Error al marcar misión"
    }
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
