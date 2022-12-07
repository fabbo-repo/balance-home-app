import 'package:balance_home_app/src/features/expense/data/models/expense_model.dart';
import 'package:balance_home_app/src/features/revenue/data/models/revenue_model.dart';

class StatisticsDataModel {
  List<RevenueModel> revenues;
  List<ExpenseModel> expenses;
  List<int> revenueYears;
  List<int> expenseYears;

  StatisticsDataModel({
    required this.revenues,
    required this.expenses,
    required this.revenueYears,
    required this.expenseYears,
  });
}