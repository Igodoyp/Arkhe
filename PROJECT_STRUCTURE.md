# 🌳 PROJECT STRUCTURE - BONFIRE IMPLEMENTATION

## 📂 Estructura de Archivos Completa

```
d0/
├── lib/
│   └── features/
│       └── missions/
│           ├── domain/
│           │   ├── entities/
│           │   │   ├── mission_entity.dart
│           │   │   ├── user_stats_entity.dart
│           │   │   ├── stat_type.dart
│           │   │   ├── day_session_entity.dart
│           │   │   └── day_feedback_entity.dart ✨ NUEVO
│           │   ├── repositories/
│           │   │   ├── mission_repository.dart
│           │   │   ├── user_stats_repository.dart
│           │   │   ├── day_session_repository.dart
│           │   │   └── day_feedback_repository.dart ✨ NUEVO
│           │   └── usecases/
│           │       ├── user_stats_usecase.dart
│           │       ├── day_session_usecase.dart
│           │       └── day_feedback_usecase.dart ✨ NUEVO
│           ├── data/
│           │   ├── models/
│           │   │   ├── mission_model.dart
│           │   │   ├── user_stats_model.dart
│           │   │   ├── day_session_model.dart
│           │   │   └── day_feedback_model.dart ✨ NUEVO
│           │   ├── datasources/
│           │   │   ├── mission_datasource.dart
│           │   │   ├── user_stats_datasource.dart
│           │   │   ├── day_session_datasource.dart
│           │   │   └── day_feedback_datasource.dart ✨ NUEVO
│           │   └── repositories/
│           │       ├── mission_repository_impl.dart
│           │       ├── user_stats_repository_impl.dart
│           │       ├── day_session_repository_impl.dart
│           │       └── day_feedback_repository_impl.dart ✨ NUEVO
│           └── presentation/
│               ├── controllers/
│               │   ├── mission_controller.dart
│               │   ├── user_stats_controller.dart
│               │   ├── day_session_controller.dart 🔧 MODIFICADO
│               │   └── bonfire_controller.dart ✨ NUEVO
│               ├── pages/
│               │   ├── mission_page.dart 🔧 MODIFICADO
│               │   ├── user_stats_page.dart
│               │   └── bonfire_page.dart ✨ NUEVO
│               └── widgets/
│                   └── stats_radar.dart
├── ARCHITECTURE_REVIEW.md
├── DAY_SESSION_FLOW.md
├── BONFIRE_SYSTEM.md ✨ NUEVO
├── BONFIRE_QUICKSTART.md ✨ NUEVO
├── IMPLEMENTATION_SUMMARY.md ✨ NUEVO
├── README.md 🔧 MODIFICADO
├── .gitignore
└── pubspec.yaml
```

## 📊 Leyenda

- ✨ **NUEVO**: Archivo creado en esta implementación
- 🔧 **MODIFICADO**: Archivo existente que fue actualizado
- (sin icono): Archivos existentes sin cambios

## 📈 Estadísticas

### Archivos Nuevos (11 total)

#### Código (8 archivos)
1. `lib/features/missions/domain/entities/day_feedback_entity.dart`
2. `lib/features/missions/domain/repositories/day_feedback_repository.dart`
3. `lib/features/missions/domain/usecases/day_feedback_usecase.dart`
4. `lib/features/missions/data/models/day_feedback_model.dart`
5. `lib/features/missions/data/datasources/day_feedback_datasource.dart`
6. `lib/features/missions/data/repositories/day_feedback_repository_impl.dart`
7. `lib/features/missions/presentation/controllers/bonfire_controller.dart`
8. `lib/features/missions/presentation/pages/bonfire_page.dart`

#### Documentación (3 archivos)
9. `BONFIRE_SYSTEM.md`
10. `BONFIRE_QUICKSTART.md`
11. `IMPLEMENTATION_SUMMARY.md`

### Archivos Modificados (3 total)

1. `lib/features/missions/presentation/controllers/day_session_controller.dart`
   - Agregado: método `getBonfireData()`
   - Agregado: clase `BonfireData`

2. `lib/features/missions/presentation/pages/mission_page.dart`
   - Modificado: `_showEndDaySummary()` para navegar a Bonfire
   - Agregados: imports de Bonfire y Provider

3. `README.md`
   - Actualizado: descripción completa del proyecto
   - Agregado: sección de Bonfire System
   - Agregado: roadmap y features

## 🎯 Componentes por Capa

### Domain Layer (Lógica de Negocio)
```
domain/
├── entities/
│   └── day_feedback_entity.dart (181 líneas)
│       ├── class DayFeedback
│       ├── enum DifficultyLevel
│       └── extension DifficultyLevelExtension
├── repositories/
│   └── day_feedback_repository.dart (23 líneas)
│       └── abstract class DayFeedbackRepository
└── usecases/
    └── day_feedback_usecase.dart (350 líneas)
        ├── SaveFeedbackUseCase
        ├── GetFeedbackHistoryUseCase
        ├── AnalyzeFeedbackTrendsUseCase
        ├── GenerateAIPromptUseCase
        └── class FeedbackAnalysis
```

### Data Layer (Persistencia)
```
data/
├── models/
│   └── day_feedback_model.dart (110 líneas)
│       └── class DayFeedbackModel extends DayFeedback
├── datasources/
│   └── day_feedback_datasource.dart (150 líneas)
│       ├── abstract class DayFeedbackDataSource
│       └── class DayFeedbackDataSourceDummy
└── repositories/
    └── day_feedback_repository_impl.dart (200 líneas)
        └── class DayFeedbackRepositoryImpl implements DayFeedbackRepository
```

### Presentation Layer (UI y Estado)
```
presentation/
├── controllers/
│   └── bonfire_controller.dart (250 líneas)
│       ├── enum BonfireState
│       └── class BonfireController extends ChangeNotifier
└── pages/
    └── bonfire_page.dart (550 líneas)
        ├── class BonfirePage extends StatefulWidget
        └── class _BonfirePageState extends State<BonfirePage>
```

## 🔗 Dependencias entre Archivos

### Flujo de Datos (Bonfire)

```
[BonfirePage] (UI)
       ↓
[BonfireController] (Estado)
       ↓
[SaveFeedbackUseCase] ────────┐
[GetFeedbackHistoryUseCase] ──┤
[AnalyzeFeedbackTrendsUseCase]┼→ [DayFeedbackRepository] (Interfaz)
[GenerateAIPromptUseCase] ────┘          ↓
                           [DayFeedbackRepositoryImpl] (Implementación)
                                      ↓
                           [DayFeedbackDataSource] (Interfaz)
                                      ↓
                           [DayFeedbackDataSourceDummy] (Persistencia)
                                      ↓
                                  [Storage]
                            (Map en memoria - dummy)
```

### Flujo de Navegación

```
[MissionsPage]
      ↓ (Usuario presiona "FINALIZAR DÍA")
[DaySessionController.endDay()]
      ↓ (Calcula stats)
[DaySessionController.getBonfireData()]
      ↓ (Obtiene datos para Bonfire)
[Navigator.push]
      ↓
[BonfirePage]
      ↓ (Usuario proporciona feedback)
[BonfireController.saveFeedback()]
      ↓
[Success Screen]
      ↓ (Usuario presiona "VOLVER AL INICIO")
[Navigator.popUntil]
      ↓
[MissionsPage] (De vuelta al inicio)
```

## 📦 Imports Chain

### BonfirePage imports:
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/day_feedback_entity.dart';
import '../../domain/entities/mission_entity.dart';
import '../controllers/bonfire_controller.dart';
```

### BonfireController imports:
```dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/day_feedback_entity.dart';
import '../../domain/usecases/day_feedback_usecase.dart';
```

### day_feedback_usecase imports:
```dart
import '../entities/day_feedback_entity.dart';
import '../repositories/day_feedback_repository.dart';
```

### day_feedback_repository_impl imports:
```dart
import '../../domain/entities/day_feedback_entity.dart';
import '../../domain/repositories/day_feedback_repository.dart';
import '../datasources/day_feedback_datasource.dart';
import '../models/day_feedback_model.dart';
```

### day_feedback_model imports:
```dart
import '../../domain/entities/day_feedback_entity.dart';
```

## 🎨 UI Component Tree (BonfirePage)

```
Scaffold
└── SafeArea
    └── SingleChildScrollView
        └── Column
            ├── _buildHeader()
            │   ├── Container (Icono de fuego)
            │   ├── Text "BONFIRE"
            │   └── Text "Descansa..."
            ├── _buildDaySummary()
            │   └── Container
            │       ├── Text "Resumen del Día"
            │       ├── _summaryRow (Misiones)
            │       └── _summaryRow (Stats)
            ├── _buildDifficultySelector()
            │   └── Column
            │       └── 4x InkWell (DifficultyLevel options)
            ├── _buildEnergySelector()
            │   └── Row
            │       └── 5x GestureDetector (círculos 1-5)
            ├── _buildMissionFeedback()
            │   └── List of Containers
            │       └── Row (Mission + emojis)
            ├── _buildNotesField()
            │   └── TextField
            ├── _buildAnalysisCard() [Condicional]
            │   └── Container (Recomendaciones)
            ├── _buildSaveButton()
            │   └── ElevatedButton
            └── _buildCancelButton()
                └── TextButton
```

## 🧮 Complejidad por Archivo

| Archivo | Líneas | Clases | Métodos | Enums | Complejidad |
|---------|--------|--------|---------|-------|-------------|
| day_feedback_entity.dart | 181 | 1 | 8 | 1 | Media |
| day_feedback_repository.dart | 23 | 1 | 6 | 0 | Baja |
| day_feedback_usecase.dart | 350 | 5 | 15 | 0 | Alta |
| day_feedback_model.dart | 110 | 1 | 5 | 0 | Media |
| day_feedback_datasource.dart | 150 | 2 | 8 | 0 | Media |
| day_feedback_repository_impl.dart | 200 | 1 | 8 | 0 | Alta |
| bonfire_controller.dart | 250 | 1 | 15 | 1 | Alta |
| bonfire_page.dart | 550 | 2 | 12 | 0 | Alta |

## 🔍 Puntos de Entrada

### Para ejecutar Bonfire:
1. **Entry Point**: `lib/main.dart` (no modificado)
2. **Initial Route**: `MissionsPage`
3. **Trigger**: Usuario presiona "FINALIZAR DÍA"
4. **Navigation**: `_showEndDaySummary()` en `mission_page.dart`
5. **Destination**: `BonfirePage` con `BonfireController`

### Para acceder al feedback guardado:
```dart
// Desde cualquier lugar del código:
final feedbackDataSource = DayFeedbackDataSourceDummy();
final feedbackRepository = DayFeedbackRepositoryImpl(
  dataSource: feedbackDataSource,
);
final historyUseCase = GetFeedbackHistoryUseCase(feedbackRepository);
final allFeedbacks = await historyUseCase.getAllFeedbacks();
```

## 📚 Documentación Asociada

| Archivo | Propósito | Líneas |
|---------|-----------|--------|
| BONFIRE_SYSTEM.md | Doc técnica completa | ~450 |
| BONFIRE_QUICKSTART.md | Guía de testing | ~250 |
| IMPLEMENTATION_SUMMARY.md | Resumen ejecutivo | ~350 |
| README.md | Overview del proyecto | ~180 |

---

**Total de archivos en el proyecto**: ~30 archivos de código  
**Archivos afectados en Bonfire**: 14 archivos  
**Porcentaje de cambio**: ~47% del proyecto

**Estructura completa y organizada siguiendo Clean Architecture ✅**
