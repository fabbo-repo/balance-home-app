import 'package:balance_home_app/src/core/data/models/pagination_model.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:balance_home_app/src/features/expense/data/models/expense_model.dart';

abstract class IExpenseRepository {
  Future<ExpenseModel> getExpense(int id);

  Future<List<ExpenseModel>> getExpenses({
    DateTime? dateFrom,
    DateTime? dateTo
  });
  
  Future<void> createExpense(ExpenseModel expense);
  
  Future<void> updateExpense(ExpenseModel expense);
}

class ExpenseRepository implements IExpenseRepository {

  final HttpService httpService;

  ExpenseRepository({required this.httpService});

  /// Sends a [GET] request to backend service to fetch an expense.
  @override
  Future<ExpenseModel> getExpense(int id) async {
    HttpResponse response = await httpService.sendGetRequest(
      '${APIContract.expense}/${id.toString()}'
    );
    return ExpenseModel.fromJson(response.content);
  }

  /// Sends a [GET] request to backend service to fetch all expenses.
  @override
  Future<List<ExpenseModel>> getExpenses({
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
      '${APIContract.expense}?page=$pageNumber$extraArgs'
    );
    PaginationModel page = PaginationModel.fromJson(response.content);
    List<ExpenseModel> expenses = page.results.map((e) => ExpenseModel.fromJson(e)).toList();
    while (page.next != null) {
      HttpResponse response = await httpService.sendGetRequest(
        '${APIContract.expense}?page=$pageNumber$extraArgs'
      );
      page = PaginationModel.fromJson(response.content);
      expenses += page.results.map((e) => ExpenseModel.fromJson(e)).toList();
      pageNumber ++;
    }
    return expenses;
  }

  /// Sends a [POST] request to backend service to create an expense.
  @override
  Future<void> createExpense(ExpenseModel expense) async {
    await httpService.sendPostRequest(
      '${APIContract.expense}/${expense.id.toString()}',
      expense.toJson()
    );
  }

  /// Sends a [PUT] request to backend service to update an expense.
  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await httpService.sendPutRequest(
      '${APIContract.expense}/${expense.id.toString()}',
      expense.toJson()
    );
  }
}