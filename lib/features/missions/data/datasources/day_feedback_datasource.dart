// data/datasources/day_feedback_datasource.dart

// ============================================================================
// DATASOURCE: DAY FEEDBACK (DUMMY)
// ============================================================================
// Fuente de datos dummy para el feedback del día.
// Simula almacenamiento en memoria (en producción sería SharedPreferences,
// SQLite, Firebase, etc.)
//
// RESPONSABILIDADES:
// - Guardar feedback del usuario
// - Recuperar feedback por sessionId
// - Recuperar historial de feedback
// - Limpiar datos (para testing/reset)

import '../../domain/entities/day_feedback_entity.dart';
import '../models/day_feedback_model.dart';

/// Datasource abstracto para el feedback del día
/// Define el contrato que debe cumplir cualquier implementación
abstract class DayFeedbackDataSource {
  /// Guarda un feedback del día
  Future<void> saveFeedback(DayFeedbackModel feedback);
  
  /// Obtiene el feedback de una sesión específica
  Future<DayFeedbackModel?> getFeedbackBySessionId(String sessionId);
  
  /// Obtiene todos los feedbacks ordenados por fecha (más reciente primero)
  Future<List<DayFeedbackModel>> getAllFeedbacks();
  
  /// Obtiene los últimos N feedbacks
  Future<List<DayFeedbackModel>> getRecentFeedbacks(int count);
  
  /// Elimina todos los feedbacks (para testing/reset)
  Future<void> clearAllFeedbacks();
}

/// Implementación dummy del datasource
/// Almacena los datos en memoria (se pierden al cerrar la app)
class DayFeedbackDataSourceDummy implements DayFeedbackDataSource {
  // ========== Almacenamiento en Memoria ==========
  
  /// Mapa de feedbacks: sessionId -> DayFeedbackModel
  final Map<String, DayFeedbackModel> _feedbacks = {};

  // ========== Métodos del Datasource ==========

  @override
  Future<void> saveFeedback(DayFeedbackModel feedback) async {
    // Simular un pequeño delay de red/disco
    await Future.delayed(const Duration(milliseconds: 100));
    
    _feedbacks[feedback.sessionId] = feedback;
    
    print('[DayFeedbackDataSource] ✅ Feedback guardado para sesión ${feedback.sessionId}');
    print('  - Dificultad: ${feedback.difficulty.displayName}');
    print('  - Energía: ${feedback.energyLevel}/5');
    print('  - Misiones difíciles: ${feedback.struggledMissions.length}');
    print('  - Misiones fáciles: ${feedback.easyMissions.length}');
  }

  @override
  Future<DayFeedbackModel?> getFeedbackBySessionId(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final feedback = _feedbacks[sessionId];
    
    if (feedback != null) {
      print('[DayFeedbackDataSource] 📖 Feedback encontrado para sesión $sessionId');
    } else {
      print('[DayFeedbackDataSource] ❌ No se encontró feedback para sesión $sessionId');
    }
    
    return feedback;
  }

  @override
  Future<List<DayFeedbackModel>> getAllFeedbacks() async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Ordenar por fecha, más reciente primero
    final feedbacks = _feedbacks.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    print('[DayFeedbackDataSource] 📚 Se obtuvieron ${feedbacks.length} feedbacks');
    
    return feedbacks;
  }

  @override
  Future<List<DayFeedbackModel>> getRecentFeedbacks(int count) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final allFeedbacks = await getAllFeedbacks();
    final recentFeedbacks = allFeedbacks.take(count).toList();
    
    print('[DayFeedbackDataSource] 📊 Se obtuvieron los últimos $count feedbacks');
    
    return recentFeedbacks;
  }

  @override
  Future<void> clearAllFeedbacks() async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final count = _feedbacks.length;
    _feedbacks.clear();
    
    print('[DayFeedbackDataSource] 🗑️ Se eliminaron $count feedbacks');
  }

  // ========== Métodos Auxiliares (Debug) ==========
  
  /// Obtiene estadísticas agregadas del historial de feedbacks
  /// Útil para análisis y debugging
  Map<String, dynamic> getStatistics() {
    if (_feedbacks.isEmpty) {
      return {
        'totalFeedbacks': 0,
        'message': 'No hay feedbacks registrados',
      };
    }

    final feedbacks = _feedbacks.values.toList();
    
    // Calcular promedios y frecuencias
    final avgEnergy = feedbacks
        .map((f) => f.energyLevel)
        .reduce((a, b) => a + b) / feedbacks.length;
    
    final difficultyFrequency = <DifficultyLevel, int>{};
    for (final feedback in feedbacks) {
      difficultyFrequency[feedback.difficulty] = 
          (difficultyFrequency[feedback.difficulty] ?? 0) + 1;
    }

    return {
      'totalFeedbacks': feedbacks.length,
      'averageEnergy': avgEnergy.toStringAsFixed(1),
      'difficultyFrequency': difficultyFrequency
          .map((key, value) => MapEntry(key.displayName, value)),
      'oldestFeedback': feedbacks
          .reduce((a, b) => a.date.isBefore(b.date) ? a : b)
          .date
          .toIso8601String(),
      'newestFeedback': feedbacks
          .reduce((a, b) => a.date.isAfter(b.date) ? a : b)
          .date
          .toIso8601String(),
    };
  }

  /// Imprime las estadísticas en consola (para debugging)
  void printStatistics() {
    final stats = getStatistics();
    print('[DayFeedbackDataSource] 📈 ESTADÍSTICAS:');
    stats.forEach((key, value) {
      print('  $key: $value');
    });
  }
}
