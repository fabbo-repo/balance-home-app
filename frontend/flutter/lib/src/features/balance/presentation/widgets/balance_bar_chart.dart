import 'dart:math';
import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

class BalanceBarChart extends StatelessWidget {

  List<_ChartData> data = [
    _ChartData("Uno", 3),
    _ChartData("Dos", 3),
    _ChartData("Uno", 2),
    _ChartData("Dos", 1)
  ];
  TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  final List<BalanceModel> balances;
  final BalanceTypeEnum balanceType;
  
  BalanceBarChart({
    required this.balances,
    required this.balanceType,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
        tooltipBehavior: _tooltip,
        series: <ChartSeries<_ChartData, String>>[
          BarSeries<_ChartData, String>(
            dataSource: data,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: Color.fromRGBO(8, 142, 255, 1)
          )
        ]
      )
    );
  }

}

class _ChartData {
  _ChartData(this.x, this.y);
 
  final String x;
  final double y;
}