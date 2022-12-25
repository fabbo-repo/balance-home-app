import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/forgot_password_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/forgot_password_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class ForgotPasswordRepository implements ForgotPasswordRepositoryInterface {
  final HttpService httpService;

  ForgotPasswordRepository({required this.httpService});

  /// Request forgot password code by `email`.
  @override
  Future<Either<Failure, void>> requestCode(String email) async {
    HttpResponse response = await httpService
        .sendPostRequest(APIContract.userPasswordResetStart, {"email": email});
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(null);
  }

  /// Request forgot password code verification.
  @override
  Future<Either<Failure, bool>> verifyCode(ForgotPasswordEntity entity) async {
    HttpResponse response = await httpService.sendPostRequest(
        APIContract.userPasswordResetVerify, entity.toJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(true);
  }
}
