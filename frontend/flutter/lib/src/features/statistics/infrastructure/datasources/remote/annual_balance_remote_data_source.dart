import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_client.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:fpdart/fpdart.dart';

class AnnualBalanceRemoteDataSource {
  final HttpClient client;

  AnnualBalanceRemoteDataSource({required this.client});

  Future<Either<Failure, AnnualBalanceEntity>> get(int id) async {
    HttpResponse response = await client
        .sendGetRequest('${APIContract.annualBalance}/${id.toString()}');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(AnnualBalanceEntity.fromJson(response.content));
  }

  Future<Either<Failure, List<AnnualBalanceEntity>>> list() async {
    int pageNumber = 1;
    HttpResponse response = await client
        .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<AnnualBalanceEntity> annualBalances =
        page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response = await client
          .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
      if (response.hasError) {
        return left(Failure.badRequest(message: response.errorMessage));
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
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<AnnualBalanceEntity> annualBalances =
        page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
    while (page.next != null && annualBalances.length < 8) {
      pageNumber++;
      HttpResponse response = await client
          .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
      if (response.hasError) {
        return left(Failure.badRequest(message: response.errorMessage));
      }
      page = PaginationEntity.fromJson(response.content);
      annualBalances +=
          page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
    }
    return right(annualBalances.take(8).toList());
  }
}
