// data/datasources/day_session_datasource.dart

// 1. La Interfaz del DataSource
abstract class DaySessionDataSource {
  Future<Map<String, dynamic>?> getCurrentDaySession();
  Future<void> saveDaySession(Map<String, dynamic> sessionJson);
  Future<void> finalizeDaySession(String sessionId);
  Future<void> clearCurrentSession();
}

// 2. La Implementación "Dummy" (simula almacenamiento en memoria)
class DaySessionDummyDataSourceImpl implements DaySessionDataSource {
  // Simula almacenamiento local (en memoria por ahora)
  Map<String, dynamic>? _currentSession;

  @override
  Future<Map<String, dynamic>?> getCurrentDaySession() async {
    // Simula delay de lectura
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Si no hay sesión, crear una nueva para hoy
    if (_currentSession == null) {
      final now = DateTime.now();
      _currentSession = {
        'id': 'session_${now.year}_${now.month}_${now.day}',
        'date': now.toIso8601String(),
        'completedMissions': [],
        'isFinalized': false,
      };
    }
    
    print('DaySessionDataSource: Sesión actual cargada: $_currentSession');
    return _currentSession;
  }

  @override
  Future<void> saveDaySession(Map<String, dynamic> sessionJson) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentSession = sessionJson;
    print('DaySessionDataSource: Sesión guardada: $sessionJson');
  }

  @override
  Future<void> finalizeDaySession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentSession != null && _currentSession!['id'] == sessionId) {
      _currentSession!['isFinalized'] = true;
      print('DaySessionDataSource: Día finalizado: $sessionId');
    }
  }

  @override
  Future<void> clearCurrentSession() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentSession = null;
    print('DaySessionDataSource: Sesión limpiada (nuevo día)');
  }
}

// Nota: En el futuro, crearás 'DaySessionLocalDataSourceImpl' 
// que use SQLite/Hive/SharedPreferences para persistencia real.
