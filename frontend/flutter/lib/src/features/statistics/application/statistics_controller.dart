import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/coin_type_repository_interface.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/exchange_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/annual_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/monthly_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsController
    extends StateNotifier<AsyncValue<StatisticsData>> {
  final BalanceRepositoryInterface _balanceRepository;
  final AnnualBalanceRepositoryInterface _annualBalanceRepository;
  final MonthlyBalanceRepositoryInterface _monthlyBalanceRepository;
  final CoinTypeRepositoryInterface _coinTypeRepository;
  final ExchangeRepositoryInterface _exchangeRepository;
  final SelectedDate _selectedBalanceDate;
  final SelectedDate _selectedSavingsDate;

  StatisticsController(
      this._balanceRepository,
      this._annualBalanceRepository,
      this._monthlyBalanceRepository,
      this._coinTypeRepository,
      this._exchangeRepository,
      this._selectedBalanceDate,
      this._selectedSavingsDate)
      : super(const AsyncValue.loading());

  Future<void> handle() async {
    SelectedDate balanceDate =
        _selectedBalanceDate.copyWith(selectedDateMode: SelectedDateMode.year);
    final revenues = await _balanceRepository.getBalances(
        BalanceTypeMode.revenue,
        dateFrom: balanceDate.dateFrom,
        dateTo: balanceDate.dateTo);
    final revenueYears =
        await _balanceRepository.getBalanceYears(BalanceTypeMode.revenue);
    final expenses = await _balanceRepository.getBalances(
        BalanceTypeMode.expense,
        dateFrom: balanceDate.dateFrom,
        dateTo: balanceDate.dateTo);
    final expenseYears =
        await _balanceRepository.getBalanceYears(BalanceTypeMode.expense);
    final monthlyBalances = await _monthlyBalanceRepository.getMonthlyBalances(
        year: _selectedSavingsDate.year);
    final annualBalances = await _annualBalanceRepository.getAnnualBalances();
    final coinTypes = await _coinTypeRepository.getCoinTypes();
    final dateExchanges =
        await _exchangeRepository.getLastDateExchanges(days: 20);
    state = AsyncValue.data(StatisticsData(
      revenues: revenues,
      revenueYears: revenueYears,
      expenses: expenses,
      expenseYears: expenseYears,
      monthlyBalances: monthlyBalances,
      annualBalances: annualBalances,
      coinTypes: coinTypes,
      dateExchanges: dateExchanges,
    ));
  }
}
