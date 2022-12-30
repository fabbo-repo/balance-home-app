import 'dart:math';
import 'package:balance_home_app/config/platform_utils.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/presentation/widgets/chart_indicator.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceLineChart extends ConsumerWidget {
  /// Border chart lines decoration
  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: Colors.black, width: 2),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 22,
        interval: PlatformUtils().isSmallWindow(navigatorKey.currentContext!) &&
                selectedDateMode == SelectedDateMode.month
            ? 2
            : 1,
        getTitlesWidget: (double value, TitleMeta meta) {
          const style = TextStyle(
            color: Colors.black,
            fontSize: 12,
          );
          String tittle = (selectedDateMode == SelectedDateMode.year)
              ? monthList[value.toInt() - 1]
              : "${value.toInt()}";
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 5,
            child: Text(tittle, style: style),
          );
        },
      );

  SideTitles get leftTitles => SideTitles(
        getTitlesWidget: (double value, TitleMeta meta) {
          const style = TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          );
          return Text("${value.toInt()}",
              style: style, textAlign: TextAlign.center);
        },
        showTitles: true,
        interval: (getMaxQuantity() / 5).ceilToDouble(),
        reservedSize: 30,
      );

  /// Border chart side tittles setup
  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        // Ignore right details
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // Ignore top details
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles,
        ),
      );

  /// List containing every month's translation
  final List<String> monthList;

  /// List of revenues. If empty then all revenues are
  /// set to 0, if `null` then revenue line are not shown
  final List<BalanceEntity>? revenues;

  /// List of expenses. If empty then all expenses are
  /// set to 0, if `null` then expense line are not shown
  final List<BalanceEntity>? expenses;

  final SelectedDateMode selectedDateMode;

  /// Required for `SelectedDate.month` as [dateType]
  final int? selectedMonth;

  /// Required for `SelectedDate.month` as [dateType]
  final int? selectedYear;

  const BalanceLineChart(
      {required this.monthList,
      required this.revenues,
      required this.expenses,
      required this.selectedDateMode,
      required this.selectedMonth,
      required this.selectedYear,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: titlesData,
                borderData: borderData,
                lineBarsData: [
                  if (revenues != null)
                    balancesChartBarData(revenues!, BalanceTypeMode.revenue),
                  if (expenses != null)
                    balancesChartBarData(expenses!, BalanceTypeMode.expense),
                ],
                minX: 1,
                maxX: selectedDateMode == SelectedDateMode.year
                    ? 12
                    : DateUtils.getDaysInMonth(
                            selectedYear ?? DateTime.now().year,
                            selectedMonth ?? DateTime.now().month)
                        .toDouble(),
                maxY: getMaxQuantity(),
                minY: 0,
              ),
              swapAnimationDuration: const Duration(milliseconds: 250),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (revenues != null)
                ChartIndicator(
                  color: const Color.fromARGB(184, 0, 175, 15),
                  text: appLocalizations.revenues,
                  isSquare: true,
                ),
              if (revenues != null && expenses != null)
                const SizedBox(width: 10),
              if (expenses != null)
                ChartIndicator(
                  color: const Color.fromARGB(188, 255, 17, 0),
                  text: appLocalizations.expenses,
                  isSquare: true,
                ),
            ],
          )
        ],
      ),
    );
  }

  @visibleForTesting
  LineChartBarData balancesChartBarData(
      List<BalanceEntity> balances, BalanceTypeMode balanceType) {
    // Dictionary with balances quantities per month or day
    Map<int, double> spotsMap = {};
    for (BalanceEntity balance in balances) {
      int key = selectedDateMode == SelectedDateMode.year
          ? balance.date.month
          : balance.date.day;
      if (spotsMap.containsKey(key)) {
        spotsMap[key] = spotsMap[key]! + balance.quantity;
      } else {
        spotsMap[key] = balance.quantity;
      }
    }
    if (selectedDateMode == SelectedDateMode.year) {
      // Check unexistant months
      for (int month = 1; month <= 12; month++) {
        if (!spotsMap.containsKey(month)) spotsMap[month] = 0.0;
      }
    } else if (selectedDateMode == SelectedDateMode.month) {
      int days = DateUtils.getDaysInMonth(selectedYear ?? DateTime.now().year,
          selectedMonth ?? DateTime.now().month);
      // Check unexistant days
      for (int day = 1; day <= days; day++) {
        if (!spotsMap.containsKey(day)) spotsMap[day] = 0.0;
      }
    }
    // Data conversion
    List<FlSpot> spots = [];
    for (int key in spotsMap.keys.toList()..sort()) {
      spots.add(FlSpot(key.toDouble(), spotsMap[key]!.toDouble()));
    }
    return LineChartBarData(
        isCurved: true,
        preventCurveOverShooting: true,
        color: (balanceType == BalanceTypeMode.expense)
            ? const Color.fromARGB(188, 255, 17, 0)
            : const Color.fromARGB(184, 0, 175, 15),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: (balanceType == BalanceTypeMode.expense)
              ? const Color.fromARGB(55, 212, 117, 117)
              : const Color.fromARGB(55, 0, 175, 15),
        ),
        spots: spots);
  }

  @visibleForTesting
  double getMaxQuantity() {
    double quantity = 4.0;
    Map<String, double> quantityMap = {};
    if (revenues != null) {
      for (BalanceEntity revenue in revenues!) {
        String key = selectedDateMode == SelectedDateMode.year
            ? "${revenue.date.month}"
            : "${revenue.date.day}";
        if (quantityMap.containsKey(key)) {
          quantityMap[key] = quantityMap[key]! + revenue.quantity;
        } else {
          quantityMap[key] = revenue.quantity;
        }
      }
      if (revenues!.isNotEmpty) {
        quantity = quantityMap.values.reduce(max);
      }
    }
    quantityMap = {};
    if (expenses != null) {
      for (BalanceEntity expense in expenses!) {
        String key = (selectedDateMode == SelectedDateMode.year)
            ? "${expense.date.month}"
            : "${expense.date.day}";
        if (quantityMap.containsKey(key)) {
          quantityMap[key] = quantityMap[key]! + expense.quantity;
        } else {
          quantityMap[key] = expense.quantity;
        }
      }
      if (expenses!.isNotEmpty && quantity < quantityMap.values.reduce(max)) {
        quantity = quantityMap.values.reduce(max);
      }
    }
    // Maximun default value is 4
    if (quantity < 4) quantity = 4;
    return quantity.ceilToDouble();
  }
}
