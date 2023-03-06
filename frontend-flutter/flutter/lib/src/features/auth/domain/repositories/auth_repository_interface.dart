import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

/// Authentication Repository Interface.
abstract class AuthRepositoryInterface {
  Future<Either<Failure, bool>> createUser(RegisterEntity registration);
  
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);
  
  Future<Either<Failure, bool>> updateUserImage(Uint8List imageBytes, String imageType);

  Future<Either<Failure, UserEntity>> getUser();

  Future<Either<Failure, bool>> deleteUser();

  Future<Either<Failure, bool>> trySignIn();

  Future<Either<Failure, bool>> signIn(CredentialsEntity credentials,
      {bool store = false});

  Future<Either<Failure, bool>> signOut();
}
