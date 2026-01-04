import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORTACIONES DE TU ARQUITECTURA ---
// (Asegúrate de que las rutas coincidan con tu estructura de carpetas)

// 1. Capa de Infraestructura (Data)
import 'features/missions/data/repositories/mission_repository_impl.dart';
import 'features/missions/data/datasources/local/drift/database.dart';
import 'features/missions/data/datasources/local/drift/mission_local_datasource_drift.dart';

// 2. Capa de Dominio (UseCases)
import 'features/missions/domain/usecases/get_missions_usecase.dart';
import 'features/missions/domain/usecases/toggle_mission_usecase.dart';

// 3. Time Provider
import 'core/time/time_provider.dart';
import 'core/time/real_time_provider.dart';

// 4. Presentación (Providers)

// 3. Capa de Presentación (Provider y UI)
import 'features/missions/presentation/providers/mission_provider.dart';
import 'features/missions/presentation/pages/splash_page.dart';

void main() {
  // Asegura que el motor de Flutter esté listo antes de cualquier lógica
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------
  // ZONA DE ENSAMBLAJE (DEPENDENCY INJECTION)
  // Aquí conectamos las piezas. Si cambiamos una pieza, solo tocamos aquí.
  // ---------------------------------------------------------

  // A. Nivel Bajo: Creamos la base de datos y datasources
  final database = AppDatabase();
  final missionLocalDataSource = MissionLocalDataSourceDrift(database: database);
  final timeProvider = RealTimeProvider();
  
  // B. Creamos el Repositorio (El almacén de datos)
  final missionRepository = MissionRepositoryImpl(
    localDataSource: missionLocalDataSource,
    timeProvider: timeProvider,
  );

  // C. Nivel Medio: Creamos los Casos de Uso (Las órdenes de trabajo)
  // Les "inyectamos" el repositorio que acabamos de crear.
  final getMissionsUseCase = GetMissionsUseCase(missionRepository);
  final toggleMissionUseCase = ToggleMissionUseCase(missionRepository);

  // ---------------------------------------------------------
  // INICIO DE LA APLICACIÓN
  // ---------------------------------------------------------
  runApp(
    // MultiProvider permite tener varios "departamentos" (Providers) activos.
    MultiProvider(
      providers: [
        // D. Nivel Alto: Creamos el Provider (La sala de control)
        // Le inyectamos los UseCases.
        ChangeNotifierProvider(
          create: (_) => MissionProvider(
            getMissionsUseCase: getMissionsUseCase,
            toggleMissionUseCase: toggleMissionUseCase,
          )..loadMissions(), // <-- TRUCO: Cargamos los datos apenas nace la app
        ),
      ],
      child: const RPGApp(),
    ),
  );
}

class RPGApp extends StatelessWidget {
  const RPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPG Life Tracker',
      debugShowCheckedModeBanner: false, // Quitamos la etiqueta "Debug" fea
      
      // CONFIGURACIÓN VISUAL (THEMING)
      // Un tema oscuro queda mejor para apps de gaming/RPG
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C), // Gris muy oscuro
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D2D44),
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: const ColorScheme.dark().copyWith(
          secondary: Colors.amberAccent, // Color de acento para botones/toggles
        ),
      ),
      
      // PUNTO DE ENTRADA VISUAL
      // Comienza con SplashPage que verifica onboarding
      home: const SplashPage(),
    );
  }
}