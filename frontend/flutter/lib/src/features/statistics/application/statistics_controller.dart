import 'package:balance_home_app/src/core/application/utils.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/date_exchanges_list_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/coin_type_repository_interface.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/exchange_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/annual_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/monthly_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsController extends StateNotifier<AsyncValue<StatisticsData>> {
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
    // Revenues
    final revenues = await _balanceRepository.getBalances(
        BalanceTypeMode.revenue,
        dateFrom: balanceDate.dateFrom,
        dateTo: balanceDate.dateTo);
    if (revenues.isLeft()) {
      state = ControllerUtils.asyncError(revenues);
      return;
    }
    // Revenue years
    final revenueYears =
        await _balanceRepository.getBalanceYears(BalanceTypeMode.revenue);
    if (revenueYears.isLeft()) {
      state = ControllerUtils.asyncError(revenueYears);
      return;
    }
    // Expenses
    final expenses = await _balanceRepository.getBalances(
        BalanceTypeMode.expense,
        dateFrom: balanceDate.dateFrom,
        dateTo: balanceDate.dateTo);
    if (expenses.isLeft()) {
      state = ControllerUtils.asyncError(expenses);
      return;
    }
    // Expense years
    final expenseYears =
        await _balanceRepository.getBalanceYears(BalanceTypeMode.expense);
    if (expenseYears.isLeft()) {
      state = ControllerUtils.asyncError(expenseYears);
      return;
    }
    // Monthly balances
    final monthlyBalances = await _monthlyBalanceRepository.getMonthlyBalances(
        year: _selectedSavingsDate.year);
    if (monthlyBalances.isLeft()) {
      state = ControllerUtils.asyncError(monthlyBalances);
      return;
    }
    // Annual balances
    final annualBalances = await _annualBalanceRepository.getAnnualBalances();
    if (annualBalances.isLeft()) {
      state = ControllerUtils.asyncError(annualBalances);
      return;
    }
    // Coin types
    final coinTypes = await _coinTypeRepository.getCoinTypes();
    if (coinTypes.isLeft()) {
      state = ControllerUtils.asyncError(coinTypes);
      return;
    }
    // Date exchanges
    final dateExchanges =
        await _exchangeRepository.getLastDateExchanges(days: 20);
    if (dateExchanges.isLeft()) {
      state = ControllerUtils.asyncError(dateExchanges);
      return;
    }
    state = AsyncValue.data(StatisticsData(
      revenues: ControllerUtils.getRight(revenues, []),
      revenueYears: ControllerUtils.getRight(revenueYears, []),
      expenses: ControllerUtils.getRight(expenses, []),
      expenseYears: ControllerUtils.getRight(expenseYears, []),
      monthlyBalances: ControllerUtils.getRight(monthlyBalances, []),
      annualBalances: ControllerUtils.getRight(annualBalances, []),
      coinTypes: ControllerUtils.getRight(coinTypes, []),
      dateExchanges: ControllerUtils.getRight(
          dateExchanges, const DateExchangesListEntity(dateExchanges: [])),
    ));
  }
}
