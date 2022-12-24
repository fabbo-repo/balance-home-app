import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/http_service.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_respository_interface.dart';

/// Balance Type Repository.
class BalanceTypeRepository implements BalanceTypeRepositoryInterface {
  final HttpService httpService;

  BalanceTypeRepository({required this.httpService});

  /// Get [BalanceTypeEntity] by `name`.
  @override
  Future<BalanceTypeEntity> getBalanceType(
      String name, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseType
        : APIContract.revenueType;
    HttpResponse response = await httpService.sendGetRequest('$baseUrl/$name');
    return BalanceTypeEntity.fromJson(response.content);
  }

  /// Get a list of all [BalanceTypeEntity].
  @override
  Future<List<BalanceTypeEntity>> getBalanceTypes(
      BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseType
        : APIContract.revenueType;
    int pageNumber = 1;
    HttpResponse response =
        await httpService.sendGetRequest('$baseUrl?page=$pageNumber');
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<BalanceTypeEntity> balanceTypes =
        page.results.map((e) => BalanceTypeEntity.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response =
          await httpService.sendGetRequest('$baseUrl?page=$pageNumber');
      page = PaginationEntity.fromJson(response.content);
      balanceTypes +=
          page.results.map((e) => BalanceTypeEntity.fromJson(e)).toList();
      pageNumber++;
    }
    return balanceTypes;
  }
}
