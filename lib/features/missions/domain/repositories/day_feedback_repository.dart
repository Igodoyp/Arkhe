// domain/repositories/day_feedback_repository.dart

// ============================================================================
// REPOSITORIO (INTERFAZ): DAY FEEDBACK
// ============================================================================
// Define el contrato para acceder a los datos de feedback del día.
// Esta interfaz pertenece al dominio y es implementada por la capa de datos.
//
// RESPONSABILIDADES:
// - Definir operaciones de alto nivel para el feedback
// - Abstraer la fuente de datos del dominio
// - Trabajar con entidades de dominio (DayFeedback)

import '../entities/day_feedback_entity.dart';

/// Repositorio abstracto para el feedback del día
abstract class DayFeedbackRepository {
  /// Guarda el feedback del usuario para una sesión
  Future<void> saveFeedback(DayFeedback feedback);
  
  /// Obtiene el feedback de una sesión específica
  Future<DayFeedback?> getFeedbackBySessionId(String sessionId);
  
  /// Obtiene todos los feedbacks ordenados por fecha (más reciente primero)
  Future<List<DayFeedback>> getAllFeedbacks();
  
  /// Obtiene los últimos N feedbacks para análisis de tendencias
  Future<List<DayFeedback>> getRecentFeedbacks(int count);
  
  /// Elimina todos los feedbacks (para testing/reset)
  Future<void> clearAllFeedbacks();
  
  /// Calcula el ajuste de dificultad sugerido basado en el historial reciente
  /// Retorna un multiplicador (ej: 1.0 = sin cambio, 1.2 = +20% dificultad)
  Future<double> calculateDifficultyAdjustment({int basedOnLastDays = 7});
}
