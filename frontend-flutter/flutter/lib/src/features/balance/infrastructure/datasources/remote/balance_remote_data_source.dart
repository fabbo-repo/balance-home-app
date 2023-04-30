import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/utils/failure_utils.dart';
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
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold(
        (failure) => left(failure),
        (body) => right(balanceTypeMode == BalanceTypeMode.expense
            ? BalanceEntity.fromExpenseJson(body)
            : BalanceEntity.fromRevenueJson(body)));
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
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    if (responseCheck.isLeft()) {
      return left(
          responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<BalanceEntity> balances = page.results.map((e) {
      return balanceTypeMode == BalanceTypeMode.expense
          ? BalanceEntity.fromExpenseJson(e)
          : BalanceEntity.fromRevenueJson(e);
    }).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response =
          await client.sendGetRequest('$baseUrl?page=$pageNumber$extraArgs');
      // Check if there is a request failure
      final responseCheck = FailureUtils.checkResponse(
          body: response.content, statusCode: response.statusCode);
      if (responseCheck.isLeft()) {
        return left(
            responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
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
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold((failure) => left(failure),
        (body) => right(BalanceYearsEntity.fromJson(body).years));
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
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold(
        (failure) => left(failure),
        (body) => right(balanceTypeMode == BalanceTypeMode.expense
            ? BalanceEntity.fromExpenseJson(body)
            : BalanceEntity.fromRevenueJson(body)));
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
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold(
        (failure) => left(failure),
        (body) => right(balanceTypeMode == BalanceTypeMode.expense
            ? BalanceEntity.fromExpenseJson(body)
            : BalanceEntity.fromRevenueJson(body)));
  }

  Future<Either<Failure, void>> delete(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    HttpResponse response =
        await client.sendDelRequest('$baseUrl/${balance.id.toString()}');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold(
        (failure) => left(failure), (body) => right(null));
  }
}
