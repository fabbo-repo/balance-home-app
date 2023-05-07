import 'package:balance_home_app/config/providers.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/presentation/states/selected_date_state.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:balance_home_app/src/features/currency/providers.dart';
import 'package:balance_home_app/src/features/statistics/application/statistics_controller.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/annual_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/monthly_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/local/annual_balance_local_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/local/monthly_balance_local_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/remote/annual_balance_remote_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/remote/monthly_balance_remote_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/repositories/annual_balance_repository.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/repositories/monthly_balance_repository.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/selected_exchange.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
import 'package:balance_home_app/src/features/statistics/presentation/states/selected_exchange_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

///
/// Infrastructure dependencies
///

/// Annual balance repository
final annualBalanceRepositoryProvider =
    Provider<AnnualBalanceRepositoryInterface>((ref) => AnnualBalanceRepository(
        annualBalanceRemoteDataSource: AnnualBalanceRemoteDataSource(
            apiClient: ref.read(apiClientProvider)),
        annualBalanceLocalDataSource: AnnualBalanceLocalDataSource(
            localDbClient: ref.read(localDbClientProvider))));

/// Monthly balance repository
final monthlyBalanceRepositoryProvider =
    Provider<MonthlyBalanceRepositoryInterface>((ref) =>
        MonthlyBalanceRepository(
            monthlyBalanceRemoteDataSource: MonthlyBalanceRemoteDataSource(
                apiClient: ref.read(apiClientProvider)),
            monthlyBalanceLocalDataSource: MonthlyBalanceLocalDataSource(
                localDbClient: ref.read(localDbClientProvider))));

///
/// Application dependencies
///

final statisticsControllerProvider = StateNotifierProvider<StatisticsController,
    AsyncValue<Either<Failure, StatisticsData>>>((ref) {
  final balanceRepo = ref.watch(balanceRepositoryProvider);
  final annualBalanceRepo = ref.watch(annualBalanceRepositoryProvider);
  final monthlyBalanceRepo = ref.watch(monthlyBalanceRepositoryProvider);
  final currencyTypeRepo = ref.watch(currencyTypeRepositoryProvider);
  final currencyConversionRepo =
      ref.watch(currencyConversionRepositoryProvider);
  final selectedBalanceDate = ref.watch(statisticsBalanceSelectedDateProvider);
  final selectedSavingsDate = ref.watch(statisticsSavingsSelectedDateProvider);
  return StatisticsController(
      balanceRepository: balanceRepo,
      annualBalanceRepository: annualBalanceRepo,
      monthlyBalanceRepository: monthlyBalanceRepo,
      currencyTypeRepository: currencyTypeRepo,
      currencyConversionRepository: currencyConversionRepo,
      selectedBalanceDate: selectedBalanceDate,
      selectedSavingsDate: selectedSavingsDate);
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
  final user = ref.watch(authControllerProvider).asData?.value;
  String coinFrom = user != null ? user.prefCoinType : "EUR";
  String cointTo = coinFrom == "EUR" ? "USD" : "EUR";
  return SelectedExchangeState(coinFrom: coinFrom, coinTo: cointTo);
});
