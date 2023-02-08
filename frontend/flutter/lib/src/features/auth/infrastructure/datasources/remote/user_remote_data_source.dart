import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

class UserRemoteDataSource {
  final HttpClient client;

  /// Default constructor
  UserRemoteDataSource({
    required this.client,
  });

  Future<Either<Failure, bool>> create(RegisterEntity registration) async {
    HttpResponse response = await client.sendPostRequest(
        APIContract.userCreation, registration.toJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(true);
  }

  Future<Either<Failure, UserEntity>> update(UserEntity user) async {
    HttpResponse response =
        await client.sendPutRequest(APIContract.userProfile, user.toJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(UserEntity.fromJson(response.content));
  }

  Future<Either<Failure, bool>> updateImage(
      Uint8List imageBytes, String imageType) async {
    HttpResponse response = await client.sendPatchImageRequest(
        APIContract.userProfile, imageBytes, imageType);
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(true);
  }

  Future<Either<Failure, UserEntity>> get() async {
    HttpResponse response =
        await client.sendGetRequest(APIContract.userProfile);
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(UserEntity.fromJson(response.content));
  }

  Future<Either<Failure, bool>> delete() async {
    HttpResponse response =
        await client.sendDelRequest(APIContract.userProfile);
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(true);
  }
}
