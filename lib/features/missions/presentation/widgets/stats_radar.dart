import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/stat_type.dart';

class StatsRadarChart extends StatelessWidget {
  final Map<StatType, double> stats; // valores de 0 a 100

  const StatsRadarChart({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final statValues = StatType.values.map((e) => stats[e] ?? 0.0).toList();
    final features = StatType.values.map((e) => e.name).toList();
    
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        radarBackgroundColor: Colors.transparent,
        radarBorderData: const BorderSide(color: Colors.black, width: 2),
        gridBorderData: const BorderSide(color: Colors.white38, width: 1.5),
        tickBorderData: const BorderSide(color: Colors.white24),
        ticksTextStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
        getTitle: (index, angle) => RadarChartTitle(text: features[index]),
        tickCount: 4,
        dataSets: [
          RadarDataSet(
            borderColor: Colors.redAccent,
            fillColor: Colors.redAccent.withOpacity(0.3),
            entryRadius: 4,
            borderWidth: 3,
            dataEntries: statValues.map((v) => RadarEntry(value: v)).toList(),
          ),
        ],
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeInOutCubic,
    );
  }
}
