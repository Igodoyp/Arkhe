// domain/repositories/user_profile_repository.dart

import '../entities/user_profile_entity.dart';

/// Repositorio para gestionar el perfil del usuario (Ideal Self)
/// 
/// Este repositorio maneja la persistencia y recuperación del perfil
/// aspiracional del usuario, que es fundamental para la generación
/// personalizada de misiones.
abstract class UserProfileRepository {
  /// Obtiene el perfil del usuario
  /// 
  /// Retorna null si el usuario aún no ha configurado su perfil.
  /// En este caso, la UI debería guiar al usuario al onboarding.
  Future<UserProfile?> getUserProfile();
  
  /// Guarda o actualiza el perfil del usuario
  /// 
  /// @param profile: El perfil completo a guardar
  Future<void> saveUserProfile(UserProfile profile);
  
  /// Verifica si existe un perfil configurado
  /// 
  /// Útil para decidir si mostrar onboarding o ir directo a la app.
  Future<bool> hasProfile();
  
  /// Elimina el perfil del usuario
  /// 
  /// Usado principalmente para testing o cuando el usuario
  /// quiere resetear completamente su perfil.
  Future<void> deleteUserProfile();
}
