import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Coin Type Repository Interface.
abstract class CoinTypeRepositoryInterface {
  /// Get [CoinTypeEntity] by `code`.
  Future<Either<Failure, CoinTypeEntity>> getCoinType(String code);

  /// Get a list of [CoinTypeEntity].
  Future<Either<Failure, List<CoinTypeEntity>>> getCoinTypes();
}
