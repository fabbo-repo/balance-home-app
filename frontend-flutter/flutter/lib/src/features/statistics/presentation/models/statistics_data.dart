import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_type_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/date_currency_conversion_list_entity.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';

class StatisticsData {
  List<BalanceEntity> revenues;
  List<BalanceEntity> expenses;
  List<int> revenueYears;
  List<int> expenseYears;
  List<MonthlyBalanceEntity> monthlyBalances;
  List<AnnualBalanceEntity> annualBalances;
  DateCurrencyConversionListEntity dateCurrencyConversion;
  List<CurrencyTypeEntity> currencyTypes;

  StatisticsData({
    required this.revenues,
    required this.expenses,
    required this.revenueYears,
    required this.expenseYears,
    required this.monthlyBalances,
    required this.annualBalances,
    required this.dateCurrencyConversion,
    required this.currencyTypes,
  });
}
