import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/utils/failure_utils.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:fpdart/fpdart.dart';

class AnnualBalanceRemoteDataSource {
  final HttpClient client;

  AnnualBalanceRemoteDataSource({required this.client});

  Future<Either<Failure, AnnualBalanceEntity>> get(int id) async {
    HttpResponse response = await client
        .sendGetRequest('${APIContract.annualBalance}/${id.toString()}');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    return responseCheck.fold((failure) => left(failure),
        (body) => right(AnnualBalanceEntity.fromJson(body)));
  }

  Future<Either<Failure, List<AnnualBalanceEntity>>> list() async {
    int pageNumber = 1;
    HttpResponse response = await client
        .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    if (responseCheck.isLeft()) {
      return left(
          responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<AnnualBalanceEntity> annualBalances =
        page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response = await client
          .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
      // Check if there is a request failure
      final responseCheck = FailureUtils.checkResponse(
          body: response.content, statusCode: response.statusCode);
      if (responseCheck.isLeft()) {
        return left(
            responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
      }
      page = PaginationEntity.fromJson(response.content);
      annualBalances +=
          page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
    }
    return right(annualBalances);
  }

  Future<Either<Failure, List<AnnualBalanceEntity>>> getLastEightYears() async {
    int pageNumber = 1;
    HttpResponse response = await client
        .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
    // Check if there is a request failure
    final responseCheck = FailureUtils.checkResponse(
        body: response.content, statusCode: response.statusCode);
    if (responseCheck.isLeft()) {
      return left(
          responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<AnnualBalanceEntity> annualBalances =
        page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
    while (page.next != null && annualBalances.length < 8) {
      pageNumber++;
      HttpResponse response = await client
          .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
      // Check if there is a request failure
      final responseCheck = FailureUtils.checkResponse(
          body: response.content, statusCode: response.statusCode);
      if (responseCheck.isLeft()) {
        return left(
            responseCheck.getLeft().getOrElse(() => const EmptyFailure()));
      }
      page = PaginationEntity.fromJson(response.content);
      annualBalances +=
          page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
    }
    return right(annualBalances.take(8).toList());
  }
}
