import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/theme.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/statistics_balance_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/currency/statistics_currency_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/statistics_savings_eight_years_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/presentation/widgets/savings/statistics_savings_year_chart_container.dart';
import 'package:balance_home_app/src/features/statistics/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsViewDesktop extends ConsumerWidget {
  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  StatisticsViewDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = connectionStateListenable.value;
    final theme = ref.watch(themeDataProvider);
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return ref.watch(statisticsControllerProvider).when<Widget>(data: (data) {
      return data.fold((failure) {
        if (failure is HttpConnectionFailure ||
            failure is NoLocalEntityFailure) {
          return showError(
              icon: Icons.network_wifi_1_bar,
              text: appLocalizations.noConnection,
              background: cache.value);
        }
        return showError(background: cache.value, text: failure.detail);
      }, (statisticsData) {
        cache.value = SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: theme == AppTheme.lightTheme
                    ? AppColors.balanceBackgroundColor
                    : AppColors.balanceDarkBackgroundColor,
                foregroundDecoration: BoxDecoration(border: Border.all()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatisticsBalanceChartContainer(
                      dateMode: SelectedDateMode.month,
                      revenues: statisticsData.revenues,
                      expenses: statisticsData.expenses,
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
              Container(
                color: theme == AppTheme.lightTheme
                    ? AppColors.balanceBackgroundColor
                    : AppColors.balanceDarkBackgroundColor,
                foregroundDecoration: BoxDecoration(border: Border.all()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatisticsSavingsYearChartContainer(
                      monthlyBalances: statisticsData.monthlyBalances,
                      revenueYears: statisticsData.revenueYears,
                      expenseYears: statisticsData.expenseYears,
                    ),
                    StatisticsSavingsEightYearsChartContainer(
                      annualBalances: statisticsData.annualBalances,
                    )
                  ],
                ),
              ),
              (isConnected)
                  ? statisticsCurrencyChartContainer(statisticsData, theme)
                  : showError(
                      background: statisticsCurrencyChartContainer(
                          statisticsData, theme),
                      icon: Icons.network_wifi_1_bar,
                      text: appLocalizations.noConnection)
            ],
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

  Widget statisticsCurrencyChartContainer(
      StatisticsData statisticsData, ThemeData theme) {
    return Container(
        color: theme == AppTheme.lightTheme
            ? const Color.fromARGB(254, 201, 241, 253)
            : const Color.fromARGB(253, 112, 157, 170),
        foregroundDecoration: BoxDecoration(border: Border.all()),
        child: StatisticsCurrencyChartContainer(
          dateCurrencyConversion: statisticsData.dateCurrencyConversion,
          currencyTypes: statisticsData.currencyTypes,
        ));
  }
}
