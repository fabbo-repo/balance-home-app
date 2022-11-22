import 'package:balance_home_app/src/core/utils/date_util.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BalanceLineChart extends StatelessWidget {
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
    revenueChartBarData,
    expenseChartBarData,
  ];
  
  final List<String> monthList;

  const BalanceLineChart({
    required this.monthList,
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
      FlSpot(2, 3.5),
      FlSpot(3, 1.5),
      FlSpot(4, 0.5),
      FlSpot(5, 1.4),
      FlSpot(6, 1.4),
      FlSpot(7, 3.4),
      FlSpot(8, 1),
      FlSpot(10, 2),
      FlSpot(12, 2.2)
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
    ],
  );
}