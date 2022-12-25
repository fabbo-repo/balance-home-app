import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/jwt_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class JwtRepository implements JwtRepositoryInterface {
  final HttpService httpService;

  JwtRepository({required this.httpService});

  /// Get [JwtEntity] by [credentials].
  @override
  Future<Either<Failure, JwtEntity>> getJwt(
      CredentialsEntity credentials) async {
    HttpResponse response = await httpService.sendPostRequest(
        APIContract.jwtLogin, credentials.toJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    JwtEntity jwt = JwtEntity.fromJson(response.content);
    httpService.setJwtModel(jwt);
    return right(jwt);
  }

  /// Get new [JwtEntity] with old [jwt].
  ///
  /// Note: only required refresh token in [jwt]
  @override
  Future<Either<Failure, JwtEntity>> refreshJwt(JwtEntity jwt) async {
    HttpResponse response = await httpService
        .sendPostRequest(APIContract.jwtRefresh, {"refresh": jwt.refresh});
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    response.content['refresh'] = jwt.refresh;
    JwtEntity newJwt = JwtEntity.fromJson(response.content);
    httpService.setJwtModel(newJwt);
    return right(newJwt);
  }
}
