import 'package:balance_home_app/config/api_client.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_years_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';

class BalanceRemoteDataSource {
  final ApiClient apiClient;

  BalanceRemoteDataSource({required this.apiClient});

  Future<Either<Failure, BalanceEntity>> get(
      int id, BalanceTypeMode balanceTypeMode) async {
    String balanceUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    final response = await apiClient.getRequest('$balanceUrl/${id.toString()}');
    // Check if there is a request failure
    return response.fold(
        (failure) => left(failure),
        (value) => right(balanceTypeMode == BalanceTypeMode.expense
            ? BalanceEntity.fromExpenseJson(value.data)
            : BalanceEntity.fromRevenueJson(value.data)));
  }

  Future<Either<Failure, List<BalanceEntity>>> list(
      BalanceTypeMode balanceTypeMode,
      {DateTime? dateFrom,
      DateTime? dateTo}) async {
    String balanceUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    Map<String, dynamic> queryParameters = {"page": 1};
    if (dateFrom != null) {
      queryParameters["date_from"] = DateFormat('yyyy-MM-dd').format(dateFrom);
    }
    if (dateTo != null) {
      queryParameters["date_to"] = DateFormat('yyyy-MM-dd').format(dateTo);
    }
    final response = await apiClient.getRequest(balanceUrl,
        queryParameters: queryParameters);
    // Check if there is a request failure
    return await response.fold((failure) => left(failure), (value) async {
      PaginationEntity page = PaginationEntity.fromJson(value.data);
      List<BalanceEntity> balances = page.results.map((e) {
        return balanceTypeMode == BalanceTypeMode.expense
            ? BalanceEntity.fromExpenseJson(e)
            : BalanceEntity.fromRevenueJson(e);
      }).toList();
      while (page.next != null) {
        queryParameters["page"]++;
        final response = await apiClient.getRequest(balanceUrl,
            queryParameters: queryParameters);
        // Check if there is a request failure
        response.fold((_) => null, (value) {
          page = PaginationEntity.fromJson(value.data);
          balances += page.results.map((e) {
            return balanceTypeMode == BalanceTypeMode.expense
                ? BalanceEntity.fromExpenseJson(e)
                : BalanceEntity.fromRevenueJson(e);
          }).toList();
        });
        if (response.isLeft()) {
          return left(
              response.getLeft().getOrElse(() => HttpRequestFailure.empty()));
        }
      }
      return right(balances);
    });
  }

  Future<Either<Failure, List<int>>> getYears(
      BalanceTypeMode balanceTypeMode) async {
    String balanceUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseYears
        : APIContract.revenueYears;
    final response = await apiClient.getRequest(balanceUrl);
    // Check if there is a request failure
    return response.fold((failure) => left(failure),
        (value) => right(BalanceYearsEntity.fromJson(value.data).years));
  }

  Future<Either<Failure, BalanceEntity>> create(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String balanceUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    final response = await apiClient.postRequest(balanceUrl,
        data: balanceTypeMode == BalanceTypeMode.expense
            ? balance.toExpenseJson()
            : balance.toRevenueJson());
    // Check if there is a request failure
    return response.fold(
        (failure) => left(failure),
        (value) => right(balanceTypeMode == BalanceTypeMode.expense
            ? BalanceEntity.fromExpenseJson(value.data)
            : BalanceEntity.fromRevenueJson(value.data)));
  }

  Future<Either<Failure, BalanceEntity>> update(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String balanceUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    final response = await apiClient.putRequest(
        '$balanceUrl/${balance.id.toString()}',
        data: balanceTypeMode == BalanceTypeMode.expense
            ? balance.toExpenseJson()
            : balance.toRevenueJson());
    // Check if there is a request failure
    return response.fold(
        (failure) => left(failure),
        (value) => right(balanceTypeMode == BalanceTypeMode.expense
            ? BalanceEntity.fromExpenseJson(value.data,
                type: balance.balanceType)
            : BalanceEntity.fromRevenueJson(value.data,
                type: balance.balanceType)));
  }

  Future<Either<Failure, void>> delete(
      BalanceEntity balance, BalanceTypeMode balanceTypeMode) async {
    String balanceUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expense
        : APIContract.revenue;
    final response =
        await apiClient.delRequest('$balanceUrl/${balance.id.toString()}');
    // Check if there is a request failure
    return response.fold((failure) => left(failure), (_) => right(null));
  }
}
