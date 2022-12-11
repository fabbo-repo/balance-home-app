import 'package:balance_home_app/src/core/data/models/pagination_model.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/expense/data/models/expense_type_model.dart';

abstract class IExpenseTypeRepository {
  Future<ExpenseTypeModel> getExpenseType(String code);

  Future<List<ExpenseTypeModel>> getExpenseTypes();
}

class ExpenseTypeRepository implements IExpenseTypeRepository {

  final HttpService httpService;

  ExpenseTypeRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch an expense type.
  @override
  Future<ExpenseTypeModel> getExpenseType(String name) async {
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.expenseType}/$name'
    );
    return ExpenseTypeModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch all expense types.
  @override
  Future<List<ExpenseTypeModel>> getExpenseTypes() async {
    int pageNumber = 1; 
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.expenseType}?page=$pageNumber'
    );
    PaginationModel page = PaginationModel.fromJson(response.content);
    List<ExpenseTypeModel> expenseTypes = page.results.map((e) => ExpenseTypeModel.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService.sendGetRequest(
        '${APIContract.expenseType}?page=$pageNumber'
      );
      page = PaginationModel.fromJson(response.content);
      expenseTypes += page.results.map((e) => ExpenseTypeModel.fromJson(e)).toList();
      pageNumber ++;
    }
    return expenseTypes;
  }
}