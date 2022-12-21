import 'package:balance_home_app/src/core/data/models/selected_date_enum.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:flutter/material.dart';

class StatisticsViewMobile extends StatelessWidget {
  final StatisticsDataModel statisticsData;

  const StatisticsViewMobile({
    required this.statisticsData,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(254, 254, 252, 224),
      child: Column(
        children: [
          BalanceChartContainer(
            statisticsData: statisticsData,
            dateType: SelectedDateEnum.month
          ),
          BalanceChartContainer(
            statisticsData: statisticsData,
            dateType: SelectedDateEnum.year
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