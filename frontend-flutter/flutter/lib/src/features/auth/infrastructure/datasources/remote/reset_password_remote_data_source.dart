import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/reset_password_entity.dart';
import 'package:fpdart/fpdart.dart';

class ResetPasswordRemoteDataSource {
  final HttpClient client;

  ResetPasswordRemoteDataSource({required this.client});

  Future<Either<Failure, void>> request(String email) async {
    HttpResponse response = await client
        .sendPostRequest(APIContract.userPasswordResetStart, {"email": email});
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(null);
  }

  Future<Either<Failure, bool>> verify(ResetPasswordEntity entity) async {
    HttpResponse response = await client.sendPostRequest(
        APIContract.userPasswordResetVerify, entity.toJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(true);
  }
}
