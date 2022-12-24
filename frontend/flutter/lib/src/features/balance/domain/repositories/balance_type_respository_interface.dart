import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';

/// Balance Type Repository Interface.
abstract class BalanceTypeRepositoryInterface {
  /// Get [BalanceTypeEntity] by `name`.
  Future<BalanceTypeEntity> getBalanceType(
      String name, BalanceTypeMode balanceTypeMode);

  /// Get a list of all [BalanceTypeEntity].
  Future<List<BalanceTypeEntity>> getBalanceTypes(
      BalanceTypeMode balanceTypeMode);
}
