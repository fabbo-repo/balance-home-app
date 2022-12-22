import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/widgets/future_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/responsive_layout.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date_model_provider.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/repositories/balance_repository.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_provider.dart';
import 'package:balance_home_app/src/features/coin/data/repositories/coin_type_repository.dart';
import 'package:balance_home_app/src/features/coin/data/repositories/exchange_repository.dart';
import 'package:balance_home_app/src/features/coin/logic/providers/coin_provider.dart';
import 'package:balance_home_app/src/features/coin/logic/providers/exchange_provider.dart';
import 'package:balance_home_app/src/features/statistics/data/models/statistics_data_model.dart';
import 'package:balance_home_app/src/features/statistics/data/repositories/annual_balance_repository.dart';
import 'package:balance_home_app/src/features/statistics/data/repositories/monthly_balance_repository.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/annual_balance_provider.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/monthly_balance_provider.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_exchange/selected_exchange_model_provider.dart';
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
    final selectedBalanceDate = ref.watch(selectedBalanceDateStateNotifierProvider).date;
    final selectedSavingsDate = ref.watch(selectedSavingsDateStateNotifierProvider).date;
    final balanceRepository = ref.read(balanceRepositoryProvider);
    final monthlyBalanceRepository = ref.read(monthlyBalanceRepositoryProvider);
    final annualBalanceRepository = ref.read(annualBalanceRepositoryProvider);
    final coinTypeRepository = ref.read(coinTypeRepositoryProvider);
    final exchangeRepository = ref.read(exchangeRepositoryProvider);
    final selectedExchange = ref.watch(selectedExchangeStateNotifierProvider).model;
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
        balanceRepository,
        monthlyBalanceRepository,
        annualBalanceRepository,
        coinTypeRepository,
        selectedBalanceDate,
        selectedSavingsDate,
        exchangeRepository,
        selectedExchange.selectedCoinFrom,
        selectedExchange.selectedCoinTo
      ),
    );
  }

  /// Get all data for statistics page
  @visibleForTesting
  Future<StatisticsDataModel> getStatisticData(
    IBalanceRepository balanceRepository,
    IMonthlyBalanceRepository monthlyBalanceRepository,
    IAnnualBalanceRepository annualBalanceRepository,
    ICoinTypeRepository coinTypeRepositoryProvider,
    SelectedDate selectedBalanceDate,
    SelectedDate savingsSelectedDate,
    IExchangeRepository exchangeRepository,
    String selectedCoinFrom,
    String selectedCoinTo
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
        expenses: await balanceRepository.getBalances(
          BalanceTypeEnum.expense,
          dateFrom: dateFrom,
          dateTo: dateTo
        ),
        revenues: await balanceRepository.getBalances(
          BalanceTypeEnum.revenue,
          dateFrom: dateFrom,
          dateTo: dateTo
        ),
        expenseYears: await balanceRepository.getBalanceYears(BalanceTypeEnum.expense),
        revenueYears: await balanceRepository.getBalanceYears(BalanceTypeEnum.revenue),
        monthlyBalances: await monthlyBalanceRepository.getMonthlyBalances(
          year: savingsSelectedDate.year
        ),
        annualBalances: await annualBalanceRepository.getLastEightYearsAnnualBalances(),
        selectedBalanceDate: selectedBalanceDate,
        savingsSelectedDate: savingsSelectedDate,
        dateExchangesModel: await exchangeRepository.getLastDateExchanges(days: 20),
        selectedCoinFrom: selectedCoinFrom,
        selectedCoinTo: selectedCoinTo,
        coinTypes: await coinTypeRepositoryProvider.getCoinTypes()
      );
    } else {
      if(selectedBalanceDate != statisticsData!.selectedBalanceDate) {
        statisticsData!.expenses = await balanceRepository.getBalances(
          BalanceTypeEnum.expense,
          dateFrom: dateFrom,
          dateTo: dateTo
        );
        statisticsData!.revenues = await balanceRepository.getBalances(
          BalanceTypeEnum.revenue,
          dateFrom: dateFrom,
          dateTo: dateTo
        );
        statisticsData!.selectedBalanceDate = selectedBalanceDate;
      }
      if(savingsSelectedDate != statisticsData!.savingsSelectedDate) {
        statisticsData!.monthlyBalances = await monthlyBalanceRepository.getMonthlyBalances(
          year: savingsSelectedDate.year
        );
        statisticsData!.savingsSelectedDate = savingsSelectedDate;
      }
      statisticsData!.selectedCoinFrom = selectedCoinFrom;
      statisticsData!.selectedCoinTo = selectedCoinTo;
    }
    return statisticsData!;
  }
}