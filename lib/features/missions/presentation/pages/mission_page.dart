import 'package:flutter/material.dart';
import '../controllers/mission_controller.dart';
import '../../data/datasources/mission_datasource.dart';
import '../../data/repositories/mission_repository_impl.dart';
import 'user_stats_page.dart'; // Asegúrate de importar la página de stats

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  // En una app real, usarías Provider/Riverpod/GetIt para obtener esto
  late MissionController _controller;

  @override
  void initState() {
    super.initState();
    // Inyección de Dependencias Manual (para el ejemplo)
    // 1. Instanciamos el DataSource Dummy
    final dataSource = MissionGeminiDummyDataSourceImpl();
    // 2. Inyectamos al Repo
    final repository = MissionRepositoryImpl(remoteDataSource: dataSource);
    // 3. Inyectamos al Controller
    _controller = MissionController(repository: repository);
    
    // Cargar datos
    _controller.loadMissions();
    
    // Escuchar cambios (simple setState para el ejemplo)
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
          'MISIONES DIARIAS',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            tooltip: 'Ver Stats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
            },
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : ListView.builder(
              itemCount: _controller.missions.length,
              itemBuilder: (context, index) {
                final mission = _controller.missions[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(4, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          left: BorderSide(color: Colors.red.shade700, width: 7),
                          bottom: const BorderSide(color: Colors.black, width: 3),
                          right: const BorderSide(color: Colors.black, width: 3),
                          top: const BorderSide(color: Colors.black, width: 3),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        onTap: () {
                          _controller.toggleMission(index);
                        },
                        leading: CircleAvatar(
                          backgroundColor: mission.isCompleted ? Colors.redAccent : Colors.black,
                          radius: 26,
                          child: Icon(
                            mission.isCompleted ? Icons.check : Icons.flash_on,
                            color: Colors.white,
                            size: 28,
                            shadows: const [Shadow(color: Colors.red, blurRadius: 6)],
                          ),
                        ),
                        title: Text(
                          mission.title.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.black,
                            letterSpacing: 1.2,
                            shadows: [Shadow(color: Colors.red, blurRadius: 2, offset: Offset(1, 1))],
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mission.description,
                                style: const TextStyle(
                                  color: Color(0xFF232323),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade700,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: Text(
                                  mission.type.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Transform.rotate(
                          angle: -0.1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade700,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              '+${mission.xpReward} XP',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                letterSpacing: 1.2,
                                shadows: [Shadow(color: Colors.white, blurRadius: 2)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}