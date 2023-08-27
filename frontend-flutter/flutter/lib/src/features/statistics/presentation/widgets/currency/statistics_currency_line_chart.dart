import 'package:balance_home_app/src/features/currency/domain/entities/currency_conversion_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_conversion_list_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/date_currency_conversion_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/date_currency_conversion_list_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsCurrencyLineChart extends StatelessWidget {
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
          DateTime date =
              DateTime.now().subtract(Duration(days: 19 - value.toInt()));
          const style = TextStyle(
            fontSize: 12,
          );
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 5,
            child: Text("${date.day}/${date.month}", style: style),
          );
        },
      );

  SideTitles get leftTitles => SideTitles(
        getTitlesWidget: (double value, TitleMeta meta) {
          const style = TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
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

  List<LineChartBarData> get lineBarsData => [
        currencyChartBarData(),
      ];

  final String selectedCoinFrom;
  final String selectedCoinTo;
  final DateCurrencyConversionListEntity dateCurrencyConversion;

  const StatisticsCurrencyLineChart(
      {required this.selectedCoinFrom,
      required this.selectedCoinTo,
      required this.dateCurrencyConversion,
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
          minX: 0,
          maxX: 19,
          maxY: getMaxQuantity(),
          minY: 0,
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }

  @visibleForTesting
  LineChartBarData currencyChartBarData() {
    List<FlSpot> spots = [];
    for (int i = 0; i <= 19; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: 19 - i));
      spots.add(FlSpot(i.toDouble(), getExchange(date)));
    }
    return LineChartBarData(
        isCurved: true,
        preventCurveOverShooting: true,
        color: const Color.fromARGB(200, 0, 65, 205),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: const Color.fromARGB(55, 0, 65, 205),
        ),
        spots: spots);
  }

  @visibleForTesting
  double getMaxQuantity() {
    double quantity = 1.0;
    for (DateCurrencyConversionEntity dateCurrencyConversion
        in dateCurrencyConversion.dateExchanges) {
      double current = getExchange(dateCurrencyConversion.date);
      if (current > quantity) quantity = current;
    }
    return quantity.ceilToDouble();
  }

  @visibleForTesting
  double getExchange(DateTime date) {
    // Same coin
    if (selectedCoinFrom == selectedCoinTo) return 1;
    // Search for coin
    for (DateCurrencyConversionEntity dateCurrencyConversion
        in dateCurrencyConversion.dateExchanges) {
      if (dateCurrencyConversion.date.day == date.day &&
          dateCurrencyConversion.date.month == date.month &&
          dateCurrencyConversion.date.year == date.year) {
        for (CurrencyConversionListEntity currencyConversion
            in dateCurrencyConversion.exchanges) {
          if (currencyConversion.code == selectedCoinFrom) {
            for (CurrencyConversionEntity exchange
                in currencyConversion.exchanges) {
              if (exchange.code == selectedCoinTo) {
                return exchange.value;
              }
            }
          }
        }
      }
    }
    // If not exists then 0
    return 0;
  }
}
