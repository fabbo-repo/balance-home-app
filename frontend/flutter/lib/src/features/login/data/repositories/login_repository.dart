import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/data/models/jwt_model.dart';

abstract class ILoginRepository {
  Future<JwtModel> getJwt(CredentialsModel credentials);
}

class LoginRepository implements ILoginRepository {
  @override
  Future<JwtModel> getJwt(CredentialsModel credentials) async {
    HttpResponse response = await HttpService().sendPostRequest(
      APIContract.jwtLogin,
      credentials.toJson()
    );
    return JwtModel.fromJson(response.content);
  }
}