import 'dart:math';
import 'package:balance_home_app/src/features/expense/data/models/expense_model.dart';
import 'package:balance_home_app/src/features/revenue/data/models/revenue_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BalanceYearLineChart extends StatelessWidget {
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
      String month = monthList[value.toInt()-1];
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 5,
        child: Text(month, style: style),
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
    interval: 1,
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
    revenueChartBarData(),
    expenseChartBarData(),
  ];
  
  final List<String> monthList;
  final List<RevenueModel> revenues;
  final List<ExpenseModel> expenses;

  const BalanceYearLineChart({
    required this.monthList,
    required this.revenues,
    required this.expenses,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: titlesData,
          borderData: borderData,
          lineBarsData: lineBarsData,
          minX: 1,
          maxX: 12,
          maxY: getMaxQuantity(),
          minY: 0,
        ),
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @visibleForTesting
  LineChartBarData revenueChartBarData() {
    // Dictionary with months and revenue quantities per month
    Map<int, double> spotsMap = {};
    for (RevenueModel revenue in revenues) {
      if (spotsMap.containsKey(revenue.date.month)) {
        spotsMap[revenue.date.month] = spotsMap[revenue.date.month]! + revenue.quantity;
      } else {
        spotsMap[revenue.date.month] = revenue.quantity;
      }
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
      color: const Color.fromARGB(184, 0, 175, 15),
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color.fromARGB(55, 0, 175, 15),
      ),
      spots: spots
    );
  }

  @visibleForTesting
  LineChartBarData expenseChartBarData() { 
    // Dictionary with months and expense quantities per month
    Map<int, double> spotsMap = {};
    for (ExpenseModel expense in expenses) {
      if (spotsMap.containsKey(expense.date.month)) {
        spotsMap[expense.date.month] = spotsMap[expense.date.month]! + expense.quantity;
      } else {
        spotsMap[expense.date.month] = expense.quantity;
      }
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
      color: const Color.fromARGB(188, 255, 17, 0),
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color.fromARGB(55, 212, 117, 117),
      ),
      spots: spots
    );
  }

  @visibleForTesting
  double getMaxQuantity() {
    double quantity = 4.0;
    Map<String, double> quantityMap = {};
    for (RevenueModel revenue in revenues) {
      String key = "${revenue.date.day}${revenue.date.month}";
      if (quantityMap.containsKey(key)) {
        quantityMap[key] = quantityMap[key]! + revenue.quantity;
      } else {
        quantityMap[key] = revenue.quantity;
      }
    }
    if (revenues.isNotEmpty) {
      quantity = quantityMap.values.reduce(max);
    }
    quantityMap = {};
    for (ExpenseModel expense in expenses) {
      String key = "${expense.date.day}${expense.date.month}";
      if (quantityMap.containsKey(key)) {
        quantityMap[key] = quantityMap[key]! + expense.quantity;
      } else {
        quantityMap[key] = expense.quantity;
      }
    }
    if (expenses.isNotEmpty && quantity < quantityMap.values.reduce(max)) {
      quantity = quantityMap.values.reduce(max);
    }
    return quantity.ceil().toDouble();
  }
}