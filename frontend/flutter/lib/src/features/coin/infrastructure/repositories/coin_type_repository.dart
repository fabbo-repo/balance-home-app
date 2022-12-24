import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/coin_type_repository_interface.dart';

class CoinTypeRepository implements CoinTypeRepositoryInterface {
  final HttpService httpService;

  CoinTypeRepository({required this.httpService});

  /// Get [CoinTypeEntity] by `code`.
  @override
  Future<CoinTypeEntity> getCoinType(String code) async {
    HttpResponse response =
        await httpService.sendGetRequest('${APIContract.coinType}/$code');
    return CoinTypeEntity.fromJson(response.content);
  }

  /// Get a list of [CoinTypeEntity].
  @override
  Future<List<CoinTypeEntity>> getCoinTypes() async {
    int pageNumber = 1;
    HttpResponse response = await httpService
        .sendGetRequest('${APIContract.coinType}?page=$pageNumber');
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<CoinTypeEntity> coinTypes =
        page.results.map((e) => CoinTypeEntity.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService
          .sendGetRequest('${APIContract.coinType}?page=$pageNumber');
      page = PaginationEntity.fromJson(response.content);
      coinTypes += page.results.map((e) => CoinTypeEntity.fromJson(e)).toList();
      pageNumber++;
    }
    return coinTypes;
  }
}
