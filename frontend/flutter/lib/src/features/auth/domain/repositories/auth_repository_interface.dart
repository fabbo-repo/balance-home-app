import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Authentication Repository Interface.
abstract class AuthRepositoryInterface {
  Future<Either<Failure, bool>> createUser(RegisterEntity registration);

  Future<Either<Failure, UserEntity>> getUser();

  Future<Either<Failure, bool>> trySignIn();

  Future<Either<Failure, bool>> signIn(CredentialsEntity credentials);

  Future<Either<Failure, bool>> signOut();
}
