import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date_enum.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/currency/currency_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/savings_eight_years_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/savings_year_chart_container.dart';
import 'package:flutter/material.dart';

class StatisticsViewDesktop extends StatelessWidget {
  final StatisticsDataModel statisticsData;
  
  const StatisticsViewDesktop({
    required this.statisticsData,
    super.key
  });

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
          ),
          Container(
            color: const Color.fromARGB(254, 254, 252, 224),
            foregroundDecoration: borderDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SavingsYearChartContainer(statisticsData: statisticsData),
                SavingsEightYearsChartContainer(statisticsData: statisticsData)
              ],
            ),
          ),
          Container(
            color: const Color.fromARGB(254, 201, 241, 253),
            foregroundDecoration: borderDecoration(),
            child: CurrencyChartContainer(statisticsData: statisticsData)
          ),
        ],
      ),
    );
  }

  @visibleForTesting
  BoxDecoration borderDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }
}