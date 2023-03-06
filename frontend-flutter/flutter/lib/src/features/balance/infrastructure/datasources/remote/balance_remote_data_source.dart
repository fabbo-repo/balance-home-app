import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_years_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:fpdart/fpdart.dart';

class BalanceRemoteDataSource {
  final HttpClient client;

  BalanceRemoteDataSource({required this.client});

  Future<Either<Failure, BalanceEntity>> get(
      int id, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response =
        await client.sendGetRequest('$baseUrl/${id.toString()}');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(balanceTypeMode == BalanceTypeMode.expense
        ? BalanceEntity.fromExpenseJson(response.content)
        : BalanceEntity.fromRevenueJson(response.content));
  }

  Future<Either<Failure, List<BalanceEntity>>> list(
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
        await client.sendGetRequest('$baseUrl?page=$pageNumber$extraArgs');
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
      HttpResponse response = await client
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

  Future<Either<Failure, List<int>>> getYears(
      BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseYears
        : APIContract.revenueYears;
    HttpResponse response = await client.sendGetRequest(baseUrl);
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(BalanceYearsEntity.fromJson(response.content).years);
  }

  Future<Either<Failure, BalanceEntity>> create(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response = await client.sendPostRequest(
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

  Future<Either<Failure, BalanceEntity>> update(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response = await client.sendPutRequest(
        '$baseUrl/${balance.id.toString()}',
        balanceTypeMode == BalanceTypeMode.expense
            ? balance.toExpenseJson()
            : balance.toRevenueJson());
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(balanceTypeMode == BalanceTypeMode.expense
        ? BalanceEntity.fromExpenseJson(response.content, type: balance.balanceType)
        : BalanceEntity.fromRevenueJson(response.content, type: balance.balanceType));
  }

  Future<Either<Failure, void>> delete(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response =
        await client.sendDelRequest('$baseUrl/${balance.id.toString()}');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(null);
  }
}
