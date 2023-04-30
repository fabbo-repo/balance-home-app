import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/utils/failure_utils.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:fpdart/fpdart.dart';

class CoinTypeRemoteDataSource {
  final HttpClient client;

  CoinTypeRemoteDataSource({required this.client});

  Future<Either<Failure, CoinTypeEntity>> get(String code) async {
    HttpResponse response =
        await client.sendGetRequest('${APIContract.coinType}/$code');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold((failure) => left(failure),
        (body) => right(CoinTypeEntity.fromJson(body)));
  }

  Future<Either<Failure, List<CoinTypeEntity>>> list() async {
    int pageNumber = 1;
    HttpResponse response =
        await client.sendGetRequest('${APIContract.coinType}?page=$pageNumber');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    if (responseCheck.isLeft()) {
      return left(
          responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<CoinTypeEntity> coinTypes =
        page.results.map((e) => CoinTypeEntity.fromJson(e)).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response = await client
          .sendGetRequest('${APIContract.coinType}?page=$pageNumber');
      // Check if there is a request failure
      final responseCheck = FailureUtils.checkResponse(
          body: response.content, statusCode: response.statusCode);
      if (responseCheck.isLeft()) {
        return left(
            responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
      }
      page = PaginationEntity.fromJson(response.content);
      coinTypes += page.results.map((e) => CoinTypeEntity.fromJson(e)).toList();
    }
    return right(coinTypes);
  }
}
