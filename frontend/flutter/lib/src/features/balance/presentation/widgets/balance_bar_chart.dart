import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/type_util.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BalanceBarChart extends ConsumerWidget {
  final List<BalanceEntity> balances;
  final BalanceTypeMode balanceType;

  const BalanceBarChart(
      {required this.balances, required this.balanceType, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    List<ChartData> data = getBalanceData(appLocalizations);
    double max = getMax();
    return Padding(
        padding: const EdgeInsets.all(15),
        child: SfCartesianChart(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? null
                : balanceType == BalanceTypeMode.expense
                    ? const Color.fromARGB(108, 136, 47, 39)
                    : const Color.fromARGB(108, 0, 109, 44),
            primaryXAxis: CategoryAxis(),
            primaryYAxis:
                NumericAxis(minimum: 0, maximum: max, interval: max / 5),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries<ChartData, String>>[
              BarSeries<ChartData, String>(
                  dataSource: data,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  width: (data.length < 2) ? 0.2 : null,
                  color: balanceType == BalanceTypeMode.expense
                      ? const Color.fromARGB(255, 232, 80, 65)
                      : const Color.fromARGB(255, 0, 179, 71))
            ]));
  }

  List<ChartData> getBalanceData(AppLocalizations appLocalizations) {
    List<ChartData> chartData = [];
    Map<String, double> dataMap = {};
    for (BalanceEntity balance in balances) {
      String key = balance.balanceType.name;
      if (dataMap.containsKey(key)) {
        dataMap[key] = dataMap[key]! + balance.quantity;
      } else {
        dataMap[key] = balance.quantity;
      }
    }
    for (String balanceType in dataMap.keys) {
      chartData.add(ChartData(
          TypeUtil.balanceTypeToString(balanceType, appLocalizations),
          dataMap[balanceType]!));
    }
    return chartData;
  }

  double getMax() {
    double max = 4;
    for (BalanceEntity balance in balances) {
      if (balance.quantity > max) max = balance.quantity;
    }
    return max.ceilToDouble();
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}
