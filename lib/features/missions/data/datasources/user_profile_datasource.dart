// data/datasources/user_profile_datasource.dart

// ============================================================================
// 1. INTERFAZ DEL DATASOURCE (Contrato/Abstracción)
// ============================================================================

/// DataSource para gestionar el perfil del usuario
abstract class UserProfileDataSource {
  /// Obtiene el perfil del usuario almacenado
  /// Retorna null si no existe ningún perfil guardado
  Future<Map<String, dynamic>?> getUserProfile();
  
  /// Guarda o actualiza el perfil del usuario
  Future<void> saveUserProfile(Map<String, dynamic> profileJson);
  
  /// Verifica si existe un perfil guardado
  Future<bool> hasProfile();
  
  /// Elimina el perfil del usuario
  Future<void> deleteUserProfile();
}

// ============================================================================
// 2. IMPLEMENTACIÓN "DUMMY" (Almacenamiento en Memoria)
// ============================================================================

/// Implementación en memoria para desarrollo y testing
/// 
/// En producción, esto será reemplazado por:
/// - SharedPreferences (perfil pequeño, simple)
/// - Drift/SQLite (si se necesita versionado/historial)
/// - Hive (alternativa ligera)
class UserProfileDummyDataSourceImpl implements UserProfileDataSource {
  // Variable privada que guarda el perfil en memoria
  Map<String, dynamic>? _profile;

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    // Simula delay de lectura
    await Future.delayed(const Duration(milliseconds: 200));
    
    print('[UserProfileDataSource] 📖 ${_profile != null ? "Perfil cargado" : "No hay perfil"}');
    return _profile;
  }

  @override
  Future<void> saveUserProfile(Map<String, dynamic> profileJson) async {
    // Simula delay de escritura
    await Future.delayed(const Duration(milliseconds: 150));
    
    _profile = profileJson;
    print('[UserProfileDataSource] 💾 Perfil guardado: ${profileJson['name']}');
  }

  @override
  Future<bool> hasProfile() async {
    // Simula delay de verificación
    await Future.delayed(const Duration(milliseconds: 50));
    
    return _profile != null;
  }

  @override
  Future<void> deleteUserProfile() async {
    // Simula delay de eliminación
    await Future.delayed(const Duration(milliseconds: 100));
    
    _profile = null;
    print('[UserProfileDataSource] 🗑️ Perfil eliminado');
  }
}

// ============================================================================
// NOTAS PARA MIGRACIÓN A PERSISTENCIA REAL
// ============================================================================
//
// Opción 1 - SharedPreferences (Recomendado para este caso):
// ============================================================================
// class UserProfileSharedPrefsDataSourceImpl implements UserProfileDataSource {
//   final SharedPreferences prefs;
//   static const String _key = 'user_profile';
//
//   UserProfileSharedPrefsDataSourceImpl({required this.prefs});
//
//   @override
//   Future<Map<String, dynamic>?> getUserProfile() async {
//     final jsonString = prefs.getString(_key);
//     if (jsonString == null) return null;
//     return json.decode(jsonString) as Map<String, dynamic>;
//   }
//
//   @override
//   Future<void> saveUserProfile(Map<String, dynamic> profileJson) async {
//     final jsonString = json.encode(profileJson);
//     await prefs.setString(_key, jsonString);
//   }
//
//   @override
//   Future<bool> hasProfile() async {
//     return prefs.containsKey(_key);
//   }
//
//   @override
//   Future<void> deleteUserProfile() async {
//     await prefs.remove(_key);
//   }
// }
//
// ============================================================================
// Opción 2 - Drift/SQLite (Si necesitas historial de versiones):
// ============================================================================
// Agregar a tables.dart:
//
// @DataClassName('UserProfileData')
// class UserProfiles extends Table {
//   TextColumn get id => text()();
//   TextColumn get name => text()();
//   TextColumn get idealSelfDescription => text()();
//   TextColumn get focusAreasJson => text()(); // JSON array
//   TextColumn get currentGoalsJson => text()(); // JSON array
//   TextColumn get additionalContext => text().nullable()();
//   DateTimeColumn get lastUpdated => dateTime()();
//   BoolColumn get isActive => boolean().withDefault(const Constant(true))();
//   
//   @override
//   Set<Column> get primaryKey => {id};
// }
//
// Luego en el DataSource:
//
// class UserProfileDriftDataSourceImpl implements UserProfileDataSource {
//   final AppDatabase database;
//
//   @override
//   Future<Map<String, dynamic>?> getUserProfile() async {
//     final results = await database.select(database.userProfiles)
//       ..where((tbl) => tbl.isActive.equals(true))
//       ..limit(1);
//     
//     if (results.isEmpty) return null;
//     
//     final profile = results.first;
//     return {
//       'id': profile.id,
//       'name': profile.name,
//       'idealSelfDescription': profile.idealSelfDescription,
//       'focusAreas': json.decode(profile.focusAreasJson),
//       'currentGoals': json.decode(profile.currentGoalsJson),
//       'additionalContext': profile.additionalContext,
//       'lastUpdated': profile.lastUpdated.toIso8601String(),
//     };
//   }
//
//   @override
//   Future<void> saveUserProfile(Map<String, dynamic> profileJson) async {
//     await database.into(database.userProfiles).insert(
//       UserProfilesCompanion.insert(
//         id: profileJson['id'],
//         name: profileJson['name'],
//         idealSelfDescription: profileJson['idealSelfDescription'],
//         focusAreasJson: json.encode(profileJson['focusAreas']),
//         currentGoalsJson: json.encode(profileJson['currentGoals']),
//         additionalContext: Value(profileJson['additionalContext']),
//         lastUpdated: DateTime.parse(profileJson['lastUpdated']),
//       ),
//       mode: InsertMode.replace,
//     );
//   }
// }
