import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/email_code_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/email_code_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class EmailCodeRepository implements EmailCodeRepositoryInterface {
  final HttpService httpService;

  EmailCodeRepository({required this.httpService});

  /// Request email code by `email`.
  @override
  Future<Either<Failure, void>> requestCode(String email) async {
    HttpResponse response = await httpService
        .sendPostRequest(APIContract.emailCodeSend, {"email": email});
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(null);
  }

  /// Request email code verification.
  @override
  Future<Either<Failure, bool>> verifyCode(EmailCodeEntity entity) async {
    HttpResponse response = await httpService.sendPostRequest(
        APIContract.emailCodeVerify, entity.toJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(true);
  }
}
