import 'package:balance_home_app/src/core/data/models/pagination_model.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/statistics/data/models/monthly_balance_model.dart';

abstract class IMonthlyBalanceRepository {
  Future<MonthlyBalanceModel> getMonthlyBalance(int id);

  Future<List<MonthlyBalanceModel>> getMonthlyBalances({int? year});
}

class MonthlyBalanceRepository implements IMonthlyBalanceRepository {

  final HttpService httpService;

  MonthlyBalanceRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch a monthly balance.
  @override
  Future<MonthlyBalanceModel> getMonthlyBalance(int id) async {
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.monthlyBalance}/${id.toString()}'
    );
    return MonthlyBalanceModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch all monthly balances.
  @override
  Future<List<MonthlyBalanceModel>> getMonthlyBalances({int? year}) async {
    String extraArgs = "";
    if (year != null) {
      extraArgs += "&year=$year";
    }
    int pageNumber = 1; 
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.monthlyBalance}?page=$pageNumber$extraArgs'
    );
    PaginationModel page = PaginationModel.fromJson(response.content);
    List<MonthlyBalanceModel> monthlyBalances = page.results.map((e) => MonthlyBalanceModel.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService.sendGetRequest(
        '${APIContract.monthlyBalance}?page=$pageNumber$extraArgs'
      );
      page = PaginationModel.fromJson(response.content);
      monthlyBalances += page.results.map((e) => MonthlyBalanceModel.fromJson(e)).toList();
      pageNumber ++;
    }
    return monthlyBalances;
  }
}