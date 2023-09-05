import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/account/domain/entities/account_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

class UserRemoteDataSource {
  final ApiClient apiClient;

  /// Default constructor
  UserRemoteDataSource({required this.apiClient});

  Future<Either<Failure, void>> create(RegisterEntity registration) async {
    final response = await apiClient.postRequest(APIContract.userCreation,
        data: registration.toJson());
    // Check if there is a request failure
    return response.fold((failure) => left(failure), (_) => right(null));
  }

  Future<Either<Failure, AccountEntity>> update(AccountEntity user) async {
    final response = await apiClient.patchRequest(APIContract.userProfile,
        data: user.toJson());
    // Check if there is a request failure
    return response.fold((failure) => left(failure),
        (value) => right(AccountEntity.fromJson(value.data)));
  }

  Future<Either<Failure, void>> updateImage(
      Uint8List bytes, String type) async {
    final response =
        await apiClient.patchImageRequest(APIContract.userProfile, bytes, type);
    // Check if there is a request failure
    return response.fold((failure) => left(failure), (_) => right(null));
  }

  Future<Either<Failure, AccountEntity>> get() async {
    final response = await apiClient.getRequest(APIContract.userProfile);
    // Check if there is a request failure
    return response.fold((failure) => left(failure),
        (value) => right(AccountEntity.fromJson(value.data)));
  }

  Future<Either<Failure, void>> delete() async {
    final response = await apiClient.delRequest(APIContract.userProfile);
    // Check if there is a request failure
    return response.fold((failure) => left(failure), (_) => right(null));
  }
}
