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
    revenueChartBarData,
    expenseChartBarData,
  ];

  final int selectedMonth;
  final int selectedYear;
  
  const BalanceMonthLineChart({
    required this.selectedMonth,
    required this.selectedYear,
    super.key});

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
          maxY: 4,
          minY: 0,
        ),
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }


  LineChartBarData get revenueChartBarData => LineChartBarData(
    isCurved: true,
    color: const Color.fromARGB(184, 0, 175, 15),
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(
      show: true,
      color: const Color.fromARGB(55, 0, 175, 15),
    ),
    spots: const [
      FlSpot(1, 1),
      FlSpot(3, 1.5),
      FlSpot(5, 1.4),
      FlSpot(7, 3.4),
      FlSpot(10, 2),
      FlSpot(12, 2.2),
      FlSpot(13, 1.8),
    ],
  );

  LineChartBarData get expenseChartBarData => LineChartBarData(
    isCurved: true,
    color: const Color.fromARGB(188, 255, 17, 0),
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(
      show: true,
      color: const Color.fromARGB(55, 212, 117, 117),
    ),
    spots: const [
      FlSpot(1, 1),
      FlSpot(3, 2.8),
      FlSpot(7, 1.2),
      FlSpot(10, 2.8),
      FlSpot(12, 2.6),
      FlSpot(13, 3.9),
    ],
  );
}