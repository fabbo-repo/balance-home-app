import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_conversion_list_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/date_currency_conversion_list_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_conversion_repository_interface.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/datasources/remote/currency_conversion_remote_data_source.dart';
import 'package:fpdart/fpdart.dart';

class CurrencyConversionRepository implements CurrencyConversionRepositoryInterface {
  final CurrencyConversionRemoteDataSource currencyConversionRemoteDataSource;

  CurrencyConversionRepository({required this.currencyConversionRemoteDataSource});

  /// Get [CurrencyConversionListEntity] by `code`.
  @override
  Future<Either<Failure, CurrencyConversionListEntity>> getCurrencyConversion(String code) async {
    return await currencyConversionRemoteDataSource.get(code);
  }

  /// Get [DateCurrencyConversionListEntity] by `days`.
  @override
  Future<Either<Failure, DateCurrencyConversionListEntity>> getLastDateCurrencyConversion(
      {required int days}) async {
    return await currencyConversionRemoteDataSource.getLastDate(days: days);
  }
}
