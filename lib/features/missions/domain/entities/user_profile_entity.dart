// domain/entities/user_profile_entity.dart

// ============================================================================
// ENTIDAD: USER PROFILE
// ============================================================================
// Representa el "Ideal Self" del usuario en el sistema Arkhe.
// Esta entidad es CRUCIAL para la generación de misiones personalizadas,
// ya que contiene la visión aspiracional del usuario que guía a Gemini.
//
// USO EN GENERACIÓN DE MISIONES:
// - Cold Start: Se usa para crear el primer conjunto de misiones
// - Feedback-based: Se combina con DayFeedback y UserStats para ajustar misiones

/// Entidad que representa el perfil ideal del usuario
/// 
/// Este perfil define quién aspira ser el usuario y qué valores/objetivos
/// persigue. Es la brújula que guía la generación de misiones.
class UserProfile {
  /// ID único del perfil (normalmente será "default" o el user ID)
  final String id;
  
  /// Nombre o apodo del usuario
  final String name;
  
  /// Descripción del "Ideal Self" en texto libre
  /// 
  /// Ejemplo: "Quiero ser una persona disciplinada que mantiene un balance
  /// entre trabajo, salud y aprendizaje continuo. Valoro la constancia
  /// sobre la intensidad y busco mejorar 1% cada día."
  /// 
  /// Este texto se inyecta directamente en el prompt de Gemini.
  final String idealSelfDescription;
  
  /// Áreas de vida prioritarias para el usuario
  /// 
  /// Ejemplos: "Salud física", "Carrera profesional", "Relaciones",
  /// "Finanzas", "Crecimiento personal", "Creatividad"
  /// 
  /// Estas áreas ayudan a Gemini a balancear las misiones generadas.
  final List<String> focusAreas;
  
  /// Objetivos específicos a corto/mediano plazo
  /// 
  /// Ejemplos:
  /// - "Correr 5K en menos de 30 minutos"
  /// - "Leer 12 libros este año"
  /// - "Aprender Dart/Flutter a nivel intermedio"
  /// 
  /// Estos objetivos informan a Gemini sobre qué tipos de misiones generar.
  final List<String> currentGoals;
  
  /// Contexto adicional opcional (trabajo, estilo de vida, restricciones)
  /// 
  /// Ejemplo: "Trabajo remoto, tengo hijos pequeños, solo puedo hacer
  /// ejercicio temprano en la mañana"
  final String? additionalContext;
  
  /// Preferencias de dificultad y tipo de desafíos
  /// Map con keys como 'difficulty', 'typePreference', etc.
  final Map<String, dynamic> challengePreferences;
  
  /// Indica si el usuario ha completado el onboarding
  final bool hasCompletedOnboarding;
  
  /// Timestamp de última actualización del perfil (DEBE ser inyectado)
  final DateTime lastUpdated;

  UserProfile({
    required this.id,
    required this.name,
    required this.idealSelfDescription,
    required this.focusAreas,
    required this.currentGoals,
    this.additionalContext,
    this.challengePreferences = const {},
    this.hasCompletedOnboarding = false,
    required this.lastUpdated,
  }) : assert(focusAreas.isNotEmpty, 'Debe haber al menos un área de enfoque');

  // ========== Método copyWith (Inmutabilidad) ==========
  
  UserProfile copyWith({
    String? id,
    String? name,
    String? idealSelfDescription,
    List<String>? focusAreas,
    List<String>? currentGoals,
    String? additionalContext,
    Map<String, dynamic>? challengePreferences,
    bool? hasCompletedOnboarding,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      idealSelfDescription: idealSelfDescription ?? this.idealSelfDescription,
      focusAreas: focusAreas ?? List.from(this.focusAreas),
      currentGoals: currentGoals ?? List.from(this.currentGoals),
      additionalContext: additionalContext ?? this.additionalContext,
      challengePreferences: challengePreferences ?? Map.from(this.challengePreferences),
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // ========== Helpers para Prompt Building ==========
  
  /// Retorna una representación en texto del perfil para usar en prompts de IA
  /// 
  /// Este método formatea el perfil de manera óptima para inyectar
  /// en el contexto de Gemini.
  String toPromptContext() {
    final buffer = StringBuffer();
    
    buffer.writeln('# Perfil del Usuario: $name');
    buffer.writeln();
    buffer.writeln('## Ideal Self');
    buffer.writeln(idealSelfDescription);
    buffer.writeln();
    buffer.writeln('## Áreas de Enfoque');
    for (final area in focusAreas) {
      buffer.writeln('- $area');
    }
    buffer.writeln();
    buffer.writeln('## Objetivos Actuales');
    for (final goal in currentGoals) {
      buffer.writeln('- $goal');
    }
    
    if (additionalContext != null && additionalContext!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('## Contexto Adicional');
      buffer.writeln(additionalContext);
    }
    
    return buffer.toString();
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, focusAreas: ${focusAreas.length}, goals: ${currentGoals.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
