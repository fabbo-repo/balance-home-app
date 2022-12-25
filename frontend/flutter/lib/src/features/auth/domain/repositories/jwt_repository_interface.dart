import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/jwt_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Jwt Repository Interface.
abstract class JwtRepositoryInterface {
  /// Get [JwtEntity] by [credentials].
  Future<Either<Failure, JwtEntity>> getJwt(CredentialsEntity credentials);

  /// Get new [JwtEntity] with old [jwt].
  /// 
  /// Note: only required refresh token in [jwt] 
  Future<Either<Failure, JwtEntity>> refreshJwt(JwtEntity jwt);
}