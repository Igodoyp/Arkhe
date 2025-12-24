import 'package:flutter/material.dart';
import '../widgets/stats_radar.dart';
import '../../domain/entities/stat_type.dart';
import '../controllers/user_stats_controller.dart';
import '../../data/datasources/user_stats_datasource.dart';
import '../../data/repositories/user_stats_repository_impl.dart';
import '../../domain/usecases/user_stats_usecase.dart';

//TODO: añadir doble capa  en el rad chart con sombra representando los stats que tendria si terminara el dia hoy

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late UserStatsController _controller;

  @override
  void initState() {
    super.initState();
    // Inyección de Dependencias Manual
    // 1. Instanciamos el DataSource Dummy
    final dataSource = StatsDummyDataSourceImpl();
    // 2. Inyectamos al Repo
    final repository = UserStatsRepositoryImpl(remoteDataSource: dataSource);
    // 3. Instanciamos los UseCases
    final getUserStatsUseCase = GetUserStatsUseCase(repository);
    final updateUserStatsUseCase = UpdateUserStatsUseCase(repository);
    final incrementStatUseCase = IncrementStatUseCase(repository);
    // 4. Inyectamos al Controller
    _controller = UserStatsController(
      getUserStatsUseCase: getUserStatsUseCase,
      updateUserStatsUseCase: updateUserStatsUseCase,
      incrementStatUseCase: incrementStatUseCase,
    );

    // Cargar datos
    _controller.loadUserStats();

    // Escuchar cambios
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        title: const Text(
          'TUS STATS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.5,
            shadows: [Shadow(color: Colors.red, blurRadius: 4, offset: Offset(1, 2))],
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.redAccent.withOpacity(0.5),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Volver a Misiones',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Center(              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'PROGRESO DE ATRIBUTOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 1.5,
                        shadows: [Shadow(color: Colors.red, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 300,
                      child: StatsRadarChart(stats: _controller.statsMap),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade700, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(4, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: StatType.values.map((type) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    type.name.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: Text(
                                  '${_controller.statsMap[type]?.toStringAsFixed(0) ?? '0'} / 100',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
