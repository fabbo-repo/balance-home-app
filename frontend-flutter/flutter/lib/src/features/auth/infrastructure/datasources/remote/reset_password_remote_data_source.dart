import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/reset_password_entity.dart';
import 'package:fpdart/fpdart.dart';

class ResetPasswordRemoteDataSource {
  final ApiClient apiClient;

  ResetPasswordRemoteDataSource({required this.apiClient});

  Future<Either<Failure, void>> request(String email) async {
    final response = await apiClient.postRequest(
        APIContract.userPasswordReset,
        data: {"email": email});
    // Check if there is a request failure
    return response.fold((failure) => left(failure), (_) => right(null));
  }

  Future<Either<Failure, void>> verify(ResetPasswordEntity entity) async {
    final response = await apiClient.postRequest(
        APIContract.userPasswordResetVerify,
        data: entity.toJson());
    // Check if there is a request failure
    return response.fold((failure) => left(failure), (_) => right(null));
  }
}
