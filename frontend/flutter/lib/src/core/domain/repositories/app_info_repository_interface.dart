import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:fpdart/fpdart.dart';

/// App info Repository Interface
abstract class AppInfoRepositoryInterface {
  /// Get app current last version
  Future<Either<Failure, AppVersion>> getVersion();
}