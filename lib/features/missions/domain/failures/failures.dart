// domain/failures/failures.dart

/// Clase base para todos los errores del dominio
abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  String toString() => message;
}

/// Error de red/servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Error de caché/almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error cuando no se encuentra un recurso
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Error cuando el día ya está finalizado
class DayAlreadyFinalizedFailure extends Failure {
  const DayAlreadyFinalizedFailure() : super('El día ya ha sido finalizado');
}
