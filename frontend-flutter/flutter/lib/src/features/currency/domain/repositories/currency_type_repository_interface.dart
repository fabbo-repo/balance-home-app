import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_type_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Currency Type Repository Interface.
abstract class CurrencyTypeRepositoryInterface {
  /// Get [CurrencyTypeEntity] by `code`.
  Future<Either<Failure, CurrencyTypeEntity>> getCurrencyType(String code);

  /// Get a list of [CurrencyTypeEntity].
  Future<Either<Failure, List<CurrencyTypeEntity>>> getCurrencyTypes();
}
