// data/models/user_profile_model.dart

import '../../domain/entities/user_profile_entity.dart';

/// Modelo de datos para UserProfile
/// Extiende la entidad de dominio y agrega capacidades de serialización
class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.id,
    required super.name,
    required super.idealSelfDescription,
    required super.focusAreas,
    required super.currentGoals,
    super.additionalContext,
    super.challengePreferences = const {},
    super.hasCompletedOnboarding = false,
    required super.lastUpdated,
  });

  // ========== Factory Constructors ==========
  
  /// Crea un modelo desde una entidad de dominio
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      idealSelfDescription: profile.idealSelfDescription,
      focusAreas: List.from(profile.focusAreas),
      currentGoals: List.from(profile.currentGoals),
      additionalContext: profile.additionalContext,
      challengePreferences: Map.from(profile.challengePreferences),
      hasCompletedOnboarding: profile.hasCompletedOnboarding,
      lastUpdated: profile.lastUpdated,
    );
  }

  /// Crea un modelo desde JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      idealSelfDescription: json['idealSelfDescription'] as String,
      focusAreas: (json['focusAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      currentGoals: (json['currentGoals'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      additionalContext: json['additionalContext'] as String?,
      challengePreferences: (json['challengePreferences'] as Map<String, dynamic>?) ?? {},
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String)
          : throw ArgumentError('lastUpdated is required in UserProfile JSON'),
    );
  }

  // ========== Serialización ==========
  
  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'idealSelfDescription': idealSelfDescription,
      'focusAreas': focusAreas,
      'currentGoals': currentGoals,
      'additionalContext': additionalContext,
      'challengePreferences': challengePreferences,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // ========== copyWith override ==========
  
  @override
  UserProfileModel copyWith({
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
    return UserProfileModel(
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

  // ========== Factory para crear perfil por defecto ==========
  
  /// Crea un perfil de ejemplo/default para testing o onboarding
  /// @param lastUpdated: Timestamp opcional (solo para testing/demo, usa DateTime.now si no se provee)
  factory UserProfileModel.defaultProfile({DateTime? lastUpdated}) {
    return UserProfileModel(
      id: 'default',
      name: 'Usuario',
      idealSelfDescription: 
          'Soy una persona que busca mejorar continuamente en todas las áreas '
          'de mi vida. Valoro el equilibrio, la disciplina y el crecimiento personal.',
      focusAreas: [
        'Salud y Bienestar',
        'Desarrollo Profesional',
        'Crecimiento Personal',
      ],
      currentGoals: [
        'Establecer una rutina matutina consistente',
        'Leer al menos 30 minutos al día',
        'Hacer ejercicio 3 veces por semana',
      ],
      additionalContext: null,
      lastUpdated: lastUpdated ?? DateTime.now(),  // Fallback solo para testing
    );
  }
}
