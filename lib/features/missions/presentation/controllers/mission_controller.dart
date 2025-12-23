import 'package:flutter/material.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/mission_repository.dart';

class MissionController extends ChangeNotifier {
  // 1. EL ESTADO (Las variables que la UI mira)
  List<Mission> missions = []; // La lista de datos
  bool isLoading = false;      // ¿Estamos esperando?

  final MissionRepository repository; // Conexión con la cocina

  MissionController({required this.repository});

  // 2. LA LÓGICA (Lo que hace cuando pasa algo)
  Future<void> loadMissions() async {
    // AVISA a la UI: "Ponte a cargar" (círculo girando)
    isLoading = true;
    notifyListeners(); 

    try {
      // 3. HABLA CON EL REPO: "Traeme los datos"
      missions = await repository.getDailyMissions();
    } catch (e) {
      print("Error: $e");
    } finally {
      // AVISA a la UI: "Ya terminé, muestra la lista"
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleMission(int index) async {
    final mission = missions[index];
    final updatedMission = mission.copyWith(isCompleted: !mission.isCompleted);
    missions[index] = updatedMission;
    notifyListeners();
    await repository.updateMission(updatedMission);
  }
}