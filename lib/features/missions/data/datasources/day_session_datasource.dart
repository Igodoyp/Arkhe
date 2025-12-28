// data/datasources/day_session_datasource.dart

// ============================================================================
// 1. INTERFAZ DEL DATASOURCE (Contrato/Abstracción)
// ============================================================================
// Define QUÉ operaciones se pueden hacer con las sesiones del día,
// pero NO cómo se implementan. Esto permite cambiar la implementación
// (de memoria a SQLite, por ejemplo) sin tocar el resto del código.
abstract class DaySessionDataSource {
  /// Obtiene la sesión del día actual.
  /// Retorna null si no existe ninguna sesión guardada.
  Future<Map<String, dynamic>?> getCurrentDaySession();
  
  /// Guarda o actualiza una sesión del día.
  /// @param sessionJson: Los datos de la sesión en formato JSON
  Future<void> saveDaySession(Map<String, dynamic> sessionJson);
  
  /// Marca una sesión como finalizada (ya no se pueden agregar más misiones).
  /// @param sessionId: El ID de la sesión a finalizar
  Future<void> finalizeDaySession(String sessionId);
  
  /// Limpia la sesión actual. Útil para resetear al siguiente día.
  Future<void> clearCurrentSession();
}

// ============================================================================
// 2. IMPLEMENTACIÓN "DUMMY" (Almacenamiento en Memoria)
// ============================================================================
// Esta implementación guarda la sesión en memoria (solo mientras la app está abierta).
// Es perfecta para desarrollo/testing, pero se pierde al cerrar la app.
// En producción, reemplazarás esto con SQLite/Hive/SharedPreferences.
class DaySessionDummyDataSourceImpl implements DaySessionDataSource {
  // Variable privada que guarda la sesión actual en memoria.
  // Es null cuando no hay sesión o cuando la app se reinicia.
  Map<String, dynamic>? _currentSession;

  @override
  Future<Map<String, dynamic>?> getCurrentDaySession() async {
    // Simula el delay de leer desde una base de datos o red.
    // En una implementación real con SQLite, aquí harías:
    // await database.query('sessions', where: 'date = ?', whereArgs: [today])
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Si no existe una sesión en memoria O la sesión actual está finalizada,
    // crear una nueva para HOY.
    // Esto ocurre cuando:
    // 1. La app se abre por primera vez
    // 2. Se llamó a clearCurrentSession() (nuevo día)
    // 3. La app se reinició (memoria se limpió)
    // 4. La sesión anterior ya fue finalizada (después de Bonfire)
    final isFinalized = _currentSession?['isFinalized'] as bool? ?? false;
    
    if (_currentSession == null || isFinalized) {
      final now = DateTime.now();
      
      // Crear una sesión nueva con estructura predefinida
      _currentSession = {
        // ID único basado en la fecha Y timestamp para permitir múltiples sesiones por día (testing)
        'id': 'session_${now.year}_${now.month}_${now.day}_${now.millisecondsSinceEpoch}',
        
        // Fecha de la sesión en formato ISO8601 (ej: "2025-12-28T14:30:00.000")
        'date': now.toIso8601String(),
        
        // Lista vacía de misiones completadas (se llenan durante el día)
        'completedMissions': [],
        
        // Bandera que indica si el día ya fue finalizado
        // false = aún puedes marcar misiones
        // true = día cerrado, stats ya aplicadas
        'isFinalized': false,
      };
      
      print('[DaySessionDataSource] 🆕 Nueva sesión creada: ${_currentSession!['id']}');
    } else {
      print('[DaySessionDataSource] 📖 Sesión existente cargada: ${_currentSession!['id']}');
    }
    
    return _currentSession;
  }

  @override
  Future<void> saveDaySession(Map<String, dynamic> sessionJson) async {
    // Simula el delay de escribir en base de datos.
    // En una implementación real con SQLite:
    // await database.update('sessions', sessionJson, where: 'id = ?')
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Actualiza la sesión en memoria.
    // Esto se llama cada vez que:
    // - Se marca/desmarca una misión (actualiza completedMissions)
    // - Se finaliza el día (actualiza isFinalized)
    _currentSession = sessionJson;
    
    print('DaySessionDataSource: Sesión guardada: $sessionJson');
  }

  @override
  Future<void> finalizeDaySession(String sessionId) async {
    // Simula delay de actualización en base de datos.
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Verifica que:
    // 1. Exista una sesión en memoria (_currentSession != null)
    // 2. El ID coincida con el que queremos finalizar
    // Esto previene finalizar la sesión equivocada por error.
    if (_currentSession != null && _currentSession!['id'] == sessionId) {
      // Marca la sesión como finalizada.
      // Una vez true, no se pueden agregar más misiones completadas.
      // El botón "Finalizar Día" se deshabilita cuando esto es true.
      _currentSession!['isFinalized'] = true;
      
      print('DaySessionDataSource: Día finalizado: $sessionId');
    }
  }

  @override
  Future<void> clearCurrentSession() async {
    // Simula delay de operación de limpieza.
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Limpia la sesión en memoria (la pone en null).
    // Esto se usaría cuando:
    // - Comienza un nuevo día (día siguiente)
    // - El usuario hace logout
    // - Se quiere resetear manualmente para testing
    // 
    // Al volver a llamar getCurrentDaySession(), se creará una nueva sesión.
    _currentSession = null;
    
    print('DaySessionDataSource: Sesión limpiada (nuevo día)');
  }
}

// ============================================================================
// NOTAS PARA MIGRACIÓN A BASE DE DATOS REAL
// ============================================================================
// Cuando estés listo para implementar persistencia real, crearás una clase:
//
// class DaySessionLocalDataSourceImpl implements DaySessionDataSource {
//   final Database database; // SQLite
//   // o
//   final Box box; // Hive
//   // o
//   final SharedPreferences prefs;
//
//   @override
//   Future<Map<String, dynamic>?> getCurrentDaySession() async {
//     // Opción 1 - SQLite:
//     final results = await database.query(
//       'day_sessions',
//       where: 'date = ? AND isFinalized = ?',
//       whereArgs: [DateFormat('yyyy-MM-dd').format(DateTime.now()), 0],
//     );
//     return results.isNotEmpty ? results.first : null;
//
//     // Opción 2 - Hive:
//     final session = box.get('current_day_session');
//     return session?.toJson();
//
//     // Opción 3 - SharedPreferences:
//     final jsonString = prefs.getString('day_session');
//     return jsonString != null ? json.decode(jsonString) : null;
//   }
//
//   @override
//   Future<void> saveDaySession(Map<String, dynamic> sessionJson) async {
//     // SQLite: await database.insert('day_sessions', sessionJson, 
//     //           conflictAlgorithm: ConflictAlgorithm.replace);
//     // Hive: await box.put('current_day_session', DaySessionModel.fromJson(sessionJson));
//     // SharedPreferences: await prefs.setString('day_session', json.encode(sessionJson));
//   }
// }
//
// Y luego cambias la inyección de dependencias en mission_page.dart:
// final daySessionDataSource = DaySessionLocalDataSourceImpl(database: db);
// ↑ Solo cambias esta línea, el resto del código sigue igual! (Clean Architecture FTW!)

