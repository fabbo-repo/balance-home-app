import 'package:balance_home_app/src/core/data/models/balance_years_model.dart';
import 'package:balance_home_app/src/core/data/models/pagination_model.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/revenue/data/models/revenue_model.dart';

abstract class IRevenueRepository {
  Future<RevenueModel> getRevenue(int id);

  Future<List<RevenueModel>> getRevenues({
    DateTime? dateFrom,
    DateTime? dateTo
  });

  Future<List<int>> getRevenueYears();
  
  Future<void> createRevenue(RevenueModel revenue);
  
  Future<void> updateRevenue(RevenueModel revenue);
}

class RevenueRepository implements IRevenueRepository {

  final HttpService httpService;

  RevenueRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch a revenue.
  @override
  Future<RevenueModel> getRevenue(int id) async {
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.revenue}/${id.toString()}'
    );
    return RevenueModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch all revenues.
  @override
  Future<List<RevenueModel>> getRevenues({
    DateTime? dateFrom,
    DateTime? dateTo
  }) async {
    String extraArgs = "";
    if (dateFrom != null) {
      extraArgs += "&date_from=${dateFrom.year}-${dateFrom.month}-${dateFrom.day}";
    }
    if (dateTo != null) {
      extraArgs += "&date_to=${dateTo.year}-${dateTo.month}-${dateTo.day}";
    }
    int pageNumber = 1; 
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.revenue}?page=$pageNumber$extraArgs'
    );
    PaginationModel page = PaginationModel.fromJson(response.content);
    List<RevenueModel> revenues = page.results.map((e) => RevenueModel.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService.sendGetRequest(
        '${APIContract.revenue}?page=$pageNumber$extraArgs'
      );
      page = PaginationModel.fromJson(response.content);
      revenues += page.results.map((e) => RevenueModel.fromJson(e)).toList();
      pageNumber ++;
    }
    return revenues;
  }

  /// Sends a [GET] request to backend service to fetch all years with revenues.
  @override
  Future<List<int>> getRevenueYears() async {
    HttpResponse response = await httpService.sendGetRequest(
      APIContract.expenseYears
    );
    return BalanceYearsModel.fromJson(response.content).years;
  }

  /// Sends a [POST] request to backend service to create an revenue.
  @override
  Future<void> createRevenue(RevenueModel revenue) async {
    await httpService.sendPostRequest(
      '${APIContract.revenue}/${revenue.id.toString()}',
      revenue.toJson()
    );
  }

  /// Sends a [PUT] request to backend service to update an revenue.
  @override
  Future<void> updateRevenue(RevenueModel revenue) async {
    await httpService.sendPutRequest(
      '${APIContract.revenue}/${revenue.id.toString()}',
      revenue.toJson()
    );
  }
}