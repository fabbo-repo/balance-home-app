import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/data/models/jwt_model.dart';

abstract class IJwtRepository {
  Future<JwtModel> getJwt(CredentialsModel credentials);
  
  Future<JwtModel> refreshJwt(JwtModel jwt);
}

class JwtRepository implements IJwtRepository {

  final HttpService httpService;

  JwtRepository({required this.httpService});

  /// Sends a [POST] request to backend service to fetch the JWT 
  /// with given [credentials]. It also updates JWT in the [HttpService].
  @override
  Future<JwtModel> getJwt(CredentialsModel credentials) async {
    HttpResponse response = await httpService.sendPostRequest(
      APIContract.jwtLogin,
      credentials.toJson()
    );
    JwtModel jwt = JwtModel.fromJson(response.content);
    httpService.setJwtModel(jwt);
    return jwt;
  }

  /// Sends a [POST] request to backend service to get a new JWT 
  /// with old [JwtModel], only refresh field is needed. 
  /// It also updates JWT in the [HttpService].
  @override
  Future<JwtModel> refreshJwt(JwtModel jwt) async {
    HttpResponse response = await httpService.sendPostRequest(
      APIContract.jwtRefresh,
      {
        "refresh": jwt.refresh
      }
    );
    response.content['refresh'] = jwt.refresh;
    JwtModel new_jwt = JwtModel.fromJson(response.content);
    httpService.setJwtModel(new_jwt);
    return new_jwt;
  }
}