// data/datasources/stats_datasource.dart
import '../../domain/entities/stat_type.dart';

//TODO: implementar data base real

// 1. La Interfaz del DataSource
abstract class StatsRemoteDataSource {
  Future<Map<String, dynamic>> fetchUserStatsFromServer();
  Future<void> updateUserStats(Map<String, dynamic> statsJson);
}

// 2. La Implementación "Dummy"
class StatsDummyDataSourceImpl implements StatsRemoteDataSource {
  // Simulación de stats del usuario guardadas en memoria
  Map<StatType, double> _userStats = {
    StatType.strength: 32.0,
    StatType.intelligence: 50.0,
    StatType.creativity: 25.0,
    StatType.discipline: 30.0,
  };

  @override
  Future<Map<String, dynamic>> fetchUserStatsFromServer() async {
    // Simula un delay de red
    await Future.delayed(const Duration(milliseconds: 600));

    // Retorna las stats como JSON
    return {
      'strength': _userStats[StatType.strength],
      'intelligence': _userStats[StatType.intelligence],
      'creativity': _userStats[StatType.creativity],
      'discipline': _userStats[StatType.discipline],
    };
  }

  @override
  Future<void> updateUserStats(Map<String, dynamic> statsJson) async {
    print('DummyDataSource recibió actualización de stats: $statsJson');
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Actualiza las stats en memoria (simulando persistencia)
    _userStats[StatType.strength] = statsJson['strength'] ?? _userStats[StatType.strength];
    _userStats[StatType.intelligence] = statsJson['intelligence'] ?? _userStats[StatType.intelligence];
    _userStats[StatType.creativity] = statsJson['creativity'] ?? _userStats[StatType.creativity];
    _userStats[StatType.discipline] = statsJson['discipline'] ?? _userStats[StatType.discipline];
    
    print('Stats actualizadas: $_userStats');
  }
}

// Nota: En el futuro, crearás 'StatsApiDataSourceImpl' que llame a la API real.
