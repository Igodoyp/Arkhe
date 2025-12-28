// data/repositories/day_feedback_repository_impl.dart

// ============================================================================
// REPOSITORIO (IMPLEMENTACIÓN): DAY FEEDBACK
// ============================================================================
// Implementa el contrato definido en DayFeedbackRepository.
// Coordina entre el datasource y el dominio, convirtiendo modelos a entidades.
//
// RESPONSABILIDADES:
// - Implementar todas las operaciones del repositorio
// - Convertir entre modelos (data) y entidades (domain)
// - Agregar lógica de negocio adicional (ej: cálculo de ajuste de dificultad)
// - Manejar errores y logging

import '../../domain/entities/day_feedback_entity.dart';
import '../../domain/repositories/day_feedback_repository.dart';
import '../datasources/day_feedback_datasource.dart';
import '../models/day_feedback_model.dart';

/// Implementación del repositorio de feedback del día
class DayFeedbackRepositoryImpl implements DayFeedbackRepository {
  final DayFeedbackDataSource dataSource;

  DayFeedbackRepositoryImpl({required this.dataSource});

  // ========== Operaciones Básicas ==========

  @override
  Future<void> saveFeedback(DayFeedback feedback) async {
    try {
      // Convertir entidad de dominio a modelo
      final model = DayFeedbackModel.fromEntity(feedback);
      
      // Guardar en el datasource
      await dataSource.saveFeedback(model);
      
      print('[DayFeedbackRepository] ✅ Feedback guardado correctamente');
    } catch (e) {
      print('[DayFeedbackRepository] ❌ Error al guardar feedback: $e');
      rethrow;
    }
  }

  @override
  Future<DayFeedback?> getFeedbackBySessionId(String sessionId) async {
    try {
      final model = await dataSource.getFeedbackBySessionId(sessionId);
      
      // Convertir modelo a entidad (si existe)
      return model?.toEntity();
    } catch (e) {
      print('[DayFeedbackRepository] ❌ Error al obtener feedback: $e');
      rethrow;
    }
  }

  @override
  Future<List<DayFeedback>> getAllFeedbacks() async {
    try {
      final models = await dataSource.getAllFeedbacks();
      
      // Convertir lista de modelos a lista de entidades
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('[DayFeedbackRepository] ❌ Error al obtener feedbacks: $e');
      rethrow;
    }
  }

  @override
  Future<List<DayFeedback>> getRecentFeedbacks(int count) async {
    try {
      final models = await dataSource.getRecentFeedbacks(count);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('[DayFeedbackRepository] ❌ Error al obtener feedbacks recientes: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllFeedbacks() async {
    try {
      await dataSource.clearAllFeedbacks();
      print('[DayFeedbackRepository] 🗑️ Todos los feedbacks eliminados');
    } catch (e) {
      print('[DayFeedbackRepository] ❌ Error al eliminar feedbacks: $e');
      rethrow;
    }
  }

  // ========== Lógica de Análisis ==========

  @override
  Future<double> calculateDifficultyAdjustment({int basedOnLastDays = 7}) async {
    try {
      // Obtener feedbacks recientes
      final recentFeedbacks = await getRecentFeedbacks(basedOnLastDays);

      if (recentFeedbacks.isEmpty) {
        print('[DayFeedbackRepository] ℹ️ No hay feedbacks para calcular ajuste, '
              'retornando 1.0 (sin cambio)');
        return 1.0; // Sin ajuste si no hay datos
      }

      // Calcular el ajuste promedio basado en los niveles de dificultad reportados
      final adjustments = recentFeedbacks
          .map((feedback) => feedback.difficulty.difficultyAdjustment)
          .toList();

      final averageAdjustment = 
          adjustments.reduce((a, b) => a + b) / adjustments.length;

      // Aplicar ponderación adicional basada en energía
      final avgEnergy = recentFeedbacks
          .map((f) => f.energyLevel)
          .reduce((a, b) => a + b) / recentFeedbacks.length;

      // Si la energía promedio es baja (< 3), reducir dificultad un poco más
      double energyAdjustment = 1.0;
      if (avgEnergy < 3) {
        energyAdjustment = 0.9; // Reducir 10% adicional
        print('[DayFeedbackRepository] ⚡ Energía promedio baja detectada, '
              'aplicando ajuste adicional');
      }

      final finalAdjustment = averageAdjustment * energyAdjustment;

      print('[DayFeedbackRepository] 📊 Ajuste de dificultad calculado:');
      print('  - Feedbacks analizados: ${recentFeedbacks.length}');
      print('  - Ajuste base: ${averageAdjustment.toStringAsFixed(2)}');
      print('  - Energía promedio: ${avgEnergy.toStringAsFixed(1)}/5');
      print('  - Ajuste por energía: ${energyAdjustment.toStringAsFixed(2)}');
      print('  - Ajuste final: ${finalAdjustment.toStringAsFixed(2)}');

      return finalAdjustment;
    } catch (e) {
      print('[DayFeedbackRepository] ❌ Error al calcular ajuste: $e');
      return 1.0; // Retornar sin ajuste en caso de error
    }
  }

  // ========== Métodos Adicionales de Análisis ==========

  /// Analiza las tendencias del usuario en los últimos N días
  /// Retorna un resumen con insights útiles
  Future<Map<String, dynamic>> analyzeTrends({int lastDays = 7}) async {
    try {
      final feedbacks = await getRecentFeedbacks(lastDays);

      if (feedbacks.isEmpty) {
        return {
          'hasData': false,
          'message': 'No hay datos suficientes para analizar',
        };
      }

      // Calcular métricas
      final avgEnergy = feedbacks
          .map((f) => f.energyLevel)
          .reduce((a, b) => a + b) / feedbacks.length;

      final struggledMissionsTotal = feedbacks
          .map((f) => f.struggledMissions.length)
          .reduce((a, b) => a + b);

      final easyMissionsTotal = feedbacks
          .map((f) => f.easyMissions.length)
          .reduce((a, b) => a + b);

      // Determinar tendencia de dificultad
      final tooEasyCount = feedbacks
          .where((f) => f.difficulty == DifficultyLevel.tooEasy)
          .length;
      final tooHardCount = feedbacks
          .where((f) => f.difficulty == DifficultyLevel.tooHard)
          .length;

      String trend = 'equilibrado';
      if (tooEasyCount > feedbacks.length / 2) {
        trend = 'necesita_mas_desafio';
      } else if (tooHardCount > feedbacks.length / 2) {
        trend = 'necesita_menos_carga';
      }

      return {
        'hasData': true,
        'daysAnalyzed': feedbacks.length,
        'averageEnergy': avgEnergy,
        'totalStruggledMissions': struggledMissionsTotal,
        'totalEasyMissions': easyMissionsTotal,
        'difficultyTrend': trend,
        'suggestedAdjustment': await calculateDifficultyAdjustment(
          basedOnLastDays: lastDays,
        ),
      };
    } catch (e) {
      print('[DayFeedbackRepository] ❌ Error al analizar tendencias: $e');
      return {
        'hasData': false,
        'error': e.toString(),
      };
    }
  }
}
