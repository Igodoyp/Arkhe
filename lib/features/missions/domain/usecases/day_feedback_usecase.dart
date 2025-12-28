// domain/usecases/day_feedback_usecase.dart

// ============================================================================
// USE CASES: DAY FEEDBACK
// ============================================================================
// Casos de uso que encapsulan la lógica de negocio relacionada con el feedback.
// Coordinan operaciones del repositorio y aplican reglas de negocio.
//
// CASOS DE USO IMPLEMENTADOS:
// 1. SaveFeedbackUseCase - Guardar feedback del día
// 2. GetFeedbackHistoryUseCase - Obtener historial de feedbacks
// 3. AnalyzeFeedbackTrendsUseCase - Analizar tendencias del usuario
// 4. GenerateAIPromptUseCase - Generar prompt para IA basado en feedback

import '../entities/day_feedback_entity.dart';
import '../repositories/day_feedback_repository.dart';

// ============================================================================
// 1. SAVE FEEDBACK USE CASE
// ============================================================================

/// Caso de uso para guardar el feedback del usuario sobre un día completado
class SaveFeedbackUseCase {
  final DayFeedbackRepository repository;

  SaveFeedbackUseCase(this.repository);

  /// Guarda el feedback con validaciones adicionales
  Future<void> call(DayFeedback feedback) async {
    print('[SaveFeedbackUseCase] 💾 Guardando feedback para sesión ${feedback.sessionId}');
    
    // Validación: energy level debe estar en rango válido
    if (feedback.energyLevel < 1 || feedback.energyLevel > 5) {
      throw ArgumentError('Energy level debe estar entre 1 y 5');
    }

    // Guardar en el repositorio
    await repository.saveFeedback(feedback);

    print('[SaveFeedbackUseCase] ✅ Feedback guardado exitosamente');
  }
}

// ============================================================================
// 2. GET FEEDBACK HISTORY USE CASE
// ============================================================================

/// Caso de uso para obtener el historial de feedbacks
class GetFeedbackHistoryUseCase {
  final DayFeedbackRepository repository;

  GetFeedbackHistoryUseCase(this.repository);

  /// Obtiene todos los feedbacks
  Future<List<DayFeedback>> getAllFeedbacks() async {
    print('[GetFeedbackHistoryUseCase] 📚 Obteniendo todos los feedbacks');
    return await repository.getAllFeedbacks();
  }

  /// Obtiene los últimos N feedbacks
  Future<List<DayFeedback>> getRecentFeedbacks(int count) async {
    print('[GetFeedbackHistoryUseCase] 📊 Obteniendo últimos $count feedbacks');
    return await repository.getRecentFeedbacks(count);
  }

  /// Obtiene el feedback de una sesión específica
  Future<DayFeedback?> getFeedbackBySessionId(String sessionId) async {
    print('[GetFeedbackHistoryUseCase] 🔍 Buscando feedback para sesión $sessionId');
    return await repository.getFeedbackBySessionId(sessionId);
  }
}

// ============================================================================
// 3. ANALYZE FEEDBACK TRENDS USE CASE
// ============================================================================

/// Caso de uso para analizar tendencias del usuario basadas en su feedback
class AnalyzeFeedbackTrendsUseCase {
  final DayFeedbackRepository repository;

  AnalyzeFeedbackTrendsUseCase(this.repository);

  /// Analiza las tendencias de los últimos N días
  /// Retorna un mapa con insights y recomendaciones
  Future<FeedbackAnalysis> call({int lastDays = 7}) async {
    print('[AnalyzeFeedbackTrendsUseCase] 📈 Analizando tendencias de los últimos $lastDays días');

    final feedbacks = await repository.getRecentFeedbacks(lastDays);

    if (feedbacks.isEmpty) {
      return FeedbackAnalysis.empty();
    }

    // Calcular métricas
    final avgEnergy = _calculateAverageEnergy(feedbacks);
    final difficultyDistribution = _calculateDifficultyDistribution(feedbacks);
    final suggestedAdjustment = await repository.calculateDifficultyAdjustment(
      basedOnLastDays: lastDays,
    );

    // Generar recomendaciones
    final recommendations = _generateRecommendations(
      feedbacks,
      avgEnergy,
      difficultyDistribution,
    );

    return FeedbackAnalysis(
      daysAnalyzed: feedbacks.length,
      averageEnergy: avgEnergy,
      difficultyDistribution: difficultyDistribution,
      suggestedDifficultyMultiplier: suggestedAdjustment,
      recommendations: recommendations,
    );
  }

  double _calculateAverageEnergy(List<DayFeedback> feedbacks) {
    if (feedbacks.isEmpty) return 3.0;
    return feedbacks.map((f) => f.energyLevel).reduce((a, b) => a + b) / 
           feedbacks.length;
  }

  Map<DifficultyLevel, int> _calculateDifficultyDistribution(
    List<DayFeedback> feedbacks,
  ) {
    final distribution = <DifficultyLevel, int>{};
    for (final feedback in feedbacks) {
      distribution[feedback.difficulty] = 
          (distribution[feedback.difficulty] ?? 0) + 1;
    }
    return distribution;
  }

  List<String> _generateRecommendations(
    List<DayFeedback> feedbacks,
    double avgEnergy,
    Map<DifficultyLevel, int> distribution,
  ) {
    final recommendations = <String>[];

    // Recomendación por energía
    if (avgEnergy < 2.5) {
      recommendations.add('Considera reducir la carga de misiones diarias');
      recommendations.add('Tu energía promedio es baja, prioriza el descanso');
    } else if (avgEnergy > 4.0) {
      recommendations.add('Tienes buena energía, podrías aumentar el desafío');
    }

    // Recomendación por dificultad
    final tooEasyCount = distribution[DifficultyLevel.tooEasy] ?? 0;
    final tooHardCount = distribution[DifficultyLevel.tooHard] ?? 0;
    final total = feedbacks.length;

    if (tooEasyCount > total / 2) {
      recommendations.add('Las misiones parecen demasiado fáciles, aumenta la dificultad');
    } else if (tooHardCount > total / 2) {
      recommendations.add('Las misiones son muy difíciles, reduce la complejidad');
    }

    // Recomendación por consistencia
    final justRightCount = distribution[DifficultyLevel.justRight] ?? 0;
    if (justRightCount > total * 0.6) {
      recommendations.add('¡Excelente! Has encontrado un buen equilibrio');
    }

    return recommendations;
  }
}

/// Clase que encapsula el resultado del análisis de tendencias
class FeedbackAnalysis {
  final int daysAnalyzed;
  final double averageEnergy;
  final Map<DifficultyLevel, int> difficultyDistribution;
  final double suggestedDifficultyMultiplier;
  final List<String> recommendations;

  FeedbackAnalysis({
    required this.daysAnalyzed,
    required this.averageEnergy,
    required this.difficultyDistribution,
    required this.suggestedDifficultyMultiplier,
    required this.recommendations,
  });

  factory FeedbackAnalysis.empty() {
    return FeedbackAnalysis(
      daysAnalyzed: 0,
      averageEnergy: 3.0,
      difficultyDistribution: {},
      suggestedDifficultyMultiplier: 1.0,
      recommendations: ['No hay datos suficientes para generar recomendaciones'],
    );
  }

  @override
  String toString() {
    return 'FeedbackAnalysis(\n'
        '  daysAnalyzed: $daysAnalyzed,\n'
        '  averageEnergy: ${averageEnergy.toStringAsFixed(1)},\n'
        '  suggestedMultiplier: ${suggestedDifficultyMultiplier.toStringAsFixed(2)},\n'
        '  recommendations: ${recommendations.length}\n'
        ')';
  }
}

// ============================================================================
// 4. GENERATE AI PROMPT USE CASE
// ============================================================================

/// Caso de uso para generar un prompt dinámico para la IA (Gemini)
/// basado en el feedback del usuario
class GenerateAIPromptUseCase {
  final DayFeedbackRepository repository;

  GenerateAIPromptUseCase(this.repository);

  /// Genera un prompt para la IA que incluye:
  /// - Contexto del usuario (energía, tendencias)
  /// - Ajustes de dificultad
  /// - Historial de misiones problemáticas/fáciles
  Future<String> call({int basedOnLastDays = 7}) async {
    print('[GenerateAIPromptUseCase] 🤖 Generando prompt para IA');

    final feedbacks = await repository.getRecentFeedbacks(basedOnLastDays);

    if (feedbacks.isEmpty) {
      return _generateDefaultPrompt();
    }

    final analysis = await _analyzeForPrompt(feedbacks);

    final prompt = '''
# CONTEXTO DEL USUARIO

## Historial Reciente (últimos ${feedbacks.length} días)
- Energía promedio: ${analysis['avgEnergy']}/5
- Nivel de dificultad percibido: ${analysis['mainDifficulty']}
- Tendencia: ${analysis['trend']}

## Ajustes Requeridos
- Multiplicador de dificultad sugerido: ${analysis['difficultyMultiplier']}x
- ${analysis['adjustmentReason']}

## Misiones Problemáticas
${analysis['struggledMissions'].isNotEmpty 
  ? '- IDs frecuentes: ${analysis['struggledMissions'].take(3).join(', ')}'
  : '- No hay patrones identificados'}

## Misiones Fáciles
${analysis['easyMissions'].isNotEmpty 
  ? '- IDs frecuentes: ${analysis['easyMissions'].take(3).join(', ')}'
  : '- No hay patrones identificados'}

## Notas del Usuario
${analysis['recentNotes']}

# INSTRUCCIONES PARA LA IA

Por favor, genera misiones para el día de hoy que:
1. Se ajusten al nivel de energía actual del usuario (${analysis['avgEnergy']}/5)
2. Apliquen el multiplicador de dificultad sugerido (${analysis['difficultyMultiplier']}x)
3. Eviten repetir misiones que fueron problemáticas recientemente
4. Consideren las notas y feedback del usuario
5. Mantengan un balance entre desafío y alcanzabilidad

# FORMATO DE SALIDA
Genera 3-5 misiones en formato JSON con los campos: id, title, description, difficulty, statImpacts.
''';

    print('[GenerateAIPromptUseCase] ✅ Prompt generado (${prompt.length} caracteres)');
    return prompt;
  }

  Future<Map<String, dynamic>> _analyzeForPrompt(List<DayFeedback> feedbacks) async {
    final avgEnergy = feedbacks
        .map((f) => f.energyLevel)
        .reduce((a, b) => a + b) / feedbacks.length;

    final difficultyMultiplier = await repository.calculateDifficultyAdjustment(
      basedOnLastDays: feedbacks.length,
    );

    // Determinar dificultad principal
    final difficultyCount = <DifficultyLevel, int>{};
    for (final f in feedbacks) {
      difficultyCount[f.difficulty] = (difficultyCount[f.difficulty] ?? 0) + 1;
    }
    final mainDifficulty = difficultyCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key
        .displayName;

    // Recopilar misiones problemáticas
    final allStruggledMissions = feedbacks
        .expand((f) => f.struggledMissions)
        .toList();
    final allEasyMissions = feedbacks
        .expand((f) => f.easyMissions)
        .toList();

    // Recopilar notas recientes
    final recentNotes = feedbacks
        .take(3)
        .map((f) => f.notes)
        .where((note) => note.isNotEmpty)
        .join('\n- ');

    // Determinar tendencia
    String trend;
    if (difficultyMultiplier > 1.1) {
      trend = 'Usuario necesita más desafío';
    } else if (difficultyMultiplier < 0.9) {
      trend = 'Usuario necesita menos carga';
    } else {
      trend = 'Usuario en equilibrio';
    }

    String adjustmentReason;
    if (avgEnergy < 2.5) {
      adjustmentReason = 'Reducir dificultad por baja energía';
    } else if (avgEnergy > 4.0 && difficultyMultiplier > 1.0) {
      adjustmentReason = 'Aumentar dificultad - usuario tiene buena energía';
    } else {
      adjustmentReason = 'Mantener nivel actual';
    }

    return {
      'avgEnergy': avgEnergy.toStringAsFixed(1),
      'difficultyMultiplier': difficultyMultiplier.toStringAsFixed(2),
      'mainDifficulty': mainDifficulty,
      'trend': trend,
      'adjustmentReason': adjustmentReason,
      'struggledMissions': allStruggledMissions.toSet().toList(),
      'easyMissions': allEasyMissions.toSet().toList(),
      'recentNotes': recentNotes.isNotEmpty ? recentNotes : 'Sin notas',
    };
  }

  String _generateDefaultPrompt() {
    return '''
# CONTEXTO DEL USUARIO

No hay historial de feedback disponible. Este es un usuario nuevo o se reinició el historial.

# INSTRUCCIONES PARA LA IA

Por favor, genera misiones iniciales balanceadas para un usuario nuevo:
1. Nivel de dificultad: moderado (ni muy fácil ni muy difícil)
2. 3-5 misiones variadas que cubran diferentes stats (Fuerza, Agilidad, Inteligencia, etc.)
3. Descripción clara y motivadora
4. Impactos equilibrados en stats

# FORMATO DE SALIDA
Genera 3-5 misiones en formato JSON con los campos: id, title, description, difficulty, statImpacts.
''';
  }
}
