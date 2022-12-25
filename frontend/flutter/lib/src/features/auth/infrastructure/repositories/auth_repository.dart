import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:fpdart/src/either.dart';

class AuthRepository implements AuthRepositoryInterface {
  final HttpService httpService;

  AuthRepository({required this.httpService});
  
  @override
  Future<Either<Failure, void>> createUser(RegisterEntity registration) {
    HttpResponse response =
        await httpService.sendGetRequest(APIContract.userProfile);
    return AccountModel.fromJson(response.content);
  }

  @override
  Future<Either<Failure, UserEntity>> getUser() {
    await httpService.sendPostRequest(
        APIContract.userCreation, registration.toJson());
  }
}
