// domain/entities/day_feedback_entity.dart

// ============================================================================
// ENTIDAD: DAY FEEDBACK
// ============================================================================
// Representa el feedback que el usuario proporciona después de completar un día.
// Esta información se usa para:
// 1. Analizar cómo el usuario percibe las misiones
// 2. Adaptar la dificultad de las misiones futuras
// 3. Generar prompts dinámicos para la IA (Gemini)
// 4. Mantener un historial de progreso y ajustes

/// Nivel de dificultad percibido por el usuario
enum DifficultyLevel {
  /// Demasiado fácil - El usuario se aburrió, necesita más desafío
  tooEasy,
  
  /// Perfecto - El usuario logró un estado de "flow", dificultad ideal
  justRight,
  
  /// Desafiante - Fue difícil pero lograble, buen nivel de esfuerzo
  challenging,
  
  /// Demasiado difícil - El usuario se sintió frustrado o abrumado
  tooHard,
}

/// Extensión para obtener información adicional sobre cada nivel
extension DifficultyLevelExtension on DifficultyLevel {
  /// Nombre legible para mostrar en UI
  String get displayName {
    switch (this) {
      case DifficultyLevel.tooEasy:
        return 'Muy Fácil';
      case DifficultyLevel.justRight:
        return 'Perfecto';
      case DifficultyLevel.challenging:
        return 'Desafiante';
      case DifficultyLevel.tooHard:
        return 'Muy Difícil';
    }
  }
  
  /// Descripción para ayudar al usuario a elegir
  String get description {
    switch (this) {
      case DifficultyLevel.tooEasy:
        return 'Me aburrí, quiero más desafío';
      case DifficultyLevel.justRight:
        return 'Estuvo perfecto, sigue así';
      case DifficultyLevel.challenging:
        return 'Difícil pero lograble';
      case DifficultyLevel.tooHard:
        return 'Me sentí abrumado';
    }
  }
  
  /// Ajuste sugerido para la dificultad (multiplicador)
  /// - tooEasy: +20% dificultad
  /// - justRight: 0% cambio
  /// - challenging: -10% dificultad
  /// - tooHard: -30% dificultad
  double get difficultyAdjustment {
    switch (this) {
      case DifficultyLevel.tooEasy:
        return 1.2;  // Aumentar 20%
      case DifficultyLevel.justRight:
        return 1.0;  // Mantener igual
      case DifficultyLevel.challenging:
        return 0.9;  // Reducir 10%
      case DifficultyLevel.tooHard:
        return 0.7;  // Reducir 30%
    }
  }
}

/// Entidad que representa el feedback del usuario sobre un día completado
class DayFeedback {
  /// ID de la sesión del día a la que pertenece este feedback
  final String sessionId;
  
  /// Fecha en la que se dio el feedback
  final DateTime date;
  
  /// Nivel de dificultad percibido por el usuario
  final DifficultyLevel difficulty;
  
  /// Nivel de energía del usuario durante el día (1-5)
  /// 1 = Muy cansado, 5 = Lleno de energía
  final int energyLevel;
  
  /// IDs de las misiones que el usuario sintió que fueron difíciles
  /// Útil para identificar qué tipos de tareas le cuestan más
  final List<String> struggledMissions;
  
  /// IDs de las misiones que el usuario sintió que fueron fáciles
  /// Útil para identificar qué puede hacer sin esfuerzo
  final List<String> easyMissions;
  
  /// Notas adicionales del usuario (texto libre)
  /// Ej: "Tuve mucho trabajo hoy", "Me sentí motivado", etc.
  final String notes;

  DayFeedback({
    required this.sessionId,
    required this.date,
    required this.difficulty,
    required this.energyLevel,
    required this.struggledMissions,
    required this.easyMissions,
    required this.notes,
  }) : assert(energyLevel >= 1 && energyLevel <= 5, 
              'Energy level debe estar entre 1 y 5');

  // ========== Método copyWith (Inmutabilidad) ==========
  /// Crea una copia de la entidad con algunos campos modificados
  DayFeedback copyWith({
    String? sessionId,
    DateTime? date,
    DifficultyLevel? difficulty,
    int? energyLevel,
    List<String>? struggledMissions,
    List<String>? easyMissions,
    String? notes,
  }) {
    return DayFeedback(
      sessionId: sessionId ?? this.sessionId,
      date: date ?? this.date,
      difficulty: difficulty ?? this.difficulty,
      energyLevel: energyLevel ?? this.energyLevel,
      struggledMissions: struggledMissions ?? List.from(this.struggledMissions),
      easyMissions: easyMissions ?? List.from(this.easyMissions),
      notes: notes ?? this.notes,
    );
  }

  // ========== Métodos de Análisis ==========
  
  /// Verifica si el usuario tuvo baja energía (≤ 2)
  bool get hadLowEnergy => energyLevel <= 2;
  
  /// Verifica si el usuario tuvo alta energía (≥ 4)
  bool get hadHighEnergy => energyLevel >= 4;
  
  /// Verifica si el usuario necesita más desafío
  bool get needsMoreChallenge => difficulty == DifficultyLevel.tooEasy;
  
  /// Verifica si el usuario necesita menos carga
  bool get needsLessLoad => 
      difficulty == DifficultyLevel.tooHard || 
      energyLevel <= 2;
  
  /// Cuenta total de misiones mencionadas en el feedback
  int get totalMentionedMissions => 
      struggledMissions.length + easyMissions.length;

  @override
  String toString() {
    return 'DayFeedback('
        'sessionId: $sessionId, '
        'date: ${date.toIso8601String()}, '
        'difficulty: ${difficulty.name}, '
        'energyLevel: $energyLevel, '
        'struggledMissions: ${struggledMissions.length}, '
        'easyMissions: ${easyMissions.length}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DayFeedback &&
        other.sessionId == sessionId &&
        other.date == date;
  }

  @override
  int get hashCode => sessionId.hashCode ^ date.hashCode;
}
