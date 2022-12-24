import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';

/// Monthly Balance Repository Interface.
abstract class MonthlyBalanceRepositoryInterface {
  /// Get [MonthlyBalanceEntity] by `id`.
  Future<MonthlyBalanceEntity> getMonthlyBalance(int id);

  /// Get a list of [MonthlyBalanceEntity].
  Future<List<MonthlyBalanceEntity>> getMonthlyBalances({int? year});
}
