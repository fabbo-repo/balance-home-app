import 'package:balance_home_app/src/core/utils/platform_utils.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/statistics/domain/entities/annual_balance_entity.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/statistics_savings_eight_years_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticsSavingsEightYearsChartContainer extends ConsumerWidget {
  final List<AnnualBalanceEntity> annualBalances;

  const StatisticsSavingsEightYearsChartContainer(
      {required this.annualBalances, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
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
              width: (PlatformUtils.isSmallWindow(context))
                  ? screenWidth * 0.95
                  : screenWidth * 0.35,
              child: Center(
                  child: Text(
                      style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      appLocalizations.savingsEightChartTitle)),
            )
          ],
        ),
        SizedBox(
            height: chartLineHeight,
            width: (PlatformUtils.isSmallWindow(context))
                ? screenWidth * 0.95
                : screenWidth * 0.45,
            child: StatisticsSavingsEightYearsLineChart(
              annualBalances: annualBalances,
            )),
      ],
    );
  }
}
