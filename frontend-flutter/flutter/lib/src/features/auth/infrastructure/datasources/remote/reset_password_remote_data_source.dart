import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/utils/failure_utils.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/reset_password_entity.dart';
import 'package:fpdart/fpdart.dart';

class ResetPasswordRemoteDataSource {
  final HttpClient client;

  ResetPasswordRemoteDataSource({required this.client});

  Future<Either<Failure, void>> request(String email) async {
    HttpResponse response = await client
        .sendPostRequest(APIContract.userPasswordResetStart, {"email": email});
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold(
        (failure) => left(failure), (body) => right(null));
  }

  Future<Either<Failure, void>> verify(ResetPasswordEntity entity) async {
    HttpResponse response = await client.sendPostRequest(
        APIContract.userPasswordResetVerify, entity.toJson());
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold(
        (failure) => left(failure), (body) => right(null));
  }
}
