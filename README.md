# 🎮 RPG Daily Missions - D0

Un sistema de misiones diarias con mecánicas RPG y adaptación inteligente basada en feedback del usuario.

## 🌟 Features

### ✅ Implementado

- **Sistema de Misiones Diarias**: Marca misiones como completadas durante el día
- **Stats RPG**: 6 estadísticas (Fuerza, Agilidad, Inteligencia, Carisma, Sabiduría, Vitalidad)
- **Radar Chart**: Visualización hermosa de stats en formato radar
- **Day Session**: Las stats solo se actualizan al finalizar el día
- **Zero Missions Support**: Finaliza el día incluso sin completar misiones ⭐ NUEVO
- **🔥 Bonfire System**: Pantalla de feedback post-día inspirada en Dark Souls
  - Selección de dificultad percibida
  - Nivel de energía del usuario
  - Marcado de misiones fáciles/difíciles
  - Notas personalizadas
  - Análisis de tendencias
  - Generación de prompts para IA
  - Multi-day testing flow (simula múltiples días sin reiniciar)

### 🚧 En Desarrollo

- **Drift Database**: Implementación de persistencia con SQLite + Drift 🔄 EN PROGRESO
  - Guías completas creadas (ver documentación)
  - Type-safe queries
  - Migraciones robustas
  - Testing con in-memory database
- Integración con Gemini AI para misiones generadas dinámicamente
- Tests unitarios y de widgets
- Visualización de tendencias (gráficas)

## 🏗️ Arquitectura

**Clean Architecture** en 3 capas:

```
presentation/ (UI, Controllers)
    ↓↑
domain/ (Entities, Use Cases, Repositories)
    ↓↑
data/ (Models, DataSources, Repository Implementations)
```

**Estado**: Provider + ChangeNotifier

### Módulos Principales

1. **Missions**: CRUD de misiones diarias
2. **User Stats**: Gestión de estadísticas del usuario
3. **Day Session**: Sesión del día y cálculo de stats ganadas
4. **Bonfire**: Sistema de feedback adaptativo

## 📁 Estructura del Proyecto

```
lib/features/missions/
├── domain/
│   ├── entities/
│   │   ├── mission_entity.dart
│   │   ├── user_stats_entity.dart
│   │   ├── day_session_entity.dart
│   │   └── day_feedback_entity.dart
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
└── presentation/
    ├── controllers/
    │   ├── mission_controller.dart
    │   ├── user_stats_controller.dart
    │   ├── day_session_controller.dart
    │   └── bonfire_controller.dart
    ├── pages/
    │   ├── mission_page.dart
    │   ├── user_stats_page.dart
    │   └── bonfire_page.dart
    └── widgets/
```

## 🚀 Quick Start

### Requisitos

- Flutter SDK (3.0+)
- Dart (3.0+)

### Instalación

```powershell
cd d:\D0\d0
flutter pub get
flutter run
```

### Uso Básico

1. **Completar Misiones**: Marca checkboxes de las misiones durante el día
2. **Finalizar Día**: Presiona "FINALIZAR DÍA" para aplicar stats
3. **Bonfire**: Proporciona feedback sobre tu experiencia
4. **Ver Stats**: Navega al radar chart para ver tu progreso

## 📊 Bonfire System

El **Bonfire** es un sistema de feedback adaptativo que:

1. Recopila feedback del usuario después de cada día
2. Analiza tendencias (energía, dificultad, misiones problemáticas)
3. Calcula ajustes de dificultad basados en el historial
4. Genera prompts dinámicos para IA (Gemini)
5. Adapta futuras misiones al estado del usuario

### Lógica de Adaptación

| Feedback | Multiplicador | Acción |
|----------|---------------|--------|
| Muy Fácil | 1.2x | Aumentar dificultad 20% |
| Perfecto | 1.0x | Mantener igual |
| Desafiante | 0.9x | Reducir 10% |
| Muy Difícil | 0.7x | Reducir 30% |

**+ Ajuste por Energía**: Si energía promedio < 3, se reduce 10% adicional.

Para más detalles, consulta: [`BONFIRE_SYSTEM.md`](BONFIRE_SYSTEM.md)

## 📚 Documentación

### Arquitectura y Flujos
- **[ARCHITECTURE_REVIEW.md](ARCHITECTURE_REVIEW.md)**: Revisión completa de la arquitectura
- **[DAY_SESSION_FLOW.md](DAY_SESSION_FLOW.md)**: Flujo detallado de la sesión del día
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)**: Estructura detallada del proyecto

### Sistema Bonfire
- **[BONFIRE_SYSTEM.md](BONFIRE_SYSTEM.md)**: Sistema de feedback adaptativo
- **[BONFIRE_QUICKSTART.md](BONFIRE_QUICKSTART.md)**: Guía rápida para probar el Bonfire
- **[MULTI_DAY_TESTING.md](MULTI_DAY_TESTING.md)**: Flujo de testing multi-día

### Features y Testing
- **[ZERO_MISSIONS_FEATURE.md](ZERO_MISSIONS_FEATURE.md)**: Feature de finalizar día sin misiones
- **[TEST_ZERO_MISSIONS.md](TEST_ZERO_MISSIONS.md)**: Guía rápida de testing

### Base de Datos (Drift)
- **[DATABASE_STRATEGY.md](DATABASE_STRATEGY.md)**: Comparación de frameworks de BD ⭐ NUEVO
- **[DRIFT_QUICK_START.md](DRIFT_QUICK_START.md)**: Setup de Drift en 30 minutos ⭐ NUEVO
- **[DRIFT_IMPLEMENTATION_GUIDE_PART1.md](DRIFT_IMPLEMENTATION_GUIDE_PART1.md)**: Tablas, Database, DAOs ⭐ NUEVO
- **[DRIFT_IMPLEMENTATION_GUIDE_PART2.md](DRIFT_IMPLEMENTATION_GUIDE_PART2.md)**: DataSources, Repositories ⭐ NUEVO

### Historial
- **[CHANGELOG.md](CHANGELOG.md)**: Historial de cambios
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)**: Resumen ejecutivo
- **[VERIFICATION_CHECKLIST.md](VERIFICATION_CHECKLIST.md)**: Checklist de verificación

## 🧪 Testing

### Ejecutar Tests (cuando estén implementados)

```powershell
flutter test
flutter test --coverage
```

### Verificar Errores

```powershell
flutter analyze
```

## 🎨 Tech Stack

- **Framework**: Flutter 3.x
- **Lenguaje**: Dart 3.x
- **Estado**: Provider
- **Arquitectura**: Clean Architecture
- **Charts**: fl_chart
- **IA (futuro)**: Gemini API

## 🛣️ Roadmap

### v1.0 (Current) ✅
- [x] Misiones diarias con stats
- [x] Day Session
- [x] Bonfire feedback system
- [x] Clean architecture
- [x] Documentación completa

### v1.1 (Next)
- [ ] Integración con Gemini AI
- [ ] Persistencia real (SQLite)
- [ ] Tests completos
- [ ] Visualización de tendencias

### v2.0 (Future)
- [ ] Modo multiplayer
- [ ] Logros y badges
- [ ] Sistema de niveles
- [ ] Misiones épicas (multi-día)
- [ ] Exportar/importar datos

## 🤝 Contributing

Este es un proyecto educativo/personal. Si tienes sugerencias:

1. Revisa la documentación existente
2. Abre un issue con tu propuesta
3. Sigue la arquitectura establecida

## 📄 License

Este proyecto es de código abierto bajo licencia MIT.

## 🙏 Créditos

- **Inspiración**: Dark Souls (Bonfire system)
- **Teoría**: Flow State (Mihaly Csikszentmihalyi)
- **Arquitectura**: Clean Architecture (Robert C. Martin)

---

**Construido con ❤️ y mucho café ☕**

Para empezar rápidamente, ejecuta:
```powershell
flutter run
```

¡Y disfruta mejorando tus stats diarios! 🎯🔥
