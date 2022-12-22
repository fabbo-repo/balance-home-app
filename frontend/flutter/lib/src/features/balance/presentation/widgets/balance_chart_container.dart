import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date_enum.dart';
import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_line_chart.dart';
import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date_model_provider.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state_notifier.dart';
import 'package:balance_home_app/src/core/services/platform_service.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BalanceChartContainer extends ConsumerWidget {
  final StatisticsDataModel statisticsData;
  final SelectedDateEnum dateType;

  const BalanceChartContainer({
    required this.statisticsData,
    required this.dateType,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    SelectedDate selectedBalanceDate = ref.watch(selectedBalanceDateStateNotifierProvider).date;
    SelectedDateStateNotifier selectedBalanceDateNotifier = ref.read(selectedBalanceDateStateNotifierProvider.notifier);
    List<int> years = <int>{
      ...statisticsData.revenueYears, ...statisticsData.expenseYears
    }.toList();
    int selectedYear = selectedBalanceDate.year;
    // Month names list
    List<String> months = DateUtil.getMonthList(appLocalizations);
    String selectedMonth = DateUtil.monthNumToString(
      selectedBalanceDate.month, appLocalizations);
    // Adding selected year to years list
    if (!years.contains(selectedYear)) years.add(selectedYear);
    // Adding current year to years list
    if (!years.contains(DateTime.now().year)) years.add(DateTime.now().year);
    years.sort();
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
                  (dateType == SelectedDateEnum.month) ? 
                    "${appLocalizations.balanceChartTitle} $selectedMonth"
                    : "${appLocalizations.balanceChartTitle} $selectedYear",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  )
                )
              ),
            ),
            dateButton(
              selectedMonth, 
              selectedYear, 
              months, 
              years.map((e) => e.toString()).toList(), 
              selectedBalanceDateNotifier,
              appLocalizations
            )
          ],
        ),
        SizedBox(
          height: chartLineHeight,
          width: (PlatformService().isSmallWindow(context)) ? 
            screenWidth * 0.95 : screenWidth * 0.45,
          child: BalanceLineChart(
            monthList: months,
            revenues: (dateType == SelectedDateEnum.month) ? 
              getRevenues(selectedBalanceDate.month) : statisticsData.revenues,
            expenses: (dateType == SelectedDateEnum.month) ?
              getExpenses(selectedBalanceDate.month) : statisticsData.expenses,
            dateType: dateType,
            selectedMonth: DateUtil.monthStringToNum(selectedMonth, appLocalizations),
            selectedYear: selectedBalanceDate.year,
          )
        ),
      ],
    );
  }

  Widget dateButton(
    String selectedMonth, 
    int selectedYear,
    List<String> months,
    List<String> years,
    SelectedDateStateNotifier selectedBalanceDateNotifier,
    AppLocalizations appLocalizations
  ) {
    List<String> values = (dateType == SelectedDateEnum.month) ?
      months : years;
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      color: const Color.fromARGB(255, 195, 187, 56),
      padding: const EdgeInsets.only(left: 10, right: 10),
      height: 45,
      child: DropdownButton<String>(
        value: (dateType == SelectedDateEnum.month) ? 
          selectedMonth : "$selectedYear",
        items: values.map(
          (value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }
        ).toList(),
        onChanged: (value) {
          if (dateType == SelectedDateEnum.month) {
            selectedBalanceDateNotifier.setMonth(
              DateUtil.monthStringToNum(value!, appLocalizations)
            );
          } else {
            selectedBalanceDateNotifier.setYear(int.parse(value!));
          }
        }
      ),
    );
  }

  List<BalanceModel> getExpenses(int month) {
    List<BalanceModel> aux = [];
    for (BalanceModel expense in statisticsData.expenses) {
      if (expense.date.month == month) aux.add(expense);
    }
    return aux;
  }
  
  List<BalanceModel> getRevenues(int month) {
    List<BalanceModel> aux = [];
    for (BalanceModel revenue in statisticsData.revenues) {
      if (revenue.date.month == month) aux.add(revenue);
    }
    return aux;
  }
}