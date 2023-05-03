import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_type_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_type_repository_interface.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/datasources/remote/currency_type_remote_data_source.dart';
import 'package:fpdart/fpdart.dart';

class CurrencyTypeRepository implements CurrencyTypeRepositoryInterface {
  final CurrencyTypeRemoteDataSource currencyTypeRemoteDataSource;

  CurrencyTypeRepository({required this.currencyTypeRemoteDataSource});

  /// Get [CurrencyTypeEntity] by `code`.
  @override
  Future<Either<Failure, CurrencyTypeEntity>> getCurrencyType(String code) async {
    return await currencyTypeRemoteDataSource.get(code);
  }

  /// Get a list of [CurrencyTypeEntity].
  @override
  Future<Either<Failure, List<CurrencyTypeEntity>>> getCurrencyTypes() async {
    return await currencyTypeRemoteDataSource.list();
  }
}
