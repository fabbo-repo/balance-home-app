import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:fpdart/fpdart.dart';

class MonthlyBalanceRemoteDataSource {
  final HttpClient client;

  MonthlyBalanceRemoteDataSource({required this.client});

  Future<Either<Failure, MonthlyBalanceEntity>> get(int id) async {
    HttpResponse response = await client
        .sendGetRequest('${APIContract.monthlyBalance}/${id.toString()}');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(MonthlyBalanceEntity.fromJson(response.content));
  }

  Future<Either<Failure, List<MonthlyBalanceEntity>>> list({int? year}) async {
    String extraArgs = "";
    if (year != null) {
      extraArgs += "&year=$year";
    }
    int pageNumber = 1;
    HttpResponse response = await client.sendGetRequest(
        '${APIContract.monthlyBalance}?page=$pageNumber$extraArgs');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<MonthlyBalanceEntity> monthlyBalances =
        page.results.map((e) => MonthlyBalanceEntity.fromJson(e)).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response = await client.sendGetRequest(
          '${APIContract.monthlyBalance}?page=$pageNumber$extraArgs');
      if (response.hasError) {
        return left(Failure.badRequest(message: response.errorMessage));
      }
      page = PaginationEntity.fromJson(response.content);
      monthlyBalances +=
          page.results.map((e) => MonthlyBalanceEntity.fromJson(e)).toList();
    }
    return right(monthlyBalances);
  }
}
