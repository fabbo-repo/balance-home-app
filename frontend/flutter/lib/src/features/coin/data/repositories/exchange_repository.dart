import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/coin/data/models/date_exchanges_list_model.dart';
import 'package:balance_home_app/src/features/coin/data/models/exchanges_list_model.dart';

abstract class IExchangeRepository {
  Future<ExchangesListModel> getExchanges(String code);

  Future<DateExchangesListModel> getLastDateExchanges({required int days});
}

class ExchangeRepository implements IExchangeRepository {

  final HttpService httpService;

  ExchangeRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch an exchange.
  @override
  Future<ExchangesListModel> getExchanges(String code) async {
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.coinExchange}/$code'
    );
    return ExchangesListModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch as many 
  /// date exchanges as days.
  @override
  Future<DateExchangesListModel> getLastDateExchanges({required int days}) async {
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.coinExchange}/days=$days'
    );
    return DateExchangesListModel.fromJson(response.content);
  }
}