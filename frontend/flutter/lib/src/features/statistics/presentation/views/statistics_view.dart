import 'package:balance_home_app/src/core/widgets/future_widget.dart';
import 'package:balance_home_app/src/core/widgets/responsive_layout.dart';
import 'package:balance_home_app/src/features/expense/data/repositories/expense_repository.dart';
import 'package:balance_home_app/src/features/expense/logic/providers/expense_provider.dart';
import 'package:balance_home_app/src/features/revenue/data/repositories/revenue_repository.dart';
import 'package:balance_home_app/src/features/revenue/logic/providers/revenue_provider.dart';
import 'package:balance_home_app/src/features/statistics/data/models/selected_date_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date/selected_date_model_provider.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view_desktop.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsView extends ConsumerWidget {

  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBalanceDate = ref.watch(selectedBalanceDateStateNotifierProvider).model;
    final expenseRepository = ref.read(expenseRepositoryProvider);
    final revenueRepository = ref.read(revenueRepositoryProvider);
    return FutureWidget<StatisticsDataModel>(
      childCreation: (StatisticsDataModel data) {
        return SingleChildScrollView(
          child: ResponsiveLayout(
            desktopChild: StatisticsViewDesktop(statisticsData: data),
            mobileChild: StatisticsViewMobile(statisticsData: data),
            tabletChild: StatisticsViewMobile(statisticsData: data),
          )
        );
      },
      future: getStatisticData(
        revenueRepository,
        expenseRepository,
        selectedBalanceDate
      ),
    );
  }

  /// Get all data for the selected year
  @visibleForTesting
  Future<StatisticsDataModel> getStatisticData(
    IRevenueRepository revenueRepository, 
    IExpenseRepository expenseRepository,
    SelectedDateModel selectedDate,
  ) async {
    DateTime dateFrom = DateTime(
      selectedDate.year,
      1,
      1
    );
    DateTime dateTo = DateTime(
      selectedDate.year,
      12,
      DateUtils.getDaysInMonth(
        selectedDate.year, 12)
    );
    return StatisticsDataModel(
      expenses: await expenseRepository.getExpenses(
        dateFrom: dateFrom,
        dateTo: dateTo
      ),
      revenues: await revenueRepository.getRevenues(
        dateFrom: dateFrom,
        dateTo: dateTo
      )
    );
  }
}