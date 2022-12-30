import 'package:balance_home_app/src/core/domain/entities/pagination_entity.dart';
import 'package:balance_home_app/config/api_contract.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/http_service.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_respository_interface.dart';
import 'package:fpdart/fpdart.dart';

/// Balance Type Repository.
class BalanceTypeRepository implements BalanceTypeRepositoryInterface {
  final HttpService httpService;

  BalanceTypeRepository({required this.httpService});

  /// Get [BalanceTypeEntity] by `name`.
  @override
  Future<Either<Failure, BalanceTypeEntity>> getBalanceType(
      String name, BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseType
        : APIContract.revenueType;
    HttpResponse response = await httpService.sendGetRequest('$baseUrl/$name');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    return right(BalanceTypeEntity.fromJson(response.content));
  }

  /// Get a list of all [BalanceTypeEntity].
  @override
  Future<Either<Failure, List<BalanceTypeEntity>>> getBalanceTypes(
      BalanceTypeMode balanceTypeMode) async {
    String baseUrl = balanceTypeMode == BalanceTypeMode.expense
        ? APIContract.expenseType
        : APIContract.revenueType;
    int pageNumber = 1;
    HttpResponse response =
        await httpService.sendGetRequest('$baseUrl?page=$pageNumber');
    if (response.hasError) {
      return left(Failure.badRequest(message: response.errorMessage));
    }
    PaginationEntity page = PaginationEntity.fromJson(response.content);
    List<BalanceTypeEntity> balanceTypes =
        page.results.map((e) => BalanceTypeEntity.fromJson(e)).toList();
    while (page.next != null) {
      pageNumber++;
      HttpResponse response =
          await httpService.sendGetRequest('$baseUrl?page=$pageNumber');
      if (response.hasError) {
        return left(Failure.badRequest(message: response.errorMessage));
      }
      page = PaginationEntity.fromJson(response.content);
      balanceTypes +=
          page.results.map((e) => BalanceTypeEntity.fromJson(e)).toList();
    }
    return right(balanceTypes);
  }
}
