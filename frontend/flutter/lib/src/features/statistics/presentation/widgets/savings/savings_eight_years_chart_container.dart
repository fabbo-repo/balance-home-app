import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/core/services/platform_service.dart';
import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/savings_eight_years_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavingsEightYearsChartContainer extends ConsumerWidget {
  final StatisticsDataModel statisticsData;

  const SavingsEightYearsChartContainer(
      {required this.statisticsData, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations =
        ref.watch(localizationStateNotifierProvider).localization;
    // Screen sizes:
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double chartLineHeight = (screenHeight * 0.45 <= 200)
        ? 200
        : (screenHeight * 0.45 <= 350)
            ? screenHeight * 0.45
            : 350;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              color: const Color.fromARGB(255, 194, 56, 235),
              height: 45,
              width: (PlatformService().isSmallWindow(context))
                  ? screenWidth * 0.95
                  : screenWidth * 0.35,
              child: Center(
                  child: Text(
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      appLocalizations.savingsEightChartTitle)),
            )
          ],
        ),
        SizedBox(
            height: chartLineHeight,
            width: (PlatformService().isSmallWindow(context))
                ? screenWidth * 0.95
                : screenWidth * 0.45,
            child: SavingsEightYearsLineChart(
              annualBalances: statisticsData.annualBalances,
            )),
      ],
    );
  }
}
