import 'package:flutter/material.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/usecases/get_missions_usecase.dart';
import '../../domain/usecases/toggle_mission_usecase.dart';

class MissionProvider extends ChangeNotifier {
  // --- MAQUINARIA INTERNA (UseCases) ---
  final GetMissionsUseCase getMissionsUseCase;
  final ToggleMissionUseCase toggleMissionUseCase;

  // --- INVENTARIO (Estado) ---
  List<Mission> _missions = [];
  bool _isLoading = false;

  // --- EXPOSICIÓN DE DATOS (Salidas para la UI) ---
  List<Mission> get missions => _missions;
  bool get isLoading => _isLoading;

  // KPI EN TIEMPO REAL: CALCULO DE XP TOTAL
  // Esto es una "Computed Property". Recorre el inventario y suma.
  int get totalXp {
    return _missions
        .where((m) => m.isCompleted) // 1. Filtra las completadas
        .fold(0, (sum, mission) => sum + mission.xpReward); // 2. Suma sus recompensas
  }

  // --- CONSTRUCTOR (Inyección) ---
  MissionProvider({
    required this.getMissionsUseCase,
    required this.toggleMissionUseCase,
  });

  // --- OPERACIONES (Botones del tablero) ---

  // 1. Cargar Misiones (Inicialización)
  Future<void> loadMissions() async {
    _isLoading = true;
    notifyListeners(); // Enciende luz de "Cargando..."

    try {
      _missions = await getMissionsUseCase.call();
    } catch (e) {
      print("Error en la línea de producción: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Apaga luz de carga y actualiza lista
    }
  }

  // 2. Completar/Descompletar Misión
  Future<void> toggleMission(Mission mission) async {
    // A. Ejecutamos la orden de cambio
    await toggleMissionUseCase.call(mission);
    
    // B. Recargamos el inventario para reflejar el cambio
    // (En sistemas más complejos, actualizaríamos solo el item localmente para más velocidad)
    await loadMissions(); 
    
    // Al hacer loadMissions, se dispara notifyListeners(),
    // lo que hace que la UI se redibuje y el totalXP se recalcule solo.
  }
}