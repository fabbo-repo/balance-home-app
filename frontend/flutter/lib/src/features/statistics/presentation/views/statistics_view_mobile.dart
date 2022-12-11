import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance/balance_month_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/balance/balance_year_chart_container.dart';
import 'package:flutter/material.dart';

class StatisticsViewMobile extends StatelessWidget {
  final StatisticsDataModel statisticsData;

  const StatisticsViewMobile({
    required this.statisticsData,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: const Color.fromARGB(254, 254, 252, 224),
        child: Column(
          children: [
            BalanceMonthChartContainer(statisticsData: statisticsData),
            BalanceYearChartContainer(statisticsData: statisticsData),
          ],
        ),
      ),
    );
  }

  BoxDecoration borderDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }
}