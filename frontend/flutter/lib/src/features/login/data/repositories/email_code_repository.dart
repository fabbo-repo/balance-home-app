import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/login/data/models/email_code_model.dart';

abstract class ICodeRepository {
  Future<void> sendCode(String email);
  
  Future<void> verifyCode(EmailCodeModel code);
}

class EmailCodeRepository implements ICodeRepository {

  final HttpService httpService;

  EmailCodeRepository({required this.httpService});

  /// Sends a [POST] request to backend service to notify that 
  /// an email code should be sent.
  @override
  Future<void> sendCode(String email) async {
    await httpService.sendPostRequest(
      APIContract.emailCodeSend,
      {
        "email": email
      }
    );
  }

  /// Sends a [POST] request to backend service to verify 
  /// sent email code. It should update [User] model in backend
  /// as [verified].
  @override
  Future<void> verifyCode(EmailCodeModel code) async {
    await httpService.sendPostRequest(
      APIContract.emailCodeVerify,
      code.toJson()
    );
  }
}