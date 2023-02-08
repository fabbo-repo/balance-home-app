import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:fpdart/fpdart.dart';

class CoinTypeRemoteDataSource {
  final HttpClient client;

  CoinTypeRemoteDataSource({required this.client});

  Future<Either<Failure, CoinTypeEntity>> get(String code) async {
    HttpResponse response =
        await client.sendGetRequest('${APIContract.coinType}/$code');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(CoinTypeEntity.fromJson(response.content));
  }

  Future<Either<Failure, List<CoinTypeEntity>>> list() async {
    int pageNumber = 1;
    HttpResponse response =
        await client.sendGetRequest('${APIContract.coinType}?page=$pageNumber');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<CoinTypeEntity> coinTypes =
        page.results.map((e) => CoinTypeEntity.fromJson(e)).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response = await client
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
