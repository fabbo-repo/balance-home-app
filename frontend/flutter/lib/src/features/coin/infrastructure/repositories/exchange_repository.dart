import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/date_exchanges_list_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/exchanges_list_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/exchange_repository_interface.dart';

class ExchangeRepository implements ExchangeRepositoryInterface {
  final HttpService httpService;

  ExchangeRepository({required this.httpService});

  /// Get [ExchangesListEntity] by `code`.
  @override
  Future<ExchangesListEntity> getExchanges(String code) async {
    HttpResponse response =
        await httpService.sendGetRequest('${APIContract.coinExchange}/$code');
    return ExchangesListEntity.fromJson(response.content);
  }

  /// Get [DateExchangesListEntity] by `days`.
  @override
  Future<DateExchangesListEntity> getLastDateExchanges(
      {required int days}) async {
    HttpResponse response = await httpService
        .sendGetRequest('${APIContract.coinExchange}/days=$days');
    return DateExchangesListEntity.fromJson(response.content);
  }
}
