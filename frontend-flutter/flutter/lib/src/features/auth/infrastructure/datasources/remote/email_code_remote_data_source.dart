import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/email_code_entity.dart';
import 'package:fpdart/fpdart.dart';

class EmailCodeRemoteDataSource {
  final HttpClient client;

  EmailCodeRemoteDataSource({required this.client});

  Future<Either<Failure, void>> request(String email) async {
    HttpResponse response = await client
        .sendPostRequest(APIContract.emailCodeSend, {"email": email});
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(null);
  }

  Future<Either<Failure, bool>> verify(EmailCodeEntity entity) async {
    HttpResponse response = await client.sendPostRequest(
        APIContract.emailCodeVerify, entity.toJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(true);
  }
}
