import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:balance_home_app/src/core/utils/platform_utils.dart';
import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/statistics_savings_year_line_chart.dart';
import 'package:balance_home_app/src/features/statistics/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsSavingsYearChartContainer extends ConsumerWidget {
  final List<MonthlyBalanceEntity> monthlyBalances;
  final List<int> revenueYears;
  final List<int> expenseYears;

  const StatisticsSavingsYearChartContainer(
      {required this.monthlyBalances,
      required this.revenueYears,
      required this.expenseYears,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = connectionStateListenable.value;
    final appLocalizations = ref.watch(appLocalizationsProvider);
    SelectedDate selectedDate =
        ref.watch(statisticsSavingsSelectedDateProvider);
    final selectedDateState =
        ref.read(statisticsSavingsSelectedDateProvider.notifier);
    List<int> years = <int>{...revenueYears, ...expenseYears}.toList();
    int selectedYear = selectedDate.year;
    // Month names list
    List<String> months = DateUtil.getMonthList(appLocalizations);
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
              color: const Color.fromARGB(255, 194, 56, 235),
              height: 45,
              width: (PlatformUtils().isSmallWindow(context))
                  ? screenWidth * 0.70
                  : screenWidth * 0.35,
              child: Center(
                  child: Text(
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      "${appLocalizations.savingsChartTitle} $selectedYear")),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 179, 141, 247),
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: 45,
              child: DropdownButton<int>(
                  value: selectedYear,
                  items: years.map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (isConnected)
                      ? (year) {
                          if (year! != selectedDate.year) {
                            selectedDateState.setYear(year);
                          }
                        }
                      : null),
            )
          ],
        ),
        SizedBox(
            height: chartLineHeight,
            width: (PlatformUtils().isSmallWindow(context))
                ? screenWidth * 0.95
                : screenWidth * 0.45,
            child: StatisticsSavingsYearLineChart(
                monthList: months, monthlyBalances: monthlyBalances)),
      ],
    );
  }
}
