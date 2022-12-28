import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Monthly Balance Repository Interface.
abstract class MonthlyBalanceRepositoryInterface {
  /// Get [MonthlyBalanceEntity] by `id`.
  Future<Either<Failure, MonthlyBalanceEntity>> getMonthlyBalance(int id);

  /// Get a list of [MonthlyBalanceEntity].
  Future<Either<Failure, List<MonthlyBalanceEntity>>> getMonthlyBalances(
      {int? year});
}
