import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance_year_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance_line_chart.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/currency_line_chart.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings_line_chart.dart';
import 'package:flutter/material.dart';

class StatisticsViewMobile extends StatelessWidget {
  const StatisticsViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: const Color.fromARGB(254, 254, 252, 224),
            foregroundDecoration: borderDecoration(),
            child: SizedBox(
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: SavingsLineChart()
            ),
          ),
          Container(
            color: const Color.fromARGB(254, 254, 252, 224),
            foregroundDecoration: borderDecoration(),
            child: SizedBox(
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: SavingsLineChart()
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