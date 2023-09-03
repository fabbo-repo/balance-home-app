import 'dart:math';
import 'package:balance_home_app/src/core/presentation/models/min_max.dart';
import 'package:balance_home_app/src/core/presentation/widgets/chart_indicator.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/monthly_balance_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticsSavingsYearLineChart extends ConsumerWidget {
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
          final style = GoogleFonts.openSans(
            fontSize: 12,
          );
          String month = monthList[value.toInt() - 1];
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 5,
            child: Text(month, style: style),
          );
        },
      );

  SideTitles get leftTitles => SideTitles(
        getTitlesWidget: (double value, TitleMeta meta) {
          final style = GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          );
          return Text("$value", style: style, textAlign: TextAlign.center);
        },
        showTitles: true,
        interval: (([
                  getMinMaxQuantity().max.ceilToDouble(),
                  getMinMaxQuantity().min.floorToDouble().abs()
                ].reduce(max)) /
                5)
            .abs()
            .ceilToDouble(),
        reservedSize: 40,
      );

  /// Border chart side tittles setup
  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        // Ignore right details
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // Ignore top details
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles,
        ),
      );

  List<LineChartBarData> get lineBarsData => [
        quantityChartBarData(),
        expectedChartBarData(),
      ];

  final List<String> monthList;
  final List<MonthlyBalanceEntity> monthlyBalances;

  final minMaxModelState = ValueNotifier<MinMax?>(null);

  StatisticsSavingsYearLineChart(
      {required this.monthList,
      required this.monthlyBalances,
      MinMax? minMaxModel,
      super.key}) {
    minMaxModelState.value = minMaxModel;
  }

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
                gridData: const FlGridData(show: true),
                titlesData: titlesData,
                borderData: borderData,
                lineBarsData: lineBarsData,
                minX: 1,
                maxX: 12,
                maxY: getMinMaxQuantity().max.ceilToDouble(),
                minY: getMinMaxQuantity().min.floorToDouble(),
              ),
              duration: const Duration(milliseconds: 250),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChartIndicator(
                color: const Color.fromARGB(225, 224, 167, 231),
                text: appLocalizations.expected,
                isSquare: true,
              ),
              const SizedBox(width: 10),
              ChartIndicator(
                color: const Color.fromARGB(184, 7, 95, 15),
                text: appLocalizations.quantity,
                isSquare: true,
              ),
            ],
          )
        ],
      ),
    );
  }

  @visibleForTesting
  LineChartBarData quantityChartBarData() {
    // Dictionary with months and gross quantities per month
    Map<int, double> spotsMap = {};
    for (MonthlyBalanceEntity monthlyBalance in monthlyBalances) {
      if (spotsMap.containsKey(monthlyBalance.month)) {
        spotsMap[monthlyBalance.month] =
            spotsMap[monthlyBalance.month]! + monthlyBalance.grossQuantity;
      } else {
        spotsMap[monthlyBalance.month] = monthlyBalance.grossQuantity;
      }
      spotsMap[monthlyBalance.month] =
          (spotsMap[monthlyBalance.month]! * 100).roundToDouble() / 100;
    }
    // Check unexistant months
    for (int month = 1; month <= 12; month++) {
      if (!spotsMap.containsKey(month)) {
        spotsMap[month] = 0.0;
      }
    }
    // Data conversion
    List<FlSpot> spots = [];
    for (int month in spotsMap.keys.toList()..sort()) {
      spots.add(FlSpot(month.toDouble(), spotsMap[month]!.toDouble()));
    }
    return LineChartBarData(
        isCurved: true,
        preventCurveOverShooting: true,
        color: const Color.fromARGB(184, 7, 95, 15),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: const Color.fromARGB(34, 9, 82, 15),
        ),
        spots: spots);
  }

  @visibleForTesting
  LineChartBarData expectedChartBarData() {
    // Dictionary with months and expected quantities per month
    Map<int, double> spotsMap = {};
    for (MonthlyBalanceEntity monthlyBalance in monthlyBalances) {
      if (spotsMap.containsKey(monthlyBalance.month)) {
        spotsMap[monthlyBalance.month] =
            spotsMap[monthlyBalance.month]! + monthlyBalance.expectedQuantity;
      } else {
        spotsMap[monthlyBalance.month] = monthlyBalance.expectedQuantity;
      }
      spotsMap[monthlyBalance.month] =
          (spotsMap[monthlyBalance.month]! * 100).roundToDouble() / 100;
    }
    // Check unexistant months
    for (int month = 1; month <= 12; month++) {
      if (!spotsMap.containsKey(month)) {
        spotsMap[month] = 0.0;
      }
    }
    // Data conversion
    List<FlSpot> spots = [];
    for (int month in spotsMap.keys.toList()..sort()) {
      spots.add(FlSpot(month.toDouble(), spotsMap[month]!.toDouble()));
    }
    return LineChartBarData(
        isCurved: true,
        preventCurveOverShooting: true,
        color: const Color.fromARGB(225, 224, 167, 231),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: const Color.fromARGB(47, 224, 167, 231),
        ),
        spots: spots);
  }

  @visibleForTesting
  MinMax getMinMaxQuantity() {
    if (minMaxModelState.value != null) return minMaxModelState.value!;
    double maxQuantity = 4.0;
    double minQuantity = 0.0;
    Map<String, double> quantityMap = {};
    Map<String, double> expectedMap = {};
    for (MonthlyBalanceEntity monthlyBalance in monthlyBalances) {
      String key = "${monthlyBalance.month}";
      if (quantityMap.containsKey(key)) {
        quantityMap[key] = quantityMap[key]! + monthlyBalance.grossQuantity;
      } else {
        quantityMap[key] = monthlyBalance.grossQuantity;
      }
      if (expectedMap.containsKey(key)) {
        expectedMap[key] = expectedMap[key]! + monthlyBalance.expectedQuantity;
      } else {
        expectedMap[key] = monthlyBalance.expectedQuantity;
      }
    }
    if (monthlyBalances.isNotEmpty) {
      maxQuantity = quantityMap.values.reduce(max);
      double maxExpected = expectedMap.values.reduce(max);
      if (maxQuantity < maxExpected) maxQuantity = maxExpected;
      minQuantity = quantityMap.values.reduce(min);
      double minExpected = expectedMap.values.reduce(min);
      if (minQuantity > minExpected) minQuantity = minExpected;
    }
    if (maxQuantity < 4) maxQuantity = 4;
    if (minQuantity > 0) minQuantity = 0;
    minMaxModelState.value = MinMax(min: minQuantity, max: maxQuantity);
    return minMaxModelState.value!;
  }
}
