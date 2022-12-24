import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';

/// Annual Balance Repository Interface.
abstract class AnnualBalanceRepositoryInterface {
  /// Get [AnnualBalanceEntity] by `id`.
  Future<AnnualBalanceEntity> getAnnualBalance(int id);

  /// Get a list of [AnnualBalanceEntity].
  Future<List<AnnualBalanceEntity>> getAnnualBalances();

  /// Get last eight [AnnualBalanceEntity].
  Future<List<AnnualBalanceEntity>> getLastEightYearsAnnualBalances();
}
