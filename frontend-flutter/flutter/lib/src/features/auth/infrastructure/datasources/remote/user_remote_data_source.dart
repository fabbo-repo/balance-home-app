import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/utils/failure_utils.dart';
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

  Future<Either<Failure, void>> create(RegisterEntity registration) async {
    HttpResponse response = await client.sendPostRequest(
        APIContract.userCreation, registration.toJson());
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold(
        (failure) => left(failure), (body) => right(null));
  }

  Future<Either<Failure, UserEntity>> update(UserEntity user) async {
    HttpResponse response =
        await client.sendPutRequest(APIContract.userProfile, user.toJson());
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold((failure) => left(failure),
        (body) => right(UserEntity.fromJson(response.content)));
  }

  Future<Either<Failure, void>> updateImage(
      Uint8List imageBytes, String imageType) async {
    HttpResponse response = await client.sendPatchImageRequest(
        APIContract.userProfile, imageBytes, imageType);
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold(
        (failure) => left(failure), (body) => right(null));
  }

  Future<Either<Failure, UserEntity>> get() async {
    HttpResponse response =
        await client.sendGetRequest(APIContract.userProfile);
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold((failure) => left(failure),
        (body) => right(UserEntity.fromJson(response.content)));
  }

  Future<Either<Failure, void>> delete() async {
    HttpResponse response =
        await client.sendDelRequest(APIContract.userProfile);
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold(
        (failure) => left(failure), (body) => right(null));
  }
}
