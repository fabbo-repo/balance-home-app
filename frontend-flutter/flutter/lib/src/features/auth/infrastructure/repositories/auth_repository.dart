import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/user_local_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/jwt_remote_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/user_remote_data_source.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/jwt_local_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

/// Repository that handles authorization and persists session
class AuthRepository implements AuthRepositoryInterface {
  /// Remote jwt provider
  final JwtRemoteDataSource jwtRemoteDataSource;

  /// Local jwt storage provider
  final JwtLocalDataSource jwtLocalDataSource;

  /// Remote user data provider
  final UserRemoteDataSource userRemoteDataSource;

  /// Local user data provider
  final UserLocalDataSource userLocalDataSource;

  /// Default constructor
  AuthRepository({
    required this.jwtRemoteDataSource,
    required this.jwtLocalDataSource,
    required this.userRemoteDataSource,
    required this.userLocalDataSource,
  });

  @override
  Future<Either<Failure, void>> createUser(RegisterEntity registration) async {
    return await userRemoteDataSource.create(registration);
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    return await userRemoteDataSource.update(user);
  }

  @override
  Future<Either<Failure, void>> updateUserImage(
      Uint8List imageBytes, String imageType) async {
    return await userRemoteDataSource.updateImage(imageBytes, imageType);
  }

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    final response = await userRemoteDataSource.get();
    return await response.fold((failure) async {
      if (failure is HttpConnectionFailure) {
        return await userLocalDataSource.get();
      }
      return left(failure);
    }, (remoteUser) async {
      // Store user data
      await userLocalDataSource.put(remoteUser);
      return right(remoteUser);
    });
  }

  @override
  Future<Either<Failure, void>> deleteUser() async {
    await userLocalDataSource.delete();
    return await userRemoteDataSource.delete();
  }

  @override
  Future<Either<Failure, void>> trySignIn() async {
    final jwtStorage = await jwtLocalDataSource.get();
    return await jwtStorage.fold((failure) async {
      // Clean wrong data
      await jwtLocalDataSource.remove();
      return left(failure);
    }, (value) async {
      jwtRemoteDataSource.setJwt(value);
      return right(null);
    });
  }

  @override
  Future<Either<Failure, void>> signIn(CredentialsEntity credentials,
      {bool store = false}) async {
    final response = await jwtRemoteDataSource.get(credentials);
    // Check if there is a request failure
    return await response.fold((failure) => left(failure), (value) async {
      await jwtLocalDataSource.store(value, longDuration: store);
      jwtRemoteDataSource.setJwt(value);
      return right(null);
    });
  }

  @override
  Future<Either<Failure, bool>> signOut() async {
    if (!await jwtLocalDataSource.remove()) return left(const EmptyFailure());
    jwtRemoteDataSource.removeJwt();
    // Delete user data
    await userLocalDataSource.delete();
    return right(true);
  }
}
