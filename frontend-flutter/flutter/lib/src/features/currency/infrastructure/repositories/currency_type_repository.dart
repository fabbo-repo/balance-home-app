import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_type_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_type_repository_interface.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/datasources/local/currency_type_local_data_source.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/datasources/remote/currency_type_remote_data_source.dart';
import 'package:fpdart/fpdart.dart';

class CurrencyTypeRepository implements CurrencyTypeRepositoryInterface {
  final CurrencyTypeRemoteDataSource currencyTypeRemoteDataSource;
  final CurrencyTypeLocalDataSource currencyTypeLocalDataSource;

  CurrencyTypeRepository(
      {required this.currencyTypeRemoteDataSource,
      required this.currencyTypeLocalDataSource});

  /// Get [CurrencyTypeEntity] by `code`.
  @override
  Future<Either<Failure, CurrencyTypeEntity>> getCurrencyType(
      String code) async {
    final response = await currencyTypeRemoteDataSource.get(code);
    return await response.fold((failure) async {
      if (failure is HttpConnectionFailure) {
        return await currencyTypeLocalDataSource.get(code);
      }
      return left(failure);
    }, (currencyType) async {
      // Store currency type data
      await currencyTypeLocalDataSource.put(currencyType);
      return right(currencyType);
    });
  }

  /// Get a list of [CurrencyTypeEntity].
  @override
  Future<Either<Failure, List<CurrencyTypeEntity>>> getCurrencyTypes() async {
    final response = await currencyTypeRemoteDataSource.list();
    return await response.fold((failure) async {
      if (failure is HttpConnectionFailure) {
        return await currencyTypeLocalDataSource.list();
      }
      return left(failure);
    }, (currencyTypes) async {
      print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
      // Store currency types data
      for (final currencyType in currencyTypes) {
        await currencyTypeLocalDataSource.put(currencyType);
      }
      return right(currencyTypes);
    });
  }
}
