import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/utils/failure_utils.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:fpdart/fpdart.dart';

class BalanceTypeRemoteDataSource {
  final HttpClient client;

  BalanceTypeRemoteDataSource({required this.client});

  Future<Either<Failure, BalanceTypeEntity>> get(
      String name, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseType
        : APIContract.revenueType;
    HttpResponse response = await client.sendGetRequest('$baseUrl/$name');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold((failure) => left(failure),
        (body) => right(BalanceTypeEntity.fromJson(body)));
  }

  Future<Either<Failure, List<BalanceTypeEntity>>> list(
      BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseType
        : APIContract.revenueType;
    int pageNumber = 1;
    HttpResponse response =
        await client.sendGetRequest('$baseUrl?page=$pageNumber');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    if (responseCheck.isLeft()) {
      return left(
          responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<BalanceTypeEntity> balanceTypes =
        page.results.map((e) => BalanceTypeEntity.fromJson(e)).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response =
          await client.sendGetRequest('$baseUrl?page=$pageNumber');
      // Check if there is a request failure
      final responseCheck = FailureUtils.checkResponse(
          body: response.content, statusCode: response.statusCode);
      if (responseCheck.isLeft()) {
        return left(
            responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
      }
      page = PaginationEntity.fromJson(response.content);
      balanceTypes +=
          page.results.map((e) => BalanceTypeEntity.fromJson(e)).toList();
    }
    return right(balanceTypes);
  }
}
