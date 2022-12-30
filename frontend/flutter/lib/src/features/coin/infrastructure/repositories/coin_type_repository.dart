import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_service.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/coin_type_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class CoinTypeRepository implements CoinTypeRepositoryInterface {
  final HttpService httpService;

  CoinTypeRepository({required this.httpService});

  /// Get [CoinTypeEntity] by `code`.
  @override
  Future<Either<Failure, CoinTypeEntity>> getCoinType(String code) async {
    HttpResponse response =
        await httpService.sendGetRequest('${APIContract.coinType}/$code');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(CoinTypeEntity.fromJson(response.content));
  }

  /// Get a list of [CoinTypeEntity].
  @override
  Future<Either<Failure, List<CoinTypeEntity>>> getCoinTypes() async {
    int pageNumber = 1;
    HttpResponse response = await httpService
        .sendGetRequest('${APIContract.coinType}?page=$pageNumber');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<CoinTypeEntity> coinTypes =
        page.results.map((e) => CoinTypeEntity.fromJson(e)).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response = await httpService
          .sendGetRequest('${APIContract.coinType}?page=$pageNumber');
      if (response.hasError) {
        return left(Failure.badRequest(message: response.errorMessage));
      }
      page = PaginationEntity.fromJson(response.content);
      coinTypes += page.results.map((e) => CoinTypeEntity.fromJson(e)).toList();
    }
    return right(coinTypes);
  }
}
