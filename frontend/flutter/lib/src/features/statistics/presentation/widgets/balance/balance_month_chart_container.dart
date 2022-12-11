
import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/services/platform_service.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/features/expense/data/models/expense_model.dart';
import 'package:balance_home_app/src/features/revenue/data/models/revenue_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/selected_date_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date/selected_date_model_provider.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date/selected_date_model_state_notifier.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance/balance_month_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceMonthChartContainer extends ConsumerWidget {
  final StatisticsDataModel statisticsData;

  const BalanceMonthChartContainer({
    required this.statisticsData,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    SelectedDateModel selectedBalanceDate = ref.watch(selectedBalanceDateStateNotifierProvider).model;
    SelectedDateModelStateNotifier selectedBalanceDateNotifier = ref.read(selectedBalanceDateStateNotifierProvider.notifier);
    // Month names list
    List<String> months = DateUtil.getMonthList(appLocalizations);
    String selectedMonth = DateUtil.monthNumToString(
      selectedBalanceDate.month, appLocalizations);
    // Screen sizes:
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double chartLineHeight = (screenHeight * 0.45 <= 200) ? 
      200 : (screenHeight * 0.45 <= 350) ? screenHeight * 0.45 : 350;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 114, 187, 83),
              height: 45,
              width: (PlatformService().isSmallWindow(context)) ? 
                screenWidth * 0.80 : screenWidth * 0.35,
              child: Center(
                child: Text(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                  "${appLocalizations.balanceChartTitle} $selectedMonth"
                )
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 195, 187, 56),
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: 45,
              child: DropdownButton<String>(
                value: selectedMonth,
                items: months.map(
                  (month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }
                ).toList(),
                onChanged: (month) {
                  selectedBalanceDateNotifier.setMonth(
                    DateUtil.monthStringToNum(month!, appLocalizations)
                  );
                }
              ),
            )
          ],
        ),
        SizedBox(
          height: chartLineHeight,
          width: (PlatformService().isSmallWindow(context)) ? 
            screenWidth * 0.95 : screenWidth * 0.45,
          child: BalanceMonthLineChart(
            selectedMonth: DateUtil.monthStringToNum(selectedMonth, appLocalizations),
            selectedYear: selectedBalanceDate.year,
            expenses: getExpenses(selectedBalanceDate.month),
            revenues: getRevenues(selectedBalanceDate.month)
          )
        ),
      ],
    );
  }

  List<ExpenseModel> getExpenses(int month) {
    List<ExpenseModel> expenses = [];
    for (ExpenseModel expense in statisticsData.expenses) {
      if (expense.date.month == month) expenses.add(expense);
    }
    return expenses;
  }
  
  List<RevenueModel> getRevenues(int month) {
    List<RevenueModel> revenues = [];
    for (RevenueModel revenue in statisticsData.revenues) {
      if (revenue.date.month == month) revenues.add(revenue);
    }
    return revenues;
  }
}