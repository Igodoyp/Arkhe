// data/models/day_feedback_model.dart

// ============================================================================
// MODELO: DAY FEEDBACK
// ============================================================================
// Modelo de datos que extiende la entidad DayFeedback del dominio.
// Proporciona métodos para serialización/deserialización JSON
// para persistir el feedback del usuario.

import '../../domain/entities/day_feedback_entity.dart';

/// Modelo de datos para el feedback del día
/// Extiende DayFeedback y agrega capacidades de serialización
class DayFeedbackModel extends DayFeedback {
  DayFeedbackModel({
    required super.sessionId,
    required super.date,
    required super.difficulty,
    required super.energyLevel,
    required super.struggledMissions,
    required super.easyMissions,
    required super.notes,
  });

  // ========== Factory Constructors ==========
  
  /// Crea un modelo desde una entidad de dominio
  factory DayFeedbackModel.fromEntity(DayFeedback feedback) {
    return DayFeedbackModel(
      sessionId: feedback.sessionId,
      date: feedback.date,
      difficulty: feedback.difficulty,
      energyLevel: feedback.energyLevel,
      struggledMissions: List.from(feedback.struggledMissions),
      easyMissions: List.from(feedback.easyMissions),
      notes: feedback.notes,
    );
  }

  /// Crea un modelo desde JSON
  /// Usado para deserializar datos almacenados o recibidos de APIs
  factory DayFeedbackModel.fromJson(Map<String, dynamic> json) {
    return DayFeedbackModel(
      sessionId: json['sessionId'] as String,
      date: DateTime.parse(json['date'] as String),
      difficulty: _parseDifficultyLevel(json['difficulty'] as String),
      energyLevel: json['energyLevel'] as int,
      struggledMissions: (json['struggledMissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      easyMissions: (json['easyMissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String? ?? '',
    );
  }

  // ========== Serialización ==========
  
  /// Convierte el modelo a JSON
  /// Usado para persistir o enviar datos
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'date': date.toIso8601String(),
      'difficulty': difficulty.name,
      'energyLevel': energyLevel,
      'struggledMissions': struggledMissions,
      'easyMissions': easyMissions,
      'notes': notes,
    };
  }

  // ========== Conversión a Entidad ==========
  
  /// Convierte el modelo a una entidad de dominio
  DayFeedback toEntity() {
    return DayFeedback(
      sessionId: sessionId,
      date: date,
      difficulty: difficulty,
      energyLevel: energyLevel,
      struggledMissions: List.from(struggledMissions),
      easyMissions: List.from(easyMissions),
      notes: notes,
    );
  }

  // ========== Helpers Privados ==========
  
  /// Parsea el nivel de dificultad desde string
  static DifficultyLevel _parseDifficultyLevel(String value) {
    switch (value) {
      case 'tooEasy':
        return DifficultyLevel.tooEasy;
      case 'justRight':
        return DifficultyLevel.justRight;
      case 'challenging':
        return DifficultyLevel.challenging;
      case 'tooHard':
        return DifficultyLevel.tooHard;
      default:
        throw ArgumentError('Invalid difficulty level: $value');
    }
  }

  @override
  String toString() {
    return 'DayFeedbackModel(${super.toString()})';
  }
}
