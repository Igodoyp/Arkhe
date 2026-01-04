// domain/usecases/save_generated_missions_usecase.dart

import '../entities/mission_entity.dart';
import '../../data/repositories/mission_repository_impl.dart';
import '../../../../core/time/date_time_extensions.dart';

/// Use Case para guardar misiones generadas en Drift
/// 
/// RESPONSABILIDADES:
/// - Persistir misiones generadas por Gemini en base de datos local
/// - Asegurar que las fechas estén stripped antes de guardar
/// - Eliminar misiones antiguas si se regeneran para una fecha
class SaveGeneratedMissionsUseCase {
  final MissionRepositoryImpl missionRepository;

  SaveGeneratedMissionsUseCase({required this.missionRepository});

  /// Guarda misiones generadas para una fecha específica
  /// 
  /// @param missions: Lista de misiones generadas
  /// @param targetDate: Fecha para la cual fueron generadas (será stripped internamente)
  /// @param sessionId: ID de la sesión del día (opcional)
  /// @param replaceExisting: Si true, elimina misiones existentes antes de guardar (default: true)
  Future<void> call(
    List<Mission> missions,
    DateTime targetDate, {
    String? sessionId,
    bool replaceExisting = true,
  }) async {
    final dateStripped = targetDate.stripped;
    
    print('[SaveGeneratedMissions] 💾 Guardando ${missions.length} misiones para: $dateStripped');
    
    // Opcionalmente eliminar misiones existentes para esta fecha
    if (replaceExisting) {
      print('[SaveGeneratedMissions] 🗑️ Eliminando misiones antiguas...');
      await missionRepository.deleteMissionsForDate(dateStripped);
    }
    
    // Guardar nuevas misiones
    await missionRepository.saveMissionsForDate(missions, dateStripped);
    
    print('[SaveGeneratedMissions] ✅ Misiones guardadas exitosamente');
  }
}
