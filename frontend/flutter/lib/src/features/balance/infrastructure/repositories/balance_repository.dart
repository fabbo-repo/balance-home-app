import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/http_service.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_years_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:fpdart/fpdart.dart';

/// Balance Repository.
class BalanceRepository implements BalanceRepositoryInterface {
  final HttpService httpService;

  BalanceRepository({required this.httpService});

  /// Get [BalanceEntity] by `id`.
  @override
  Future<Either<Failure, BalanceEntity>> getBalance(
      int id, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response =
        await httpService.sendGetRequest('$baseUrl/${id.toString()}');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(balanceTypeMode == BalanceTypeMode.expense
        ? BalanceEntity.fromExpenseJson(response.content)
        : BalanceEntity.fromRevenueJson(response.content));
  }

  /// Get a list of [BalanceEntity].
  @override
  Future<Either<Failure, List<BalanceEntity>>> getBalances(
      BalanceTypeMode balanceTypeMode,
      {DateTime? dateFrom,
      DateTime? dateTo}) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    String extraArgs = "";
    if (dateFrom != null) {
      extraArgs +=
          "&date_from=${dateFrom.year}-${dateFrom.month}-${dateFrom.day}";
    }
    if (dateTo != null) {
      extraArgs += "&date_to=${dateTo.year}-${dateTo.month}-${dateTo.day}";
    }
    int pageNumber = 1;
    HttpResponse response =
        await httpService.sendGetRequest('$baseUrl?page=$pageNumber$extraArgs');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<BalanceEntity> balances = page.results.map((e) {
      return balanceTypeMode == BalanceTypeMode.expense
          ? BalanceEntity.fromExpenseJson(e)
          : BalanceEntity.fromRevenueJson(e);
    }).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response = await httpService
          .sendGetRequest('$baseUrl?page=$pageNumber$extraArgs');
      if (response.hasError) {
        return left(Failure.badRequest(message: response.errorMessage));
      }
      page = PaginationEntity.fromJson(response.content);
      balances += page.results.map((e) {
        return balanceTypeMode == BalanceTypeMode.expense
            ? BalanceEntity.fromExpenseJson(e)
            : BalanceEntity.fromRevenueJson(e);
      }).toList();
    }
    return right(balances);
  }

  /// Get a list of years related to existing [BalanceEntity] years.
  @override
  Future<Either<Failure, List<int>>> getBalanceYears(
      BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseYears
        : APIContract.revenueYears;
    HttpResponse response = await httpService.sendGetRequest(baseUrl);
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(BalanceYearsEntity.fromJson(response.content).years);
  }

  /// Store a [BalanceEntity].
  @override
  Future<Either<Failure, BalanceEntity>> createBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response = await httpService.sendPostRequest(
        baseUrl,
        balanceTypeMode == BalanceTypeMode.expense
            ? balance.toExpenseJson()
            : balance.toRevenueJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(balanceTypeMode == BalanceTypeMode.expense
        ? BalanceEntity.fromExpenseJson(response.content,
            type: balance.balanceType)
        : BalanceEntity.fromRevenueJson(response.content,
            type: balance.balanceType));
  }

  /// Update a [BalanceEntity].
  @override
  Future<Either<Failure, BalanceEntity>> updateBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response = await httpService.sendPutRequest(
        '$baseUrl/${balance.id.toString()}',
        balanceTypeMode == BalanceTypeMode.expense
            ? balance.toExpenseJson()
            : balance.toRevenueJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(balanceTypeMode == BalanceTypeMode.expense
        ? BalanceEntity.fromExpenseJson(response.content)
        : BalanceEntity.fromRevenueJson(response.content));
  }

  /// Delete a [BalanceEntity].
  @override
  Future<Either<Failure, void>> deleteBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response =
        await httpService.sendDelRequest('$baseUrl/${balance.id.toString()}');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(null);
  }
}
