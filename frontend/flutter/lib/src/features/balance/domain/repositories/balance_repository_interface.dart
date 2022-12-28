import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:fpdart/fpdart.dart';

/// Balance Repository Interface.
abstract class BalanceRepositoryInterface {
  /// Get [BalanceEntity] by `id`.
  Future<Either<Failure, BalanceEntity>> getBalance(
      int id, BalanceTypeMode balanceTypeMode);

  /// Get a list of [BalanceEntity].
  Future<Either<Failure, List<BalanceEntity>>> getBalances(
      BalanceTypeMode balanceTypeMode,
      {DateTime? dateFrom,
      DateTime? dateTo});

  /// Get a list of years related to existing [BalanceEntity] years.
  Future<Either<Failure, List<int>>> getBalanceYears(
      BalanceTypeMode balanceTypeMode);

  /// Store a [BalanceEntity].
  Future<Either<Failure, BalanceEntity>> createBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode);

  /// Update a [BalanceEntity].
  Future<Either<Failure, BalanceEntity>> updateBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode);

  /// Delete a [BalanceEntity].
  Future<Either<Failure, void>> deleteBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode);
}
