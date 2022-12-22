import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/statistics/data/models/annual_balance_model.dart';

abstract class IAnnualBalanceRepository {
  Future<AnnualBalanceModel> getAnnualBalance(int id);

  Future<List<AnnualBalanceModel>> getAnnualBalances();

  Future<List<AnnualBalanceModel>> getLastEightYearsAnnualBalances();
}

class AnnualBalanceRepository implements IAnnualBalanceRepository {

  final HttpService httpService;

  AnnualBalanceRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch a annual balance.
  @override
  Future<AnnualBalanceModel> getAnnualBalance(int id) async {
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.annualBalance}/${id.toString()}'
    );
    return AnnualBalanceModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch all annual balances.
  @override
  Future<List<AnnualBalanceModel>> getAnnualBalances() async {
    int pageNumber = 1; 
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.revenue}?page=$pageNumber'
    );
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<AnnualBalanceModel> annualBalances = page.results.map((e) => AnnualBalanceModel.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService.sendGetRequest(
        '${APIContract.revenue}?page=$pageNumber'
      );
      page = PaginationEntity.fromJson(response.content);
      annualBalances += page.results.map((e) => AnnualBalanceModel.fromJson(e)).toList();
      pageNumber ++;
    }
    return annualBalances;
  }

  /// Sends a [GET] request to backend service to fetch last
  /// 8 years annual balances.
  @override
  Future<List<AnnualBalanceModel>> getLastEightYearsAnnualBalances() async {
    int pageNumber = 1; 
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.annualBalance}?page=$pageNumber'
    );
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<AnnualBalanceModel> annualBalances = page.results.map((e) => AnnualBalanceModel.fromJson(e)).toList();
    while (page.next != null && annualBalances.length < 8) {
      HttpResponse response = await httpService.sendGetRequest(
        '${APIContract.annualBalance}?page=$pageNumber'
      );
      page = PaginationEntity.fromJson(response.content);
      annualBalances += page.results.map((e) => AnnualBalanceModel.fromJson(e)).toList();
      pageNumber ++;
    }
    return annualBalances.take(8).toList();
  }
}