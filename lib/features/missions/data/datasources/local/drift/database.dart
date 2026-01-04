import 'package:drift/drift.dart';
import 'tables.dart';
import 'connection/connection.dart' as impl;

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Missions,
    UserStats,
    DaySessions,
    DayFeedbacks,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Singleton instance
  static AppDatabase? _instance;

  // Factory constructor que retorna siempre la misma instancia
  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  // Constructor privado real
  AppDatabase._internal() : super(_openConnection());
  
  // Constructor para testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        print('[AppDatabase] ✅ Base de datos creada (v$schemaVersion)');
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        if (details.wasCreated) {
          print('[AppDatabase] 🎉 Primera vez abriendo la BD');
        }
      },
    );
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(dayFeedbacks).go();
      await delete(daySessions).go();
      await delete(missions).go();
      await delete(userStats).go();
    });
    print('[AppDatabase] 🧹 Toda la data fue eliminada');
  }

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

QueryExecutor _openConnection() {
  return impl.connect();
}

class DatabaseProvider {
  static AppDatabase? _instance;
  
  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }
  
  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
