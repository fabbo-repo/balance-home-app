import 'package:balance_home_app/src/core/widgets/future_widget.dart';
import 'package:balance_home_app/src/core/widgets/responsive_layout.dart';
import 'package:balance_home_app/src/features/expense/data/repositories/expense_repository.dart';
import 'package:balance_home_app/src/features/expense/logic/providers/expense_provider.dart';
import 'package:balance_home_app/src/features/revenue/data/repositories/revenue_repository.dart';
import 'package:balance_home_app/src/features/revenue/logic/providers/revenue_provider.dart';
import 'package:balance_home_app/src/features/statistics/data/models/selected_date_model.dart';
import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:balance_home_app/src/features/statistics/data/repositories/annual_balance_repository.dart';
import 'package:balance_home_app/src/features/statistics/data/repositories/monthly_balance_repository.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/annual_balance_provider.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/monthly_balance_provider.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date/selected_date_model_provider.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view_desktop.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class StatisticsView extends ConsumerWidget {
  StatisticsDataModel? statisticsData;

  StatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBalanceDate = ref.watch(selectedBalanceDateStateNotifierProvider).model;
    final selectedSavingsDate = ref.watch(selectedBalanceDateStateNotifierProvider).model;
    final expenseRepository = ref.read(expenseRepositoryProvider);
    final revenueRepository = ref.read(revenueRepositoryProvider);
    final monthlyBalanceRepository = ref.read(monthlyBalanceRepositoryProvider);
    final annualBalanceRepository = ref.read(annualBalanceRepositoryProvider);
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
        monthlyBalanceRepository,
        annualBalanceRepository,
        selectedBalanceDate,
        selectedSavingsDate,
      ),
    );
  }

  /// Get all data for statistics page
  @visibleForTesting
  Future<StatisticsDataModel> getStatisticData(
    IRevenueRepository revenueRepository,
    IExpenseRepository expenseRepository,
    IMonthlyBalanceRepository monthlyBalanceRepository,
    IAnnualBalanceRepository annualBalanceRepository,
    SelectedDateModel selectedBalanceDate,
    SelectedDateModel savingsSelectedDate,
  ) async {
    DateTime dateFrom = DateTime(
      selectedBalanceDate.year,
      1,
      1
    );
    DateTime dateTo = DateTime(
      selectedBalanceDate.year,
      12,
      DateUtils.getDaysInMonth(
        selectedBalanceDate.year, 12)
    );
    if (statisticsData == null) {
      statisticsData = StatisticsDataModel(
        expenses: await expenseRepository.getExpenses(
          dateFrom: dateFrom,
          dateTo: dateTo
        ),
        revenues: await revenueRepository.getRevenues(
          dateFrom: dateFrom,
          dateTo: dateTo
        ),
        expenseYears: await expenseRepository.getExpenseYears(),
        revenueYears: await revenueRepository.getRevenueYears(),
        monthlyBalances: await monthlyBalanceRepository.getMonthlyBalances(
          year: savingsSelectedDate.year
        ),
        annualBalances: await annualBalanceRepository.getLastEightYearsAnnualBalances(),
        selectedBalanceDate: selectedBalanceDate,
        savingsSelectedDate: savingsSelectedDate
      );
    } else {
      if(selectedBalanceDate != statisticsData!.selectedBalanceDate) {
        statisticsData!.expenses = await expenseRepository.getExpenses(
          dateFrom: dateFrom,
          dateTo: dateTo
        );
        statisticsData!.revenues = await revenueRepository.getRevenues(
          dateFrom: dateFrom,
          dateTo: dateTo
        );
        statisticsData!.selectedBalanceDate = selectedBalanceDate;
      }
      if(savingsSelectedDate != statisticsData!.savingsSelectedDate) {
        statisticsData!.monthlyBalances = await monthlyBalanceRepository.getMonthlyBalances(
          year: savingsSelectedDate.year
        );
        statisticsData!.selectedBalanceDate = selectedBalanceDate;
      }
    }
    return statisticsData!;
  }
}