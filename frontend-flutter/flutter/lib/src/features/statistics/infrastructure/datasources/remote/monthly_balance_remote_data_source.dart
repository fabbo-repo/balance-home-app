import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:fpdart/fpdart.dart';

class MonthlyBalanceRemoteDataSource {
  final ApiClient apiClient;

  MonthlyBalanceRemoteDataSource({required this.apiClient});

  Future<Either<Failure, MonthlyBalanceEntity>> get(int id) async {
    final response = await apiClient
        .getRequest('${APIContract.monthlyBalance}/${id.toString()}');
    // Check if there is a request failure
    return response.fold((failure) => left(failure),
        (value) => right(MonthlyBalanceEntity.fromJson(value.data)));
  }

  Future<Either<Failure, List<MonthlyBalanceEntity>>> list({int? year}) async {
    Map<String, dynamic> queryParameters = {"page": 1};
    if (year != null) {
      queryParameters["year"] = year.toString();
    }
    final response = await apiClient.getRequest(APIContract.monthlyBalance,
        queryParameters: queryParameters);
    // Check if there is a request failure
    return await response.fold((failure) => left(failure), (value) async {
      PaginationEntity page = PaginationEntity.fromJson(value.data);
      List<MonthlyBalanceEntity> monthlyBalances =
          page.results.map((e) => MonthlyBalanceEntity.fromJson(e)).toList();
      while (page.next != null) {
        queryParameters["page"]++;
        final response = await apiClient.getRequest(APIContract.monthlyBalance,
            queryParameters: queryParameters);
        // Check if there is a request failure
        response.fold((_) => null, (value) {
          page = PaginationEntity.fromJson(value.data);
          monthlyBalances += page.results
              .map((e) => MonthlyBalanceEntity.fromJson(e))
              .toList();
        });
        if (response.isLeft()) {
          return left(
              response.getLeft().getOrElse(() => HttpRequestFailure.empty()));
        }
      }
      return right(monthlyBalances);
    });
  }
}
