import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance_month_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance_year_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance_line_chart.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/currency_line_chart.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings_line_chart.dart';
import 'package:flutter/material.dart';

class StatisticsViewDesktop extends StatelessWidget {
  const StatisticsViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: const Color.fromARGB(254, 254, 252, 224),
            foregroundDecoration: borderDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BalanceMonthChartContainer(),
                BalanceYearChartContainer(),
              ],
            ),
          ),
          Container(
            color: const Color.fromARGB(254, 254, 252, 224),
            foregroundDecoration: borderDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: SavingsLineChart()
                ),
                SizedBox(
                  height: 400,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: SavingsLineChart()
                ),
              ],
            ),
          ),
          Container(
            color: const Color.fromARGB(254, 201, 241, 253),
            foregroundDecoration: borderDecoration(),
            child: Center(
              child: SizedBox(
                height: 600,
                width: MediaQuery.of(context).size.width * 0.95,
                child: CurrencyLineChart()
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration borderDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }
}