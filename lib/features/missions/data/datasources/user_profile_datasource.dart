// data/datasources/user_profile_datasource.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
/// SINGLETON: Usa una única instancia compartida para que el perfil
/// persista entre navegaciones dentro de la misma sesión de la app.
/// 
/// En producción, esto será reemplazado por:
/// - SharedPreferences (perfil pequeño, simple)
/// - Drift/SQLite (si se necesita versionado/historial)
/// - Hive (alternativa ligera)
class UserProfileDummyDataSourceImpl implements UserProfileDataSource {
  // Singleton pattern
  static final UserProfileDummyDataSourceImpl _instance = 
      UserProfileDummyDataSourceImpl._internal();
  
  factory UserProfileDummyDataSourceImpl() => _instance;
  
  UserProfileDummyDataSourceImpl._internal();
  
  // Variable privada que guarda el perfil en memoria
  Map<String, dynamic>? _profile;

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    // Simula delay de lectura
    await Future.delayed(const Duration(milliseconds: 200));
    
    print('[UserProfileDataSource] 📖 ${_profile != null ? "Perfil cargado: ${_profile!['name']}" : "No hay perfil"}');
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
    
    final result = _profile != null;
    print('[UserProfileDataSource] 🔍 hasProfile: $result');
    return result;
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
// 3. IMPLEMENTACIÓN CON SHAREDPREFERENCES (Persistencia Real)
// ============================================================================

/// Implementación con SharedPreferences para persistencia entre sesiones
/// 
/// Ventajas:
/// - Sobrevive al reinicio de la app
/// - Simple y ligero (ideal para un solo perfil)
/// - No requiere esquema SQL
class UserProfileSharedPrefsDataSourceImpl implements UserProfileDataSource {
  final SharedPreferences prefs;
  static const String _key = 'user_profile';

  UserProfileSharedPrefsDataSourceImpl({required this.prefs});

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      print('[UserProfileDataSource] 📖 No hay perfil (SharedPrefs)');
      return null;
    }
    
    final profile = json.decode(jsonString) as Map<String, dynamic>;
    print('[UserProfileDataSource] 📖 Perfil cargado: ${profile['name']} (SharedPrefs)');
    return profile;
  }

  @override
  Future<void> saveUserProfile(Map<String, dynamic> profileJson) async {
    final jsonString = json.encode(profileJson);
    await prefs.setString(_key, jsonString);
    print('[UserProfileDataSource] 💾 Perfil guardado: ${profileJson['name']} (SharedPrefs)');
  }

  @override
  Future<bool> hasProfile() async {
    final result = prefs.containsKey(_key);
    print('[UserProfileDataSource] 🔍 hasProfile: $result (SharedPrefs)');
    return result;
  }

  @override
  Future<void> deleteUserProfile() async {
    await prefs.remove(_key);
    print('[UserProfileDataSource] 🗑️ Perfil eliminado (SharedPrefs)');
  }
}

// ============================================================================
// 4. FACTORY SEGURO (Con fallback para tests)
// ============================================================================

/// Crea un datasource con persistencia real si está disponible,
/// o fallback a memoria si no (útil para widget tests donde SharedPreferences
/// puede no estar disponible)
Future<UserProfileDataSource> createUserProfileDataSource() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    print('[UserProfileDataSource] ✅ Usando SharedPreferences (persistencia real)');
    return UserProfileSharedPrefsDataSourceImpl(prefs: prefs);
  } catch (e) {
    print('[UserProfileDataSource] ⚠️ SharedPreferences no disponible, usando memoria: $e');
    return UserProfileDummyDataSourceImpl();
  }
}

// ============================================================================
// NOTAS PARA MIGRACIÓN FUTURA A DRIFT
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
