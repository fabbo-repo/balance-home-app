import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_request_failure.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:fpdart/fpdart.dart';

class AnnualBalanceRemoteDataSource {
  final ApiClient apiClient;

  AnnualBalanceRemoteDataSource({required this.apiClient});

  Future<Either<Failure, AnnualBalanceEntity>> get(int id) async {
    final response = await apiClient
        .getRequest('${APIContract.annualBalance}/${id.toString()}');
    // Check if there is a request failure
    return response.fold((failure) => left(failure),
        (value) => right(AnnualBalanceEntity.fromJson(value.data)));
  }

  Future<Either<Failure, List<AnnualBalanceEntity>>> list() async {
    Map<String, dynamic> queryParameters = {"page": 1};
    final response = await apiClient.getRequest(APIContract.annualBalance,
        queryParameters: queryParameters);
    // Check if there is a request failure
    return await response.fold((failure) => left(failure), (value) async {
      PaginationEntity page = PaginationEntity.fromJson(value.data);
      List<AnnualBalanceEntity> annualBalances =
          page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
      // No more than 10 annual balances data would be needed
      while (page.next != null && annualBalances.length < 10) {
        queryParameters["page"]++;
        final response = await apiClient.getRequest(APIContract.annualBalance,
            queryParameters: queryParameters);
        // Check if there is a request failure
        response.fold((_) => null, (value) {
          page = PaginationEntity.fromJson(value.data);
          annualBalances +=
              page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
        });
        if (response.isLeft()) {
          return left(
              response.getLeft().getOrElse(() => HttpRequestFailure.empty()));
        }
      }
      return right(annualBalances);
    });
  }
}
