import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';

/// Balance Repository Interface.
abstract class BalanceRepositoryInterface {
  /// Get [BalanceEntity] by `id`.
  Future<BalanceEntity> getBalance(int id, BalanceTypeMode balanceTypeMode);

  /// Get a list of [BalanceEntity].
  Future<List<BalanceEntity>> getBalances(BalanceTypeMode balanceTypeMode,
      {DateTime? dateFrom, DateTime? dateTo});

  /// Get a list of years related to existing [BalanceEntity] years.
  Future<List<int>> getBalanceYears(BalanceTypeMode balanceTypeMode);

  /// Store a [BalanceEntity].
  Future<BalanceEntity> createBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode);

  /// Update a [BalanceEntity].
  Future<void> updateBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode);

  /// Delete a [BalanceEntity].
  Future<void> deleteBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode);
}
