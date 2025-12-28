# 🚀 DRIFT - QUICK START GUIDE

## ⏱️ Setup en 30 Minutos

### Prerequisitos
- ✅ Proyecto Flutter D0 funcionando
- ✅ VS Code o Android Studio
- ✅ Terminal PowerShell

---

## 📦 PASO 1: Instalación (5 min)

```powershell
cd d:\D0\d0

# Agregar dependencias
flutter pub add drift sqlite3_flutter_libs path_provider path
flutter pub add --dev drift_dev build_runner

# Verificar que se agregaron
flutter pub get
```

**Verificar en `pubspec.yaml`:**
```yaml
dependencies:
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.1
  path: ^1.8.3

dev_dependencies:
  drift_dev: ^2.14.1
  build_runner: ^2.4.7
```

---

## 📁 PASO 2: Crear Estructura (5 min)

### Crear carpetas:

```powershell
# Crear estructura de Drift
New-Item -ItemType Directory -Path "lib\features\missions\data\datasources\local\drift\daos" -Force
```

### Archivos a crear (siguiente paso):

```
lib/features/missions/data/datasources/local/drift/
  ├── tables.dart          ← Definiciones de tablas
  ├── database.dart        ← Base de datos principal
  └── daos/
      ├── mission_dao.dart
      ├── user_stats_dao.dart
      ├── day_session_dao.dart
      └── day_feedback_dao.dart
```

---

## 💻 PASO 3: Copiar Código Base (10 min)

### 3.1 Crear `tables.dart`

**Ruta:** `lib/features/missions/data/datasources/local/drift/tables.dart`

<details>
<summary>📄 Ver código completo de tables.dart</summary>

```dart
import 'package:drift/drift.dart';

@DataClassName('MissionData')
class Missions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text()();
  TextColumn get type => text()();
  IntColumn get xpReward => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserStatsData')
class UserStats extends Table {
  TextColumn get id => text()();
  TextColumn get statsJson => text()();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DaySessionData')
class DaySessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get completedMissionIds => text().withDefault(const Constant('[]'))();
  BoolColumn get isFinalized => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get finalizedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DayFeedbackData')
class DayFeedbacks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text().references(DaySessions, #id)();
  TextColumn get difficulty => text()();
  IntColumn get energy => integer()();
  TextColumn get struggledMissionIds => text().withDefault(const Constant('[]'))();
  TextColumn get easyMissionIds => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

</details>

### 3.2 Crear `database.dart`

**Ruta:** `lib/features/missions/data/datasources/local/drift/database.dart`

<details>
<summary>📄 Ver código completo de database.dart</summary>

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

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
  AppDatabase() : super(_openConnection());
  
  // Constructor para testing
  AppDatabase.forTesting(QueryExecutor e) : super(e);

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

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'd0_database.sqlite'));
    
    print('[AppDatabase] 📂 Database path: ${file.path}');
    
    return NativeDatabase.createInBackground(file);
  });
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
```

</details>

---

## 🔨 PASO 4: Generar Código (2 min)

```powershell
cd d:\D0\d0

# Generar código de Drift
flutter pub run build_runner build --delete-conflicting-outputs
```

**Output esperado:**
```
[INFO] Generating build script completed, took 441ms
[INFO] Reading cached asset graph completed, took 89ms
[INFO] Checking for updates since last build completed, took 634ms
[INFO] Running build completed, took 3.4s
[INFO] Caching finalized dependency graph completed, took 44ms
[INFO] Succeeded after 3.5s with 2 outputs
```

**Archivos generados:**
- ✅ `database.g.dart`

---

## 🧪 PASO 5: Probar que Funciona (5 min)

### Crear test rápido

**Ruta:** `test/drift_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:d0/features/missions/data/datasources/local/drift/database.dart';

void main() {
  test('Database should create tables', () async {
    // Crear BD en memoria
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    
    // Intentar insertar una misión
    await db.into(db.missions).insert(MissionsCompanion.insert(
      id: 'test_mission_1',
      title: 'Test Mission',
      description: 'This is a test',
      type: 'physical',
      xpReward: 50,
    ));
    
    // Leer misiones
    final missions = await db.select(db.missions).get();
    
    // Verificar
    expect(missions.length, 1);
    expect(missions.first.title, 'Test Mission');
    
    // Limpiar
    await db.close();
  });
}
```

### Ejecutar test

```powershell
flutter test test/drift_test.dart
```

**Output esperado:**
```
00:01 +1: All tests passed!
```

---

## ✅ VERIFICACIÓN

Si llegaste aquí sin errores, tienes:

- ✅ Drift instalado
- ✅ Tablas definidas
- ✅ Database funcionando
- ✅ Código generado
- ✅ Test pasando

---

## 🎯 PRÓXIMOS PASOS

### Opción A: Implementar DAOs (Recomendado)
1. Copia los DAOs de `DRIFT_IMPLEMENTATION_GUIDE_PART1.md`
2. Genera código: `flutter pub run build_runner build`
3. Crea DataSources con los DAOs
4. Actualiza Repositories

### Opción B: Implementar 1 Feature Completo
1. Empieza con **Mission**
2. Crea solo `mission_dao.dart`
3. Crea `drift_mission_datasource.dart`
4. Actualiza `mission_repository_impl.dart`
5. Prueba en la UI
6. Repite para otros features

### Opción C: Migración Gradual
1. Mantén Dummy DataSources
2. Agrega Drift en paralelo
3. Usa feature flag: `USE_DRIFT = true/false`
4. Prueba ambos
5. Migra cuando estés seguro

---

## 🐛 Troubleshooting

### Error: "part 'database.g.dart' doesn't exist"
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: "No file 'part ...' could be found"
- Verifica que el nombre del archivo coincida
- `database.dart` debe tener `part 'database.g.dart';`

### Error de importación
```dart
// Asegúrate de importar correctamente:
import 'package:drift/drift.dart';
import 'package:drift/native.dart';  // Para testing
```

### Database no se crea
- Verifica que `main.dart` inicialice la BD
- Revisa logs: busca "📂 Database path:"

### Build runner se queda en "Waiting..."
```powershell
# Mata el proceso y limpia
flutter pub run build_runner clean
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📚 Documentación Completa

1. **DRIFT_IMPLEMENTATION_GUIDE_PART1.md** - Tablas, Database, DAOs
2. **DRIFT_IMPLEMENTATION_GUIDE_PART2.md** - DataSources, Repositories, Integration
3. **DATABASE_STRATEGY.md** - Comparación de frameworks

---

## 🎉 ¡ÉXITO!

Si todo funcionó:
- 🎯 Tienes Drift configurado
- 🗄️ Base de datos SQLite funcionando
- 📊 Type-safe queries listas
- 🚀 Listo para implementar features

---

## 💬 ¿Necesitas Ayuda?

**Preguntas comunes:**
1. "¿Cómo creo el primer DAO?" → Ver PART1, Paso 5
2. "¿Cómo integro con mi Repository?" → Ver PART2, Paso 8
3. "¿Cómo migro los datos dummy?" → Ver PART2, Paso 11
4. "¿Cómo hago testing?" → Ver PART2, Paso 10

**Siguiente paso recomendado:**
```powershell
# Leer la guía completa
code DRIFT_IMPLEMENTATION_GUIDE_PART1.md
code DRIFT_IMPLEMENTATION_GUIDE_PART2.md
```

🔥 **¡Drift está listo para tu proyecto!** 🔥
