import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_service.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/reset_password_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/reset_password_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class ResetPasswordRepository implements ResetPasswordRepositoryInterface {
  final HttpService httpService;

  ResetPasswordRepository({required this.httpService});

  /// Request reset password code by `email`.
  @override
  Future<Either<Failure, void>> requestCode(String email) async {
    HttpResponse response = await httpService
        .sendPostRequest(APIContract.userPasswordResetStart, {"email": email});
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(null);
  }

  /// Request reset password code verification.
  @override
  Future<Either<Failure, bool>> verifyCode(ResetPasswordEntity entity) async {
    HttpResponse response = await httpService.sendPostRequest(
        APIContract.userPasswordResetVerify, entity.toJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(true);
  }
}
