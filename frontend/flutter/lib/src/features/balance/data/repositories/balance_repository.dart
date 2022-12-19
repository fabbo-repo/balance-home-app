import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:balance_home_app/src/core/data/models/pagination_model.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_years_model.dart';
import 'package:flutter/cupertino.dart';

abstract class IBalanceRepository {
  Future<BalanceModel> getBalance(int id, BalanceTypeEnum balanceTypeEnum);

  Future<List<BalanceModel>> getBalances(
    BalanceTypeEnum balanceTypeEnum, {
    DateTime? dateFrom,
    DateTime? dateTo
  });
  
  Future<List<int>> getBalanceYears(BalanceTypeEnum balanceTypeEnum);
  
  Future<BalanceModel> createBalance(BalanceModel balance, BalanceTypeEnum balanceTypeEnum);
  
  Future<void> updateBalance(BalanceModel balance, BalanceTypeEnum balanceTypeEnum);
  
  Future<void> deleteBalance(BalanceModel balance, BalanceTypeEnum balanceTypeEnum);
}

class BalanceRepository implements IBalanceRepository {

  final HttpService httpService;

  BalanceRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch a balance model.
  @override
  Future<BalanceModel> getBalance(int id, BalanceTypeEnum balanceTypeEnum) async {
    String baseUrl = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      APIContract.expense : APIContract.revenue;
    HttpResponse response = await httpService.sendGetRequest(
      '$baseUrl/${id.toString()}'
    );
    response.content["balance_type"] = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      response.content["exp_type"] : response.content["rev_type"];
    return BalanceModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch all balance models.
  @override
  Future<List<BalanceModel>> getBalances(
    BalanceTypeEnum balanceTypeEnum, {
    DateTime? dateFrom,
    DateTime? dateTo
  }) async {
    String baseUrl = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      APIContract.expense : APIContract.revenue;
    String extraArgs = "";
    if (dateFrom != null) {
      extraArgs += "&date_from=${dateFrom.year}-${dateFrom.month}-${dateFrom.day}";
    }
    if (dateTo != null) {
      extraArgs += "&date_to=${dateTo.year}-${dateTo.month}-${dateTo.day}";
    }
    int pageNumber = 1;
    HttpResponse response = await httpService.sendGetRequest(
      '$baseUrl?page=$pageNumber$extraArgs'
    );
    PaginationModel page = PaginationModel.fromJson(response.content);
    List<BalanceModel> balances = page.results.map((e) {
      e["balance_type"] = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
        e["exp_type"] : e["rev_type"];
      return BalanceModel.fromJson(e);
    }).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response = await httpService.sendGetRequest(
        '$baseUrl?page=$pageNumber$extraArgs'
      );
      page = PaginationModel.fromJson(response.content);
      balances += page.results.map((e) {
        e["balance_type"] = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
          e["exp_type"] : e["rev_type"];
        return BalanceModel.fromJson(e);
      }).toList();
    }
    return balances;
  }

  /// Sends a [GET] request to backend service to fetch all years with balance models.
  @override
  Future<List<int>> getBalanceYears(BalanceTypeEnum balanceTypeEnum) async {
    String baseUrl = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      APIContract.expenseYears : APIContract.revenueYears;
    HttpResponse response = await httpService.sendGetRequest(baseUrl);
    return BalanceYearsModel.fromJson(response.content).years;
  }

  /// Sends a [POST] request to backend service to create a balance.
  @override
  Future<BalanceModel> createBalance(BalanceModel balance, BalanceTypeEnum balanceTypeEnum) async {
    String baseUrl = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      APIContract.expense : APIContract.revenue;
    HttpResponse response = await httpService.sendPostRequest(
      '$baseUrl/${balance.id.toString()}',
      balanceToJson(balance, balanceTypeEnum)
    );
    return BalanceModel.fromJson(response.content);
  }

  /// Sends a [PUT] request to backend service to update a balance.
  @override
  Future<void> updateBalance(BalanceModel balance, BalanceTypeEnum balanceTypeEnum) async {
    String baseUrl = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      APIContract.expense : APIContract.revenue;
    await httpService.sendPutRequest(
      '$baseUrl/${balance.id.toString()}',
      balanceToJson(balance, balanceTypeEnum)
    );
  }
  
  /// Sends a [PUT] request to backend service to delete a balance.
  @override
  Future<void> deleteBalance(BalanceModel balance, BalanceTypeEnum balanceTypeEnum) async {
    String baseUrl = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      APIContract.expense : APIContract.revenue;
    await httpService.sendDelRequest(
      '$baseUrl/${balance.id.toString()}'
    );
  }

  @visibleForTesting
  Map<String, dynamic> balanceToJson(BalanceModel balance, BalanceTypeEnum balanceTypeEnum) {
    Map<String, dynamic> map = balance.toJson();
    if (balanceTypeEnum == BalanceTypeEnum.expense) {
      map["exp_type"] = map["balance_type"]; 
    } else { 
      map["rev_type"] = map["balance_type"]; 
    }
    map.remove("balance_type");
    return map;
  }
}