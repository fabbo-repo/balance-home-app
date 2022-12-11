import 'package:balance_home_app/src/core/data/models/pagination_model.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/revenue/data/models/revenue_type_model.dart';

abstract class IRevenueTypeRepository {
  Future<RevenueTypeModel> getRevenueType(String code);

  Future<List<RevenueTypeModel>> getRevenueTypes();
}

class RevenueTypeRepository implements IRevenueTypeRepository {

  final HttpService httpService;

  RevenueTypeRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch an revenue type.
  @override
  Future<RevenueTypeModel> getRevenueType(String name) async {
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.revenueType}/$name'
    );
    return RevenueTypeModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch all revenue types.
  @override
  Future<List<RevenueTypeModel>> getRevenueTypes() async {
    int pageNumber = 1; 
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.revenueType}?page=$pageNumber'
    );
    PaginationModel page = PaginationModel.fromJson(response.content);
    List<RevenueTypeModel> revenueTypes = page.results.map((e) => RevenueTypeModel.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService.sendGetRequest(
        '${APIContract.revenueType}?page=$pageNumber'
      );
      page = PaginationModel.fromJson(response.content);
      revenueTypes += page.results.map((e) => RevenueTypeModel.fromJson(e)).toList();
      pageNumber ++;
    }
    return revenueTypes;
  }
}