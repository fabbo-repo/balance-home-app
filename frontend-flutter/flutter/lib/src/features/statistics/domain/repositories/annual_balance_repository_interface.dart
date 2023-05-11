import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Annual Balance Repository Interface.
abstract class AnnualBalanceRepositoryInterface {
  /// Get [AnnualBalanceEntity] by `id`.
  Future<Either<Failure, AnnualBalanceEntity>> getAnnualBalance(int id);

  /// Get a list of [AnnualBalanceEntity].
  Future<Either<Failure, List<AnnualBalanceEntity>>> getAnnualBalances();
}
