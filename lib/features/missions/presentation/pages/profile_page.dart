// presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/audio/audio_service.dart';
import '../../domain/entities/stat_type.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/repositories/mission_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../../domain/services/xp_level_calculator.dart';
import '../widgets/stats_radar.dart';

/// Página de perfil del usuario
/// 
/// Muestra:
/// - XP total y nivel calculado (no hardcoded)
/// - Stats en radar chart + lista
/// - Datos del onboarding (nombre, ideal self, áreas de enfoque)
class ProfilePage extends StatefulWidget {
  final UserProfileRepository userProfileRepository;
  final UserStatsRepository userStatsRepository;
  final MissionRepository missionRepository;

  const ProfilePage({
    super.key,
    required this.userProfileRepository,
    required this.userStatsRepository,
    required this.missionRepository,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  UserProfile? _profile;
  UserStats? _stats;
  int _totalXp = 0;
  late XpLevelCalculator _levelCalculator;
  LevelInfo? _levelInfo;

  @override
  void initState() {
    super.initState();
    _levelCalculator = XpLevelCalculator();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar en paralelo: profile, stats (que incluye totalXp)
      final results = await Future.wait([
        widget.userProfileRepository.getUserProfile(),
        widget.userStatsRepository.getUserStats(),
      ]);

      _profile = results[0] as UserProfile;
      _stats = results[1] as UserStats;
      _totalXp = _stats!.totalXp; // AHORA VIENE DE UserStats, NO de MissionRepository
      _levelInfo = _levelCalculator.getLevelInfo(_totalXp);

      print('[ProfilePage] 📊 Perfil cargado: ${_profile?.name}');
      print('[ProfilePage] 💎 XP total: $_totalXp, Nivel: ${_levelInfo?.level}');
    } catch (e) {
      print('[ProfilePage] ❌ Error cargando datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            final audioService = Provider.of<AudioService>(context, listen: false);
            audioService.playTap();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'PERFIL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.red),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ========== SECCIÓN: NIVEL Y XP ==========
                  _buildLevelSection(),
                  const SizedBox(height: 32),

                  // ========== SECCIÓN: STATS ==========
                  _buildStatsSection(),
                  const SizedBox(height: 32),

                  // ========== SECCIÓN: PERFIL (ONBOARDING) ==========
                  _buildProfileSection(),
                ],
              ),
            ),
    );
  }

  // ==========================================================================
  // NIVEL Y XP
  // ==========================================================================

  Widget _buildLevelSection() {
    if (_levelInfo == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.2),
        border: Border.all(color: Colors.red.shade700, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Nivel grande
          Text(
            'NIVEL ${_levelInfo!.level}',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),

          // XP total
          Text(
            '$_totalXp XP TOTAL',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),

          // Barra de progreso al siguiente nivel
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso a nivel ${_levelInfo!.level + 1}',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${_levelInfo!.xpInCurrentLevel}/${_levelInfo!.xpNeededForNextLevel} XP',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _levelInfo!.progressToNextLevel,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Faltan ${_levelInfo!.xpToNextLevel} XP',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // STATS
  // ==========================================================================

  Widget _buildStatsSection() {
    if (_stats == null) return const SizedBox.shrink();

    return Column(
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
        const SizedBox(height: 32),

        // Radar chart (mismo estilo que StatsPage)
        SizedBox(
          height: 320,
          child: StatsRadarChart(stats: _stats!.stats),
        ),
        const SizedBox(height: 32),

        // Desglose de stats
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
            children: [
              const Text(
                'DESGLOSE DE ATRIBUTOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.5,
                  shadows: [Shadow(color: Colors.red, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 16),
              ...StatType.values.map((type) {
                final value = _stats!.getStat(type);
                return _buildStatRow(type, value);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(StatType type, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Icono
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: type.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              type.icon,
              color: type.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Nombre
          Expanded(
            child: Text(
              type.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Valor
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              color: type.color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PERFIL (ONBOARDING DATA)
  // ==========================================================================

  Widget _buildProfileSection() {
    if (_profile == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERFIL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),

        // Nombre
        _buildProfileField('Nombre', _profile!.name),
        const SizedBox(height: 16),

        // Ideal Self
        _buildProfileField('Tu Visión', _profile!.idealSelfDescription),
        const SizedBox(height: 16),

        // Áreas de enfoque
        _buildProfileField(
          'Áreas de Enfoque',
          _profile!.focusAreas.join(', '),
        ),

        // Objetivos actuales (si existen)
        if (_profile!.currentGoals.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildProfileField(
            'Objetivos',
            _profile!.currentGoals.join('\n• '),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
