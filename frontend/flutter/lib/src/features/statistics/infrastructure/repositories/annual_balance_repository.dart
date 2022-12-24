import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/annual_balance_repository_interface.dart';

class AnnualBalanceRepository implements AnnualBalanceRepositoryInterface {
  final HttpService httpService;

  AnnualBalanceRepository({required this.httpService});

  /// Get [AnnualBalanceEntity] by `id`.
  @override
  Future<AnnualBalanceEntity> getAnnualBalance(int id) async {
    HttpResponse response = await httpService
        .sendGetRequest('${APIContract.annualBalance}/${id.toString()}');
    return AnnualBalanceEntity.fromJson(response.content);
  }

  /// Get a list of [AnnualBalanceEntity].
  @override
  Future<List<AnnualBalanceEntity>> getAnnualBalances() async {
    int pageNumber = 1;
    HttpResponse response = await httpService
        .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<AnnualBalanceEntity> annualBalances =
        page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService
          .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
      page = PaginationEntity.fromJson(response.content);
      annualBalances +=
          page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
      pageNumber++;
    }
    return annualBalances;
  }

  /// Get last eight [AnnualBalanceEntity].
  @override
  Future<List<AnnualBalanceEntity>> getLastEightYearsAnnualBalances() async {
    int pageNumber = 1;
    HttpResponse response = await httpService
        .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<AnnualBalanceEntity> annualBalances =
        page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
    while (page.next != null && annualBalances.length < 8) {
      HttpResponse response = await httpService
          .sendGetRequest('${APIContract.annualBalance}?page=$pageNumber');
      page = PaginationEntity.fromJson(response.content);
      annualBalances +=
          page.results.map((e) => AnnualBalanceEntity.fromJson(e)).toList();
      pageNumber++;
    }
    return annualBalances.take(8).toList();
  }
}
