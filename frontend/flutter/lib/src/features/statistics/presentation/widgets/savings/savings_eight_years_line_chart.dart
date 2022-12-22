import 'dart:math';
import 'package:balance_home_app/src/core/infrastructure/datasources/min_max.dart';
import 'package:balance_home_app/src/core/presentation/widgets/chart_indicator.dart';
import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/features/statistics/data/models/annual_balance_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class SavingsEightYearsLineChart extends ConsumerWidget {
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
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 5,
            child: Text("$value", style: style),
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

  List<LineChartBarData> get lineBarsData => [
        quantityChartBarData(),
        expectedChartBarData(),
      ];

  final List<AnnualBalanceModel> annualBalances;
  MinMax? minMaxModel;

  SavingsEightYearsLineChart(
      {required this.annualBalances, this.minMaxModel, super.key});

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
                lineBarsData: lineBarsData,
                minX: DateTime.now().year.toDouble() - 7,
                maxX: DateTime.now().year.toDouble(),
                maxY: getMinMaxQuantity().max.ceilToDouble(),
                minY: getMinMaxQuantity().min.floorToDouble(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 250),
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
    // Dictionary with years and gross quantities per year
    Map<int, double> spotsMap = {};
    for (AnnualBalanceModel annualBalance in annualBalances) {
      if (spotsMap.containsKey(annualBalance.year)) {
        spotsMap[annualBalance.year] =
            spotsMap[annualBalance.year]! + annualBalance.grossQuantity;
      } else {
        spotsMap[annualBalance.year] = annualBalance.grossQuantity;
      }
    }
    // Check unexistant years
    for (int year = DateTime.now().year - 7;
        year <= DateTime.now().year;
        year++) {
      if (!spotsMap.containsKey(year)) {
        spotsMap[year] = 0.0;
      }
    }
    // Data conversion
    List<FlSpot> spots = [];
    for (int year in spotsMap.keys.toList()..sort()) {
      spots.add(FlSpot(year.toDouble(), spotsMap[year]!.toDouble()));
    }
    return LineChartBarData(
        isCurved: true,
        preventCurveOverShooting: true,
        color: const Color.fromARGB(184, 7, 95, 15),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: const Color.fromARGB(34, 9, 82, 15),
        ),
        spots: spots);
  }

  @visibleForTesting
  LineChartBarData expectedChartBarData() {
    // Dictionary with years and expected quantities per year
    Map<int, double> spotsMap = {};
    for (AnnualBalanceModel annualBalance in annualBalances) {
      spotsMap[annualBalance.year] = annualBalance.expectedQuantity;
    }
    // Check unexistant years
    for (int year = DateTime.now().year - 7;
        year <= DateTime.now().year;
        year++) {
      if (!spotsMap.containsKey(year)) {
        spotsMap[year] = 0.0;
      }
    }
    // Data conversion
    List<FlSpot> spots = [];
    for (int year in spotsMap.keys.toList()..sort()) {
      spots.add(FlSpot(year.toDouble(), spotsMap[year]!.toDouble()));
    }
    return LineChartBarData(
        isCurved: true,
        preventCurveOverShooting: true,
        color: const Color.fromARGB(225, 224, 167, 231),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: const Color.fromARGB(47, 224, 167, 231),
        ),
        spots: spots);
  }

  @visibleForTesting
  MinMax getMinMaxQuantity() {
    if (minMaxModel != null) return minMaxModel!;
    double maxQuantity = 4.0;
    double minQuantity = 0.0;
    Map<String, double> quantityMap = {};
    Map<String, double> expectedMap = {};
    for (AnnualBalanceModel annualBalance in annualBalances) {
      String key = "${annualBalance.year}";
      if (quantityMap.containsKey(key)) {
        quantityMap[key] = quantityMap[key]! + annualBalance.grossQuantity;
      } else {
        quantityMap[key] = annualBalance.grossQuantity;
      }
      if (expectedMap.containsKey(key)) {
        expectedMap[key] = expectedMap[key]! + annualBalance.expectedQuantity;
      } else {
        expectedMap[key] = annualBalance.expectedQuantity;
      }
    }
    if (annualBalances.isNotEmpty) {
      maxQuantity = quantityMap.values.reduce(max);
      double maxExpected = expectedMap.values.reduce(max);
      if (maxQuantity < maxExpected) maxQuantity = maxExpected;
      minQuantity = quantityMap.values.reduce(min);
      double minExpected = expectedMap.values.reduce(min);
      if (minQuantity > minExpected) minQuantity = minExpected;
    }
    if (maxQuantity < 4) maxQuantity = 4;
    if (minQuantity > 0) minQuantity = 0;
    minMaxModel = MinMax(min: minQuantity, max: maxQuantity);
    return minMaxModel!;
  }
}
