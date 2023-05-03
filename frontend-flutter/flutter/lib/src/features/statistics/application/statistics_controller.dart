import 'package:balance_home_app/src/core/domain/failures/api_bad_request_failure.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_conversion_repository_interface.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_type_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/annual_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/monthly_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsController extends StateNotifier<AsyncValue<StatisticsData>> {
  final BalanceRepositoryInterface _balanceRepository;
  final AnnualBalanceRepositoryInterface _annualBalanceRepository;
  final MonthlyBalanceRepositoryInterface _monthlyBalanceRepository;
  final CurrencyTypeRepositoryInterface _currencyTypeRepository;
  final CurrencyConversionRepositoryInterface _currencyConversionRepository;
  final SelectedDate _selectedBalanceDate;
  final SelectedDate _selectedSavingsDate;

  StatisticsController(
      this._balanceRepository,
      this._annualBalanceRepository,
      this._monthlyBalanceRepository,
      this._currencyTypeRepository,
      this._currencyConversionRepository,
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
    state = await revenues.fold(
        (failure) => AsyncValue.error(
            failure is ApiBadRequestFailure ? failure.detail : "",
            StackTrace.empty), (revenues) async {
      // Revenues years
      final revenueYears =
          await _balanceRepository.getBalanceYears(BalanceTypeMode.revenue);
      return await revenueYears.fold(
          (failure) => AsyncValue.error(
              failure is ApiBadRequestFailure ? failure.detail : "",
              StackTrace.empty), (revenueYears) async {
        // Expenses
        final expenses = await _balanceRepository.getBalances(
            BalanceTypeMode.expense,
            dateFrom: balanceDate.dateFrom,
            dateTo: balanceDate.dateTo);
        return await expenses.fold(
            (failure) => AsyncValue.error(
                failure is ApiBadRequestFailure ? failure.detail : "",
                StackTrace.empty), (expenses) async {
          // Expense years
          final expenseYears =
              await _balanceRepository.getBalanceYears(BalanceTypeMode.expense);
          return await expenseYears.fold(
              (failure) => AsyncValue.error(
                  failure is ApiBadRequestFailure ? failure.detail : "",
                  StackTrace.empty), (expenseYears) async {
            // Monthly balances
            final monthlyBalances = await _monthlyBalanceRepository
                .getMonthlyBalances(year: _selectedSavingsDate.year);
            return await monthlyBalances.fold(
                (failure) => AsyncValue.error(
                    failure is ApiBadRequestFailure ? failure.detail : "",
                    StackTrace.empty), (monthlyBalances) async {
              // Annual balances
              final annualBalances =
                  await _annualBalanceRepository.getAnnualBalances();
              return await annualBalances.fold(
                  (failure) => AsyncValue.error(
                      failure is ApiBadRequestFailure ? failure.detail : "",
                      StackTrace.empty), (annualBalances) async {
                // Coin types
                final coinTypes =
                    await _currencyTypeRepository.getCurrencyTypes();
                return await coinTypes.fold(
                    (failure) => AsyncValue.error(
                        failure is ApiBadRequestFailure ? failure.detail : "",
                        StackTrace.empty), (coinTypes) async {
                  // Date exchanges
                  final dateExchanges = await _currencyConversionRepository
                      .getLastDateCurrencyConversion(days: 20);
                  return await dateExchanges.fold(
                      (failure) => AsyncValue.error(
                          failure is ApiBadRequestFailure ? failure.detail : "",
                          StackTrace.empty), (dateExchanges) async {
                    return AsyncValue.data(StatisticsData(
                      revenues: revenues,
                      revenueYears: revenueYears,
                      expenses: expenses,
                      expenseYears: expenseYears,
                      monthlyBalances: monthlyBalances,
                      annualBalances: annualBalances,
                      currencyTypes: coinTypes,
                      dateCurrencyConversion: dateExchanges,
                    ));
                  });
                });
              });
            });
          });
        });
      });
    });
  }
}
