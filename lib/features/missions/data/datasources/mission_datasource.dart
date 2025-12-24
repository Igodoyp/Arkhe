// data/datasources/mission_datasource.dart

//TODO: conectar con api real

// 1. La Interfaz del DataSource
abstract class MissionRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchMissionsFromGemini();
}

// 2. La Implementación "Dummy" (Aquí vive el hardcode)
class MissionGeminiDummyDataSourceImpl implements MissionRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> fetchMissionsFromGemini() async {
    // Simula un delay de red para realismo
    await Future.delayed(const Duration(milliseconds: 800));

    // ESTA es la respuesta simulada de Gemini 
    return [
      {
        "id": "1",
        "title": "Protocolo Pomodoro",
        "description": "Completa 4 ciclos de estudio de 25 minutos sin interrupciones.",
        "xpReward": 150,
        "isCompleted": false,
        "type": "intelligence"
      },
      {
        "id": "2",
        "title": "Hidratación Táctica",
        "description": "Bebe 2 litros de agua antes de las 18:00.",
        "xpReward": 50,
        "isCompleted": false,
        "type": "strength"
      },
      {
        "id": "3",
        "title": "Lectura Analítica",
        "description": "Lee 10 páginas de un libro de no-ficción y resume la idea principal.",
        "xpReward": 100,
        "isCompleted": true,
        "type": "discipline"
      }
    ];
  }
  Future<void> updateMissionDummy(Map<String, dynamic> missionJson) async {
    print('DummyDataSource recibió actualización: $missionJson');
    await Future.delayed(const Duration(milliseconds: 200));
  }
}


// Nota: En el futuro, crearás 'MissionGeminiApiDataSourceImpl' que llame a la API real.