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
  // Sistema de 6 stats: Strength, Intelligence, Charisma, Vitality, Dexterity, Wisdom
  final Map<StatType, double> _userStats = {
    StatType.strength: 32.0,
    StatType.intelligence: 50.0,
    StatType.charisma: 25.0,
    StatType.vitality: 40.0,
    StatType.dexterity: 35.0,
    StatType.wisdom: 28.0,
  };

  @override
  Future<Map<String, dynamic>> fetchUserStatsFromServer() async {
    // Simula un delay de red
    await Future.delayed(const Duration(milliseconds: 600));

    // Retorna las stats como JSON
    return {
      'strength': _userStats[StatType.strength],
      'intelligence': _userStats[StatType.intelligence],
      'charisma': _userStats[StatType.charisma],
      'vitality': _userStats[StatType.vitality],
      'dexterity': _userStats[StatType.dexterity],
      'wisdom': _userStats[StatType.wisdom],
    };
  }

  @override
  Future<void> updateUserStats(Map<String, dynamic> statsJson) async {
    print('DummyDataSource recibió actualización de stats: $statsJson');
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Actualiza las stats en memoria (simulando persistencia)
    _userStats[StatType.strength] = statsJson['strength'] ?? _userStats[StatType.strength];
    _userStats[StatType.intelligence] = statsJson['intelligence'] ?? _userStats[StatType.intelligence];
    _userStats[StatType.charisma] = statsJson['charisma'] ?? _userStats[StatType.charisma];
    _userStats[StatType.vitality] = statsJson['vitality'] ?? _userStats[StatType.vitality];
    _userStats[StatType.dexterity] = statsJson['dexterity'] ?? _userStats[StatType.dexterity];
    _userStats[StatType.wisdom] = statsJson['wisdom'] ?? _userStats[StatType.wisdom];
    
    print('Stats actualizadas: $_userStats');
  }
}

// Nota: En el futuro, crearás 'StatsApiDataSourceImpl' que llame a la API real.
