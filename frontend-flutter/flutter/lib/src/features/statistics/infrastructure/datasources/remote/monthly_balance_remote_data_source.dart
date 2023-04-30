import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/utils/failure_utils.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:fpdart/fpdart.dart';

class MonthlyBalanceRemoteDataSource {
  final HttpClient client;

  MonthlyBalanceRemoteDataSource({required this.client});

  Future<Either<Failure, MonthlyBalanceEntity>> get(int id) async {
    HttpResponse response = await client
        .sendGetRequest('${APIContract.monthlyBalance}/${id.toString()}');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold((failure) => left(failure),
        (body) => right(MonthlyBalanceEntity.fromJson(body)));
  }

  Future<Either<Failure, List<MonthlyBalanceEntity>>> list({int? year}) async {
    String extraArgs = "";
    if (year != null) {
      extraArgs += "&year=$year";
    }
    int pageNumber = 1;
    HttpResponse response = await client.sendGetRequest(
        '${APIContract.monthlyBalance}?page=$pageNumber$extraArgs');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    if (responseCheck.isLeft()) {
      return left(
          responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<MonthlyBalanceEntity> monthlyBalances =
        page.results.map((e) => MonthlyBalanceEntity.fromJson(e)).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response = await client.sendGetRequest(
          '${APIContract.monthlyBalance}?page=$pageNumber$extraArgs');
      // Check if there is a request failure
      final responseCheck = FailureUtils.checkResponse(
          body: response.content, statusCode: response.statusCode);
      if (responseCheck.isLeft()) {
        return left(
            responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
      }
      page = PaginationEntity.fromJson(response.content);
      monthlyBalances +=
          page.results.map((e) => MonthlyBalanceEntity.fromJson(e)).toList();
    }
    return right(monthlyBalances);
  }
}
