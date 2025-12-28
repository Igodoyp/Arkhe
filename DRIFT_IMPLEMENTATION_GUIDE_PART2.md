# 🗄️ GUÍA DRIFT - PARTE 2: DataSources y Repository

## 📚 Continuación de DRIFT_IMPLEMENTATION_GUIDE_PART1.md

---

## 💾 PASO 7: Crear DataSources con Drift

### 7.1 Mission DataSource

Crear `lib/features/missions/data/datasources/local/drift_mission_datasource.dart`

```dart
import '../../domain/entities/mission_entity.dart';
import '../models/mission_model.dart';
import 'drift/database.dart';
import 'drift/daos/mission_dao.dart';
import 'package:drift/drift.dart' as drift;

// ============================================================================
// DRIFT MISSION DATASOURCE
// ============================================================================
/// DataSource que usa Drift para persistir misiones
abstract class DriftMissionDataSource {
  Future<List<Mission>> getMissions();
  Future<List<Mission>> getTodaysMissions();
  Future<void> saveMissions(List<Mission> missions);
  Future<void> updateMission(Mission mission);
  Future<void> toggleMissionComplete(String id, bool isCompleted);
  Future<void> clearAllMissions();
  Stream<List<Mission>> watchMissions();
}

class DriftMissionDataSourceImpl implements DriftMissionDataSource {
  final AppDatabase database;
  late final MissionDao _missionDao;

  DriftMissionDataSourceImpl({required this.database}) {
    _missionDao = MissionDao(database);
  }

  @override
  Future<List<Mission>> getMissions() async {
    print('[DriftMissionDataSource] 📖 Obteniendo todas las misiones...');
    
    final missionDataList = await _missionDao.getAllMissions();
    final missions = missionDataList
        .map((data) => _missionDataToEntity(data))
        .toList();
    
    print('[DriftMissionDataSource] ✅ ${missions.length} misiones encontradas');
    return missions;
  }

  @override
  Future<List<Mission>> getTodaysMissions() async {
    print('[DriftMissionDataSource] 📖 Obteniendo misiones de hoy...');
    
    final missionDataList = await _missionDao.getTodaysMissions();
    final missions = missionDataList
        .map((data) => _missionDataToEntity(data))
        .toList();
    
    print('[DriftMissionDataSource] ✅ ${missions.length} misiones de hoy encontradas');
    return missions;
  }

  @override
  Future<void> saveMissions(List<Mission> missions) async {
    print('[DriftMissionDataSource] 💾 Guardando ${missions.length} misiones...');
    
    final companions = missions
        .map((mission) => _missionToCompanion(mission))
        .toList();
    
    await _missionDao.insertMissions(companions);
    print('[DriftMissionDataSource] ✅ Misiones guardadas');
  }

  @override
  Future<void> updateMission(Mission mission) async {
    print('[DriftMissionDataSource] 🔄 Actualizando misión ${mission.id}...');
    
    final existingData = await _missionDao.getMissionById(mission.id);
    
    if (existingData == null) {
      // Si no existe, insertarla
      await _missionDao.insertMission(_missionToCompanion(mission));
    } else {
      // Si existe, actualizarla
      final updatedData = existingData.copyWith(
        title: mission.title,
        description: mission.description,
        type: mission.type.name,
        xpReward: mission.xpReward,
        isCompleted: mission.isCompleted,
        updatedAt: drift.Value(DateTime.now()),
      );
      await _missionDao.updateMission(updatedData);
    }
    
    print('[DriftMissionDataSource] ✅ Misión actualizada');
  }

  @override
  Future<void> toggleMissionComplete(String id, bool isCompleted) async {
    print('[DriftMissionDataSource] 🔄 Marcando misión $id como ${isCompleted ? "completada" : "incompleta"}...');
    
    if (isCompleted) {
      await _missionDao.markAsCompleted(id);
    } else {
      await _missionDao.markAsIncomplete(id);
    }
    
    print('[DriftMissionDataSource] ✅ Estado actualizado');
  }

  @override
  Future<void> clearAllMissions() async {
    print('[DriftMissionDataSource] 🧹 Eliminando todas las misiones...');
    await _missionDao.deleteAllMissions();
    print('[DriftMissionDataSource] ✅ Misiones eliminadas');
  }

  @override
  Stream<List<Mission>> watchMissions() {
    print('[DriftMissionDataSource] 👁️ Observando cambios en misiones...');
    
    return _missionDao.watchAllMissions().map(
      (dataList) => dataList.map((data) => _missionDataToEntity(data)).toList(),
    );
  }

  // ========== HELPERS ==========

  /// Convierte MissionData (Drift) a Mission (Entity)
  Mission _missionDataToEntity(MissionData data) {
    return Mission(
      id: data.id,
      title: data.title,
      description: data.description,
      type: MissionType.values.firstWhere((t) => t.name == data.type),
      xpReward: data.xpReward,
      isCompleted: data.isCompleted,
    );
  }

  /// Convierte Mission (Entity) a MissionsCompanion (Drift)
  MissionsCompanion _missionToCompanion(Mission mission) {
    return MissionsCompanion.insert(
      id: mission.id,
      title: mission.title,
      description: mission.description,
      type: mission.type.name,
      xpReward: mission.xpReward,
      isCompleted: drift.Value(mission.isCompleted),
    );
  }
}
```

### 7.2 UserStats DataSource

Crear `lib/features/missions/data/datasources/local/drift_user_stats_datasource.dart`

```dart
import 'dart:convert';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/entities/stat_type.dart';
import 'drift/database.dart';
import 'drift/daos/user_stats_dao.dart';

abstract class DriftUserStatsDataSource {
  Future<UserStats> getUserStats();
  Future<void> updateUserStats(UserStats stats);
  Future<void> incrementStats(Map<StatType, double> increments);
  Stream<UserStats> watchUserStats();
}

class DriftUserStatsDataSourceImpl implements DriftUserStatsDataSource {
  final AppDatabase database;
  late final UserStatsDao _statsDao;

  DriftUserStatsDataSourceImpl({required this.database}) {
    _statsDao = UserStatsDao(database);
  }

  @override
  Future<UserStats> getUserStats() async {
    print('[DriftUserStatsDataSource] 📖 Obteniendo stats del usuario...');
    
    final statsData = await _statsDao.getUserStats();
    
    if (statsData == null) {
      // Inicializar con stats por defecto
      print('[DriftUserStatsDataSource] ⚠️ No hay stats, inicializando...');
      final defaultStats = _getDefaultStats();
      await _statsDao.initializeUserStats(defaultStats);
      return UserStats(stats: _mapToStatType(defaultStats));
    }
    
    final statsMap = _statsDao.parseStatsJson(statsData.statsJson);
    print('[DriftUserStatsDataSource] ✅ Stats obtenidas');
    
    return UserStats(stats: _mapToStatType(statsMap));
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    print('[DriftUserStatsDataSource] 💾 Actualizando stats del usuario...');
    
    final statsMap = _statTypeMapToString(stats.stats);
    await _statsDao.updateUserStats(statsMap);
    
    print('[DriftUserStatsDataSource] ✅ Stats actualizadas');
  }

  @override
  Future<void> incrementStats(Map<StatType, double> increments) async {
    print('[DriftUserStatsDataSource] 📈 Incrementando stats...');
    
    final incrementsMap = _statTypeMapToString(increments);
    await _statsDao.incrementStats(incrementsMap);
    
    print('[DriftUserStatsDataSource] ✅ Stats incrementadas: $increments');
  }

  @override
  Stream<UserStats> watchUserStats() {
    print('[DriftUserStatsDataSource] 👁️ Observando cambios en stats...');
    
    return _statsDao.watchUserStats().map((statsData) {
      if (statsData == null) {
        return UserStats(stats: _mapToStatType(_getDefaultStats()));
      }
      
      final statsMap = _statsDao.parseStatsJson(statsData.statsJson);
      return UserStats(stats: _mapToStatType(statsMap));
    });
  }

  // ========== HELPERS ==========

  Map<String, double> _getDefaultStats() {
    return {
      'strength': 10.0,
      'intelligence': 10.0,
      'creativity': 10.0,
      'discipline': 10.0,
      'agility': 10.0,
      'vitality': 10.0,
    };
  }

  Map<StatType, double> _mapToStatType(Map<String, double> map) {
    return {
      StatType.strength: map['strength'] ?? 10.0,
      StatType.intelligence: map['intelligence'] ?? 10.0,
      StatType.creativity: map['creativity'] ?? 10.0,
      StatType.discipline: map['discipline'] ?? 10.0,
      // Agrega los otros stats si los tienes
    };
  }

  Map<String, double> _statTypeMapToString(Map<StatType, double> map) {
    return map.map((key, value) => MapEntry(key.name, value));
  }
}
```

### 7.3 DaySession DataSource

Crear `lib/features/missions/data/datasources/local/drift_day_session_datasource.dart`

```dart
import 'dart:convert';
import '../../domain/entities/day_session_entity.dart';
import '../../domain/entities/mission_entity.dart';
import 'drift/database.dart';
import 'drift/daos/day_session_dao.dart';
import 'drift/daos/mission_dao.dart';
import 'package:drift/drift.dart' as drift;

abstract class DriftDaySessionDataSource {
  Future<DaySession> getCurrentDaySession();
  Future<void> addCompletedMission(Mission mission);
  Future<void> removeCompletedMission(String missionId);
  Future<void> finalizeSession(String sessionId);
  Stream<DaySession?> watchCurrentSession();
}

class DriftDaySessionDataSourceImpl implements DriftDaySessionDataSource {
  final AppDatabase database;
  late final DaySessionDao _sessionDao;
  late final MissionDao _missionDao;

  DriftDaySessionDataSourceImpl({required this.database}) {
    _sessionDao = DaySessionDao(database);
    _missionDao = MissionDao(database);
  }

  @override
  Future<DaySession> getCurrentDaySession() async {
    print('[DriftDaySessionDataSource] 📖 Obteniendo sesión del día actual...');
    
    var sessionData = await _sessionDao.getTodaysSession();
    
    // Si no existe sesión para hoy, crearla
    if (sessionData == null) {
      print('[DriftDaySessionDataSource] ⚠️ No hay sesión para hoy, creando...');
      sessionData = await _createTodaysSession();
    }
    
    // Si la sesión está finalizada, crear una nueva
    if (sessionData.isFinalized) {
      print('[DriftDaySessionDataSource] ⚠️ Sesión finalizada, creando nueva...');
      sessionData = await _createTodaysSession();
    }
    
    final session = await _sessionDataToEntity(sessionData);
    print('[DriftDaySessionDataSource] ✅ Sesión obtenida: ${session.id}');
    
    return session;
  }

  @override
  Future<void> addCompletedMission(Mission mission) async {
    print('[DriftDaySessionDataSource] ➕ Agregando misión ${mission.id} a la sesión...');
    
    final session = await getCurrentDaySession();
    await _sessionDao.addCompletedMission(session.id, mission.id);
    
    print('[DriftDaySessionDataSource] ✅ Misión agregada');
  }

  @override
  Future<void> removeCompletedMission(String missionId) async {
    print('[DriftDaySessionDataSource] ➖ Removiendo misión $missionId de la sesión...');
    
    final session = await getCurrentDaySession();
    await _sessionDao.removeCompletedMission(session.id, missionId);
    
    print('[DriftDaySessionDataSource] ✅ Misión removida');
  }

  @override
  Future<void> finalizeSession(String sessionId) async {
    print('[DriftDaySessionDataSource] 🏁 Finalizando sesión $sessionId...');
    
    await _sessionDao.finalizeSession(sessionId);
    
    print('[DriftDaySessionDataSource] ✅ Sesión finalizada');
  }

  @override
  Stream<DaySession?> watchCurrentSession() {
    print('[DriftDaySessionDataSource] 👁️ Observando sesión actual...');
    
    return _sessionDao.watchTodaysSession().asyncMap((sessionData) async {
      if (sessionData == null) return null;
      return await _sessionDataToEntity(sessionData);
    });
  }

  // ========== HELPERS ==========

  Future<DaySessionData> _createTodaysSession() async {
    final now = DateTime.now();
    final sessionId = 'session_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}_${now.millisecondsSinceEpoch}';
    
    final companion = DaySessionsCompanion.insert(
      id: sessionId,
      date: now,
      completedMissionIds: drift.Value('[]'),
      isFinalized: drift.Value(false),
    );
    
    await _sessionDao.createSession(companion);
    
    final created = await _sessionDao.getSessionById(sessionId);
    return created!;
  }

  Future<DaySession> _sessionDataToEntity(DaySessionData data) async {
    // Parsear IDs de misiones completadas
    final missionIds = _sessionDao.parseCompletedMissionIds(data.completedMissionIds);
    
    // Obtener las misiones completas desde la BD
    final missions = <Mission>[];
    for (final id in missionIds) {
      final missionData = await _missionDao.getMissionById(id);
      if (missionData != null) {
        missions.add(Mission(
          id: missionData.id,
          title: missionData.title,
          description: missionData.description,
          type: MissionType.values.firstWhere((t) => t.name == missionData.type),
          xpReward: missionData.xpReward,
          isCompleted: missionData.isCompleted,
        ));
      }
    }
    
    return DaySession(
      id: data.id,
      date: data.date,
      completedMissions: missions,
      isFinalized: data.isFinalized,
    );
  }
}
```

### 7.4 DayFeedback DataSource

Crear `lib/features/missions/data/datasources/local/drift_day_feedback_datasource.dart`

```dart
import 'dart:convert';
import '../../domain/entities/day_feedback_entity.dart';
import 'drift/database.dart';
import 'drift/daos/day_feedback_dao.dart';
import 'package:drift/drift.dart' as drift;

abstract class DriftDayFeedbackDataSource {
  Future<void> saveFeedback(DayFeedback feedback);
  Future<List<DayFeedback>> getFeedbackHistory({int limit = 30});
  Future<DayFeedback?> getFeedbackBySessionId(String sessionId);
}

class DriftDayFeedbackDataSourceImpl implements DriftDayFeedbackDataSource {
  final AppDatabase database;
  late final DayFeedbackDao _feedbackDao;

  DriftDayFeedbackDataSourceImpl({required this.database}) {
    _feedbackDao = DayFeedbackDao(database);
  }

  @override
  Future<void> saveFeedback(DayFeedback feedback) async {
    print('[DriftDayFeedbackDataSource] 💾 Guardando feedback para sesión ${feedback.sessionId}...');
    
    final companion = DayFeedbacksCompanion.insert(
      sessionId: feedback.sessionId,
      difficulty: feedback.difficulty.name,
      energy: feedback.energy,
      struggledMissionIds: drift.Value(jsonEncode(feedback.struggledMissionIds)),
      easyMissionIds: drift.Value(jsonEncode(feedback.easyMissionIds)),
      notes: drift.Value(feedback.notes),
    );
    
    await _feedbackDao.saveFeedback(companion);
    
    print('[DriftDayFeedbackDataSource] ✅ Feedback guardado');
  }

  @override
  Future<List<DayFeedback>> getFeedbackHistory({int limit = 30}) async {
    print('[DriftDayFeedbackDataSource] 📖 Obteniendo historial de feedback (limit: $limit)...');
    
    final feedbackDataList = await _feedbackDao.getRecentFeedbacks(limit: limit);
    final feedbacks = feedbackDataList
        .map((data) => _feedbackDataToEntity(data))
        .toList();
    
    print('[DriftDayFeedbackDataSource] ✅ ${feedbacks.length} feedbacks encontrados');
    return feedbacks;
  }

  @override
  Future<DayFeedback?> getFeedbackBySessionId(String sessionId) async {
    print('[DriftDayFeedbackDataSource] 📖 Obteniendo feedback para sesión $sessionId...');
    
    final feedbackData = await _feedbackDao.getFeedbackBySessionId(sessionId);
    
    if (feedbackData == null) {
      print('[DriftDayFeedbackDataSource] ⚠️ No se encontró feedback');
      return null;
    }
    
    print('[DriftDayFeedbackDataSource] ✅ Feedback encontrado');
    return _feedbackDataToEntity(feedbackData);
  }

  // ========== HELPERS ==========

  DayFeedback _feedbackDataToEntity(DayFeedbackData data) {
    return DayFeedback(
      sessionId: data.sessionId,
      difficulty: DifficultyLevel.values.firstWhere((d) => d.name == data.difficulty),
      energy: data.energy,
      struggledMissionIds: (jsonDecode(data.struggledMissionIds) as List).cast<String>(),
      easyMissionIds: (jsonDecode(data.easyMissionIds) as List).cast<String>(),
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }
}
```

---

## 🔄 PASO 8: Actualizar Repository Implementations

### 8.1 Mission Repository

Actualizar `lib/features/missions/data/repositories/mission_repository_impl.dart`

```dart
import '../../domain/entities/mission_entity.dart';
import '../../domain/repositories/mission_repository.dart';
import '../datasources/local/drift_mission_datasource.dart';

class MissionRepositoryImpl implements MissionRepository {
  final DriftMissionDataSource localDataSource;
  // Puedes mantener el dummy como fallback
  // final MissionGeminiDummyDataSource? remoteDataSource;

  MissionRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<List<Mission>> getMissions() async {
    try {
      // Intentar obtener de la BD local
      final missions = await localDataSource.getMissions();
      
      // Si no hay misiones, generarlas (dummy o Gemini en el futuro)
      if (missions.isEmpty) {
        print('[MissionRepository] No hay misiones locales, generando...');
        final newMissions = await _generateDummyMissions();
        await localDataSource.saveMissions(newMissions);
        return newMissions;
      }
      
      return missions;
    } catch (e) {
      print('[MissionRepository] Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMission(Mission mission) async {
    await localDataSource.updateMission(mission);
  }

  // Stream reactivo
  Stream<List<Mission>> watchMissions() {
    return localDataSource.watchMissions();
  }

  // Helper para generar misiones dummy
  Future<List<Mission>> _generateDummyMissions() async {
    return [
      Mission(
        id: 'mission_1',
        title: 'Hacer ejercicio',
        description: 'Entrenar 30 minutos',
        type: MissionType.physical,
        xpReward: 50,
      ),
      // ... más misiones
    ];
  }
}
```

### 8.2 UserStats Repository

Similar actualización para `user_stats_repository_impl.dart`:

```dart
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/entities/stat_type.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../datasources/local/drift_user_stats_datasource.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final DriftUserStatsDataSource dataSource;

  UserStatsRepositoryImpl({required this.dataSource});

  @override
  Future<UserStats> getUserStats() async {
    return await dataSource.getUserStats();
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    await dataSource.updateUserStats(stats);
  }

  @override
  Future<void> incrementStats(Map<StatType, double> increments) async {
    await dataSource.incrementStats(increments);
  }

  Stream<UserStats> watchUserStats() {
    return dataSource.watchUserStats();
  }
}
```

### 8.3 DaySession y DayFeedback Repositories

Aplicar el mismo patrón para estos repositories.

---

## 🚀 PASO 9: Integrar en main.dart

### Actualizar `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'features/missions/data/datasources/local/drift/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ========== INICIALIZAR DATABASE ==========
  print('🗄️ Inicializando Drift...');
  final database = DatabaseProvider.instance;
  
  // Opcional: Ver stats de la BD al inicio
  final stats = await database.getDatabaseStats();
  print('📊 BD Stats: $stats');
  
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  
  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    // ... tu código existente
  }
}
```

---

## 🧪 PASO 10: Testing

### Test de la Base de Datos

Crear `test/data/datasources/drift_mission_datasource_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:d0/features/missions/data/datasources/local/drift/database.dart';
import 'package:d0/features/missions/data/datasources/local/drift_mission_datasource.dart';

void main() {
  late AppDatabase database;
  late DriftMissionDataSourceImpl dataSource;

  setUp(() {
    // Crear BD en memoria para tests
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = DriftMissionDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('DriftMissionDataSource', () {
    test('should save and retrieve missions', () async {
      // Arrange
      final missions = [/* test data */];
      
      // Act
      await dataSource.saveMissions(missions);
      final retrieved = await dataSource.getMissions();
      
      // Assert
      expect(retrieved.length, equals(missions.length));
    });

    test('should toggle mission complete', () async {
      // Arrange
      final mission = /* test mission */;
      await dataSource.saveMissions([mission]);
      
      // Act
      await dataSource.toggleMissionComplete(mission.id, true);
      final updated = await dataSource.getMissions();
      
      // Assert
      expect(updated.first.isCompleted, isTrue);
    });
  });
}
```

### Constructor para Testing

Agregar en `database.dart`:

```dart
@DriftDatabase(/* ... */)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // Constructor para testing
  AppDatabase.forTesting(QueryExecutor e) : super(e);
  
  // ...rest
}
```

---

## 📋 PASO 11: Migrar desde Dummy DataSources

### Plan de Migración

1. **Fase 1: Agregar Drift sin remover Dummy**
   - Implementa todo Drift
   - Mantén Dummy como fallback
   - Usa flag para switchear: `USE_DRIFT = true`

2. **Fase 2: Testing Paralelo**
   - Prueba ambos datasources
   - Compara resultados
   - Valida migración de datos

3. **Fase 3: Migración de Datos**
   - Lee datos de Dummy
   - Guarda en Drift
   - Valida integridad

4. **Fase 4: Remover Dummy**
   - Elimina archivos dummy
   - Limpia imports
   - Update documentation

### Script de Migración

```dart
// tools/migrate_to_drift.dart
Future<void> migrateFromDummyToDrift() async {
  final dummyDataSource = MissionGeminiDummyDataSourceImpl();
  final driftDataSource = DriftMissionDataSourceImpl(
    database: DatabaseProvider.instance,
  );
  
  print('🔄 Migrando misiones...');
  final dummyMissions = await dummyDataSource.getMissions();
  await driftDataSource.saveMissions(dummyMissions);
  print('✅ ${dummyMissions.length} misiones migradas');
  
  // Repetir para otros datasources...
}
```

---

## ✅ CHECKLIST FINAL

### Implementación
- [ ] Dependencias instaladas
- [ ] Tablas definidas
- [ ] Database.dart creado
- [ ] DAOs implementados
- [ ] Código generado con build_runner
- [ ] DataSources creados
- [ ] Repositories actualizados
- [ ] main.dart integrado

### Testing
- [ ] Tests unitarios de DAOs
- [ ] Tests de DataSources
- [ ] Tests de integración
- [ ] Migración de datos validada

### Limpieza
- [ ] Dummy datasources removidos
- [ ] Imports actualizados
- [ ] Documentación actualizada
- [ ] README.md actualizado

---

## 🎯 Comandos Útiles

```powershell
# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Generar y observar cambios
flutter pub run build_runner watch

# Ver schema de la BD (opcional, requiere drift_db_viewer)
flutter pub add --dev drift_db_viewer
# Luego en la app: DriftDbViewer(db)

# Testing
flutter test

# Limpiar generated files
flutter pub run build_runner clean
```

---

## 🔍 Debugging

### Ver el Schema SQL

```dart
// En database.dart, agrega:
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      
      // Imprimir SQL de creación
      final statements = m.createAll();
      print('SQL Schema:');
      // ... ver drift docs para logging
    },
  );
}
```

### Inspeccionar BD en Runtime

```dart
// En DevTools o logs
final stats = await database.getDatabaseStats();
print('Total misiones: ${stats['missions']}');

final missions = await database.select(database.missions).get();
print('Misiones: $missions');
```

---

## 📚 Recursos

- **Drift Docs:** https://drift.simonbinder.eu/
- **Drift Examples:** https://github.com/simolus3/drift/tree/develop/examples
- **SQL Tutorial:** https://www.sqlitetutorial.net/
- **Migration Guide:** https://drift.simonbinder.eu/docs/advanced-features/migrations/

---

**¿Listo para empezar?** 
1. Instala las dependencias
2. Crea las tablas y database
3. Genera el código
4. Implementa un DataSource (empieza con Mission)
5. Prueba!

🔥 **¡Drift te dará una base de datos robusta para producción!** 🔥
