import 'package:balance_home_app/src/core/data/models/pagination_model.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/coin/data/models/coin_type_model.dart';

abstract class ICoinTypeRepository {
  Future<CoinTypeModel> getCoinType(String code);

  Future<List<CoinTypeModel>> getCoinTypes();
}

class CoinTypeRepository implements ICoinTypeRepository {

  final HttpService httpService;

  CoinTypeRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch a coin type.
  @override
  Future<CoinTypeModel> getCoinType(String code) async {
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.coinType}/$code'
    );
    return CoinTypeModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch all coin types.
  @override
  Future<List<CoinTypeModel>> getCoinTypes() async {
    int pageNumber = 1; 
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.coinType}?page=$pageNumber'
    );
    PaginationModel page = PaginationModel.fromJson(response.content);
    List<CoinTypeModel> coinTypes = page.results.map((e) => CoinTypeModel.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService.sendGetRequest(
        '${APIContract.coinType}?page=$pageNumber'
      );
      page = PaginationModel.fromJson(response.content);
      coinTypes += page.results.map((e) => CoinTypeModel.fromJson(e)).toList();
      pageNumber ++;
    }
    return coinTypes;
  }
}