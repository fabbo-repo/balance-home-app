import 'dart:math';

import 'package:balance_home_app/src/features/expense/data/models/expense_model.dart';
import 'package:balance_home_app/src/features/revenue/data/models/revenue_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BalanceMonthLineChart extends StatelessWidget {
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
        child: Text('$value', style: style),
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

  final int selectedMonth;
  final int selectedYear;
  final List<RevenueModel> revenues;
  final List<ExpenseModel> expenses;
  
  const BalanceMonthLineChart({
    required this.selectedMonth,
    required this.selectedYear,
    required this.revenues,
    required this.expenses,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    int days = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    return Padding(
      padding: const EdgeInsets.all(15),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: titlesData,
          borderData: borderData,
          lineBarsData: lineBarsData,
          minX: 1,
          maxX: days.toDouble(),
          maxY: getMaxQuantity(),
          minY: 0,
        ),
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }


  @visibleForTesting
  LineChartBarData revenueChartBarData() {
    int days = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    // Dictionary with days and revenue quantities per day
    Map<int, double> spotsMap = {};
    for (RevenueModel revenue in revenues) {
      if (spotsMap.containsKey(revenue.date.day)) {
        spotsMap[revenue.date.day] = spotsMap[revenue.date.day]! + revenue.quantity;
      } else {
        spotsMap[revenue.date.day] = revenue.quantity;
      }
    }
    // Check unexistant days
    for (int day = 1; day <= days; day++) {
      if (!spotsMap.containsKey(day)) {
        spotsMap[day] = 0.0;
      }
    }
    // Data conversion
    List<FlSpot> spots = [];
    for (int day in spotsMap.keys.toList()..sort()) {
      spots.add(FlSpot(day.toDouble(), spotsMap[day]!.toDouble()));
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
    int days = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    // Dictionary with days and expense quantities per day
    Map<int, double> spotsMap = {};
    for (ExpenseModel expense in expenses) {
      if (spotsMap.containsKey(expense.date.day)) {
        spotsMap[expense.date.day] = spotsMap[expense.date.day]! + expense.quantity;
      } else {
        spotsMap[expense.date.day] = expense.quantity;
      }
    }
    // Check unexistant days
    for (int day = 1; day <= days; day++) {
      if (!spotsMap.containsKey(day)) {
        spotsMap[day] = 0.0;
      }
    }
    // Data conversion
    List<FlSpot> spots = [];
    for (int day in spotsMap.keys.toList()..sort()) {
      spots.add(FlSpot(day.toDouble(), spotsMap[day]!.toDouble()));
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
    Map<int, double> quantityMap = {};
    for (RevenueModel revenue in revenues) {
      if (quantityMap.containsKey(revenue.date.day)) {
        quantityMap[revenue.date.day] = quantityMap[revenue.date.day]! + revenue.quantity;
      } else {
        quantityMap[revenue.date.day] = revenue.quantity;
      }
    }
    if (revenues.isNotEmpty) {
      quantity = quantityMap.values.reduce(max);
    }
    quantityMap = {};
    for (ExpenseModel expense in expenses) {
      if (quantityMap.containsKey(expense.date.day)) {
        quantityMap[expense.date.day] = quantityMap[expense.date.day]! + expense.quantity;
      } else {
        quantityMap[expense.date.day] = expense.quantity;
      }
    }
    if (expenses.isNotEmpty && quantity < quantityMap.values.reduce(max)) {
      quantity = quantityMap.values.reduce(max);
    }
    return quantity.ceil().toDouble();
  }
}