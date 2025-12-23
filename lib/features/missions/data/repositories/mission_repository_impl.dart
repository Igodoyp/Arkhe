// data/repositories/mission_repository_impl.dart
import '../../domain/repositories/mission_repository.dart';
import '../../domain/entities/mission_entity.dart';
import '../datasources/mission_datasource.dart';
import '../models/mission_model.dart';

class MissionRepositoryImpl implements MissionRepository {
  final MissionRemoteDataSource remoteDataSource;

  MissionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Mission>> getDailyMissions() async {
    try {
      // 1. Obtenemos los datos crudos (Map/JSON) del datasource
      final rawData = await remoteDataSource.fetchMissionsFromGemini();

      // 2. Mapeamos de JSON a Modelos (que son subtipos de Entidades)
      final missions = rawData.map((json) => MissionModel.fromJson(json)).toList();

      return missions;
    } catch (e) {
      // Aquí manejarías errores (ej: convertir excepciones de Dio a Failures de dominio)
      throw Exception('Error al obtener misiones de Gemini: $e');
    }
  }

  @override
  Future<void> updateMission(Mission mission) async {
    if (remoteDataSource is MissionGeminiDummyDataSourceImpl) {
      await (remoteDataSource as MissionGeminiDummyDataSourceImpl)
          .updateMissionDummy(_missionToJson(mission));
    }
    // ...puedes agregar logs o lógica adicional...
  }

  Map<String, dynamic> _missionToJson(Mission mission) => {
    'id': mission.id,
    'title': mission.title,
    'description': mission.description,
    'xpReward': mission.xpReward,
    'isCompleted': mission.isCompleted,
    'type': mission.type.name,
  };
}