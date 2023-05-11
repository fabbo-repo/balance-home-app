import 'package:balance_home_app/config/api_client.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:fpdart/fpdart.dart';

class BalanceTypeRemoteDataSource {
  final ApiClient apiClient;

  BalanceTypeRemoteDataSource({required this.apiClient});

  Future<Either<Failure, BalanceTypeEntity>> get(
      String name, BalanceTypeMode balanceTypeMode) async {
    String balanceUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseType
        : APIContract.revenueType;
    final response = await apiClient.getRequest('$balanceUrl/$name');
    // Check if there is a request failure
    return response.fold((failure) => left(failure),
        (value) => right(BalanceTypeEntity.fromJson(value.data)));
  }

  Future<Either<Failure, List<BalanceTypeEntity>>> list(
      BalanceTypeMode balanceTypeMode) async {
    String balanceUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseType
        : APIContract.revenueType;
    Map<String, dynamic> queryParameters = {"page": 1};
    final response = await apiClient.getRequest(balanceUrl,
        queryParameters: queryParameters);
    // Check if there is a request failure
    return await response.fold((failure) => left(failure), (value) async {
      PaginationEntity page = PaginationEntity.fromJson(value.data);
      List<BalanceTypeEntity> balanceTypes =
          page.results.map((e) => BalanceTypeEntity.fromJson(e)).toList();
      while (page.next != null) {
        queryParameters["page"]++;
        final response = await apiClient.getRequest(balanceUrl,
            queryParameters: queryParameters);
        // Check if there is a request failure
        response.fold((_) => null, (value) {
          page = PaginationEntity.fromJson(value.data);
          balanceTypes +=
              page.results.map((e) => BalanceTypeEntity.fromJson(e)).toList();
        });
        if (response.isLeft()) {
          return left(
              response.getLeft().getOrElse(() => HttpRequestFailure.empty()));
        }
      }
      return right(balanceTypes);
    });
  }
}
