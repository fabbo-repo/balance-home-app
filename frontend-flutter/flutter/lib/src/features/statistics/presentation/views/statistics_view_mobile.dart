import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/theme.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/statistics_savings_year_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/statistics_balance_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsViewMobile extends ConsumerWidget {
  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  StatisticsViewMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeDataProvider);
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return ref.watch(statisticsControllerProvider).when<Widget>(data: (data) {
      return data.fold((failure) {
        if (failure is HttpConnectionFailure ||
            failure is NoLocalEntityFailure) {
          return showError(
              icon: Icons.network_wifi_1_bar,
              text: appLocalizations.noConnection);
        }
        return showError(background: cache.value, text: failure.detail);
      }, (statisticsData) {
        cache.value = SingleChildScrollView(
          child: Container(
            color: theme == AppTheme.lightTheme
                ? AppColors.balanceBackgroundColor
                : AppColors.balanceDarkBackgroundColor,
            child: Column(
              children: [
                StatisticsSavingsYearChartContainer(
                  monthlyBalances: statisticsData.monthlyBalances,
                  revenueYears: statisticsData.revenueYears,
                  expenseYears: statisticsData.expenseYears,
                ),
                StatisticsBalanceChartContainer(
                    dateMode: SelectedDateMode.year,
                    revenues: statisticsData.revenues,
                    expenses: statisticsData.expenses,
                    revenueYears: statisticsData.revenueYears,
                    expenseYears: statisticsData.expenseYears),
              ],
            ),
          ),
        );
        return cache.value;
      });
    }, error: (error, _) {
      return showError(
          error: error,
          background: cache.value,
          text: appLocalizations.genericError);
    }, loading: () {
      ref.read(statisticsControllerProvider.notifier).handle();
      return showLoading(background: cache.value);
    });
  }
}
