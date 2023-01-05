import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_error_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/statistics_balance_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/currency/statistics_currency_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/statistics_savings_eight_years_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/statistics_savings_year_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class StatisticsViewDesktop extends ConsumerWidget {
  Widget cache = Container();

  StatisticsViewDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(statisticsControllerProvider).when<Widget>(
        data: (StatisticsData data) {
      cache = SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.balanceBackgroundColor,
              foregroundDecoration: BoxDecoration(border: Border.all()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatisticsBalanceChartContainer(
                    dateMode: SelectedDateMode.month,
                    revenues: data.revenues,
                    expenses: data.expenses,
                    revenueYears: data.revenueYears,
                    expenseYears: data.expenseYears,
                  ),
                  StatisticsBalanceChartContainer(
                      dateMode: SelectedDateMode.year,
                      revenues: data.revenues,
                      expenses: data.expenses,
                      revenueYears: data.revenueYears,
                      expenseYears: data.expenseYears),
                ],
              ),
            ),
            Container(
              color: AppColors.balanceBackgroundColor,
              foregroundDecoration: BoxDecoration(border: Border.all()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatisticsSavingsYearChartContainer(
                    monthlyBalances: data.monthlyBalances,
                    revenueYears: data.revenueYears,
                    expenseYears: data.expenseYears,
                  ),
                  StatisticsSavingsEightYearsChartContainer(
                    annualBalances: data.annualBalances,
                  )
                ],
              ),
            ),
            Container(
                color: const Color.fromARGB(254, 201, 241, 253),
                foregroundDecoration: BoxDecoration(border: Border.all()),
                child: StatisticsCurrencyChartContainer(
                  dateExchanges: data.dateExchanges,
                  coinTypes: data.coinTypes,
                ))
          ],
        ),
      );
      return cache;
    }, error: (error, stackTrace) {
      return showError(error, stackTrace, cache: cache);
    }, loading: () {
      ref.read(statisticsControllerProvider.notifier).handle();
      return showLoading(cache: cache);
    });
  }
}
