import 'package:balance_home_app/src/features/expense/data/models/expense_model.dart';
import 'package:balance_home_app/src/features/revenue/data/models/revenue_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/annual_balance_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/monthly_balance_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/selected_date_model.dart';

class StatisticsDataModel {
  List<RevenueModel> revenues;
  List<ExpenseModel> expenses;
  List<int> revenueYears;
  List<int> expenseYears;
  List<MonthlyBalanceModel> monthlyBalances;
  List<AnnualBalanceModel> annualBalances;
  SelectedDateModel selectedBalanceDate;
  SelectedDateModel savingsSelectedDate;

  StatisticsDataModel({
    required this.revenues,
    required this.expenses,
    required this.revenueYears,
    required this.expenseYears,
    required this.monthlyBalances,
    required this.annualBalances,
    required this.selectedBalanceDate,
    required this.savingsSelectedDate
  });
}