import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/utils/failure_utils.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/user_remote_data_source.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/credentials_local_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/jwt_local_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

/// Repository that handles authorization and persists session
class AuthRepository implements AuthRepositoryInterface {
  final HttpClient client;

  /// Local credentials storage provider
  final CredentialsLocalDataSource credentialsLocalDataSource;

  /// Local jwt storage provider
  final JwtLocalDataSource jwtLocalDataSource;

  /// Remote user data provider
  final UserRemoteDataSource userRemoteDataSource;

  /// Default constructor
  AuthRepository({
    required this.client,
    required this.credentialsLocalDataSource,
    required this.jwtLocalDataSource,
    required this.userRemoteDataSource,
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
    return await userRemoteDataSource.get();
  }

  @override
  Future<Either<Failure, void>> deleteUser() async {
    return await userRemoteDataSource.delete();
  }

  @override
  Future<Either<Failure, void>> trySignIn() async {
    final credentials = await credentialsLocalDataSource.get();
    // Clean jwt
    client.setJwtEntity(null);
    return await credentials.fold((failure) async {
      // Clean wrong data
      await credentialsLocalDataSource.remove();
      await jwtLocalDataSource.remove();
      return left(failure);
    }, (credentials) async {
      HttpResponse response = await client.sendPostRequest(
          APIContract.jwtLogin, credentials.toJson());
      // Check if there is a request failure
      final responseCheck = FailureUtils.checkResponse(
          body: response.content, statusCode: response.statusCode);
      if (responseCheck.isLeft()) {
        return left(
            responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
      }
      JwtEntity jwt = JwtEntity.fromJson(response.content);
      client.setJwtEntity(jwt);
      return right(true);
    });
  }

  @override
  Future<Either<Failure, bool>> signIn(CredentialsEntity credentials,
      {bool store = false}) async {
    // Clean jwt
    client.setJwtEntity(null);
    HttpResponse response = await client.sendPostRequest(
        APIContract.jwtLogin, credentials.toJson());
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    if (responseCheck.isLeft()) {
      return left(
          responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
    }
    JwtEntity jwt = JwtEntity.fromJson(response.content);
    client.setJwtEntity(jwt);
    await jwtLocalDataSource.store(jwt);
    if (store) await credentialsLocalDataSource.store(credentials);
    return right(true);
  }

  @override
  Future<Either<Failure, bool>> signOut() async {
    if (!await jwtLocalDataSource.remove()) return left(const EmptyFailure());
    if (!await credentialsLocalDataSource.remove()) {
      return left(const EmptyFailure());
    }
    client.setJwtEntity(null);
    return right(true);
  }
}
