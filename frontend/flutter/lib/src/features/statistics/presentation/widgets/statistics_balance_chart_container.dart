import 'package:balance_home_app/config/platform_utils.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/presentation/states/selected_date_state.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_line_chart.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/statistics/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatisticsBalanceChartContainer extends ConsumerWidget {
  final SelectedDateMode dateMode;
  final List<BalanceEntity> revenues;
  final List<BalanceEntity> expenses;
  final List<int> revenueYears;
  final List<int> expenseYears;

  const StatisticsBalanceChartContainer(
      {required this.dateMode,
      required this.revenues,
      required this.expenses,
      required this.revenueYears,
      required this.expenseYears,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final selectedDate = ref.watch(statisticsBalanceSelectedDateProvider);
    final selectedDateState =
        ref.read(statisticsBalanceSelectedDateProvider.notifier);
    List<int> years = <int>{...revenueYears, ...expenseYears}.toList();
    int selectedYear = selectedDate.year;
    // Month names list
    List<String> months = DateUtil.getMonthList(appLocalizations);
    String selectedMonth =
        DateUtil.monthNumToString(selectedDate.month, appLocalizations);
    // Adding selected year to years list
    if (!years.contains(selectedYear)) years.add(selectedYear);
    // Adding current year to years list
    if (!years.contains(DateTime.now().year)) years.add(DateTime.now().year);
    years.sort();
    // Screen sizes:
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double chartLineHeight = (screenHeight * 0.45 <= 200)
        ? 200
        : (screenHeight * 0.45 <= 350)
            ? screenHeight * 0.45
            : 350;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 114, 187, 83),
              height: 45,
              width: (PlatformUtils().isSmallWindow(context))
                  ? screenWidth * 0.80
                  : screenWidth * 0.35,
              child: Center(
                  child: Text(
                      dateMode == SelectedDateMode.month
                          ? "${appLocalizations.balanceChartTitle} $selectedMonth"
                          : "${appLocalizations.balanceChartTitle} $selectedYear",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
            ),
            dateButton(
                selectedMonth,
                selectedYear,
                months,
                years.map((e) => e.toString()).toList(),
                selectedDate,
                selectedDateState,
                appLocalizations)
          ],
        ),
        SizedBox(
            height: chartLineHeight,
            width: (PlatformUtils().isSmallWindow(context))
                ? screenWidth * 0.95
                : screenWidth * 0.45,
            child: BalanceLineChart(
              monthList: months,
              revenues: dateMode == SelectedDateMode.month
                  ? getRevenues(selectedDate.month)
                  : revenues,
              expenses: dateMode == SelectedDateMode.month
                  ? getExpenses(selectedDate.month)
                  : expenses,
              selectedDateMode: dateMode,
              selectedMonth:
                  DateUtil.monthStringToNum(selectedMonth, appLocalizations),
              selectedYear: selectedDate.year,
            )),
      ],
    );
  }

  @visibleForTesting
  Widget dateButton(
      String selectedMonth,
      int selectedYear,
      List<String> months,
      List<String> years,
      SelectedDate selectedDate,
      SelectedDateState selectedDateState,
      AppLocalizations appLocalizations) {
    List<String> values = (dateMode == SelectedDateMode.month) ? months : years;
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      color: const Color.fromARGB(255, 195, 187, 56),
      padding: const EdgeInsets.only(left: 10, right: 10),
      height: 45,
      child: DropdownButton<String>(
          value: (dateMode == SelectedDateMode.month)
              ? selectedMonth
              : "$selectedYear",
          items: values.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            if (dateMode == SelectedDateMode.month) {
              int newMonth = DateUtil.monthStringToNum(value!, appLocalizations);
              if (newMonth == selectedDate.month) return;
              selectedDateState.setMonth(newMonth);
            } else if (dateMode == SelectedDateMode.year) {
              int newYear = int.parse(value!);
              if (newYear == selectedDate.year) return;
              selectedDateState.setYear(newYear);
            }
          }),
    );
  }

  @visibleForTesting
  List<BalanceEntity> getExpenses(int month) {
    List<BalanceEntity> aux = [];
    for (BalanceEntity expense in expenses) {
      if (expense.date.month == month) aux.add(expense);
    }
    return aux;
  }

  @visibleForTesting
  List<BalanceEntity> getRevenues(int month) {
    List<BalanceEntity> aux = [];
    for (BalanceEntity revenue in revenues) {
      if (revenue.date.month == month) aux.add(revenue);
    }
    return aux;
  }
}
