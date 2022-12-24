import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_years_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';

/// Balance Repository.
class BalanceRepository implements BalanceRepositoryInterface {
  final HttpService httpService;

  BalanceRepository({required this.httpService});

  /// Get [BalanceEntity] by `id`.
  @override
  Future<BalanceEntity> getBalance(
      int id, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response =
        await httpService.sendGetRequest('$baseUrl/${id.toString()}');
    return balanceTypeMode == BalanceTypeMode.expense
        ? BalanceEntity.fromExpenseJson(response.content)
        : BalanceEntity.fromRevenueJson(response.content);
  }

  /// Get a list of [BalanceEntity].
  @override
  Future<List<BalanceEntity>> getBalances(BalanceTypeMode balanceTypeMode,
      {DateTime? dateFrom, DateTime? dateTo}) async {
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
      page = PaginationEntity.fromJson(response.content);
      balances += page.results.map((e) {
        return balanceTypeMode == BalanceTypeMode.expense
            ? BalanceEntity.fromExpenseJson(e)
            : BalanceEntity.fromRevenueJson(e);
      }).toList();
    }
    return balances;
  }

  /// Get a list of years related to existing [BalanceEntity] years.
  @override
  Future<List<int>> getBalanceYears(BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseYears
        : APIContract.revenueYears;
    HttpResponse response = await httpService.sendGetRequest(baseUrl);
    return BalanceYearsEntity.fromJson(response.content).years;
  }

  /// Store a [BalanceEntity].
  @override
  Future<BalanceEntity> createBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response = await httpService.sendPostRequest(
        '$baseUrl/${balance.id.toString()}',
        balanceTypeMode == BalanceTypeMode.expense
            ? balance.toExpenseJson()
            : balance.toRevenueJson());
    return balanceTypeMode == BalanceTypeMode.expense
        ? BalanceEntity.fromExpenseJson(response.content)
        : BalanceEntity.fromRevenueJson(response.content);
  }

  /// Update a [BalanceEntity].
  @override
  Future<void> updateBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    await httpService.sendPutRequest(
        '$baseUrl/${balance.id.toString()}',
        balanceTypeMode == BalanceTypeMode.expense
            ? balance.toExpenseJson()
            : balance.toRevenueJson());
  }

  /// Delete a [BalanceEntity].
  @override
  Future<void> deleteBalance(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    await httpService.sendDelRequest('$baseUrl/${balance.id.toString()}');
  }
}
