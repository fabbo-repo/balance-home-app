import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';

/// Coin Type Repository Interface.
abstract class CoinTypeRepositoryInterface {
  /// Get [CoinTypeEntity] by `code`.
  Future<CoinTypeEntity> getCoinType(String code);

  /// Get a list of [CoinTypeEntity].
  Future<List<CoinTypeEntity>> getCoinTypes();
}
