import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:balance_home_app/src/features/coin/data/models/coin_type_model.dart';
import 'package:balance_home_app/src/features/coin/data/models/date_exchanges_list_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/annual_balance_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/monthly_balance_model.dart';
import 'package:balance_home_app/src/core/data/models/selected_date_model.dart';

class StatisticsDataModel {
  List<BalanceModel> revenues;
  List<BalanceModel> expenses;
  List<int> revenueYears;
  List<int> expenseYears;
  List<MonthlyBalanceModel> monthlyBalances;
  List<AnnualBalanceModel> annualBalances;
  SelectedDateModel selectedBalanceDate;
  SelectedDateModel savingsSelectedDate;
  DateExchangesListModel dateExchangesModel;
  String selectedCoinFrom;
  String selectedCoinTo;
  List<CoinTypeModel> coinTypes;

  StatisticsDataModel({
    required this.revenues,
    required this.expenses,
    required this.revenueYears,
    required this.expenseYears,
    required this.monthlyBalances,
    required this.annualBalances,
    required this.selectedBalanceDate,
    required this.savingsSelectedDate,
    required this.dateExchangesModel,
    required this.selectedCoinFrom,
    required this.selectedCoinTo,
    required this.coinTypes
  });
}