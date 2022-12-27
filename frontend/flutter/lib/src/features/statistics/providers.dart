import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/presentation/states/selected_date_state.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:balance_home_app/src/features/coin/providers.dart';
import 'package:balance_home_app/src/features/statistics/application/statistics_controller.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/annual_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/monthly_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/repositories/annual_balance_repository.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/repositories/monthly_balance_repository.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/selected_exchange.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
import 'package:balance_home_app/src/features/statistics/presentation/states/selected_exchange_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
/// Infrastructure dependencies
///

/// Annual balance repository
final annualBalanceRepositoryProvider =
    Provider<AnnualBalanceRepositoryInterface>((ref) =>
        AnnualBalanceRepository(httpService: ref.watch(httpServiceProvider)));

/// Monthly balance repository
final monthlyBalanceRepositoryProvider =
    Provider<MonthlyBalanceRepositoryInterface>((ref) =>
        MonthlyBalanceRepository(httpService: ref.watch(httpServiceProvider)));

///
/// Application dependencies
///

final statisticsControllerProvider =
    StateNotifierProvider<StatisticsController, AsyncValue<StatisticsData>>(
        (ref) {
  final balanceRepo = ref.watch(balanceRepositoryProvider);
  final annualBalanceRepo = ref.watch(annualBalanceRepositoryProvider);
  final monthlyBalanceRepo = ref.watch(monthlyBalanceRepositoryProvider);
  final coinTypeRepository = ref.watch(coinTypeRepositoryProvider);
  final exchangeRepository = ref.watch(exchangeRepositoryProvider);
  final selectedBalanceDate = ref.watch(statisticsBalanceSelectedDateProvider);
  final selectedSavingsDate = ref.watch(statisticsSavingsSelectedDateProvider);
  return StatisticsController(
      balanceRepo,
      annualBalanceRepo,
      monthlyBalanceRepo,
      coinTypeRepository,
      exchangeRepository,
      selectedBalanceDate,
      selectedSavingsDate);
});

///
/// Presentation dependencies
///

/// Selected date for statistic's balance charts
final statisticsBalanceSelectedDateProvider =
    StateNotifierProvider<SelectedDateState, SelectedDate>((ref) {
  return SelectedDateState(SelectedDateMode.day);
});

/// Selected date for statistic's savings charts
final statisticsSavingsSelectedDateProvider =
    StateNotifierProvider<SelectedDateState, SelectedDate>((ref) {
  return SelectedDateState(SelectedDateMode.day);
});

/// Selected exchange for statistic's currency chart
final statisticsCurrencySelectedExchangeProvider =
    StateNotifierProvider<SelectedExchangeState, SelectedExchange>((ref) {
  // TODO check  user preferred coin when is logged in
  return SelectedExchangeState(coinFrom: "EUR", coinTo: "USD");
});
