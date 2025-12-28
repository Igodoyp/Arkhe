# 🗄️ GUÍA COMPLETA: Implementar Drift en D0

## 🎯 Por Qué Drift es Excelente para Tu Proyecto

### Ventajas para D0
✅ **SQL + Type Safety** → Compile-time safety, menos bugs  
✅ **Migraciones Robustas** → Perfecto para producción  
✅ **Queries Reactivas** → Streams automáticos para UI  
✅ **Relaciones Built-in** → Mission ↔ DaySession fácil  
✅ **Testing Fácil** → In-memory database para tests  
✅ **Debugging** → SQL queries legibles  

---

## 📦 PASO 1: Instalación

### Agregar Dependencias

```yaml
# pubspec.yaml
dependencies:
  # Database
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.1
  path: ^1.8.3

dev_dependencies:
  # Code generation
  drift_dev: ^2.14.1
  build_runner: ^2.4.7
```

### Instalar

```powershell
cd d:\D0\d0
flutter pub get
```

---

## 🏗️ PASO 2: Estructura de Archivos

### Nueva Estructura

```
lib/
  features/
    missions/
      data/
        datasources/
          local/
            drift/
              database.dart              ← NUEVO (define DB)
              tables.dart                ← NUEVO (define tablas)
              daos/
                mission_dao.dart         ← NUEVO (queries de Mission)
                user_stats_dao.dart      ← NUEVO (queries de UserStats)
                day_session_dao.dart     ← NUEVO (queries de DaySession)
                day_feedback_dao.dart    ← NUEVO (queries de DayFeedback)
            drift_mission_datasource.dart        ← NUEVO
            drift_user_stats_datasource.dart     ← NUEVO
            drift_day_session_datasource.dart    ← NUEVO
            drift_day_feedback_datasource.dart   ← NUEVO
          mission_datasource.dart        ← MANTENER (dummy fallback)
          ...
        models/
          mission_model.dart             ← MODIFICAR (usar con Drift)
          ...
```

---

## 💻 PASO 3: Definir Tablas

### Crear `lib/features/missions/data/datasources/local/drift/tables.dart`

```dart
import 'package:drift/drift.dart';

// ============================================================================
// TABLA: MISSIONS
// ============================================================================
/// Representa las misiones diarias del usuario
@DataClassName('MissionData')
class Missions extends Table {
  // Primary key
  TextColumn get id => text()();
  
  // Campos básicos
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text()();
  
  // Tipo de misión (guardamos como String del enum)
  TextColumn get type => text()();
  
  // Recompensa de XP
  IntColumn get xpReward => integer()();
  
  // Estado
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  // Stats que afecta (JSON string: {"strength": 5, "intelligence": 3})
  TextColumn get affectedStats => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// TABLA: USER_STATS
// ============================================================================
/// Estadísticas del usuario (solo 1 fila en la tabla)
@DataClassName('UserStatsData')
class UserStats extends Table {
  // Primary key (siempre será 'user_stats_singleton')
  TextColumn get id => text()();
  
  // Stats (guardamos como JSON: {"strength": 10.5, "intelligence": 8.0, ...})
  TextColumn get statsJson => text()();
  
  // Timestamps
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// TABLA: DAY_SESSIONS
// ============================================================================
/// Sesiones del día (1 por día)
@DataClassName('DaySessionData')
class DaySessions extends Table {
  // Primary key (ej: "session_2024_12_28")
  TextColumn get id => text()();
  
  // Fecha de la sesión
  DateTimeColumn get date => dateTime()();
  
  // IDs de misiones completadas (JSON array: ["mission1", "mission2"])
  TextColumn get completedMissionIds => text().withDefault(const Constant('[]'))();
  
  // Estado
  BoolColumn get isFinalized => boolean().withDefault(const Constant(false))();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finalizedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// TABLA: DAY_FEEDBACKS
// ============================================================================
/// Feedback del usuario después de completar el día
@DataClassName('DayFeedbackData')
class DayFeedbacks extends Table {
  // Primary key (auto-increment)
  IntColumn get id => integer().autoIncrement()();
  
  // Foreign key a DaySessions
  TextColumn get sessionId => text().references(DaySessions, #id)();
  
  // Dificultad percibida (enum como String)
  TextColumn get difficulty => text()();
  
  // Nivel de energía (1-5)
  IntColumn get energy => integer()();
  
  // Misiones que fueron difíciles (JSON array)
  TextColumn get struggledMissionIds => text().withDefault(const Constant('[]'))();
  
  // Misiones que fueron fáciles (JSON array)
  TextColumn get easyMissionIds => text().withDefault(const Constant('[]'))();
  
  // Notas del usuario
  TextColumn get notes => text().withDefault(const Constant(''))();
  
  // Timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// TABLA AUXILIAR: MISSION_STATS (relación many-to-many simulada)
// ============================================================================
/// Relación entre Mission y StatType (para queries avanzadas en el futuro)
@DataClassName('MissionStatData')
class MissionStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get missionId => text().references(Missions, #id, onDelete: KeyAction.cascade)();
  TextColumn get statType => text()(); // "strength", "intelligence", etc.
  RealColumn get statValue => real()(); // Cuánto afecta a ese stat
  
  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 🗄️ PASO 4: Crear la Base de Datos

### Crear `lib/features/missions/data/datasources/local/drift/database.dart`

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'database.g.dart';

// ============================================================================
// APP DATABASE
// ============================================================================
/// Base de datos principal de la aplicación
/// 
/// Incluye todas las tablas y DAOs para acceder a los datos.
/// Usa SQLite como backend a través de Drift.
@DriftDatabase(
  tables: [
    Missions,
    UserStats,
    DaySessions,
    DayFeedbacks,
    MissionStats,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Constructor
  AppDatabase() : super(_openConnection());

  // Versión del schema (incrementa cuando cambies tablas)
  @override
  int get schemaVersion => 1;

  // ========== MIGRACIONES ==========
  /// Se ejecuta cuando cambia la versión del schema
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // Crear todas las tablas
        await m.createAll();
        
        print('[AppDatabase] ✅ Base de datos creada (v$schemaVersion)');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        print('[AppDatabase] 🔄 Migrando de v$from a v$to...');
        
        // Ejemplo de migración para versión 2:
        // if (from < 2) {
        //   await m.addColumn(missions, missions.newColumn);
        // }
        
        print('[AppDatabase] ✅ Migración completada');
      },
      beforeOpen: (details) async {
        // Habilitar foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
        
        if (details.wasCreated) {
          print('[AppDatabase] 🎉 Primera vez abriendo la BD');
        }
      },
    );
  }

  // ========== QUERIES ÚTILES GLOBALES ==========
  
  /// Limpia TODA la base de datos (útil para testing)
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(dayFeedbacks).go();
      await delete(daySessions).go();
      await delete(missionStats).go();
      await delete(missions).go();
      await delete(userStats).go();
    });
    print('[AppDatabase] 🧹 Toda la data fue eliminada');
  }

  /// Obtiene estadísticas de la base de datos
  Future<Map<String, int>> getDatabaseStats() async {
    final missionCount = await (select(missions).get()).then((list) => list.length);
    final sessionCount = await (select(daySessions).get()).then((list) => list.length);
    final feedbackCount = await (select(dayFeedbacks).get()).then((list) => list.length);
    
    return {
      'missions': missionCount,
      'sessions': sessionCount,
      'feedbacks': feedbackCount,
    };
  }
}

// ============================================================================
// DATABASE CONNECTION
// ============================================================================
/// Abre la conexión a la base de datos SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Obtener directorio de documentos de la app
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'd0_database.sqlite'));
    
    print('[AppDatabase] 📂 Database path: ${file.path}');
    
    return NativeDatabase.createInBackground(file);
  });
}

// ============================================================================
// SINGLETON PATTERN (Opcional pero recomendado)
// ============================================================================
/// Instancia global de la base de datos
/// 
/// Uso:
/// ```dart
/// final db = DatabaseProvider.instance;
/// final missions = await db.getMissions();
/// ```
class DatabaseProvider {
  static AppDatabase? _instance;
  
  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }
  
  /// Cierra la base de datos (útil al cerrar la app)
  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
```

---

## 🎯 PASO 5: Crear DAOs (Data Access Objects)

### 5.1 Mission DAO

Crear `lib/features/missions/data/datasources/local/drift/daos/mission_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import 'dart:convert';

part 'mission_dao.g.dart';

// ============================================================================
// MISSION DAO
// ============================================================================
/// Data Access Object para la tabla Missions
/// 
/// Contiene todas las queries relacionadas con misiones.
@DriftAccessor(tables: [Missions])
class MissionDao extends DatabaseAccessor<AppDatabase> with _$MissionDaoMixin {
  MissionDao(AppDatabase db) : super(db);

  // ========== QUERIES BÁSICAS ==========

  /// Obtiene todas las misiones
  Future<List<MissionData>> getAllMissions() {
    return select(missions).get();
  }

  /// Obtiene una misión por ID
  Future<MissionData?> getMissionById(String id) {
    return (select(missions)..where((m) => m.id.equals(id))).getSingleOrNull();
  }

  /// Obtiene misiones de hoy
  Future<List<MissionData>> getTodaysMissions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return (select(missions)
      ..where((m) => m.createdAt.isBiggerOrEqualValue(startOfDay))
      ..orderBy([
        (m) => OrderingTerm.desc(m.createdAt),
      ])
    ).get();
  }

  /// Obtiene solo misiones completadas
  Future<List<MissionData>> getCompletedMissions() {
    return (select(missions)
      ..where((m) => m.isCompleted.equals(true))
      ..orderBy([
        (m) => OrderingTerm.desc(m.updatedAt),
      ])
    ).get();
  }

  /// Obtiene misiones pendientes
  Future<List<MissionData>> getPendingMissions() {
    return (select(missions)
      ..where((m) => m.isCompleted.equals(false))
      ..orderBy([
        (m) => OrderingTerm.asc(m.createdAt),
      ])
    ).get();
  }

  // ========== QUERIES REACTIVAS (Streams) ==========

  /// Stream de todas las misiones (se actualiza automáticamente)
  Stream<List<MissionData>> watchAllMissions() {
    return select(missions).watch();
  }

  /// Stream de misiones de hoy
  Stream<List<MissionData>> watchTodaysMissions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return (select(missions)
      ..where((m) => m.createdAt.isBiggerOrEqualValue(startOfDay))
    ).watch();
  }

  // ========== INSERTS ==========

  /// Inserta una nueva misión
  Future<int> insertMission(MissionsCompanion mission) {
    return into(missions).insert(mission);
  }

  /// Inserta múltiples misiones
  Future<void> insertMissions(List<MissionsCompanion> missionList) async {
    await batch((batch) {
      batch.insertAll(missions, missionList);
    });
  }

  // ========== UPDATES ==========

  /// Actualiza una misión existente
  Future<bool> updateMission(MissionData mission) {
    return update(missions).replace(mission);
  }

  /// Marca una misión como completada
  Future<int> markAsCompleted(String id) {
    return (update(missions)..where((m) => m.id.equals(id)))
      .write(MissionsCompanion(
        isCompleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
  }

  /// Marca una misión como NO completada
  Future<int> markAsIncomplete(String id) {
    return (update(missions)..where((m) => m.id.equals(id)))
      .write(MissionsCompanion(
        isCompleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ));
  }

  // ========== DELETES ==========

  /// Elimina una misión por ID
  Future<int> deleteMission(String id) {
    return (delete(missions)..where((m) => m.id.equals(id))).go();
  }

  /// Elimina todas las misiones
  Future<int> deleteAllMissions() {
    return delete(missions).go();
  }

  /// Elimina misiones completadas hace más de X días
  Future<int> deleteOldCompletedMissions({int daysOld = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    
    return (delete(missions)
      ..where((m) => 
        m.isCompleted.equals(true) & 
        m.updatedAt.isSmallerThanValue(cutoffDate)
      )
    ).go();
  }

  // ========== QUERIES AVANZADAS ==========

  /// Cuenta misiones por tipo
  Future<Map<String, int>> countMissionsByType() async {
    final allMissions = await getAllMissions();
    final counts = <String, int>{};
    
    for (var mission in allMissions) {
      counts[mission.type] = (counts[mission.type] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Obtiene el total de XP disponible hoy
  Future<int> getTotalXpAvailableToday() async {
    final todaysMissions = await getTodaysMissions();
    return todaysMissions.fold<int>(
      0,
      (sum, mission) => sum + (mission.isCompleted ? 0 : mission.xpReward),
    );
  }

  /// Obtiene el XP ganado hoy
  Future<int> getXpGainedToday() async {
    final todaysMissions = await getTodaysMissions();
    return todaysMissions.fold<int>(
      0,
      (sum, mission) => sum + (mission.isCompleted ? mission.xpReward : 0),
    );
  }

  // ========== BÚSQUEDA ==========

  /// Busca misiones por título o descripción
  Future<List<MissionData>> searchMissions(String query) {
    final searchPattern = '%$query%';
    
    return (select(missions)
      ..where((m) => 
        m.title.like(searchPattern) | 
        m.description.like(searchPattern)
      )
    ).get();
  }
}
```

### 5.2 UserStats DAO

Crear `lib/features/missions/data/datasources/local/drift/daos/user_stats_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import 'dart:convert';

part 'user_stats_dao.g.dart';

@DriftAccessor(tables: [UserStats])
class UserStatsDao extends DatabaseAccessor<AppDatabase> with _$UserStatsDaoMixin {
  UserStatsDao(AppDatabase db) : super(db);

  static const String STATS_ID = 'user_stats_singleton';

  // ========== QUERIES ==========

  /// Obtiene las stats del usuario (siempre hay solo 1 fila)
  Future<UserStatsData?> getUserStats() {
    return (select(userStats)..where((s) => s.id.equals(STATS_ID))).getSingleOrNull();
  }

  /// Stream de las stats del usuario
  Stream<UserStatsData?> watchUserStats() {
    return (select(userStats)..where((s) => s.id.equals(STATS_ID))).watchSingleOrNull();
  }

  // ========== INSERTS/UPDATES ==========

  /// Inicializa las stats del usuario (solo la primera vez)
  Future<void> initializeUserStats(Map<String, double> initialStats) async {
    final existing = await getUserStats();
    
    if (existing == null) {
      await into(userStats).insert(UserStatsCompanion(
        id: const Value(STATS_ID),
        statsJson: Value(jsonEncode(initialStats)),
        lastUpdated: Value(DateTime.now()),
      ));
      print('[UserStatsDao] ✅ Stats inicializadas');
    }
  }

  /// Actualiza las stats del usuario
  Future<bool> updateUserStats(Map<String, double> stats) {
    return (update(userStats)..where((s) => s.id.equals(STATS_ID)))
      .write(UserStatsCompanion(
        statsJson: Value(jsonEncode(stats)),
        lastUpdated: Value(DateTime.now()),
      ))
      .then((rows) => rows > 0);
  }

  /// Incrementa stats específicas
  Future<void> incrementStats(Map<String, double> increments) async {
    final current = await getUserStats();
    
    if (current == null) {
      await initializeUserStats(increments);
      return;
    }
    
    final currentStats = jsonDecode(current.statsJson) as Map<String, dynamic>;
    final newStats = <String, double>{};
    
    // Merge stats actuales con incrementos
    currentStats.forEach((key, value) {
      newStats[key] = (value as num).toDouble();
    });
    
    increments.forEach((key, increment) {
      newStats[key] = (newStats[key] ?? 0.0) + increment;
    });
    
    await updateUserStats(newStats);
  }

  // ========== HELPERS ==========

  /// Parsea el JSON de stats a Map
  Map<String, double> parseStatsJson(String json) {
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }
}
```

### 5.3 DaySession DAO

Crear `lib/features/missions/data/datasources/local/drift/daos/day_session_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import 'dart:convert';

part 'day_session_dao.g.dart';

@DriftAccessor(tables: [DaySessions])
class DaySessionDao extends DatabaseAccessor<AppDatabase> with _$DaySessionDaoMixin {
  DaySessionDao(AppDatabase db) : super(db);

  // ========== QUERIES ==========

  /// Obtiene la sesión de hoy
  Future<DaySessionData?> getTodaysSession() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return (select(daySessions)
      ..where((s) => s.date.isBetweenValues(startOfDay, endOfDay))
    ).getSingleOrNull();
  }

  /// Obtiene una sesión por ID
  Future<DaySessionData?> getSessionById(String id) {
    return (select(daySessions)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// Obtiene sesiones de los últimos N días
  Future<List<DaySessionData>> getRecentSessions({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    
    return (select(daySessions)
      ..where((s) => s.date.isBiggerOrEqualValue(cutoff))
      ..orderBy([(s) => OrderingTerm.desc(s.date)])
    ).get();
  }

  /// Obtiene todas las sesiones finalizadas
  Future<List<DaySessionData>> getFinalizedSessions() {
    return (select(daySessions)
      ..where((s) => s.isFinalized.equals(true))
      ..orderBy([(s) => OrderingTerm.desc(s.date)])
    ).get();
  }

  // ========== STREAMS ==========

  Stream<DaySessionData?> watchTodaysSession() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return (select(daySessions)
      ..where((s) => s.date.isBetweenValues(startOfDay, endOfDay))
    ).watchSingleOrNull();
  }

  // ========== INSERTS ==========

  Future<void> createSession(DaySessionsCompanion session) {
    return into(daySessions).insert(session);
  }

  // ========== UPDATES ==========

  Future<bool> updateSession(DaySessionData session) {
    return update(daySessions).replace(session);
  }

  /// Agrega una misión completada a la sesión
  Future<void> addCompletedMission(String sessionId, String missionId) async {
    final session = await getSessionById(sessionId);
    if (session == null) return;
    
    final currentIds = jsonDecode(session.completedMissionIds) as List;
    if (!currentIds.contains(missionId)) {
      currentIds.add(missionId);
      
      await (update(daySessions)..where((s) => s.id.equals(sessionId)))
        .write(DaySessionsCompanion(
          completedMissionIds: Value(jsonEncode(currentIds)),
        ));
    }
  }

  /// Remueve una misión completada de la sesión
  Future<void> removeCompletedMission(String sessionId, String missionId) async {
    final session = await getSessionById(sessionId);
    if (session == null) return;
    
    final currentIds = jsonDecode(session.completedMissionIds) as List;
    currentIds.remove(missionId);
    
    await (update(daySessions)..where((s) => s.id.equals(sessionId)))
      .write(DaySessionsCompanion(
        completedMissionIds: Value(jsonEncode(currentIds)),
      ));
  }

  /// Finaliza una sesión
  Future<void> finalizeSession(String sessionId) {
    return (update(daySessions)..where((s) => s.id.equals(sessionId)))
      .write(DaySessionsCompanion(
        isFinalized: const Value(true),
        finalizedAt: Value(DateTime.now()),
      ));
  }

  // ========== HELPERS ==========

  List<String> parseCompletedMissionIds(String json) {
    final decoded = jsonDecode(json) as List;
    return decoded.cast<String>();
  }
}
```

### 5.4 DayFeedback DAO

Crear `lib/features/missions/data/datasources/local/drift/daos/day_feedback_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import 'dart:convert';

part 'day_feedback_dao.g.dart';

@DriftAccessor(tables: [DayFeedbacks])
class DayFeedbackDao extends DatabaseAccessor<AppDatabase> with _$DayFeedbackDaoMixin {
  DayFeedbackDao(AppDatabase db) : super(db);

  // ========== QUERIES ==========

  /// Obtiene feedback por session ID
  Future<DayFeedbackData?> getFeedbackBySessionId(String sessionId) {
    return (select(dayFeedbacks)..where((f) => f.sessionId.equals(sessionId)))
      .getSingleOrNull();
  }

  /// Obtiene los últimos N feedbacks
  Future<List<DayFeedbackData>> getRecentFeedbacks({int limit = 7}) {
    return (select(dayFeedbacks)
      ..orderBy([(f) => OrderingTerm.desc(f.createdAt)])
      ..limit(limit)
    ).get();
  }

  /// Obtiene todos los feedbacks
  Future<List<DayFeedbackData>> getAllFeedbacks() {
    return (select(dayFeedbacks)
      ..orderBy([(f) => OrderingTerm.desc(f.createdAt)])
    ).get();
  }

  // ========== INSERTS ==========

  Future<int> saveFeedback(DayFeedbacksCompanion feedback) {
    return into(dayFeedbacks).insert(feedback);
  }

  // ========== UPDATES ==========

  Future<bool> updateFeedback(DayFeedbackData feedback) {
    return update(dayFeedbacks).replace(feedback);
  }

  // ========== DELETES ==========

  Future<int> deleteFeedback(int id) {
    return (delete(dayFeedbacks)..where((f) => f.id.equals(id))).go();
  }

  // ========== ANÁLISIS ==========

  /// Calcula el promedio de energía de los últimos N días
  Future<double> getAverageEnergy({int days = 7}) async {
    final feedbacks = await getRecentFeedbacks(limit: days);
    if (feedbacks.isEmpty) return 3.0;
    
    final sum = feedbacks.fold<int>(0, (sum, f) => sum + f.energy);
    return sum / feedbacks.length;
  }

  /// Cuenta feedbacks por nivel de dificultad
  Future<Map<String, int>> countByDifficulty() async {
    final feedbacks = await getAllFeedbacks();
    final counts = <String, int>{};
    
    for (var feedback in feedbacks) {
      counts[feedback.difficulty] = (counts[feedback.difficulty] ?? 0) + 1;
    }
    
    return counts;
  }
}
```

---

## 🔨 PASO 6: Generar Código

```powershell
cd d:\D0\d0

# Generar código de Drift (tablas, DAOs, database)
flutter pub run build_runner build --delete-conflicting-outputs

# Para desarrollo continuo (regenera automáticamente):
# flutter pub run build_runner watch
```

**Importante:** Este comando generará:
- `database.g.dart`
- `mission_dao.g.dart`
- `user_stats_dao.g.dart`
- `day_session_dao.g.dart`
- `day_feedback_dao.g.dart`

---

## 📝 CONTINÚA EN PARTE 2...

¿Quieres que continúe con:
1. **DataSources** que usan los DAOs
2. **Actualización de Repository Implementations**
3. **Integración con main.dart**
4. **Testing**
5. **Migración desde dummy datasources**

