import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/theme.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/statistics_savings_year_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/statistics_balance_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class StatisticsViewMobile extends ConsumerWidget {
  Widget cache = Container();

  StatisticsViewMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeDataProvider);
    return ref.watch(statisticsControllerProvider).when<Widget>(
        data: (StatisticsData data) {
      cache = SingleChildScrollView(
        child: Container(
          color: theme == AppTheme.lightTheme
              ? AppColors.balanceBackgroundColor
              : AppColors.balanceDarkBackgroundColor,
          child: Column(
            children: [
              StatisticsSavingsYearChartContainer(
                monthlyBalances: data.monthlyBalances,
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
      );
      return cache;
    }, error: (Object o, StackTrace st) {
      return showError(o, st, cache: cache);
    }, loading: () {
      ref.read(statisticsControllerProvider.notifier).handle();
      return showLoading(cache: cache);
    });
  }
}
