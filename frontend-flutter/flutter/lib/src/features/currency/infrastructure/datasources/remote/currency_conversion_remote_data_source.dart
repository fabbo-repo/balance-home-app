import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_conversion_list_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/date_currency_conversion_list_entity.dart';
import 'package:fpdart/fpdart.dart';

class CurrencyConversionRemoteDataSource {
  final ApiClient apiClient;

  CurrencyConversionRemoteDataSource({required this.apiClient});

  Future<Either<Failure, CurrencyConversionListEntity>> get(String code) async {
    final response =
        await apiClient.getRequest('${APIContract.currencyConversion}/$code');
    // Check if there is a request failure
    return response.fold((failure) => left(failure),
        (value) => right(CurrencyConversionListEntity.fromJson(value.data)));
  }

  Future<Either<Failure, DateCurrencyConversionListEntity>> getLastDate(
      {required int days}) async {
    final response = await apiClient
        .getRequest('${APIContract.currencyConversion}/days=$days');
    // Check if there is a request failure
    return response.fold(
        (failure) => left(failure),
        (value) =>
            right(DateCurrencyConversionListEntity.fromJson(value.data)));
  }
}
