import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/http_service.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/credentials_local_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/jwt_local_data_source.dart';
import 'package:fpdart/fpdart.dart';

/// Repository that handles authorization and persists session
class AuthRepository implements AuthRepositoryInterface {
  final HttpService httpService;

  /// Local credentials storage provider
  final CredentialsLocalDataSource credentialsLocalDataSource;

  /// Local jwt storage provider
  final JwtLocalDataSource jwtLocalDataSource;

  /// Default constructor
  AuthRepository({
    required this.httpService,
    required this.credentialsLocalDataSource,
    required this.jwtLocalDataSource,
  });

  @override
  Future<Either<Failure, bool>> createUser(RegisterEntity registration) async {
    HttpResponse response =
        await httpService.sendGetRequest(APIContract.userProfile);
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(true);
  }

  @override
  Future<Either<Failure, UserEntity>> getUser() async {
    HttpResponse response =
        await httpService.sendGetRequest(APIContract.userProfile);
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(UserEntity.fromJson(response.content));
  }

  @override
  Future<Either<Failure, bool>> trySignIn() async {
    final credentials = await credentialsLocalDataSource.get();
    return credentials.fold((l) => left(l), (credentials) async {
      // Clean jwt
      httpService.setJwtEntity(null);
      HttpResponse response = await httpService.sendPostRequest(
          APIContract.jwtLogin, credentials.toJson());
      if (response.hasError) {
        return left(Failure.badRequest(message: response.errorMessage));
      }
      JwtEntity jwt = JwtEntity.fromJson(response.content);
      httpService.setJwtEntity(jwt);
      return right(true);
    });
  }
  
  @override
  Future<Either<Failure, bool>> signIn(CredentialsEntity credentials) async {
    // Clean jwt
    httpService.setJwtEntity(null);
    HttpResponse response = await httpService.sendPostRequest(
        APIContract.jwtLogin, credentials.toJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    JwtEntity jwt = JwtEntity.fromJson(response.content);
    httpService.setJwtEntity(jwt);
    await jwtLocalDataSource.store(jwt);
    await credentialsLocalDataSource.store(credentials);
    return right(true);
  }

  @override
  Future<Either<Failure, bool>> signOut() async {
    if (!await jwtLocalDataSource.remove()) return left(const Failure.empty());
    httpService.setJwtEntity(null);
    return right(true);
  }
}
