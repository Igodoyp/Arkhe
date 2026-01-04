// data/repositories/user_profile_repository_impl.dart

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_datasource.dart';
import '../models/user_profile_model.dart';

/// Implementación del repositorio de UserProfile
/// 
/// Coordina entre el dominio y la capa de datos,
/// manejando la conversión entre entidades y modelos.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileDataSource dataSource;

  UserProfileRepositoryImpl({required this.dataSource});

  @override
  Future<UserProfile?> getUserProfile() async {
    try {
      // 1. Obtener JSON del datasource
      final json = await dataSource.getUserProfile();
      
      // 2. Si no hay perfil, retornar null
      if (json == null) {
        return null;
      }
      
      // 3. Convertir JSON a modelo
      final model = UserProfileModel.fromJson(json);
      
      // 4. Retornar como entidad (el modelo extiende la entidad)
      return model;
    } catch (e) {
      print('[UserProfileRepository] ❌ Error obteniendo perfil: $e');
      // En producción, convertir a un Failure de dominio
      rethrow;
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      // 1. Convertir entidad a modelo si no lo es
      final model = profile is UserProfileModel
          ? profile
          : UserProfileModel.fromEntity(profile);
      
      // 2. Convertir a JSON
      final json = model.toJson();
      
      // 3. Guardar en datasource
      await dataSource.saveUserProfile(json);
      
      print('[UserProfileRepository] ✅ Perfil guardado: ${profile.name}');
    } catch (e) {
      print('[UserProfileRepository] ❌ Error guardando perfil: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasProfile() async {
    try {
      return await dataSource.hasProfile();
    } catch (e) {
      print('[UserProfileRepository] ❌ Error verificando perfil: $e');
      return false;
    }
  }

  @override
  Future<void> deleteUserProfile() async {
    try {
      await dataSource.deleteUserProfile();
      print('[UserProfileRepository] ✅ Perfil eliminado');
    } catch (e) {
      print('[UserProfileRepository] ❌ Error eliminando perfil: $e');
      rethrow;
    }
  }
}
