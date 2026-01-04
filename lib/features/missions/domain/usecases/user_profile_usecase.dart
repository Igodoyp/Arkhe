// domain/usecases/user_profile_usecase.dart

import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

/// UseCase para obtener el perfil del usuario
class GetUserProfileUseCase {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfile?> call() async {
    return await repository.getUserProfile();
  }
}

/// UseCase para guardar/actualizar el perfil del usuario
class SaveUserProfileUseCase {
  final UserProfileRepository repository;

  SaveUserProfileUseCase(this.repository);

  Future<void> call(UserProfile profile) async {
    await repository.saveUserProfile(profile);
  }
}

/// UseCase para verificar si existe un perfil
class HasProfileUseCase {
  final UserProfileRepository repository;

  HasProfileUseCase(this.repository);

  Future<bool> call() async {
    return await repository.hasProfile();
  }
}

/// UseCase para eliminar el perfil del usuario
class DeleteUserProfileUseCase {
  final UserProfileRepository repository;

  DeleteUserProfileUseCase(this.repository);

  Future<void> call() async {
    await repository.deleteUserProfile();
  }
}
