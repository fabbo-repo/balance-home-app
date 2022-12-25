import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Authentication Repository Interface.
abstract class AuthRepositoryInterface {
  /// Get logged in user data.
  Future<Either<Failure, UserEntity>> getUser();

  /// Create an user by [RegisterEntity] data.
  Future<Either<Failure, void>> createUser(RegisterEntity registration);
}
