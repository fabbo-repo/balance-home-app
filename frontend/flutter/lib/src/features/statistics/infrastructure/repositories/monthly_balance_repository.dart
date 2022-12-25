import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/monthly_balance_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class MonthlyBalanceRepository implements MonthlyBalanceRepositoryInterface {
  final HttpService httpService;

  MonthlyBalanceRepository({required this.httpService});

  /// Get [MonthlyBalanceEntity] by `id`.
  @override
  Future<Either<Failure, MonthlyBalanceEntity>> getMonthlyBalance(
      int id) async {
    HttpResponse response = await httpService
        .sendGetRequest('${APIContract.monthlyBalance}/${id.toString()}');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(MonthlyBalanceEntity.fromJson(response.content));
  }

  /// Get a list of [MonthlyBalanceEntity].
  @override
  Future<Either<Failure, List<MonthlyBalanceEntity>>> getMonthlyBalances(
      {int? year}) async {
    String extraArgs = "";
    if (year != null) {
      extraArgs += "&year=$year";
    }
    int pageNumber = 1;
    HttpResponse response = await httpService.sendGetRequest(
        '${APIContract.monthlyBalance}?page=$pageNumber$extraArgs');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<MonthlyBalanceEntity> monthlyBalances =
        page.results.map((e) => MonthlyBalanceEntity.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService.sendGetRequest(
          '${APIContract.monthlyBalance}?page=$pageNumber$extraArgs');
      if (response.hasError) {
        return left(Failure.badRequest(message: response.errorMessage));
      }
      page = PaginationEntity.fromJson(response.content);
      monthlyBalances +=
          page.results.map((e) => MonthlyBalanceEntity.fromJson(e)).toList();
      pageNumber++;
    }
    return right(monthlyBalances);
  }
}
