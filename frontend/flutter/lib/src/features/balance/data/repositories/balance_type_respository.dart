import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_model.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';

abstract class IBalanceTypeRepository {
  Future<BalanceTypeModel> getBalanceType(String name, BalanceTypeEnum balanceTypeEnum);

  Future<List<BalanceTypeModel>> getBalanceTypes(BalanceTypeEnum balanceTypeEnum);
}

class BalanceTypeRepository implements IBalanceTypeRepository {

  final HttpService httpService;

  BalanceTypeRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch a balance type.
  @override
  Future<BalanceTypeModel> getBalanceType(String name, BalanceTypeEnum balanceTypeEnum) async {
    String baseUrl = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      APIContract.expenseType : APIContract.revenueType;
    HttpResponse response = await httpService.sendGetRequest(
      '$baseUrl/$name'
    );
    return BalanceTypeModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch all balance types.
  @override
  Future<List<BalanceTypeModel>> getBalanceTypes(BalanceTypeEnum balanceTypeEnum) async {
    String baseUrl = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      APIContract.expenseType : APIContract.revenueType;
    int pageNumber = 1; 
    HttpResponse response = await httpService.sendGetRequest(
      '$baseUrl?page=$pageNumber'
    );
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<BalanceTypeModel> balanceTypes = page.results.map((e) => BalanceTypeModel.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService.sendGetRequest(
        '$baseUrl?page=$pageNumber'
      );
      page = PaginationEntity.fromJson(response.content);
      balanceTypes += page.results.map((e) => BalanceTypeModel.fromJson(e)).toList();
      pageNumber ++;
    }
    return balanceTypes;
  }
}