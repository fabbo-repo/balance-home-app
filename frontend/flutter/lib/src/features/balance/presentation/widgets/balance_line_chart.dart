import 'dart:math';
import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date_enum.dart';
import 'package:balance_home_app/src/core/presentation/widgets/chart_indicator.dart';
import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
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
        interval: 1,
        getTitlesWidget: (double value, TitleMeta meta) {
          const style = TextStyle(
            color: Colors.black,
            fontSize: 12,
          );
          String tittle = (dateType == SelectedDateEnum.year)
              ? monthList[value.toInt() - 1]
              : "$value";
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
            fontSize: 14,
          );
          return Text("$value", style: style, textAlign: TextAlign.center);
        },
        showTitles: true,
        interval: (getMaxQuantity() / 5).ceilToDouble(),
        reservedSize: 40,
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
  final List<BalanceModel>? revenues;

  /// List of expenses. If empty then all expenses are
  /// set to 0, if `null` then expense line are not shown
  final List<BalanceModel>? expenses;

  final SelectedDateEnum dateType;

  /// Required for `SelectedDate.month` as [dateType]
  final int? selectedMonth;

  /// Required for `SelectedDate.month` as [dateType]
  final int? selectedYear;

  const BalanceLineChart(
      {required this.monthList,
      required this.revenues,
      required this.expenses,
      required this.dateType,
      required this.selectedMonth,
      required this.selectedYear,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations =
        ref.watch(localizationStateNotifierProvider).localization;
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
                    balancesChartBarData(revenues!, BalanceTypeEnum.revenue),
                  if (expenses != null)
                    balancesChartBarData(expenses!, BalanceTypeEnum.expense),
                ],
                minX: 1,
                maxX: (dateType == SelectedDateEnum.year)
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
      List<BalanceModel> balances, BalanceTypeEnum balanceType) {
    // Dictionary with balances quantities per month or day
    Map<int, double> spotsMap = {};
    for (BalanceModel balance in balances) {
      int key = (dateType == SelectedDateEnum.year)
          ? balance.date.month
          : balance.date.day;
      if (spotsMap.containsKey(key)) {
        spotsMap[key] = spotsMap[key]! + balance.quantity;
      } else {
        spotsMap[key] = balance.quantity;
      }
    }
    if (dateType == SelectedDateEnum.year) {
      // Check unexistant months
      for (int month = 1; month <= 12; month++) {
        if (!spotsMap.containsKey(month)) spotsMap[month] = 0.0;
      }
    } else if (dateType == SelectedDateEnum.month) {
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
        color: (balanceType == BalanceTypeEnum.expense)
            ? const Color.fromARGB(188, 255, 17, 0)
            : const Color.fromARGB(184, 0, 175, 15),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: (balanceType == BalanceTypeEnum.expense)
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
      for (BalanceModel revenue in revenues!) {
        String key = (dateType == SelectedDateEnum.year)
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
      for (BalanceModel expense in expenses!) {
        String key = (dateType == SelectedDateEnum.year)
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
