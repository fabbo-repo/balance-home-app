import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/login/data/models/forgot_password_model.dart';

abstract class IForgotPasswordRepository {
  Future<void> requestCode(String email);

  Future<void> verifyCode(ForgotPasswordModel model);
}

class ForgotPasswordRepository implements IForgotPasswordRepository {
  final HttpService httpService;

  ForgotPasswordRepository({required this.httpService});

  /// Sends a [POST] request to backend service to notify that
  /// an email code should be sent to reset password.
  @override
  Future<void> requestCode(String email) async {
    await httpService
        .sendPostRequest(APIContract.userPasswordResetStart, {"email": email});
  }

  /// Sends a [POST] request to backend service to verify
  /// sent email code and reset password.
  /// It should update [User] model's password in backend
  @override
  Future<void> verifyCode(ForgotPasswordModel model) async {
    await httpService.sendPostRequest(
        APIContract.userPasswordResetVerify, model.toJson());
  }
}
