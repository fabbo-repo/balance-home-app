import 'package:balance_home_app/src/core/exceptions/http_exceptions.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/data/models/jwt_model.dart';

abstract class ILoginRepository {
  Future<JwtModel> getJwt(CredentialsModel credentials);
  
  Future<JwtModel> refreshJwt(JwtModel jwt);
}

class LoginRepository implements ILoginRepository {
  @override
  Future<JwtModel> getJwt(CredentialsModel credentials) async {
    HttpResponse response = await HttpService().sendPostRequest(
      APIContract.jwtLogin,
      credentials.toJson()
    );
    _checkStatusCode(response);
    return JwtModel.fromJson(response.content);
  }

  @override
  Future<JwtModel> refreshJwt(JwtModel jwt) async {
    HttpResponse response = await HttpService().sendPostRequest(
      APIContract.jwtRefresh,
      {
        "refresh": jwt.refreshToken
      }
    );
    _checkStatusCode(response);
    return JwtModel.fromJson(response.content);
  }

  void _checkStatusCode(HttpResponse response) {
    if (response.statusCode == 401) {
      throw UnauthorizedHttpException(response.content);
    } else if (response.statusCode == 500) {
      throw UnauthorizedHttpException(response.content);
    }
  }
}