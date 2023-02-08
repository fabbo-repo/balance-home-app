import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/date_exchanges_list_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/exchanges_list_entity.dart';
import 'package:fpdart/fpdart.dart';

class ExchangeRemoteDataSource {
  final HttpClient client;

  ExchangeRemoteDataSource({required this.client});

  Future<Either<Failure, ExchangesListEntity>> get(String code) async {
    HttpResponse response =
        await client.sendGetRequest('${APIContract.coinExchange}/$code');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(ExchangesListEntity.fromJson(response.content));
  }

  Future<Either<Failure, DateExchangesListEntity>> getLastDate(
      {required int days}) async {
    HttpResponse response = await client
        .sendGetRequest('${APIContract.coinExchange}/days=$days');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(DateExchangesListEntity.fromJson(response.content));
  }
}
