import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/presentation/views/error_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
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
    return ref.watch(statisticsControllerProvider).when<Widget>(
        data: (StatisticsData data) {
      cache = SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(254, 254, 252, 224),
          child: Column(
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
      );
      return cache;
    }, error: (Object o, StackTrace st) {
      debugPrint("[STATISTICS_BALANCE_MOBILE] $o -> $st");
      ErrorView.go();
      return const LoadingWidget(color: Colors.red);
    }, loading: () {
      ref.read(statisticsControllerProvider.notifier).handle();
      return Stack(alignment: AlignmentDirectional.centerStart, children: [
        cache,
        const LoadingWidget(color: Colors.grey),
      ]);
    });
  }
}
