import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:fpdart/fpdart.dart';

class JwtRemoteDataSource {
  final ApiClient apiClient;

  JwtRemoteDataSource({required this.apiClient});

  Future<Either<Failure, JwtEntity>> get(CredentialsEntity credentials) async {
    final response = await apiClient.postRequest(APIContract.jwtLogin,
        data: credentials.toJson());
    // Check if there is a request failure
    return response.fold((failure) => left(failure),
        (value) => right(JwtEntity.fromJson(value.data)));
  }

  void setJwt(JwtEntity jwt) {
    apiClient.setJwt(jwt);
  }

  void removeJwt() {
    apiClient.removeJwt();
  }
}
