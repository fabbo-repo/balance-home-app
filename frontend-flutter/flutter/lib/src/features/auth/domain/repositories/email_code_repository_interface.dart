import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/email_code_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Email Code Repository Interface.
abstract class EmailCodeRepositoryInterface {
  /// Request email code by `email`.
  Future<Either<Failure, void>> requestCode(String email);

  /// Request email code verification.
  Future<Either<Failure, void>> verifyCode(EmailCodeEntity entity);
}
